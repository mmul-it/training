# Lab | Containers Query Registry

In this lab you will:

1. Given this registry:
   - Host: `https://www.mmul.it:5000`
   - User: `dockertraining`
   - Pass: `l3tstr41n`
   Use `curl` to extract the list of the available images.
2. Do the same by using [the python script registry.py](https://github.com/andrey-pohilko/registry-cli/).

## Solution

1. The `curl` command can be invoked in one single command, as follows:

   ```console
   > curl -s -X GET -u dockertraining:l3tstr41n https://www.mmul.it:5000/v2/_catalog | jq -r .repositories[]
   {
     "repositories": [
       "ncat-msg-http-port",
       "print-date"
     ]
   }

   > curl -s -X GET -u dockertraining:l3tstr41n https://www.mmul.it:5000/v2/ncat-msg-http-port/tags/list | jq
   {
     "name": "ncat-msg-http-port",
     "tags": [
       "latest"
     ]
   }

   $ curl -s -X GET -u dockertraining:l3tstr41n https://www.mmul.it:5000/v2/print-date/tags/list | jq 
   {
     "name": "print-date",
     "tags": [
       "latest"
     ]
   }
   ```

2. It is possible to use also tools and script like [the python script registry.py](https://github.com/andrey-pohilko/registry-cli/)
   that is also available as a container, and can be invoked as follows:

   ```console
   > docker run --rm anoxis/registry-cli -r https://www.mmul.it:5000 -l dockertraining:l3tstr41n
   ---------------------------------
   Image: ncat-msg-http-port
     tag: latest
   ---------------------------------
   Image: print-date
     tag: latest
   ```
