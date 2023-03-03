# Exercise | Containers Build Custom Image

1. Create an empty directory in which you will store your `Dockerfile`.

2. Compose a Dockerfile so that:

   - Starts `FROM ubuntu:latest`.
   - Use these three environmental variables:
     - `NCAT_MESSAGE` with value `Container test`.
     - `NCAT_HEADER` with value `HTTP/1.1 200 OK`.
     - `NCAT_PORT` with value `8888`.
   - While building installs the nmap package;
   - While executing launches a `ncat` command that listens on the `NCAT_PORT`
     and print via `NCAT_HEADER` the `NCAT_MESSAGE`.

3. Build the container image.

4. Run the newly created container image to check that it deploys correctly.
