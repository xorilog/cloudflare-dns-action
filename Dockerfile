FROM r.j3ss.co/terraform:latest

LABEL "com.github.actions.name"="Cloudflare DNS"
LABEL "com.github.actions.description"="Update or Create DNS record on cloudlfare"
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="orange"

RUN apk add --no-cache \
	git \
	make

COPY terraform /usr/src/terraform
COPY Makefile /usr/src
COPY deploy.sh /usr/local/bin/deploy

WORKDIR /usr/src

ENTRYPOINT ["deploy"]
