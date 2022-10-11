VERSION 0.6


COPY_SOURCECODE:
    COMMAND
    COPY "./ci" "./ci"
    COPY "./go.mod" "./go.mod"
    COPY "./src" "./src"


SAVE_OUTPUT:
    COMMAND
    SAVE ARTIFACT "starling-bank-technical-challenge" AS LOCAL "starling-bank-technical-challenge"


golang-base:
    FROM golang:1.19
    WORKDIR /tmp/starling-bank-technical-challenge
    ENV GOPROXY=direct
    ENV CGO_ENABLED=0
    ENV GOOS=linux
    ENV GOARCH=amd64


check-formatting:
    FROM +golang-base
    DO +COPY_SOURCECODE
    RUN ./ci/check-formatting.sh


fix-formatting:
    FROM +golang-base
    DO +COPY_SOURCECODE
    RUN ./ci/fix-formatting.sh
    SAVE ARTIFACT "./src" AS LOCAL "./src"


linting:
    FROM +golang-base
    RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.0
    DO +COPY_SOURCECODE
    RUN ./ci/linting.sh


compiling-linux-amd64:
    FROM +golang-base
    DO +COPY_SOURCECODE
    RUN ./ci/compiling.sh
    DO +SAVE_OUTPUT


compiling-darwin-amd64:
    FROM +golang-base
    ENV GOOS=darwin
    DO +COPY_SOURCECODE
    RUN ./ci/compiling.sh
    DO +SAVE_OUTPUT
