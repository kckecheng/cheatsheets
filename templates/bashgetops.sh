#!/usr/bin/bash
HOST=""
IMAGE=""
SPEC=""

usage() {
  echo
  echo "Usage: $0 [-h <server ip>] [-i <image id, like img-xxxx>] [-s <instance spec, like S5.LARGE8>]"
  echo
  exit 1
}

while getopts "h:i:s:" opt; do
  case $opt in
    h)
      HOST=$OPTARG
      ;;
    i)
      IMAGE=$OPTARG
      ;;
    s)
      SPEC=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      exit 1
      ;;
    ?)
      echo "Invalid option: -$OPTARG"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$HOST" || -z "$IMAGE" || -z "$SPEC" ]]; then
  usage
fi

echo "$HOST:$IMAGE:$SPEC"
