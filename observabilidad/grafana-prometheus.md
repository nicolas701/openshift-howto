# Grafana & Prometheus como operador y datasource con auth based en http header & grafana secret.

Documentacion con base en el caso [Jira].  
Procedimiento realizado en la siguiente llamada con Sebastian Mascolo, Ruben Macchi y Martin Garyulo [Video]  
Fuente https://faun.pub/openshift-leveraging-prometheus-cluster-metrics-in-your-own-grafana-7077fb0725ab

#### Necesidad del cliente
Cliente expresa necesidad de tener en ambiente No-prod, inicialmente, una implementacion de metricas que le permita medir el real consumo de sus pod y asi establecer limites de utilizacion para cada caso estableciendo rangos de uso por encima del scope detectado.

#### Implementacion tecnica
Se levanta laboratorio para implementar OCP con los operadores de Grafana y Prometheus, conectando como datasource el operador interno de Prometheus mediante una service account que ingresa mediante un http header protocol y un secret hasheado en SHA de Grafana.

#### Procedimiento
##### **Pre-requisitos**
- OCP desplegado ya sea en infra cliente o bien en un laboratorio de OpenTLC
- Acceso al mismo como administrador.
- Crear un namespace con nombre "observabilidad". (para crear namespace Home -> Projects -> click en botón azul Create Project)

##### **Pasos a seguir**
1) Instalar operador Grafana by Red Hat. (operators -> OperatorHub -> buscar operador y luego click install).
2) Instalar operador Prometheus Operator.
3) Crear instancia de Grafana con base en el manifiesto provisto en el presente repositorio con el nombre *grafana-instance.yml* (operators -> installed operators -> y dentro del operador en la solapa "all instances" crear una nueva instancia).
4) Dentro del bastion ejecutar
Hasta OCP 4.10 
    ```sh
    oc create serviceaccount grafana -n observabilidad
    oc create clusterrolebinding grafana-cluster-monitoring-view  --clusterrole=cluster-monitoring-view  --serviceaccount=observabilidad:grafana  
    oc sa get-token grafana -n observabilidad
    ```
 

Esto nos devolvera un token encriptado en SHA que deberemos poner en el archivo *grafana-datasource-with-service-account.yml*
en la linea de referencia aproximada 55
```yml
      secureJsonData:
        httpHeaderValue1: ""Bearer your_grafana_token"
```
> Nota: Para OCP 4.11
Ir a la consola, a sa, y buscar el secreto grafana, y dentro del secreto ver el grafana-token-xxxx y dentro de ese token copiar el token. 

5) Crear datasource de Grafana con base en el manifiesto provisto en el presente repositorio con el nombre *grafana-datasource-with-service-account.yml* (operators -> installed operators -> y luego click en "grafana data source"  para crear una nueva fuente de datos).
6) Crear instancia de Prometheus con base en el manifiesto provisto en el presente repositorio con el nombre *prometheus-instance.yml* (operators -> installed operators -> y dentro del operador en la solapa "all instances" crear una nueva instancia).

> Nota: Ya se peude ingrasar a Grafana y empezar a importar dashboards. La ruta se peude encontrar en Networking -> Routes dentro del namespace observabildiad.

> Nota: Las credenciales por defecto para ingresar a Grafana son root/secret.

##### Opcional
7) Crear Grafana dashboard cpu-per-deployment con el  manifiesto adjunto en el presente repositorio con el nombre grafanadashboard-cpu-per-deployment.yml y hacer lo mismo con el manifiesto grafanadashboard-memory-per-deployment.yml.
8) En caso de querer crear manualmente en Grafana los dashboards importar los archivos json adjuntos en .../dashboards.

#### Descripcion de archivos.
| File | Descripcion |
| ------ | ------ |
| grafana-instance.yml | Genera una instancia dentro del operador de Grafana|
| grafana-datasource-with-service-account.yml | Crea una fuente de datos (datasource) con acceso via http bearer protocol |
| prometeus-instance.yml | Crea una instancia dentro del operador de Prometheus |

[//]: # (Links)
   [Jira]: <https://sales-vision.atlassian.net/browse/ING-96>
   [Video]: <https://drive.google.com/file/d/1ryx9yr29Q0i3YT4vpnOOcCnAAzz3XHny/view?usp=sharing>
