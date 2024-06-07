#!/bin/bash

while (( "$#" )); do
  case "$1" in
    --path)
      path="$2"
      shift 2
      ;;
    --help)
      echo "Usage: ./docsify-serve-start.sh [--path REPOSITORY_PATH]"
      echo "Starts a docsify server."
      echo "Options:"
      echo "  --path REPOSITORY_PATH   Specify the path to repository. Defaults to current directory."
      exit 0
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

command="docsify serve ${path:-.}"
echo $command && eval $command
