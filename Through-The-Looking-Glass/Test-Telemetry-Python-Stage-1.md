# Test Telemetry with Python - Stage 1

This is the first and simplest stage where a Python application just logs on the
console standard output all the messages, and keeps track of the execution time
on the logs themselves.

## Start stage 1 of the app

After activating the Python environment and getting into the `python-app`
directory, launching the app is simple:

```console
$  ./launch.sh Stage-1-Simple
~/Git/kiratech/labs/Through-The-Looking-Glass/python-app/Stage-1-Simple ~/Git/kiratech/labs/Through-The-Looking-Glass/python-app
 * Serving Flask app 'cheshire'
 * Debug mode: off
INFO:werkzeug:WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5001
INFO:werkzeug:Press CTRL+C to quit
 * Serving Flask app 'alice'
 * Debug mode: off
INFO:werkzeug:WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5000
INFO:werkzeug:Press CTRL+C to quit
```

The frontend application will be listening at the [http://172.18.0.1:5000](http://172.18.0.1:5000)
address.

## Simulate traffic

The application can be reached using a web browser or directly using a tool like
`curl`.

Inside the `python-app` working directory there's also a `simulate-traffic.sh`
script that will make random parallel calls to the address, to simulate real
traffic coming to the application:

```console
$ ./simulate-traffic.sh
Starting traffic simulation...
Doing 47 parallel requests...
Doing 18 parallel requests...
Doing 8 parallel requests...
Doing 33 parallel requests...
Doing 12 parallel requests...
Doing 29 parallel requests...
Doing 45 parallel requests...
...
```

The script will continue until the `Ctrl+C` key combination will be pressed.

## Look at the results

All the results are part of the console's output, with groups of lines similar
to these:

```console
...
...
INFO:root:Backend: Processing request from '192.168.1.50' source. Took 0.3080742359161377 seconds.
INFO:werkzeug:192.168.1.50 - - [07/Mar/2025 11:07:03] "GET /process HTTP/1.1" 200 -
INFO:root:Frontend: request from '192.168.1.50', calling 'http://172.18.0.1:5001/process' endpoint completed. Took 0.36110544204711914 seconds.
...
...
```

Everything is inside the lines, both the logs and also some sort of metrics
related to the execution time.

This data can be exported, for example by redirecting the application execution
into a file, as in `./launch.sh Stage-1-Simple > mylog.txt` and further analyzed
elsewhere, but will remain limited to this kind of execution.
