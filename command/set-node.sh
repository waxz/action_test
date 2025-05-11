cat << 'EOF' | tee -a $HOME/.bashrc

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

EOF
