cat << 'EOF' | tee -a $HOME/.bashrc
myarn(){

  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"

  for arg in "$@"; do
    echo "Argument: $arg"
  done


if [[ -z "$1" ]]; then
    if [ !d "$1" ] ; then echo "$1 is not a folder";fi

    echo "Please provide modules-folder . Usage: myarn modules-folder ...";
else
    CUSTOM_NODE_DIR=$1 
    CUSTOM_NODE_DIR=/tmp/node_modules 
    PATH=$CUSTOM_NODE_DIR/.bin:$PATH NODE_PATH="$CUSTOM_NODE_DIR:$NODE_PATH" 
    yarn  --modules-folder $@
fi
}
EOF