#!/bin/bash -x

for script in *.cli; do
	docker cp $script solace:/usr/sw/jail/cliscripts/
done
