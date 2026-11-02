#!/bin/sh
# Usage: nightlight.sh force|schedule|off. Stopping hyprsunset restores normal colours.
pkill -x hyprsunset
# a new instance exits at once while the old one is still holding the compositor connection
while pgrep -x hyprsunset >/dev/null; do sleep 0.1; done
case "$1" in
    force) exec hyprsunset -t 4000 ;;
    schedule) exec hyprsunset ;; # uses the profiles in ~/.config/hypr/hyprsunset.conf
esac
