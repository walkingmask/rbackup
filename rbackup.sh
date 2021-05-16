#!/usr/bin/env bash
set -eu

# rbackup.sh
# updated at 2021/05/17 (Mon)
# walkingmask
# Regular backup (dotfile, app_list, brew_list, dev_list)

# Homebrew wrapper
function _brew () {
  PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin brew "$@"
}

timestamp=`date +%Y%m%d%H%M`

# log files
brewlogfile="${HOME}/Desktop/brew_log_${timestamp}.log"
errorlogfile="${HOME}/Desktop/rbackup_error_${timestamp}.log"

# Temp file
[ -e /tmp/rbackup ] && : || /bin/mkdir /tmp/rbackup
tempfile="/tmp/rbackup/tempfile_${timestamp}"

# Path of backup dirctory
DOTFILE_DIR=${HOME}/work/.dotfile
LIST_DIR=${HOME}/work/.list

# Check backup directory
if [ ! -d $DOTFILE_DIR ]; then
  /bin/mkdir -p $DOTFILE_DIR
fi
if [ ! -d $LIST_DIR ]; then
  /bin/mkdir -p $LIST_DIR
fi

# Check dotfile_list_wanted
if [ ! -f ${DOTFILE_DIR}/dotfile_list_wanted ]; then
  echo "[`date`] rbackup: Error. There is no dotfile_list_wanted." >>$errorlogfile
else
  # Backup dotfile
  for obj in `cat ${DOTFILE_DIR}/dotfile_list_wanted`; do
    if [ -e ${HOME}/${obj} ]; then
      rsync -a ${HOME}/${obj} ${DOTFILE_DIR}/${obj}
    else
      echo "[`date`] rbackup: Error. There is no ${HOME}/${obj}" >>$errorlogfile
    fi
  done
fi

# Backup app_list
printf "" >$tempfile
for obj in /Applications/*; do
  if [ "${obj##*.}" = "app" ]; then
    echo `basename "$obj"` >>$tempfile
  else
    printf "\n- " >>$tempfile
    echo `basename "$obj"` >>$tempfile
    ls "$obj" | grep ".app" >>$tempfile || :
    echo "" >>$tempfile
  fi
done
rsync -a $tempfile ${LIST_DIR}/app_list

# Check brew
if [ ! -x /usr/local/bin/brew ]; then
  echo "[`date`] rbackup: Error. There is no brew command." >>$errorlogfile
else
  _brew doctor >$brewlogfile 2>&1 || true
  _brew update >>$brewlogfile 2>&1 || true
  # Backup brew_list
  _brew list -v >$tempfile
  rsync -a $tempfile ${LIST_DIR}/brew_list
fi

# Path of dev
DEV_DIR=$HOME/dev

# Check dev directory
if [ ! -d $DEV_DIR ]; then
  mkdir -p $DEV_DIR
fi

# Backup dev_list
ls -R $DEV_DIR >$tempfile
rsync -a $tempfile ${LIST_DIR}/dev_list

# Backup bin_list
ls ${HOME}/bin >$tempfile
rsync -a $tempfile ${LIST_DIR}/bin_list

# Backup dotfile_list
ls -a $HOME | grep -E '^\..+' | grep -v "\.\." >$tempfile
rsync -a $tempfile ${LIST_DIR}/dotfile_list

# Exit
/bin/rm -f $tempfile
exit 0
