# ideVScode

## About
a visual studio code ide provided by a docker container.
it forwards the X-Display from the host to the container
and its variables. 

installed languages:
- python
- nodejs
- swift


## Overview
to use the package run `make sync` to build the
container image.
to start the package run `make run` to start the
container.


## Varia
- forwarding the xserver 
  - assumes access to it is allowed to all users
    `xhost +local:`
  - assumes installed dependencies (included in the container)
    `libxshmfence1 libx11-xcb1`
  - assumes the container to be ran, with access to the Display
    `-v /tmp/.X11-linux:/tmp/.X11-linux`
  - assumes the environment variable to be correctly set
    `-e DISPLAY=${DISPLAY}`
    
- the process is executed as the user 1001, which in turn needs
  rw access on the folder you need to work on.




test
