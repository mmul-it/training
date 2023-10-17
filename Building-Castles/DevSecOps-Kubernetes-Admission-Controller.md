# Lab | Implement a Kubernetes Admission Controller using Trivy

1. This exercise is base upon the container [https://quay.io/repository/mmul/trivy-admission-webhook](https://quay.io/repository/mmul/trivy-admission-webhook)
   that has been created starting from [this article by Abhijeet Kasurde](https://medium.com/@AbhijeetKasurde/using-kubernetes-admission-controllers-1e5ba5cc30c0).
   Everything relies on Kubernetes [Dynamic Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-configuration).

2. First we will create the initial yaml files for two basic elements: the
   webhook application and the webhook configuration.

   The webhook application will be a deployment declared in
   `trivy-admission-webhook.yaml`:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     labels:
       app: trivy-admission-webhook
     name: trivy-admission-webhook
     namespace: trivy-system
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: trivy-admission-webhook
     template:
       metadata:
         labels:
           app: trivy-admission-webhook
       spec:
         containers:
           - name: trivy-admission-webhook
             image: quay.io/mmul/trivy-admission-webhook
             env:
               - name: "TRIVY_WEBHOOK_ALLOW_INSECURE_REGISTRIES"
                 value: "True"
             volumeMounts:
              - name: certs
                mountPath: "/certs"
                readOnly: true
         volumes:
           - name: certs
             secret:
               secretName: trivy-admission-webhook-certs
               optional: true
   ---
   apiVersion: v1
   kind: Service
   metadata:
     labels:
       app: trivy-admission-webhook
     name: trivy-admission-webhook
     namespace: trivy-system
   spec:
     ports:
       - name: 443-443
         port: 443
         protocol: TCP
         targetPort: 443
     selector:
       app: trivy-admission-webhook
   ```

   Note the usage of the `env:` inside the container, which will make the
   webhook accept also insecure registries like the one created in the pipeline.

   The webhook configuration will be in
   `taw-validating-webhook-configuration.yaml`:

   ```yaml
   apiVersion: admissionregistration.k8s.io/v1
   kind: ValidatingWebhookConfiguration
   metadata:
     name: "trivy-admission-webhook.trivy-system.svc"
   webhooks:
   - name: "trivy-admission-webhook.trivy-system.svc"
     rules:
     - apiGroups:   [""]
       apiVersions: ["v1"]
       operations:  ["CREATE"]
       resources:   ["pods"]
       scope:       "Namespaced"
     clientConfig:
       service:
         namespace: "trivy-system"
         name: "trivy-admission-webhook"
         path: /validate
         port: 443
     admissionReviewVersions: ["v1", "v1beta1"]
     sideEffects: None
     timeoutSeconds: 30
   ```

3. In Minikube we will need to generate a certificate for the webhook service
   and sign it with the CA certificate coming from the Minikube installation:

   ```console
   > openssl genrsa -out webhook.key 2048

   > servicename=trivy-admission-webhook.trivy-system.svc

   > openssl req -new -key webhook.key -out webhook.csr -subj "/CN=$servicename"

   > openssl x509 -req -extfile <(printf "subjectAltName=DNS:$servicename") -days 3650 -in webhook.csr -CA .minikube/ca.crt -CAkey .minikube/ca.key -CAcreateserial -out webhook.crt
   Signature ok
   subject=CN = trivy-admission-webhook.trivy-system.svc
   Getting CA Private Key
   ```

   The certificate will be part of a service, mounted by the webhook
   application:

   ```console
   > kubectl -n trivy-system create secret tls trivy-admission-webhook-certs --key="webhook.key" --cert="webhook.crt"
   secret/trivy-admission-webhook-certs created

   > kubectl create -f trivy-admission-webhook.yaml
   deployment.apps/trivy-admission-webhook created
   service/trivy-admission-webhook created

   > kubectl -n trivy-system get all -l app=trivy-admission-webhook
   NAME                                           READY   STATUS    RESTARTS   AGE
   pod/trivy-admission-webhook-6d965d5c78-cwxnv   1/1     Running   0          13m

   NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
   service/trivy-admission-webhook   ClusterIP   10.98.90.165   <none>        443/TCP   20m

   NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/trivy-admission-webhook   1/1     1            1           20m

   NAME                                                 DESIRED   CURRENT   READY   AGE
   replicaset.apps/trivy-admission-webhook-6d965d5c78   1         1         1       20m
   ```

   The last element to be created will be the webhook element itself:

   ```console
   > kubectl create -f taw-validating-webhook-configuration.yaml

   > kubectl get ValidatingWebhookConfiguration trivy-admission-webhook.trivy-system.svc
   NAME                                       WEBHOOKS   AGE
   trivy-admission-webhook.trivy-system.svc   1          7m23s
   ```

4. With everything in place, it is time for tests. We will deploy two different
   versions of nginx, one with no CRITICAL issues (`nginx:latest`) and the other
   with some of them (`nginx:1.18`):

   ```console
   > kubectl -n myns create deployment nginx-latest --image public.ecr.aws/nginx/nginx:latest
   deployment.apps/nginx-latest created

   > kubectl -n myns create deployment nginx-insecure --image public.ecr.aws/nginx/nginx:1.18
   deployment.apps/nginx-insecure created
   ```

   The result will be this, with `nginx-insecure` not deployed:

   ```console
   > kubectl -n myns get all
   NAME                                READY   STATUS    RESTARTS   AGE
   pod/nginx-latest-8586ccc94b-9slg8   1/1     Running   0          103s

   NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx-insecure   0/1     0            0           94s
   deployment.apps/nginx-latest     1/1     1            1           103s

   NAME                                        DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-latest-8586ccc94b     1         1         1       103s
   ```

   Details about this behavior can be found inside Kubernetes events:

   ```console
   > kubectl -n myns get events --sort-by='.metadata.creationTimestamp' -A
   NAMESPACE      LAST SEEN   TYPE      REASON                    OBJECT                                          MESSAGE
   ...
   ...
   myns           25s         Normal    ScalingReplicaSet         deployment/nginx-latest                         Scaled up replica set nginx-latest-8586ccc94b to 1
   myns           23s         Normal    SuccessfulCreate          replicaset/nginx-latest-8586ccc94b              Created pod: nginx-latest-8586ccc94b-9slg8
   myns           23s         Normal    Scheduled                 pod/nginx-latest-8586ccc94b-9slg8               Successfully assigned myns/nginx-latest-8586ccc94b-9slg8 to minikube
   myns           22s         Normal    Pulling                   pod/nginx-latest-8586ccc94b-9slg8               Pulling image "nginx:latest"
   myns           21s         Normal    Started                   pod/nginx-latest-8586ccc94b-9slg8               Started container nginx
   myns           21s         Normal    Created                   pod/nginx-latest-8586ccc94b-9slg8               Created container nginx
   myns           21s         Normal    Pulled                    pod/nginx-latest-8586ccc94b-9slg8               Successfully pulled image "nginx:latest" in 1.291453932s (1.291487398s including waiting)
   myns           16s         Normal    ScalingReplicaSet         deployment/nginx-insecure                       Scaled up replica set nginx-insecure-5785468788 to 1
   myns           1s          Warning   FailedCreate              replicaset/nginx-insecure-5785468788            Error creating: admission webhook "trivy-admission-webhook.trivy-system.svc" denied the request: Not all containers secure, failing ...
   ```

   Not all the containers inside the `nginx-insecure` pod are secure!

5. Last thing will be the deployment of the application coming from the internal
   registry. It will be the one that was produced by the pipeline, so
   `172.16.99.1:5000/ncat_http_msg_port:latest`.

   We started Minikube with `--insecure-registry=172.16.99.1:5000`, so the self
   signed certificate will be accepted for the deployment, and we also made the
   webhook accept insecure registries. This means that everything should work
   with a simple:

   ```console
   > kubectl -n myns create deployment ncat-http-msg-port --image 172.16.99.1:5000/ncat_http_msg_port:latest
   deployment.apps/ncat-http-msg-port created
   ```

   From the webhook application perspective, the `trivy` command was correctly
   invoked using the `--insecure` parameter:

   ```console
   > kubectl -n trivy-system logs trivy-admission-webhook-6bb7c75d98-x5rfg
   ...
   Running command: trivy image -f json -s CRITICAL --exit-code 1 --insecure 172.16.99.1:5000/ncat_http_msg_port:latest
   10.244.0.1 - - [21/Sep/2023:13:44:28] "POST /validate?timeout=30s HTTP/1.1" 200 194 "" "kube-apiserver-admission"
   ```

   And the application appears to be correctly deployed:

   ```console
   kubectl -n myns get all -l app=ncat-http-msg-port
   NAME                                      READY   STATUS    RESTARTS   AGE
   pod/ncat-http-msg-port-6d4cc89ccc-gx8cg   1/1     Running   0          48m

   NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/ncat-http-msg-port   1/1     1            1           48m

   NAME                                            DESIRED   CURRENT   READY   AGE
   replicaset.apps/ncat-http-msg-port-6d4cc89ccc   1         1         1       48m
   ```

6. Bonus: doing the same in a multi node Kubernetes installation.

   As we said, the service will rely on certificates, so we can use the one used
   by Kuberentes, downloading them from the server:

   ```console
   > scp kubernetes-1:ca* .
   Warning: Permanently added 'kubernetes-1' (ED25519) to the list of known hosts.
   ca.crt                                             100% 1099     1.4MB/s   00:00
   ca.key                                             100% 1675     2.4MB/s   00:00
   ```

   We will then create the certificates for the webhook, using `openssl`:

   ```console
   > openssl genrsa -out taw-webhook.key 2048

   > servicename=trivy-admission-webhook.trivy-system.svc

   > openssl req -new -key taw-webhook.key -out taw-webhook.csr -subj "/CN=$servicename"

   > openssl x509 -req -extfile <(printf "subjectAltName=DNS:$servicename") -days 3650 -in taw-webhook.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out taw-webhook.crt
   Certificate request self-signature ok
   subject=CN = trivy-admission-webhook.trivy-system.svc
   ```

   And then we will store them inside Kubernetes, as a `secret`:

   ```console
   > kubectl -n trivy-system create secret tls trivy-admission-webhook-certs --key="taw-webhook.key" --cert="taw-webhook.crt"
   secret/trivy-admission-webhook-certs created
   ```

   With the secret in place, it is time to create the webhook deploynment:

   ```console
   > kubectl create -f trivy-admission-webhook.yaml
   deployment.apps/trivy-admission-webhook created
   ...

   rasca@catastrofe [~/Labs/trivy-wa]> kubectl -n trivy-system get all -l app=trivy-admission-webhook
   NAME                                           READY   STATUS    RESTARTS   AGE
   pod/trivy-admission-webhook-7c888d7d86-jsrhh   1/1     Running   0          73s

   NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   service/trivy-admission-webhook   ClusterIP   10.111.238.91   <none>        443/TCP   18h

   NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/trivy-admission-webhook   1/1     1            1           73s

   NAME                                                 DESIRED   CURRENT   READY   AGE
   replicaset.apps/trivy-admission-webhook-7c888d7d86   1         1         1       73s
   ```

   And finally the webhook itself, patching the `validatingwebhookconfiguration`
   resource by adding the `ca.crt` certificate that has been used for the
   certificate generation:

   ```console
   > kubectl create -f taw-validating-webhook-configuration.yaml
   validatingwebhookconfiguration.admissionregistration.k8s.io/trivy-admission-webhook.trivy-system.svc created

   > export CABUNDLE=$(cat ca.crt|base64 -w 0)

   > export JSONPATCH="{\"webhooks\":[{\"name\":\"trivy-admission-webhook.trivy-system.svc\", \"clientConfig\":{\"caBundle\":\"$CABUNDLE\"}}]}"

   > kubectl patch validatingwebhookconfigurations.admissionregistration.k8s.io trivy-admission-webhook.trivy-system.svc --patch="$JSONPATCH"
   ```

7. Same tests can be made:

   ```console
   rasca@catastrofe [~/Labs/trivy-wa]> kubectl -n myns create deployment nginx-latest --image public.ecr.aws/nginx/nginx:latest
   deployment.apps/nginx-latest created

   rasca@catastrofe [~/Labs/trivy-wa]> kubectl -n myns create deployment nginx-insecure --image public.ecr.aws/nginx/nginx:1.18
   deployment.apps/nginx-insecure created
   ```

   The two used images are different because one has CRITICAL vulnerabilities
   (`nginx:1.18`) and the `latest` not.
   So the events sequence will be:

   ```console
   rasca@catastrofe [~/Labs/trivy-wa]> kubectl -n myns get events --sort-by='.metadata.creationTimestamp' -A
   NAMESPACE      LAST SEEN   TYPE      REASON              OBJECT                                          MESSAGE
   ...
   ...
   myns           43s         Warning   FailedCreate        replicaset/nginx-insecure-79b595ff9b            Error creating: admission webhook "trivy-admission-webhook.trivy-system.svc" denied the request: Not all containers secure, failing ...
   myns           2m8s        Normal    ScalingReplicaSet   deployment/nginx-latest                         Scaled up replica set nginx-latest-785b998d5d to 1
   myns           2m5s        Normal    Pulling             pod/nginx-latest-785b998d5d-66tvk               Pulling image "public.ecr.aws/nginx/nginx:latest"
   myns           2m5s        Normal    Scheduled           pod/nginx-latest-785b998d5d-66tvk               Successfully assigned myns/nginx-latest-785b998d5d-66tvk to kubernetes-2
   myns           2m5s        Normal    SuccessfulCreate    replicaset/nginx-latest-785b998d5d              Created pod: nginx-latest-785b998d5d-66tvk
   myns           2m4s        Normal    Pulled              pod/nginx-latest-785b998d5d-66tvk               Successfully pulled image "public.ecr.aws/nginx/nginx:latest" in 831.767789ms (831.77442ms including waiting)
   myns           2m4s        Normal    Created             pod/nginx-latest-785b998d5d-66tvk               Created container nginx
   myns           2m4s        Normal    Started             pod/nginx-latest-785b998d5d-66tvk               Started container nginx
   ```
