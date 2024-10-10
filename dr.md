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
```scr
oc get csr
oc get co
```

## 7. En los master ver como esta la infra:

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
