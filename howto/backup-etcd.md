# etcd-backup



## Descripción
Script para realizar backup de la base de datos ETCD de OCP.

Para programar dicho script ejecutar lo siguiente:
```sh
[root@bastion OCP-NOPROD ~]# crontab -l
```
```sh
00 00 * * * sh -x /root/etcd-backup/etcd-backup-v4.5.sh > /root/
```
```sh
etcd-backup/log/backup.log
```

## Script

```bash
#!/bin/bash
set -e
export CLUSTER=prod
export DATE=$(date +'%Y%m%d.%H%M%S-%3N')
export BACKUPDIR=~/prod/backup/etcd/$CLUSTER/backup-$DATE
export SSH_KEY=~/prod/ocp4_prod.priv
export PATH=$PATH:/usr/local/bin/
export KUBECONFIG=/root/prod/auth/kubeconfig
mkdir -p $BACKUPDIR
for master in $(oc get nodes -l node-role.kubernetes.io/master | awk '/master/ {print $1}');
do
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "- Backup de base de datos ETCD - $(date)"
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "Node backup: $master"
  mkdir -p $BACKUPDIR/$master
  SSH="ssh -i $SSH_KEY core@$master"
  $SSH 'sudo -E rm /home/core/assets/backup/*'
  $SSH 'sudo -E /usr/local/bin/cluster-backup.sh /home/core/assets/backup'
  $SSH 'sudo -E chmod -R 644 /home/core/assets/backup/*'
  scp -r -i $SSH_KEY core@$master:/home/core/assets/backup/* $BACKUPDIR/$master/
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  break
  # correrlo una sola vez
done
cd ~/gire/prod/backup/etcd/$CLUSTER/
find .  -mtime +30 -type d  |xargs -d '\n' rm -rf
```

# Pasos backup y restore etcd

## BACKUP
```sh
# Me conecto a mi bastion
ssh bastion

# Salto a un nodo master
oc get nodes
oc debug node/ip-10-0-210-91.us-east-2.compute.internal

#Cambio de contexto
chroot /host

# Hago el backup
/usr/local/bin/cluster-backup.sh /home/core/assets/backup

# Comprimo la carpeta
tar -czf /home/core/assets/backup.tar.gz /home/core/assets/backup/

# Copio el backup al bastion
oc cp ip-10-0-210-91us-east-2computeinternal-debug:/host/home/core/assets/backup.tar.gz backup.tar.gz
```

## RESTORE
https://docs.openshift.com/container-platform/4.8/backup_and_restore/control_plane_backup_and_restore/disaster_recovery/scenario-2-restoring-cluster-state.html

Tambien lo probe desde adentro del debugnode y funciono el restore  
```sh
ssh node -l core
sudo -E /usr/local/bin/cluster-restore.sh /home/core/backup
```


## Con crontab

Se crea una SA con el rol para listar nodos y se verifica en ambos sitios que corra ok.
1. Crear la cuenta SA
```sh
apiVersion: v1
kind: ServiceAccount
metadata:
  name: crontab
  namespace: default
```

2. Asignar el rol
```sh
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: crontab-rb
subjects:
  - kind: ServiceAccount
    name: crontab
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: 'system:node-reader'
```
3. Buscar el token

Ir a User Managments → ServiceAcounts,  Buscar la SA y buscar el token similar crontab-token-dfsv2  y copiar el $token y pegarlo en el script de backup linea 10

4. Script a poner en crontab

```sh
#!/bin/bash
set -e
export CLUSTER=prod
export DATE=$(date +'%Y%m%d.%H%M%S-%3N')
export BACKUPDIR=~/prod/backup/etcd/$CLUSTER/backup-$DATE
export SSH_KEY=~/prod/ocp4_prod.priv
export PATH=$PATH:/usr/local/bin/
export KUBECONFIG=/root/prod/auth/kubeconfig
mkdir -p $BACKUPDIR
oc login --token=$token --server=https://api.ocp:6443 --insecure-skip-tls-verify=true

for master in $(oc get nodes -l node-role.kubernetes.io/master | awk '/master/ {print $1}');
do
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "- Backup de base de datos ETCD - $(date)"
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "Node backup: $master"
  mkdir -p $BACKUPDIR/$master
  SSH="ssh -i $SSH_KEY core@$master"
  $SSH 'sudo -E rm /home/core/assets/backup/*'
  $SSH 'sudo -E /usr/local/bin/cluster-backup.sh /home/core/assets/backup'
  $SSH 'sudo -E chmod -R 644 /home/core/assets/backup/*'
  scp -r -i $SSH_KEY core@$master:/home/core/assets/backup/* $BACKUPDIR/$master/
  echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  break
  # correrlo una sola vez
done
cd ~/gire/prod/backup/etcd/$CLUSTER/
find .  -mtime +30 -type d  |xargs -d '\n' rm -rf
```
