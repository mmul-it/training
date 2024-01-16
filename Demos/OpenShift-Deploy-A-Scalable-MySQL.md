# Demonstration | OpenShift: create a scalabe MySQL deployment

Create a new project to work with:

```console
$ oc new-project mysql-scalable
Now using project "mysql-scalable" on server "https://192.168.64.6:8443".
...
```

To have a more clear environment, you can specify environment variables on
external files, and pass that file to the `oc create` command.

Create a file with the environment variables (for master/slave configuration
you need more variables than a simple mysql app):

```console
$ cat mysql.env
MYSQL_MASTER_SERVICE_NAME=mysql-master
MYSQL_MASTER_USER=master
MYSQL_MASTER_PASSWORD=password
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_DATABASE=mysqlmaster
MYSQL_ROOT_PASSWORD=password
```

Then, you can deploy two different instances of the mysql app using those
environment variables; call the first `mysql-master`  and the second
`mysql-slave` (NOTE: the master instance name must match the
`MYSQL_MASTER_SERVICE_NAME` variable):

Master instance:

```console
$ oc new-app --env-file=mysql.env --name=mysql-master mysql:5.7
--> Found image ee80146 (7 weeks old) in image stream "openshift/mysql" under tag "5.7" for "mysql:5.7"
...
```

Slave instance:

```console
$  oc new-app --env-file=mysql.env --name=mysql-slave mysql:5.7
--> Found image ee80146 (7 weeks old) in image stream "openshift/mysql" under tag "5.7" for "mysql:5.7"
...
```

You can see the two instances up and running, with one pod each:

```console
$ oc status
...
svc/mysql-master - 172.30.191.229:3306
  dc/mysql-master deploys openshift/mysql:5.7
    deployment #1 deployed 26 seconds ago - 1 pod

svc/mysql-slave - 172.30.164.62:3306
  dc/mysql-slave deploys openshift/mysql:5.7
    deployment #1 deployed 10 seconds ago - 1 pod
...
```

Now must change the command to run inside the container for the `mysql-master`
deployment. Official OpenShift MySQL images provides a command named
`run-mysqld-master`:

```console
$ oc edit dc/mysql-master
```

Inside 'spec:template:spec:containers:' add

```yaml
command:
  - "run-mysqld-master"
```

Then save and exit:

```console
deploymentconfig.apps.openshift.io/mysql-master edited
```

```console
$ oc status
...
svc/mysql-master - 172.30.191.229:3306
  dc/mysql-master deploys openshift/mysql:5.7
    deployment #2 deployed 29 seconds ago - 1 pod
    deployment #1 deployed 6 minutes ago
...
```

You can see the new deployment was fired up and a new pod was scheduled.

It's now time to change the command to run inside the container for the
`mysql-slave` deployment. Official OpenShift MySQL images provides a command
named `run-mysqld-slave`:

```console
$ oc edit dc/mysql-slave
```

Inside `spec:template:spec:containers:` add:

```yaml
command:
  - "run-mysqld-slave"
```

Then save and exit:

```console
deploymentconfig.apps.openshift.io/mysql-slave edited
```

```console
$ oc status
...
svc/mysql-slave - 172.30.164.62:3306
  dc/mysql-slave deploys openshift/mysql:5.7
    deployment #2 deployed 51 seconds ago - 1 pod
    deployment #1 deployed 9 minutes ago
...
```

You can see if the connection with the MySQL master worked by filtering for
`Note` messages on MySQL slave log:

```console
$ oc logs dc/mysql-slave | grep Note
...
2019-04-10T12:35:46.844759Z 2 [Note] Slave SQL thread for channel '' initialized, starting replication in log 'FIRST' at position 0, relay log '/var/lib/mysql/data/mysql-relay-bin.000001' position: 4
2019-04-10T12:35:46.848338Z 1 [Note] Slave I/O thread for channel '': connected to master 'master@mysql-master:3306',replication started in log 'FIRST' at position 4
```

Now you can expose either `mysql-master` and `mysql-slave` as a `NodePort`
outside the minishift VM:

```console
$ oc expose dc mysql-master --type=LoadBalancer --name=mysql-master-lb
service/mysql-master-lb exposed

$ oc expose dc mysql-slave --type=LoadBalancer --name=mysql-slave-lb
service/mysql-slave-lb exposed
```

and obtain the ports used for each service:

```console
$ oc get svc | grep LoadBalancer
mysql-master-lb   LoadBalancer   172.30.221.190   172.29.27.6,172.29.27.6     3306:32339/TCP   54s
mysql-slave-lb    LoadBalancer   172.30.119.80    172.29.117.5,172.29.117.5   3306:31804/TCP   31s
```

Remember, you must use the mysql-master-lb port (32339) for writing and the
`mysql-slave-lb` port (31804) for reading; connect to the master, switch to
the mysqlmaster database and create a new table named `test_table`.

```console
$ mysql --user=root --password=password --host=$(minishift ip) --port=32339
...

mysql> use mysqlmaster;
Database changed

mysql> create table test_table (c CHAR(20));
Query OK, 0 rows affected (0.03 sec)

mysql> show tables;
+-----------------------+
| Tables_in_mysqlmaster |
+-----------------------+
| test_table            |
+-----------------------+
1 row in set (0.00 sec)
```

You can now connect to the slave port and check the mysqlmaster database to see
the new table is available:

```console
$ mysql --user=root --password=password --host=$(minishift ip) --port=31804
...

mysql> use mysqlmaster;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-----------------------+
| Tables_in_mysqlmaster |
+-----------------------+
| test_table            |
+-----------------------+
1 row in set (0.01 sec)

mysql> desc test_table;
+-------+----------+------+-----+---------+-------+
| Field | Type     | Null | Key | Default | Extra |
+-------+----------+------+-----+---------+-------+
| c     | char(20) | YES  |     | NULL    |       |
+-------+----------+------+-----+---------+-------+
1 row in set (0.00 sec)
```

Now you can scale you mysql-slave deployment as you want, to provide more
fire-power for your reading application:

```console
$ oc scale --replicas=3 dc/mysql-slave
deploymentconfig.apps.openshift.io/mysql-slave scaled

$ oc status
...
svc/mysql-slave-lb - 172.30.119.80:3306
svc/mysql-slave - 172.30.164.62:3306
  dc/mysql-slave deploys openshift/mysql:5.7
    deployment #2 deployed 16 minutes ago - 3 pods
    deployment #1 deployed 25 minutes ago
...
```

Remember, scaling the mysql-master deployment will not work, but you can scale
indefinetly you slave instances to parallelize reading; you can also configure
autoscaling for extend your slave number based on the cpu usage of every slave.

Now you can provide your exposed IP and port for slave service to your
application.
