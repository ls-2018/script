#!/usr/bin/env python3
import os
for i in range(10):
    os.system('sudo dscacheutil -flushcache')
    os.system('sudo killall -HUP mDNSResponder')
