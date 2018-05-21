#/bin/bash

export TF_VAR_location="West Europe"
export TF_VAR_resource_group_name="RG"

function show-env() {
  echo "Current Variables Set "
  echo " "
  env | grep TF_VAR
  echo " "
}

function clear-env() {
  echo "Clearing Variables"
  proceed
  exit 0
}

function set() {
  echo "set from varfile"
  proceed
  exit 0
}

function proceed() {
  echo $1
  echo "Do you wish to proceed? "
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) terraform plan && terraform apply; break;;
      No ) exit 0;;
    esac
  done
}

function usage() {
  printf "Usage : %s [show-env|clear-env|set-env] \n" $0
}

if [ $# -ne 1 ]; then
  printf "Exit Code PARAMS\n"
  usage
  exit 99
fi

$1
