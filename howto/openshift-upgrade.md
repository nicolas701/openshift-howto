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


# Con script automatizado

```sh
#!/bin/bash
SALIDA=cluster-pre.txt
choose=$1
all=0
if [ $# -ne 1 ]; then
  echo "Uso: $0 -h"
  echo "|------------------------------------------------------------|"
  echo "| Valores:"
  echo "|        -a all include backup yaml"
  echo "|        -s all sin backup yaml"
  echo "|        -l solo limpio pods terminating/failed"  
  echo "|        -h help"
  echo "|------------------------------------------------------------|"
  exit 1
fi
if [ "$choose" = "-a" ]; then
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                  BACKUP ALL YAML                           |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  # # Get all project names
  # projects=$(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
  # ## projects=$(oc get projects | grep -v 'openshift\|kube' | awk '{print $1}')
  # # Iterate projects
  # for project in $projects; do
  #   # Create directory for this project
  #   output_dir="/output/${project}"
  #   mkdir -p "$output_dir"
  #   # Switch to project
  #   oc project "$project"
  #   oc get project "$project" -o yaml > "$output_dir/project.yaml"
  #   # Export all objects to YAML
  #   oc get -o yaml all > "$output_dir/resources.yaml"
  # done
fi
if [ "$choose" = "-a" ] || [ "$choose" = "-s" ]; then
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                  CLUSTER VERSION                           |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get clusterversion >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                  APIS DEPRECADAS                           |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  version=$(oc get clusterversion | awk 'NR>1 {split ($2,a,"."); print "1."a[2]+14}')
  oc get apirequestcounts | grep $version >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                  CLUSTER OPERATORS                         |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get co >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                  PODS TOTAL                                |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get pods -A -o wide >>$SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 PODS FAILED                                |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get pod -A -o wide | grep Failed  >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 PODS TERMINATING                           |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get pod -A | grep Terminating >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 CERTIFICATES                               |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get csr >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 MCP STATUS                                 |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc get mcp >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 TOP NODES                                  |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  oc adm top nodes >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
  echo "|                 Fin.                                       |" >> $SALIDA
  echo "|------------------------------------------------------------|" >> $SALIDA
fi
if [ "$choose" = "-l" ]; then
  oc get pod -A | grep Terminating | awk '{print "oc delete pod " $2 " -n " $1 " --force "}'
  oc get pod -A | grep Failed | awk '{print "oc delete pod " $2 " -n " $1 " --force "}'
fi
echo "Backup etcd: ssh to master node, execute /usr/local/bin/cluster-backup.sh /home/core/assets/backup"
echo "ToDo: Upgrade operators"
echo "ToDo: ssh nodes and top"
echo "ToDo: Apis deprecate"
echo "ToDo: Proactive case
CASE TITLE:
[PROACTIVE] Production OpenShift cluster upgrade from 3.9 to 3.10
CASE DESCRIPTION: 
In two weeks, on Saturday July 22nd,  we are planning to upgrade our production cluster from OCP X.Y.Z to OCP X2.Y2.Z2 on RHEL7.5.
These guest systems are installed on Red Hat Virtualization 4.2. All systems have 8 vCPUs and 32GB of RAM. No memory or CPU over commitment is being used.
Cluster details:
  3 MASTERS.
  3 ETCD NODES.
  3 INFRA NODES.
  20 APP NODES.
  50 PROJECTS.
  200 SERVICES.
  400 PODS.
Maintenance Window Information:
   - Date - Sunday, July 22nd
   - Time frame - 6 hours
   - Timezone - CEST
   - Start Time - 08:00 AM UTC+2
   - End Time - 14:00 PM UTC+2
Primary Contact Information:
   - Name: Jane Doe
   - Email: jane.doe@example.com
   - Phone: +1-123-456-7890
---
Attach:
oc adm must-gather
tar cvaf must-gather.tar.gz must-gather.local.5421342344627712289/ 
"
```
