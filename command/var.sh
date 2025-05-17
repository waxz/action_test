#!/bin/bash

# env

# add deno

export PATH="$HOME/.deno":"$PATH"





# function

## set modules-folder for yarn
myarn(){

  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"

  for arg in "$@"; do
    echo "Argument: $arg"
  done
#echo "Original list: $@"
#shift
#echo "List after removing the first element: $@"

 if [ ! -z "$CUSTOM_NODE_DIR" ]; then CUSTOM_NODE_DIR=$CUSTOM_NODE_DIR; else CUSTOM_NODE_DIR="/tmp/node_modules";fi

if [[ -z "$CUSTOM_NODE_DIR" ]]; then
    if [ ! -d "$CUSTOM_NODE_DIR" ] ; then echo "$CUSTOM_NODE_DIR is not a folder";fi

    echo "Please provide modules-folder . Usage export CUSTOM_NODE_DIR = xxx; myarn ";
else
    PATH=$CUSTOM_NODE_DIR/.bin:$PATH  NODE_PATH=$CUSTOM_NODE_DIR:$NODE_PATH yarn  --modules-folder $CUSTOM_NODE_DIR $@
fi
}


# gh install
# gh_install vi/websocat websocat.x86_64-unknown-linux-musl
gh_install(){

  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"
  if [[ -z "$1" ||  -z "$2" || -z "$3" ]]; then
       echo "please set repo , arch and filename"
  else 
  repo=$1
  arch=$2
  filename=$3

  echo "set repo: $repo, arch: $arch, filename: $filename"

  url=$(curl -L   -H "Accept: application/vnd.github+json"   https://api.github.com/repos/$repo/releases | jq -r ".[0].assets[] | .browser_download_url" | grep "$arch") 
  count=0
  while [  -z "$url" && $count -lt 5 ];do
      url=$(curl -L   -H "Accept: application/vnd.github+json"   https://api.github.com/repos/$repo/releases | jq -r ".[0].assets[] | .browser_download_url" | grep "$arch") 
      count=$((count+1))
  done
  echo "url: $url"

  if [ ! -z "$url" ]; then
      wget $url -O $filename
  fi

  fi 

}

# vc

vc_create() {
  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "Please provide password, filename, and filesize. Usage: vc_create password filename filesize";
  else
    veracrypt --text --create "$2" --size "$3" --password "$1" --volume-type normal --encryption AES --hash sha-512 --filesystem ext4 --pim 0 --keyfiles "" --random-source ~/.bashrc;
  fi
}

# Define the function for mounting a VeraCrypt volume
vc_mnt() {
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
    echo "Please provide password, filename, mountpath and slot. Usage: vc_mnt password filename mountpath slot";
  else
    if [[ ! -d "$3" ]]; then mkdir -p "$3";fi;
    veracrypt --text --mount "$2" "$3" --password "$1" --pim 0 --keyfiles "" --protect-hidden no --slot "$4" --verbose;
  fi
}

vc_dmnt(){
  if [[ -z "$1" ]]; then
    echo "Please provide filename . Usage: vc_dmnt filename ";

  else
     veracrypt --dismount "$1"
  fi
}



