#!/bin/sh
# NOTE: On the PW2, otaupd sometimes segfaults for no good reason... Restart it if this happens.
#restart otaupd
lipc-set-prop -i com.lab126.ota startUpdate 1
