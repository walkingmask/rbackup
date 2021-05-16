#!/usr/bin/env bash
set -eux

# uninstall.sh
# updated at 2021/05/17 (Mon)
# walkingmask
# Uninstall rbackup from launchd

if launchctl list | grep rbackup >/dev/null 2>&1; then
  launchctl stop rbackup
fi

if [ -f ${HOME}/Library/LaunchAgents/rbackup.plist ]; then
  launchctl unload ${HOME}/Library/LaunchAgents/rbackup.plist
  rm ${HOME}/Library/LaunchAgents/rbackup.plist
fi

exit 0
