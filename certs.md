# Actualizaciónd e certificados


## Atachar varias CA

https://access.redhat.com/solutions/6960291

## Certifcados por vencer

https://access.redhat.com/solutions/3930291


## Ingress certificate

https://access.redhat.com/solutions/6458661



## CA, CA intermedia, Certificado

Con esto haces una ca, ca intermedia, certificado:
```sh
chmod a+x script.sh
./script.sh
```

```sh
#!/bin/bash

echo "Genero la Root CA"
echo ""
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA" -out ca.crt

echo "Genero la Intermedia CA"
echo ""

openssl req -newkey rsa:2048 -nodes -keyout int.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Intermedia CA" -out int.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:*.apps.cluster-f8fc9.f8fc9.sandbox1380.opentlc.com\nbasicConstraints=CA:true") -days 365 -in int.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out int.crt
openssl verify -CAfile ca.crt int.crt

echo "Genero el certificado firmado final"
echo ""
openssl req -newkey rsa:2048 -nodes -keyout final.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Final CA" -out final.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:*.apps.cluster-f8fc9.f8fc9.sandbox1380.opentlc.com") -days 365 -in final.csr -CA int.crt -CAkey int.key -CAcreateserial -out final.crt
cat int.crt ca.crt > chain.crt
openssl verify -CAfile chain.crt final.crt
```



### 1. Agregamos la CA

https://docs.openshift.com/container-platform/4.9/security/certificates/updating-ca-bundle.html

#### Importante:

> Esta CA se usa para que cuando un pod se conecta a una url interna o externa con un certificado custom por https no de error.
> El certificado del ingress se inyecta en todas las rutas apps, osea cualquier pod con ruta expone ese certificado, es por eso que los pods
de authenticacion cuando se quieren conectar contra el oauth, si no tiene el certificado da error.

> Esto hasta la version 4.13 reinicia nodos para cambio de certificados y pull-secret

```sh
cat BHROOTCNG.crt  BHIssuingCNG.crt > BHROOTCHAIN.crt
oc create configmap user-ca-bundle --from-file=ca-bundle.crt=BHROOTCHAIN.crt -n openshift-config
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"user-ca-bundle"}}}'
oc get pods -n openshift-authentication
```

### 2. Agregamo el certificado de Wildard mgnt:
```sh
oc create secret tls wildcard-mnt-ingress-bh-tls --cert=wildcard.mgmt.ocp-np.bh.com.ar.crt --key=wildcard.mgmt.ocp-np.bh.com.ar.key -n openshift-ingress
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "wildcard-mnt-ingress-bh-tls"}}}' -n openshift-ingress-operator
ingresscontroller.operator.openshift.io/default patched
```

### 3. Agregamo el certificado de Wildcard apps:
```sh
oc create secret tls wildcard-apps-ingress-bh-tls --cert=wildcard.apps.ocp-np.bh.com.ar.crt --key=wildcard.apps.ocp-np.bh.com.ar.key -n openshift-ingress
oc patch ingresscontroller.operator apps --type=merge -p '{"spec":{"defaultCertificate": {"name": "tls wildcard-apps-ingress-bh-tls"}}}' -n openshift-ingress-operator
ingresscontroller.operator.openshift.io/apps patched
```

### 4. Agregamo el certificado de Api:
```sh
oc create secret tls api-secret-ocp-prod--cert=api.ocp-np.bh.com.ar.crt  --key=api.ocp-np.bh.com.ar.key  -n openshift-config
oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates": [{"names": ["api.ocp-np.bh.com.ar"], "servingCertificate": {"name": "api-secret-ocp-prod"}}]}}}'
```

### 5. Probamos
```sh
oc get co; da todo ok

curl https://console-openshift-console.apps.cluster-f8fc9.f8fc9.sandbox1380.opentlc.com/k8s/cluster/config.openshift.io~v1~ClusterOperator/kube-apiserver --cacert chain.crt
<!DOCTYPE html>
<html lang="en" class="no-js">

  <head>
    <base href="/">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    
      
      
      
      <title>Red Hat OpenShift</title>
      <meta name="application-name" content="Red Hat OpenShift">

```