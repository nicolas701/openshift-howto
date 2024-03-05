# Alpine pod with Python shceduling

Pod con script de Python que ejecuta tareas programadas con la librería schedule de Python.

## Dockerfile

```Dockerfile
# Utiliza la imagen oficial de Python
FROM python:3.9-alpine

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app
RUN chmod 777 /app

# Instala la biblioteca "schedule" usando pip
RUN pip install schedule requests

# Ejecuta el script Python periódicamente

# Copia el script Python y los archivos necesarios
COPY main-test.py .
CMD ["python", "-u", "main-test.py"]
```

## Python code

```py
import schedule
import requests
import time
import sys

from datetime import datetime

# Abre un archivo para escribir
archivo_salida = open('/app/logs/salida.txt', 'w')


def mi_get(resumen, url):
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")


    try:
        response = requests.get(url)
        response.raise_for_status()  # Genera una excepción si la solicitud no fue exitosa
        archivo_salida.write(f"{resumen}: {current_time} - {response.status_code}\n")
    except requests.exceptions.RequestException as e:
        archivo_salida.write(f"Error\n")
    except Exception as e:
        archivo_salida.write(f"Error\n")
    finally:
        archivo_salida.flush()



def mi_post(resumen, url):
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Redirige stdout al archivo

    headers = {
        "Authorization": "Basic ZnVzZS5kZXY6ZnVzZTAxRGV2Lg=="
    }

    try:
        response = requests.post(url, headers=headers)
        response.raise_for_status()  # Genera una excepción si la solicitud no fue exitosa
        archivo_salida.write(f"{resumen}: {current_time} - {response.status_code}\n")
        archivo_salida.flush()
    except requests.exceptions.RequestException as e:
        archivo_salida.write(f"Error\n")
    except Exception as e:
        archivo_salida.write(f"Error\n")
    finally:
        archivo_salida.flush()


# Crones de FMS

# Programa tarea NOTIFICATION cada 30 segundos
schedule.every(30).seconds.do(mi_post, resumen="NOTIFICATION", url="http://decision-manager-dev-01-fms-faultmanager-dev.apps.ocp4-rh.cloudteco.com.ar/fms-rules-web/api/rest/event/report")

# Programa tarea EXECUTION cada 30 segundos
schedule.every(30).seconds.do(mi_post, resumen="EXECUTION", url="http://decision-manager-dev-01-fms-faultmanager-dev.apps.ocp4-rh.cloudteco.com.ar/fms-rules-web/api/rest/event/execute")

# Programa tarea DAMAGE cada 1 minuto
schedule.every(1).minutes.do(mi_get, resumen="DAMAGE" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/damage")

# Programa tarea MASKER cada 1 minutos
schedule.every(1).minutes.do(mi_get, resumen="MASKER" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/masker")

# Programa tarea SUMMARY cada 5 minutos
schedule.every(15).minutes.do(mi_get, resumen="AFFECTATION SUMMARY" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/alarm/affectationSummary")
schedule.every(5).minutes.do(mi_get, resumen="EVENT BRMS SUMMARY" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/eventBRMSSummary")
schedule.every(5).minutes.do(mi_get, resumen="GRAPH SUMMARY" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/graphSummary")
schedule.every(5).minutes.do(mi_get, resumen="SUMMARY" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/alarm/summary")

# Programa tarea PRIORITY cada 5 minutos
schedule.every(5).minutes.do(mi_get, resumen="PRIORITY" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/priority")

# Programa tarea THRESHOLD MOBILE SITES cada dia 00:00
schedule.every(24).hours.do(mi_get, resumen="THRESHOLD MOBILE SITES" ,url="http://sr-fms-ad01.corp.cablevision.com.ar:9080/api/rest/process/thresholdMobileSites")


while True:
    schedule.run_pending()
    time.sleep(1)

##############################################################################

## Si quiero ejecutar más de una tarea o script py

#import schedule
#import time
#from subprocess import run

#def ejecutar_script(script_name):
#    print(f"Ejecutando {script_name}")
#    run(["python", script_name])

# Programa una tarea para ejecutar mi_script.py cada 5 minutos
#schedule.every(5).minutes.do(ejecutar_script, script_name="mi_script.py")

# Programa una tarea para ejecutar otro_script.py cada 10 minutos
#schedule.every(10).minutes.do(ejecutar_script, script_name="otro_script.py")

#while True:
#    schedule.run_pending()
#    time.sleep(1)
```


```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: pod-vm
  namespace: fms-faultmanager-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pod-vm
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: pod-vm
    spec:
      volumes:
        - name: pod-vm-pvc
          persistentVolumeClaim:
            claimName: pod-vm-pvc
      containers:
        - resources: {}
          terminationMessagePath: /dev/termination-log
          name: pod-vm
          imagePullPolicy: Always
          volumeMounts:
            - name: pod-vm-pvc
              mountPath: /app/logs
          terminationMessagePolicy: File
          image: >-
            image-registry.openshift-image-registry.svc:5000/fms-faultmanager-test/pod-vm

          workingDir: /app
```