#!/usr/bin/env bash
set -eux


#
# Uninstall rbackup from launchd
#


if launchctl list | grep rbackup >/dev/null 2>&1; then
  launchctl stop rbackup
  launchctl unload $HOME/Library/LaunchAgents/rbackup.plist
fi

if [ -f $HOME/Library/LaunchAgents/rbackup.plist ]; then
  rm $HOME/Library/LaunchAgents/rbackup.plist
fi
