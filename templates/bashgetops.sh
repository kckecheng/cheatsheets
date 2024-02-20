#!/usr/bin/bash
#
OPT1=""
OPT2=""
OPT3=""
# one option with multiple values
OPTS=()

usage() {
  echo
  echo "Usage: $0 [-a <option 1>] [-b <option 2>] [-c] [-d <value 1>] [-d <value 2>] ... [-h]"
  echo
}

show() {
  echo "OPT1: $OPT1"
  echo "OPT2: $OPT2"
  echo "OPT3: $OPT3"
  echo "OPTS:"
  for v in "${OPTS[@]}"; do
    echo $v
  done
}

while getopts ":a:b:cd:h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    a)
      OPT1=$OPTARG
      ;;
    b)
      OPT2=$OPTARG
      ;;
    c)
      OPT3=1
      ;;
    d)
      OPTS+=( $OPTARG )
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

show
