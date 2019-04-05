#!/bin/bash

[[ "$1" == "default" ]] && {
  /usr/sbin/sshd -D
}

exec "$@"
