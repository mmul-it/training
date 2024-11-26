# Kubecost

Officiale doc: [https://www.kubecost.com/install#show-instructions](https://www.kubecost.com/install#show-instructions)

```console
$ helm install kubecost cost-analyzer \
--repo https://kubecost.github.io/cost-analyzer/ \
--namespace kubecost --create-namespace \
--set kubecostToken="c3RpY2FAc3RvY2EuaXQ=xm343yadf98"
NAME: kubecost
LAST DEPLOYED: Tue Nov 26 15:42:34 2024
NAMESPACE: kubecost
STATUS: deployed
REVISION: 1
NOTES:
--------------------------------------------------
Kubecost 2.4.3 has been successfully installed.

Kubecost 2.x is a major upgrade from previous versions and includes major new features including a brand new API Backend. Please review the following documentation to ensure a smooth transition: https://docs.kubecost.com/install-and-configure/install/kubecostv2

When pods are Ready, you can enable port-forwarding with the following command:

    kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090

Then, navigate to http://localhost:9090 in a web browser.

Please allow 25 minutes for Kubecost to gather metrics. A progress indicator will appear at the top of the UI.

Having installation issues? View our Troubleshooting Guide at http://docs.kubecost.com/troubleshoot-install
```
