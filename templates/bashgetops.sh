#!/usr/bin/bash
#
OPT1=""
OPT2=""
OPT3=""

usage() {
  echo
  echo "Usage: $0 [-a <option 1> -b <option 2>] [-c] [-h]"
  echo
}

show() {
  echo "OPT1: $OPT1"
  echo "OPT2: $OPT2"
  echo "OPT3: $OPT3"
}

while getopts ":a:b:ch" opt; do
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
