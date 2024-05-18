#!/bin/sh
if [ -f /config/.config-lock ]; then
    rm /config/.config-lock
fi
flexget daemon start --autoreload-config
