# Exercise | Containers Query Registry | Solutions

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
