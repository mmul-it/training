# Lab | Fix broken YAMLs

In this lab you will show three YAML files related to Kubernetes resources with
problems. Try to find out where the problem is before looking at the solution.

## Faulty YAML 1

Detect the problem in this `Deployment` declaration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: faulty-deployment
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
      ports:
      - containerPort: 80
```

### Faulty YAML 1 - Solution

The issue is: **Incorrect Indentation**.

The ports section is not properly indented within the containers section.

The correct YAML file is:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: corrected-deployment
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80

```

## Faulty YAML 2

Detect the problem in this `Service` declaration:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: faulty-service
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
```

### Faulty YAML 2 - Solution

The issue is: **Missing Selector**.

The Service definition lacks the `selector` field, which specifies the pods it
should target.

The correct YAML file is:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: corrected-service
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
```

## Faulty YAML 3

Detect the problem in this `Pod` declaration:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: faulty-pod
  labels:
    app: webapp
spec:
  containers:
  - name: nginx:latest
```

### Faulty YAML 3 - Solution

The issue is: **Missing image declaration for the container**.

The `containers` section includes a list of containers that must contain also
the `image:` field to correctly pull it and start the pod.

The correct YAML file is:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: corrected-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
```
