#!/usr/bin/env bash
set -eu


#
# Regular backup (dotfile, app_list, brew_list, dev_list)
#


# Error log

errorlogfile="$HOME/Desktop/rbackup_error`date +%Y%m%d%H%M`.log"


# Temp file

tempfile="$HOME/temp/tempfile`date +%Y%m%d%H%M`"


# Path of backup dirctory

DOTFILE_DIR=$HOME/work/.dotfile
LIST_DIR=$HOME/work/.list


# Check backup directory

if [ ! -d $DOTFILE_DIR ]; then
  mkdir -p $DOTFILE_DIR
fi
if [ ! -d $LIST_DIR ]; then
  mkdir -p $LIST_DIR
fi


# Check brew

if [ -x /usr/local/bin/brew ]; then
  PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  brewlogfile="$HOME/Desktop/brew_log`date +%Y%m%d%H%M`.log"
  /usr/local/bin/brew doctor >$brewlogfile 2>&1 || true
  /usr/local/bin/brew update >>$brewlogfile 2>&1 || true
else
  echo "[`date`] rbackup: Error. There is no brew command." >>$errorlogfile
  exit 1
fi


# Check dotfile_list

if [ ! -f $DOTFILE_DIR/dotfile_list_wanted ]; then
  echo "[`date`] rbackup: Error. There is no dotfile_list_wanted." >>$errorlogfile
  exit 1
fi

# Backup dotfile

for obj in `cat $DOTFILE_DIR/dotfile_list_wanted`; do
  if [ -e $HOME/$obj ]; then
    rsync -a $HOME/$obj $DOTFILE_DIR/$obj
  else
    echo "[`date`] rbackup: Error. There is no $HOME/$obj" >>$errorlogfile
  fi
done


# Backup app_list

printf "" >$tempfile
for obj in /Applications/*
do
  if [ "${obj##*.}" = "app" ]; then
    echo `basename "$obj"` >>$tempfile
  else
    printf "\n- " >>$tempfile
    echo `basename "$obj"` >>$tempfile
    ls "$obj" | grep ".app" >>$tempfile
    echo "" >>$tempfile
  fi
done
rsync -a $tempfile $LIST_DIR/app_list


# Backup brew_list

/usr/local/bin/brew list -v >$tempfile
rsync -a $tempfile $LIST_DIR/brew_list


# Path of dev

DEV_DIR=$HOME/dev


# Check dev directory

if [ ! -d $DEV_DIR ]; then
  mkdir -p $DEV_DIR
fi


# Backup dev_list

printf "" >$tempfile
for host in `ls $DEV_DIR`
do
  [[ $host =~ ".DS_Store" ]] && continue
  for user in `ls $DEV_DIR/$host`
  do
    [[ $user =~ ".DS_Store" ]] && continue
    for repo in `ls $DEV_DIR/$host/$user`
    do
      [[ $repo =~ ".DS_Store" ]] && continue
      echo "$host/$user/$repo" >>$tempfile
    done
  done
done
rsync -a $tempfile $LIST_DIR/dev_list


# Backup env_list

printf "" >$tempfile
for env in `ls $HOME/.anyenv/envs`;
do
  echo "${env}:" >>$tempfile
  if [ -f $HOME/.anyenv/envs/$env/version ]; then
    echo "* `cat $HOME/.anyenv/envs/$env/version`" >>$tempfile
  fi
  for version in `ls $HOME/.anyenv/envs/$env/versions`;
  do
    if cat $tempfile | grep $version >/dev/null; then
      :
    else
      echo $version >>$tempfile
    fi
  done
done
rsync -a $tempfile $LIST_DIR/env_list


# Backup bin_list

ls $HOME/bin >$tempfile
rsync -a $tempfile $LIST_DIR/bin_list


# Backup dotfile_list
ls -a $HOME | grep -E '^\..+' | grep -v "\.\." >$tempfile
rsync -a $tempfile $LIST_DIR/dotfile_list


# Exit

/bin/rm -f $tempfile
exit 0
