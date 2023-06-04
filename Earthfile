VERSION 0.7


COPY_CI_DATA:
    COMMAND
    COPY "./ci" "./ci"
    COPY ".github" ".github"


COPY_METADATA:
    COMMAND
    DO +COPY_CI_DATA
    COPY ".git" ".git"
    COPY "./VERSION" "./VERSION"


rust-base:
    FROM rust:1.70.0


clean-git-history-checking:
    FROM +rust-base
    RUN cargo install clean_git_history
    DO +COPY_METADATA
    ARG from_reference="origin/HEAD"
    RUN ./ci/clean-git-history-checking.sh --from-reference "${from_reference}"


conventional-commits-linting:
    FROM +rust-base
    RUN cargo install conventional_commits_linter
    DO +COPY_METADATA
    ARG from_reference="origin/HEAD"
    RUN ./ci/conventional-commits-linting.sh --from-reference "${from_reference}"


conventional-commits-next-version-checking:
    FROM +rust-base
    RUN cargo install conventional_commits_next_version
    DO +COPY_METADATA
    ARG from_reference="origin/HEAD"
    RUN ./ci/conventional-commits-next-version-checking.sh --from-reference "${from_reference}"


INSTALL_DEPENDENCIES:
    COMMAND
    COPY "go.mod" "go.mod"
    COPY "go.sum" "go.sum"
    RUN go mod download


COPY_SOURCECODE:
    COMMAND
    DO +COPY_CI_DATA
    COPY "./cmd" "./cmd"
    COPY "./api" "./api"


SAVE_OUTPUT:
    COMMAND
    SAVE ARTIFACT "starling-bank-technical-challenge" AS LOCAL "starling-bank-technical-challenge"
    SAVE ARTIFACT "go.sum" AS LOCAL "go.sum"


golang-base:
    FROM golang:1.20.4
    WORKDIR /tmp/starling-bank-technical-challenge
    ENV GOPROXY=direct
    ENV CGO_ENABLED=0
    ENV GOOS=linux
    ENV GOARCH=amd64


check-go-formatting:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/check-go-formatting.sh


sh-formatting-base:
    FROM golang
	RUN go install mvdan.cc/sh/v3/cmd/shfmt@v3.6.0
    DO +COPY_CI_DATA


check-sh-formatting:
    FROM +sh-formatting-base
    RUN ./ci/check-sh-formatting.sh


ubuntu-base:
    FROM ubuntu:22.04
	# https://askubuntu.com/questions/462690/what-does-apt-get-fix-missing-do-and-when-is-it-useful
    RUN apt-get update --fix-missing


yaml-formatting-base:
    FROM +ubuntu-base
    RUN apt-get install wget -y
	RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
    DO +COPY_CI_DATA


check-yaml-formatting:
    FROM +yaml-formatting-base
    RUN ./ci/check-yaml-formatting.sh


check-formatting:
    BUILD +check-go-formatting
    BUILD +check-sh-formatting
    BUILD +check-yaml-formatting


fix-go-formatting:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/fix-go-formatting.sh
    SAVE ARTIFACT "./src" AS LOCAL "./src"


fix-sh-formatting:
    FROM +sh-formatting-base
    RUN ./ci/fix-sh-formatting.sh
    SAVE ARTIFACT "./ci" AS LOCAL "./ci"


fix-yaml-formatting:
    FROM +yaml-formatting-base
    RUN ./ci/fix-yaml-formatting.sh
    SAVE ARTIFACT "./.github" AS LOCAL "./.github"


fix-formatting:
    BUILD +fix-go-formatting
    BUILD +fix-sh-formatting
    BUILD +fix-yaml-formatting

go-linting:
    FROM +golang-base
    RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.53.0
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/go-linting.sh


sh-linting:
    FROM +ubuntu-base
    RUN apt-get install shellcheck -y
    DO +COPY_CI_DATA
    RUN ./ci/sh-linting.sh


github-actions-workflows-linting:
    FROM +golang-base
    RUN go install github.com/rhysd/actionlint/cmd/actionlint@v1.6.24
    DO +COPY_METADATA
    RUN ./ci/github-actions-workflows-linting.sh


linting:
    BUILD +go-linting
    BUILD +sh-linting
    BUILD +github-actions-workflows-linting


check-module-tidying:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/check-module-tidying.sh


fix-module-tidying:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/fix-module-tidying.sh
    SAVE ARTIFACT "go.mod" AS LOCAL "go.mod"
    SAVE ARTIFACT "go.sum" AS LOCAL "go.sum"


compiling-linux-amd64:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/compiling.sh
    DO +SAVE_OUTPUT


compiling-darwin-amd64:
    FROM +golang-base
    ENV GOOS=darwin
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/compiling.sh
    DO +SAVE_OUTPUT


unit-testing:
    FROM +golang-base
    DO +INSTALL_DEPENDENCIES
    DO +COPY_SOURCECODE
    RUN ./ci/unit-testing.sh


releasing:
    FROM +ubuntu-base
    RUN apt-get install wget git -y
    # Install GitHub CLI.
    ENV GH_VERSION=2.30.0
    RUN wget "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz"
    RUN tar -xzvf "gh_${GH_VERSION}_linux_amd64.tar.gz"
    RUN cp "./gh_${GH_VERSION}_linux_amd64/bin/gh" /bin/gh
    # Install Git Cliff.
    ENV GIT_CLIFF_VERSION=1.2.0
    RUN wget "https://github.com/orhun/git-cliff/releases/download/v${GIT_CLIFF_VERSION}/git-cliff-${GIT_CLIFF_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    RUN tar -xzvf "git-cliff-${GIT_CLIFF_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    RUN cp "./git-cliff-${GIT_CLIFF_VERSION}/git-cliff" /bin/git-cliff
    DO +COPY_METADATA
    RUN --secret GH_TOKEN ./ci/releasing.sh
