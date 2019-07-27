#!/usr/bin/env bash

set -euxo pipefail

#
# Required environment variables:
#   TRAVIS_REPO_SLUG                     - org/repo
#   TRAVIS_PULL_REQUEST                  - pull request number, defined for PR builds only
#   TRAVIS_BRANCH                        - pull request target branch, defined for PR builds only
#   BINTRAY_ORG (optional)               - bintray organization name, defaults to git organization name
#   BINTRAY_REPO (optional)              - bintray repository name, defaults to bottles-${TAP_SHORT_NAME}
#   BINTRAY_USER (optional)              - bintray user name, defaults to BINTRAY_ORG
#   BINTRAY_KEY                          - bintray API key
#   GITHUB_DEPLOY_KEY                    - SSH key with (\n can represent a newline, as Azure Pipelines do not support multiline variables)
#

setupEnvironment() {
    if [[ -n "${TRAVIS_PULL_REQUEST:-}" ]]; then
        export GIT_PREVIOUS_COMMIT=$(git rev-parse --verify "origin/$TRAVIS_BRANCH")
        export GIT_COMMIT=$(git rev-parse --verify "HEAD^2")
        CI_MODE=--ci-pr
    else
        export GIT_PREVIOUS_COMMIT=$(git rev-parse --verify origin/master)
        export GIT_COMMIT=$(git rev-parse --verify HEAD)
        CI_MODE=--ci-testing
    fi
    export HOMEBREW_NO_ANALYTICS=1
    REPO_NAME="${TRAVIS_REPO_SLUG#*/}"
    ORG_NAME="${TRAVIS_REPO_SLUG%/*}"
    TAP_SHORT_NAME="${REPO_NAME#homebrew-}"
    TAP_NAME="$ORG_NAME/$TAP_SHORT_NAME"
    BINTRAY_ORG="${BINTRAY_ORG:-${ORG_NAME}}"
    BINTRAY_REPO="${BINTRAY_REPO:-bottles-${TAP_SHORT_NAME}}"
    BINTRAY_USER="${BINTRAY_USER:-${BINTRAY_ORG}}"
    unset TF_BUILD
    # https://github.com/Homebrew/brew/issues/5561
    rm -rf /usr/local/Homebrew/Library/Homebrew/vendor/bundle/ruby/2.3.0/
    brew vendor-install ruby

    brew update
}

setupTap() {
    local tap="$(brew --repo)/Library/Taps/$TRAVIS_REPO_SLUG"
    mkdir -p "$(dirname "$tap")"
    sudo ln -s "$PWD" "$tap"
}

uploadBottle() {
    local BOTTLE_JSON="$1"
    local BOTTLE_LOCAL_FILENAME="$(jq -r '.[].bottle.tags[].local_filename' "$BOTTLE_JSON")"
    local BOTTLE_FILENAME="$(jq -r '.[].bottle.tags[].filename' "$BOTTLE_JSON")"
    local BOTTLE_REPOSITORY="$(jq -r '.[].bintray.repository' "$BOTTLE_JSON")"
    local BOTTLE_PACKAGE="$(jq -r '.[].bintray.package' "$BOTTLE_JSON")"
    local BOTTLE_VERSION="$(jq -r '.[].formula.pkg_version' "$BOTTLE_JSON")"
    jfrog bt upload "${BOTTLE_LOCAL_FILENAME}" "${BINTRAY_ORG}/${BOTTLE_REPOSITORY}/${BOTTLE_PACKAGE}/${BOTTLE_VERSION}"
}

setupGit() {
    (
        set +x
        echo $GITHUB_DEPLOY_KEY | sed 's/\\n/\
/g' > github.key
    )
    chmod 0600 github.key
    mkdir -p ~/.ssh
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    git remote add origin-writeable "git@github.com:$TRAVIS_REPO_SLUG.git"
    git config core.sshCommand "ssh -i github.key"
    git config user.name "BrewTestBot"
    git config user.email "homebrew-test-bot@lists.sfconservancy.org"
}

setupEnvironment
setupTap

case "$1" in
    build)
        brew test-bot --bintray-org="$BINTRAY_ORG" \
            --root-url="https://dl.bintray.com/$BINTRAY_ORG/$BINTRAY_REPO" \
            --tap="$TAP_NAME" \
            --verbose \
            --no-pull \
            --junit \
            $CI_MODE
        if [[ -z "${TRAVIS_PULL_REQUEST:-}" ]]; then
            if compgen -G "*.bottle.*" > /dev/null; then
                for f in *.bottle.json; do
                    uploadBottle "$f"
                done
            fi
        fi
        ;;

    upload)
        if compgen -G "*.bottle.*" > /dev/null; then
            setupGit
            brew bottle --write --merge *.bottle.json
            for f in *.bottle.json; do
                uploadBottle "$f"
            done
            git merge origin/master -m "Merge updated bottles"
            git push --atomic origin-writeable HEAD:master HEAD:staging && publishBottles
        fi
        ;;

esac
