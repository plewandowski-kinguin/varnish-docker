#!/bin/bash

# Convert environment variables in the conf to fixed entries
# http://stackoverflow.com/questions/21056450/how-to-inject-environment-variables-in-varnish-configuration
for name in VARNISH_BACKEND_PORT VARNISH_BACKEND_IP
do
    eval value=\$$name
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

# Start varnish and log
varnishd -s malloc,100M -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT} -T 0.0.0.0:6082 -p cli_buffer=81920 -p esi_syntax=0x2 
TIME=$(date +%s)
varnishadm -T 127.0.0.1:6082 vcl.load varnish_$TIME /etc/varnish/default.vcl
varnishadm -T 127.0.0.1:6082 vcl.use varnish_$TIME
varnishlog
