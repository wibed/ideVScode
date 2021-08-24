# IDE optimized for javascript, python, swift, web
# dont forget to enable X11 access: xhost +local:root

.PHONY: help build_nc sync run

help:	Makefile
	sed -n '1,2p' $<

.DEFAULT_GOAL := run
TAGNAME=vside
GNAME := $(shell id -un)
UNAME := $(shell id -gn)

build_nc:
	docker volume rm ${TAGNAME}Data || true
	docker volume create ${TAGNAME}Data
	docker build . --no-cache -t ${TAGNAME}

sync:
	docker volume rm ${TAGNAME}Data || true
	docker volume create ${TAGNAME}Data
	docker build . -t ${TAGNAME}

run:
	docker run \
		-itd \
		--privileged \
		--network="host" \
		-e DISPLAY="${DISPLAY}" \
		-e UNAME="${UNAME}" \
		-e GNAME="${GNAME}" \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /home/general/work:/work \
		-v ${TAGNAME}Data:/home/user \
		${TAGNAME}
