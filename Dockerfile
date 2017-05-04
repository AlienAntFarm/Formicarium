FROM alpine:3.5

ENV ANTHIVE github.com/alienantfarm/anthive
ENV GOPATH /tmp
COPY colony/src/${ANTHIVE} ${GOPATH}/src/${ANTHIVE}

RUN apk add --no-cache -t buildeps go make musl-dev \
		&& go build -ldflags '-w -s' -o /usr/local/bin/anthive ${ANTHIVE} \
		&& rm -rf /tmp/anthive \
		&& apk del buildeps

ENV ANTHIVE_CONFIG /etc/anthive/config.json
COPY assets/config.json ${ANTHIVE_CONFIG}
CMD ["/usr/local/bin/anthive"]
