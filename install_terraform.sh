#!/usr/bin/env bash
# Written by: Robert J.

set -e

main(){
    VERSION=$(get_version)

    download_latest "$VERSION"
    move_to_path
}

get_version(){
    type -a jq > /dev/null || {
        apt install jq ||
            yum install jq || {
                printf "unable to install jq, exiting\n";
                exit 1;
            }
    }

    RESP=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
    printf "%s" "$RESP"
}

download_latest(){
    VERSION="$1"
    rm -f /tmp/terraform_latest.zip || true
    wget -O /tmp/terraform_latest.zip https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip
}

move_to_path(){
    unzip /tmp/terraform_latest.zip -d /tmp
    rm -f /opt/terraform
    mv /tmp/terraform /opt

    type -a terraform || {
        echo "PATH=\"$PATH:/opt\"" >> ~/.bash_profile &&
            source ~/.bash_profile
    }
}

main

