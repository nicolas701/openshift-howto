# Roles para listar solamente nodos

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
``````