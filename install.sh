#!/usr/bin/env bash
set -eux

# install.sh
# updated at 2021/05/17 (Mon)
# walkingmask
# Install rbackup with launchd

HERE=$(cd $(dirname $0); pwd)
SCRIPT_PATH=${HOME}/bin

if [ -f ${SCRIPT_PATH}/rbackup.sh ]; then
  rm ${SCRIPT_PATH}/rbackup.sh
fi
cp ${HERE}/rbackup.sh ${SCRIPT_PATH}/

if [ -f ${HOME}/Library/LaunchAgents/rbackup.plist ]; then
  if launchctl list | grep rbackup >/dev/null 2>&1; then
    launchctl stop rbackup
    launchctl unload ${HOME}/Library/LaunchAgents/rbackup.plist
  fi
  rm ${HOME}/Library/LaunchAgents/rbackup.plist
fi
sed -e "s|SCRIPT_PATH|${SCRIPT_PATH}|g" ${HERE}/rbackup.plist >${HOME}/Library/LaunchAgents/rbackup.plist

launchctl load ${HOME}/Library/LaunchAgents/rbackup.plist
launchctl start rbackup
