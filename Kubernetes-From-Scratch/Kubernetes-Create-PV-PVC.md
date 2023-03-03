# Exercise | Kubernetes Create PV PVC

1. Create a PV of 5G pointing to the `/data` directory and a `storageClassName` named `localpv`.

2. Create a namespace named `volumes-test` with a PersistentVolumeClaim of 1G claiming for the `storageClassName` named `localpv`.

3. Find the bounded volumes and show the details;
