## Pre-requisitos

# Upgrade path

https://access.redhat.com/labs/ocpupgradegraph/update_path/

### Generar caso proactivo en RedHat Support.

Para generar el must-gather con la info del cluster.

https://access.redhat.com/documentation/es-es/openshift_container_platform/4.5/html/support/gathering-cluster-data

- Generar must-gather.
```sh
oc adm must-gather
```
- Comprimir carpeta.
```sh
tar cvaf must-gather.tar.gz must-gather.local.*
```
- Ver cantidad de nodos.
```sh
oc get nodes
```
- Obtner cantidad de namespaces.
```sh
oc get projects --no-headers | wc -l
```
- Obtner cantidad de pods.
```sh
oc get pods --all-namespaces --no-headers | wc -l
```

- Subir datos al caso

### Chequear APIs removidas.
Este análisis también se hace en el caso proactivo.

https://access.redhat.com/articles/6955985

- Uso de APIs.
```sh
oc get apirequestcounts -o jsonpath='{range .items[?(@.status.removedInRelease!="")]}{.status.removedInRelease}{"\t"}{.status.requestCount}{"\t"}{.metadata.name}{"\n"}{end}'
```

- Chequeo el workload que usa una AIP en particular.
```sh
oc get apirequestcounts <API> \
  -o jsonpath='{range .status.last24h..byUser[*]}{..byVerb[*].verb}{","}{.username}{","}{.userAgent}{"\n"}{end}' \
  | sort -k 2 -t, -u | column -t -s ","
```
## Upgrade Openshfit v4.x

* Consultar listado de versiones sobre la cual podemos actualizar

```sh
oc adm upgrade
```

* Actualizar cluster a una version especifica

```sh
oc adm upgrade --to=4.3.21
```

* Actualizar el cluster a una version especifica de modo forzado

```sh
oc adm upgrade --to=4.3.21 --force
```

## Monitoreo del upgrade.

Controlar que el upgrade progrese de manera correcta

* Control de Operadores.
```sh
watch -n 2 'oc get co'
```
En caso de deseemos ver el detalle de un cluster operator

```sh
export CLUSTEROPERATOR=<cluster_operator_name>
oc describe co $CLUSTEROPERATOR
```

* Control de nodos.
```sh
watch -n 2 'oc get nodes'
```
* Control de Machine Config Pools (Cuando se empiezan a actualizar los nodos).
```sh
watch -n 2 'oc get mcp'
```
* Chequeo de certificados.
```sh
watch -n 2 'oc get csr'
```
