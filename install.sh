#!/usr/bin/env bash
set -eux


#
# Install rbackup with launchd
#


SCRIPT_PATH=$HOME/bin
if [ -f $SCRIPT_PATH/rbackup.sh ]; then
  rm $SCRIPT_PATH/rbackup.sh
fi
cp ./rbackup.sh $SCRIPT_PATH/

if [ -f $HOME/Library/LaunchAgents/rbackup.plist ]; then
  rm $HOME/Library/LaunchAgents/rbackup.plist
fi
sed -e "s|SCRIPT_PATH|$SCRIPT_PATH|g" ./rbackup.plist >$HOME/Library/LaunchAgents/rbackup.plist

if launchctl list | grep rbackup >/dev/null 2>&1; then
  launchctl stop rbackup
  launchctl unload $HOME/Library/LaunchAgents/rbackup.plist
fi
launchctl load $HOME/Library/LaunchAgents/rbackup.plist
launchctl start rbackup
