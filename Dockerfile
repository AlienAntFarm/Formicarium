FROM alpine:3.5

ARG GOPATH=/tmp/go
ARG ANTHIVE=github.com/alienantfarm/anthive
ARG ANTHIVE_P=${GOPATH}/src/${ANTHIVE}

COPY colony/src/${ANTHIVE} ${ANTHIVE_P}
RUN apk add --no-cache -t buildeps go git make musl-dev \
		&& mkdir -p ${GOPATH}
		&& cd ${ANTHIVE_P} && go get ./... \
		&& go build -ldflags '-w -s' -o /usr/local/bin/anthive ${ANTHIVE} \
		&& rm -rf ${GOPATH} \
		&& apk del buildeps

ENV ANTHIVE_CONFIG /etc/anthive/config.json
COPY assets/config.json ${ANTHIVE_CONFIG}
CMD ["/usr/local/bin/anthive"]
