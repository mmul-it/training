# Demonstration | OpenShift: create a scalable MySQL template

Create a new project called mysql-template:

```console
$ oc new-project mysql-template
Now using project "mysql-template" on server "https://192.168.64.6:8443".
```

Create a `mysql.template.yaml` file with these contents:

```yaml
apiVersion: v1
objects:
- apiVersion: image.openshift.io/v1
  generation: 0
  image:
    dockerImageLayers: null
    dockerImageMetadata:
      ContainerConfig: {}
      Created: null
      Id: ""
      apiVersion: "1.0"
      kind: DockerImage
    dockerImageMetadataVersion: "1.0"
    metadata:
      creationTimestamp: null
  kind: ImageStreamTag
  lookupPolicy:
    local: false
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
      openshift.io/imported-from: 172.30.1.1:5000/openshift/mysql:5.7
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-${INSTANCE_NAME}:5.7
  tag:
    annotations: null
    from:
      kind: DockerImage
      name: 172.30.1.1:5000/openshift/mysql:5.7
    generation: null
    importPolicy: {}
    name: "5.7"
    referencePolicy:
      type: ""
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-master-${INSTANCE_NAME}
  spec:
    replicas: 1
    selector:
      app: mysql-master-slave-${INSTANCE_NAME}
      deploymentconfig: mysql-master-${INSTANCE_NAME}
    strategy:
      resources: {}
    template:
      metadata:
        annotations:
          openshift.io/generated-by: OpenShiftNewApp
        creationTimestamp: null
        labels:
          app: mysql-master-slave-${INSTANCE_NAME}
          deploymentconfig: mysql-master-${INSTANCE_NAME}
      spec:
        containers:
        - env:
          - name: MYSQL_DATABASE
            value: ${MYSQL_DATABASE}
          - name: MYSQL_MASTER_PASSWORD
            value: ${MYSQL_MASTER_PASSWORD}
          - name: MYSQL_MASTER_SERVICE_NAME
            value: mysql-master-${INSTANCE_NAME}
          - name: MYSQL_MASTER_USER
            value: ${MYSQL_MASTER_USER}
          - name: MYSQL_PASSWORD
            value: ${MYSQL_PASSWORD}
          - name: MYSQL_ROOT_PASSWORD
            value: ${MYSQL_ROOT_PASSWORD}
          - name: MYSQL_USER
            value: ${MYSQL_USER}
          image: 172.30.1.1:5000/openshift/mysql:5.7
          name: mysql-master-${INSTANCE_NAME}
          command:
            - "run-mysqld-master"
          ports:
          - containerPort: 3306
            protocol: TCP
          resources: {}
    test: false
    triggers:
    - type: ConfigChange
    - imageChangeParams:
        automatic: true
        containerNames:
        - mysql-master-${INSTANCE_NAME}
        from:
          kind: ImageStreamTag
          name: mysql:5.7
          namespace: openshift
      type: ImageChange
  status:
    availableReplicas: 0
    latestVersion: 0
    observedGeneration: 0
    replicas: 0
    unavailableReplicas: 0
    updatedReplicas: 0
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-slave-${INSTANCE_NAME}
  spec:
    replicas: 1
    selector:
      app: mysql-master-slave-${INSTANCE_NAME}
      deploymentconfig: mysql-slave-${INSTANCE_NAME}
    strategy:
      resources: {}
    template:
      metadata:
        annotations:
          openshift.io/generated-by: OpenShiftNewApp
        creationTimestamp: null
        labels:
          app: mysql-master-slave-${INSTANCE_NAME}
          deploymentconfig: mysql-slave-${INSTANCE_NAME}
      spec:
        containers:
        - env:
          - name: MYSQL_DATABASE
            value: ${MYSQL_DATABASE}
          - name: MYSQL_MASTER_PASSWORD
            value: ${MYSQL_MASTER_PASSWORD}
          - name: MYSQL_MASTER_SERVICE_NAME
            value: mysql-master-${INSTANCE_NAME}
          - name: MYSQL_MASTER_USER
            value: ${MYSQL_MASTER_USER}
          - name: MYSQL_PASSWORD
            value: ${MYSQL_PASSWORD}
          - name: MYSQL_ROOT_PASSWORD
            value: ${MYSQL_ROOT_PASSWORD}
          - name: MYSQL_USER
            value: ${MYSQL_USER}
          image: 172.30.1.1:5000/openshift/mysql:5.7
          name: mysql-slave-${INSTANCE_NAME}
          command:
            - "run-mysqld-slave"
          ports:
          - containerPort: 3306
            protocol: TCP
          resources: {}
    test: false
    triggers:
    - type: ConfigChange
    - imageChangeParams:
        automatic: true
        containerNames:
        - mysql-slave-${INSTANCE_NAME}
        from:
          kind: ImageStreamTag
          name: mysql:5.7
          namespace: openshift
      type: ImageChange
  status:
    availableReplicas: 0
    latestVersion: 0
    observedGeneration: 0
    replicas: 0
    unavailableReplicas: 0
    updatedReplicas: 0
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-master-${INSTANCE_NAME}
  spec:
    ports:
    - name: 3306-tcp
      port: 3306
      protocol: TCP
      targetPort: 3306
    selector:
      app: mysql-master-slave-${INSTANCE_NAME}
      deploymentconfig: mysql-master-${INSTANCE_NAME}
  status:
    loadBalancer: {}
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-master-lb-${INSTANCE_NAME}
  spec:
    type: LoadBalancer
    ports:
    - name: db
      port: 3306
    loadBalancerIP:
    selector:
      app: mysql-master-slave-${INSTANCE_NAME}
      deploymentconfig: mysql-master-${INSTANCE_NAME}
  status:
    loadBalancer: {}
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      openshift.io/generated-by: OpenShiftNewApp
    creationTimestamp: null
    labels:
      app: mysql-master-slave-${INSTANCE_NAME}
    name: mysql-slave-lb-${INSTANCE_NAME}
  spec:
    type: LoadBalancer
    ports:
    - name: db
      port: 3306
    loadBalancerIP:
    selector:
      app: mysql-master-slave-${INSTANCE_NAME}
      deploymentconfig: mysql-slave-${INSTANCE_NAME}
  status:
    loadBalancer: {}
kind: Template
metadata:
  name: mysql-master-slave
  annotations:
    description: A MySQL Master/Slave deployment
parameters:
- name: INSTANCE_NAME
  description: The MySQL Master/Slave instance name
  required: true
- name: MYSQL_ROOT_PASSWORD
  description: The MySQL root password
  required: true
- name: MYSQL_DATABASE
  description: The MySQL database available from each instance
  value: mysqlmaster
- name: MYSQL_MASTER_PASSWORD
  description: The MySQL master user password
  value: password
- name: MYSQL_MASTER_USER
  description: The MySQL master user name
  value: master
- name: MYSQL_PASSWORD
  description: The MySQL user password
  value: password
- name: MYSQL_USER
  description: The MySQL user name
  value: user
```

You can see different parts in the yaml file:

- An `ImageStreamTag`: this will provides a basic container images based
  on the `mysql:5.7` OpenShift embedded image.
- Two `DeploymentConfig`:
  - The first named `mysql-master-${INSTANCE_NAME}` provides one replica
    of a `Pod` based on `mysql:5.7` image with the same name of the
    `DeploymentConfig`. On this one some environment variables will be passed
    and the command `run-mysqld-master` will be executed.
  - The second named `mysql-slave-${INSTANCE_NAME}` provides one replica of a
    `Pod` based on the same image with the same name of the `DeploymentConfig`.
    On this one the same environment variables will be passed and the command
    `run-mysqld-slave` will be executed.
- A `Service` named `mysql-master-${INSTANCE_NAME}` which provides balancing
  on pods deployed by the `mysql-master-${INSTANCE_NAME}` `DeploymentConfig`.
  This service will not be exposed outside, but will be available to every `Pod`
  into the cluster pointing to `mysql-master-${INSTANCE_NAME}` on port `3306`.
- A `Service` named `mysql-master-lb-${INSTANCE_NAME}` that will provide access
  from outside the cluster to every pods spawned by the
  mysql-master-${INSTANCE_NAME}`, and it's reachable on random port (choosed
  by OpenShift during service object creation) from every IP of the cluster
  nodes.
- A `Service` named `mysql-slave-lb-${INSTANCE_NAME}` provides access from
  outside the cluster to every pods spawned by the
  `mysql-slave-${INSTANCE_NAME}`, and it's reachable on random port (choosed by
  OpenShift during service object creation) from every IP of the cluster nodes.
- Parameters, two of them required: `INSTANCE_NAME` and `MYSQL_ROOT_PASSWORD`.

Create the new template object by executing:

```console
$ oc create -f mysql.template.yaml
template.template.openshift.io/mysql-master-slave created
```

And explore the details:

```console
$ oc get templates
NAME                 DESCRIPTION                       PARAMETERS    OBJECTS
mysql-master-slave   A MySQL Master/Slave deployment   7 (2 blank)   6

$ oc describe template mysql-master-slave
Name:           mysql-master-slave
Namespace:      mysql-template
Created:        57 seconds ago
Labels:         <none>
Description:    A MySQL Master/Slave deployment
Annotations:    <none>

Parameters:
    Name:               INSTANCE_NAME
    Description:        The MySQL Master/Slave instance name
    Required:           true
    Value:              <none>

    Name:               MYSQL_ROOT_PASSWORD
    Description:        The MySQL root password
    Required:           true
    Value:              <none>

    Name:               MYSQL_DATABASE
    Description:        The MySQL database available from each instance
    Required:           false
    Value:              mysqlmaster

    Name:               MYSQL_MASTER_PASSWORD
    Description:        The MySQL master user password
    Required:           false
    Value:              password

    Name:               MYSQL_MASTER_USER
    Description:        The MySQL master user name
    Required:           false
    Value:              master

    Name:               MYSQL_PASSWORD
    Description:        The MySQL user password
    Required:           false
    Value:              password

    Name:               MYSQL_USER
    Description:        The MySQL user name
    Required:           false
    Value:              user


Object Labels:  <none>

Message:        <none>

Objects:
    ImageStreamTag.image.openshift.io   mysql-${INSTANCE_NAME}:5.7
    DeploymentConfig.apps.openshift.io  mysql-master-${INSTANCE_NAME}
    DeploymentConfig.apps.openshift.io  mysql-slave-${INSTANCE_NAME}
    Service                             mysql-master-${INSTANCE_NAME}
    Service                             mysql-master-lb-${INSTANCE_NAME}
    Service                             mysql-slave-lb-${INSTANCE_NAME}
```

 Deploy a new app called mynewdb. Remeber, you've to pass the `INSTANCE_NAME`
and `MYSQL_ROOT_PASSWORD` parameters:

```console
$ oc new-app -p INSTANCE_NAME=mynewdb -p MYSQL_ROOT_PASSWORD=password mysql-master-slave
--> Deploying template "mysql-template/mysql-master-slave" to project mysql-template
...

$ oc status
...
svc/mysql-master-mynewdb - 172.30.30.173:3306
svc/mysql-master-lb-mynewdb - 172.30.139.51:3306
  dc/mysql-master-mynewdb deploys openshift/mysql:5.7
    deployment #1 deployed 12 seconds ago - 1 pod

svc/mysql-slave-lb-mynewdb - 172.30.131.154:3306
  dc/mysql-slave-mynewdb deploys openshift/mysql:5.7
    deployment #1 deployed 12 seconds ago - 1 pod
...
```

Check which ports are available for connection outside the cluster:

```console
$ oc get svc | grep LoadBalancer
mysql-master-lb-mynewdb   LoadBalancer   172.30.139.51    172.29.202.215,172.29.202.215   3306:31382/TCP   57s
mysql-slave-lb-mynewdb    LoadBalancer   172.30.131.154   172.29.166.19,172.29.166.19     3306:31001/TCP   57s
```

You can now reach your database for writing pointing at `$(minishift ip):31382`
port and for reading pointing to $(minishift ip):31001 port. If you need you
can already scale your `mysql-slave-mynewdb` `DeploymentConfig` as desidered:

```console
$ oc scale --replicas=3 dc mysql-slave-mynewdb
deploymentconfig.apps.openshift.io/mysql-slave-mynewdb scaled

$ oc status
...
svc/mysql-slave-lb-mynewdb - 172.30.131.154:3306
  dc/mysql-slave-mynewdb deploys openshift/mysql:5.7
    deployment #1 deployed 3 minutes ago - 3 pods
...
```

You have a quickly replicable MySQL master/slave configuration inside OpenShift.
