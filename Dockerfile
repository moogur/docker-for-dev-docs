# Set ruby version
ARG ARG_RUBY_VERSION=2.7.7-alpine

# First stage to build
FROM ruby:${ARG_RUBY_VERSION} as builder

WORKDIR /devdocs

RUN apk add git && \
  cd / && \
  git clone -b main --depth 1 https://github.com/freeCodeCamp/devdocs.git

# Second stage to run
FROM ruby:${ARG_RUBY_VERSION}

ENV LANG=C.UTF-8
ENV ENABLE_SERVICE_WORKER=true

WORKDIR /devdocs

COPY --from=builder /devdocs /devdocs

RUN apk --update add nodejs build-base libstdc++ gzip git zlib-dev libcurl && \
    export LANG= && \
    gem install bundler && \
    bundle install --system --without test && \
    thor docs:download --all && \
    thor assets:compile && \
    apk del gzip build-base git zlib-dev && \
    rm -rf /var/cache/apk/* /tmp ~/.gem /root/.bundle/cache \
    /usr/local/bundle/cache /usr/lib/node_modules

EXPOSE 9292
CMD rackup -o 0.0.0.0
