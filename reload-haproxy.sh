#!/bin/bash

/usr/local/sbin/haproxy -f /etc/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
