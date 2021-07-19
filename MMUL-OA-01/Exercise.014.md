# Exercise 014 - Attach a PVC object to a DC, then create a new one updating a DC

---

1. As 'developer' create a new 'teststorage' project.

2. Create a new DeploymentConfig named tomcat based on the 'tomcat' image with
   1 replica.

3. Check if there is an available PersistentVolumeClaim, otherwise create a
   new one named 'tomcat-claim' with 2Gb size.

4. Check if it bounds to a PersistentVolume, then attach it to the created
   'tomcat' DeploymentConfig in the /claim path.

5. Check if DeploymentConfig contains the claim details, and check if the
   tomcat pod have it mounted.

6. Using the oc command create and attach a new claim named 'tomcat-storage'
   2Gb big to the tomcat DeploymentConfig, mounted at the /storage path.

7. Check if DeploymentConfig contains the claim details, and check if the
   tomcat pod have it mounted.
