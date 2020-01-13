#!/bin/sh
# I think this is now creds of ixtab / Yifan Lu. repacked by twobob.
PREFS=/var/local/java/prefs/com.amazon.ebook.framework/prefs

case "$1" in
"L"|"R")
        lipc-set-prop -s com.lab126.winmgr orientationLock $1
#        lipc-set-prop -s com.lab126.winmgr refreshOnTurn true
        ;;
"U"|"D")
        lipc-set-prop -s com.lab126.winmgr orientationLock $1
#        lipc-set-prop -s com.lab126.winmgr refreshOnTurn $({ grep onPageTurn $PREFS || echo false ; } | sed 's/.*=//')
        ;;
esac
