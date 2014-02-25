#!/bin/bash

[ ! -e ~/.profile      ] || . ~/.profile
[ ! -e ~/.bash_profile ] || . ~/.bash_profile

eftcmdr "$@"
