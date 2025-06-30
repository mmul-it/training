# Demonstration | OpenShift: understand out-of-the-box authentication

By default the only user configured inside fresh new OpenShift installation is
just kubeadmin:

```console
$ oc get secret -A | grep kubeadmin
kube-system               kubeadmin                 Opaque           1      39d
```

Which can be viewed as a yaml:

```console
$ oc --namespace kube-system get secret kubeadmin -o yaml
apiVersion: v1
data:
  kubeadmin: JDJhJDEwJC52bE03SU16VmNhWG4zREdFaUpQMi4zbi5tajZsbHV1QjFhMWN4R2h3eVYzbGtsMGZTMVg2
kind: Secret
metadata:
...
...
```

The password is base64 formatted, to decode it you can use the `base64` command:

```console
$ echo JDJhJDEwJC52bE03SU16VmNhWG4zREdFaUpQMi4zbi5tajZsbHV1QjFhMWN4R2h3eVYzbGtsMGZTMVg2 | base64 --decode
$2a$10$.vlM7IMzVcaXn3DGEiJP2.3n.mj6lluuB1a1cxGhwyV3lkl0fS1X6
```

As you can see, this is an hash, so you can't get to know the password from
here.
The OCP 4.7 installer leaves a file named kubeadmin-password in the install
directory:

```console
$ ls -1 /var/www/html/openshift-install-dir/auth
kubeadmin-password
kubeconfig
```

So there are two choices for logging into an existing cluster:

1. Via password:

   ``` console
   $ oc login https://api.ocp.kiratech.local:6443 --insecure-skip-tls-verify=true -u kubeadmin -p IJhIR-Je7bW-H63Hi-Zo2LZ
   Login successful.

   You have access to 62 projects, the list has been suppressed. You can list all projects with 'oc projects'

   Using project "default".

   $ oc status
   In project default on server https://api.ocp.kiratech.local:6443

   svc/openshift - kubernetes.default.svc.cluster.local
   svc/kubernetes - 172.30.0.1:443 -> 6443

   View details with 'oc describe <resource>/<name>' or list resources with 'oc get all'.

   $ oc logout
   Logged "kube:admin" out on "https://api.ocp.kiratech.local:6443"
   ```

2. Via kubeconfig:

   ```console
   $ export KUBECONFIG=/var/www/html/openshift-install-dir/auth/kubeconfig

   $ oc status
   In project default on server https://api.ocp.kiratech.local:6443

   svc/openshift - kubernetes.default.svc.cluster.local
   svc/kubernetes - 172.30.0.1:443 -> 6443

   View details with 'oc describe <resource>/<name>' or list resources with 'oc get all'.

   $ oc logout
   error: You must have a token in order to logout.

   $ unset KUBECONFIG

   $ oc status
   error: you do not have rights to view project "default" specified in your config or the project doesn't exist
   ```

Using kubeconfig there's no need to logout, because there's no token.
Authentication is made contextually via certificates.

**IMPORTANT!** kubeadmin secret is vital to log into the cluster. If you remove
it **before** you configure another user with cluster admin privileges, then
the only way you can administer your cluster is using the kubeconfig file.
So you need to keep this file in a safe location, otherwise you will not be
able to recover administrative access to your cluster.
You'll need to destroy and recreate your cluster.
