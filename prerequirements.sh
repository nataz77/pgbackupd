#!/bin/bash
# shellcheck shell=bash

function install_azcli {
    curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null    
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    tee /etc/apt/sources.list.d/azure-cli.list
    
    apt-get update
    apt-get install azure-cli
}

function install_awscli {
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
}

function common {
    set -v
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt install -y zip unzip curl procps software-properties-common ca-certificates apt-transport-https lsb-release gnupg
    set +v
}

common
install_awscli
install_azcli