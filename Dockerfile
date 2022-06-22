FROM golang:1.18.3-alpine AS gcsfuse
RUN apk add --no-cache git
ENV GOPATH /go
RUN go install github.com/googlecloudplatform/gcsfuse@v0.41.2


FROM alpine:3.16.0
RUN apk add --no-cache ca-certificates fuse openssh sudo samba samba-libs samba-common-tools micro xclip
COPY --from=gcsfuse /go/bin/gcsfuse /usr/local/bin
COPY entrypoint.sh /

WORKDIR /
ENV TERM=xterm-256color

ENTRYPOINT ["sh", "/entrypoint.sh"]