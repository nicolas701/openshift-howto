# SCC - Security Context Constraints

Ejemplo de uso para ejecutar un pod en Openshift como `root`.

Test pod deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-pod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-pod
  template:
    metadata:
      labels:
        app: test-pod
    spec:
      containers:
      - name: ubuntu
        image: ubuntu
        securityContext:
          privileged: True
        resources:
          limits:
            cpu: 50m
            memory: 100Mi
          requests:
            cpu: 10m
            memory: 50Mi
        command: ["sleep", "infinity"]
```

> Nota: Aca lo improtante es el `securityContext`:
```yaml
    securityContext:
      privileged: True
```

Levantar pod.
```sh
oc apply -f test-pod-deployment.yaml
```
Crear Service Acount.
```sh
oc create sa test-pod-sa
```
Aplicar los SCC a la SA.
```sh
oc amd policy add-scc-to-user privileged -z test-pod-sa
```
Aplicar SA al deployment.
```sh
oc set sa deployment test-pod test-pod-sa
```
Verificar la regeneración del pod con `oc get pods`.
Ingresar al pod con `oc rsh NOMBRE-POD` y ejecutar comandos root, como por ejemplo `apt update`.