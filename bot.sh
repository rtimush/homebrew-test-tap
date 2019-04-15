#!/usr/bin/env bash

set -euxo pipefail

#
# Required environment variables:
#   BUILD_REPOSITORY_ID                  - org/repo
#   SYSTEM_PULLREQUEST_PULLREQUESTNUMBER - pull request number, defined for PR builds only
#   SYSTEM_PULLREQUEST_TARGETBRANCH      - pull request target branch, defined for PR builds only
#   BUILD_ARTIFACTSTAGINGDIRECTORY       - directory to copy bottles to
#   BINTRAY_ORG (optional)               - bintray organization name, defaults to git organization name
#   BINTRAY_REPO (optional)              - bintray repository name, defaults to bottles-${TAP_SHORT_NAME}
#   BINTRAY_USER (optional)              - bintray user name, defaults to BINTRAY_ORG
#   BINTRAY_KEY                          - bintray API key
#   GITHUB_DEPLOY_KEY                    - SSH key with (\n can represent a newline, as Azure Pipelines do not support multiline variables)

setupEnvironment() {
    if [[ -n "${SYSTEM_PULLREQUEST_PULLREQUESTNUMBER:-}" ]]; then
        export GIT_PREVIOUS_COMMIT=$(git rev-list --max-count=1 "origin/$SYSTEM_PULLREQUEST_TARGETBRANCH")
        export GIT_COMMIT=$(git rev-list --max-count=1 HEAD)
        CI_MODE=--ci-pr
    else
        export GIT_PREVIOUS_COMMIT=$(git rev-list --max-count=1 origin/master)
        export GIT_COMMIT=$(git rev-list --max-count=1 HEAD)
        CI_MODE=--ci-testing
    fi
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    REPO_NAME="${BUILD_REPOSITORY_ID#*/}"
    ORG_NAME="${BUILD_REPOSITORY_ID%/*}"
    TAP_SHORT_NAME="${REPO_NAME#homebrew-}"
    TAP_NAME="$ORG_NAME/$TAP_SHORT_NAME"
    BINTRAY_ORG="${BINTRAY_ORG:-${ORG_NAME}}"
    BINTRAY_REPO="${BINTRAY_REPO:-bottles-${TAP_SHORT_NAME}}"
    BINTRAY_USER="${BINTRAY_USER:-${BINTRAY_ORG}}"
    unset TF_BUILD
}

setupTap() {
    local tap="$(brew --repo)/Library/Taps/$BUILD_REPOSITORY_ID"
    mkdir -p "$(dirname "$tap")"
    sudo ln -s "$PWD" "$tap"
}

BINTRAY_PUBLISH_URLS=()

uploadBottle() {
    local BOTTLE_JSON="$1"
    local BOTTLE_LOCAL_FILENAME="$(jq -r '.[].bottle.tags[].local_filename' "$BOTTLE_JSON")"
    local BOTTLE_FILENAME="$(jq -r '.[].bottle.tags[].filename' "$BOTTLE_JSON")"
    local BOTTLE_REPOSITORY="$(jq -r '.[].bintray.repository' "$BOTTLE_JSON")"
    local BOTTLE_PACKAGE="$(jq -r '.[].bintray.package' "$BOTTLE_JSON")"
    local BOTTLE_VERSION="$(jq -r '.[].formula.pkg_version' "$BOTTLE_JSON")"
    curl -T "${BOTTLE_LOCAL_FILENAME}" -u "${BINTRAY_USER}:${BINTRAY_KEY}" "https://api.bintray.com/content/${BINTRAY_ORG}/${BOTTLE_REPOSITORY}/${BOTTLE_PACKAGE}/${BOTTLE_VERSION}/${BOTTLE_FILENAME}"
    BINTRAY_PUBLISH_URLS+=("https://api.bintray.com/content/${BINTRAY_ORG}/${BOTTLE_REPOSITORY}/${BOTTLE_PACKAGE}/${BOTTLE_VERSION}/publish")
}

publishBottles() {
    local url
    for url in "${BINTRAY_PUBLISH_URLS[@]}"; do
        curl -X POST -u "${BINTRAY_USER}:${BINTRAY_KEY}" "$url"
    done
}

setupGit() {
    echo $GITHUB_DEPLOY_KEY | sed 's/\\n/\
/g' > github.key
    chmod 0600 github.key
    mkdir -p ~/.ssh
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    git remote add origin-writeable "git@github.com:$BUILD_REPOSITORY_ID.git"
    git config core.sshCommand "ssh -i github.key"
    git config user.name "BrewTestBot"
    git config user.email "homebrew-test-bot@lists.sfconservancy.org"
}

setupEnvironment
setupTap

case "$1" in
    test)
        sudo xcode-select --switch /Applications/Xcode_10.1.app/Contents/Developer
        brew test-bot --bintray-org="$BINTRAY_ORG" \
            --root-url=https://dl.bintray.com/$BINTRAY_ORG/$BINTRAY_REPO \
            --tap=rtimush/test-tap \
            --verbose \
            --no-pull \
            --junit \
            $CI_MODE

        if compgen -G "*.bottle.*" > /dev/null; then
            mv *.bottle.* "$BUILD_ARTIFACTSTAGINGDIRECTORY/"
        fi
        ;;

    upload)
        if compgen -G "*.bottle.*" > /dev/null; then
            brew bottle --write --merge *.bottle.json
            for f in *.bottle.json; do
                uploadBottle "$f"
            done
        fi
        setupGit
        git merge origin/master -m "Merge updated bottles"
        git log --graph --oneline --decorate
        git push origin-writeable HEAD:master
        publishBottles
        git push origin-writeable HEAD:staging
        ;;

esac