# Chequeos DR Disaster recovery 
No responde la consola o la api de ocp por cli.

## Diferencias 
- openshift-apiserver (api con addons de rh, routes, dc, etc)
- openshift-kube-apiserver (kubernetes api) Con el kubeconfig me conecto 


## 1. CHECK OCP API
```sh
curl -k https://api.ocp.com:6433/healthz (no se de que es el healthz)
curl -k https://api.ocp.com:6433/readyz  (api)

curl -k https://ip-masters:6433/healthz
curl -k https://ip-masters:6433/readyz
```

## 2. Loguear con certificados excluyendo a oauth
https://access.redhat.com/solutions/4845381

En un master:
```sh
export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/localhost-recovery.kubeconfig
export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/localhost.kubeconfig
sudo kubectl get nodes --kubeconfig=$KUBECONFIG
```

## 3. Loguear sin pasar por el LB (load balancer F5)
En un bastion:

Editar el kubeconf este y ponerle la ip de cada master y volver a probar

## 4. Entrar por ssh a algun nodo
```sh
journalctl -fe --no-pager

(Ver solo logs del ultimo booteo)
journalctl --list-boots
journalctl -b -3
```

## 5. Ver logs de kubeapi
```sh
oc -n openshift-kube-apiserver logs  kube-apiserver-xxx
```
## 6. Ver certificados y CO
```sh
oc get csr
oc get co
```

### Aprobar certificados autmpaticamente
```sh
kubectl get csr --no-headers | awk '/Pending/ {print $1}' | xargs kubectl certificate approve
```
O para Openshfit.
```sh
oc get csr --no-headers | awk '/Pending/ {print $1}' | xargs oc adm certificate approve
```

## 7. En los master ver como esta la infra:

Ingresar en un nodo por ssh y ejecutar:
```sh
chroot /host
```
### Ver logs kubelet
```sh
journalctl -u kubelet --no-pager -xf
systemctl status kubelet
```

### Ver uso de cpu/ wait disco
```sh
top
df -h
```

### Ver etcd estado
```sh
podman run --volume /var/lib/etcd:/var/lib/etcd:Z quay.io/cloud-bulldozer/etcd-perf
```

Análisis de performance de discos.
https://access.redhat.com/solutions/4846891
```sh
podman run --volume /var/lib/etcd:/var/lib/etcd:Z quay.io/openshift-scale/etcd-perf
```


https://access.redhat.com/solutions/5489721


## Balancer check

```sh
curl -k -v -H "Authorization: Bearer <your-access-token>" https://<api-server>:6443/api 
```

`Authorization: Bearer <your-access-token>"` Es que sale del Copy login command.

Luego verificar fields like X-Forwarded-For, Server, or custom headers added by the load balancer or API server to identify the node.

Se puede hacer un watch para ver como cambian las ips. Con `oc get nodes -o wide | grep master` se pueden ver las ips de los masters.

Salida del curl.
```json
* About to connect() to api.ocp.prod.gire.com port 6443 (#0)
*   Trying 172.29.14.120...
* Connected to api.ocp.prod.gire.com (172.29.14.120) port 6443 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
* skipping SSL peer certificate verification
* NSS: client certificate not found (nickname not specified)
* SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
* Server certificate:
*       subject: E=LSEGURIDAD@GIRE.COM,CN=api.ocp.prod.gire.com,OU=GIRE S.A.,O=GIRE S.A.,L=C.A.B.A.,ST=C.A.B.A.,C=AR
*       start date: mar 13 13:45:23 2020 GMT
*       expire date: feb 07 15:58:09 2021 GMT
*       common name: api.ocp.prod.gire.com
*       issuer: CN=CA-01,DC=PROD,DC=gire,DC=com
> GET /api HTTP/1.1
> User-Agent: curl/7.29.0
> Host: api.ocp.prod.gire.com:6443
> Accept: */*
> Authorization: Bearer sha256~LB6KTnhk58NnuzKAMlLh-nlDiFlJJGVveZvGPiCsvco
>
< HTTP/1.1 200 OK
< Audit-Id: fd77c654-cfac-4009-9fa5-3feb77c81ce9
< Cache-Control: no-cache, private
< Content-Type: application/json
< Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
< X-Kubernetes-Pf-Flowschema-Uid: cd2e6239-827f-407b-ad21-b4f0c27690ec
< X-Kubernetes-Pf-Prioritylevel-Uid: 8253bf8b-568f-4878-9940-5c85a66c5a68
< Date: Wed, 13 Nov 2024 13:37:02 GMT
< Content-Length: 184
<
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "172.29.17.86:6443"
    }
  ]
* Connection #0 to host api.ocp.prod.gire.com left intact
```

Recordar que el balanceador debe chequear ña salida de `https://ip-masters:6433/readyz`. No solo la respuesta, si no que también que responda un OK. De dar fail el balanceador debe quitar al nodo del pool para no seguir distribuyendo el tráfico a un nodo que no esta disponible.

## 8. Problemas con operadores
Si hay algún operador que no se esta actualizando, o no se genera el intall plan para actualizarlo.

https://access.redhat.com/solutions/7003985
```sh
oc delete pods -l 'app in (catalog-operator, olm-operator)' -n openshift-operator-lifecycle-manager
```


## Chaquear pods - pvc - PV

### NS - POD - PVC -PV
```sh
oc get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,PVC:.spec.volumes[*].persistentVolumeClaim.claimName --no-headers | grep -v "<none>" | while read namespace pod pvc; do pv=$(oc get pvc $pvc -n $namespace -o jsonpath='{.spec.volumeName}'); echo "$namespace  $pod  $pvc  $pv"; done
```

### NS - POD - PVC
```sh
kubectl get pods --all-namespaces -o=json | jq -c '.items[] | {name: .metadata.name, namespace: .metadata.namespace, claimName: .spec |  select( has ("volumes") ).volumes[] | select( has ("persistentVolumeClaim") ).persistentVolumeClaim.claimName }'
```



> [!CAUTION]
> HOLA