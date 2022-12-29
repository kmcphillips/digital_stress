FROM ruby:3.2.0-alpine AS builder

ARG BUILD_PACKAGES="git build-base sqlite"
RUN apk add --no-cache ${BUILD_PACKAGES}
RUN gem install bundler -N -v 2.4.1

RUN mkdir /app
WORKDIR /app
COPY . .

RUN bundle install --jobs 8 --retry 5

FROM ruby:3.2.0-alpine AS app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app

WORKDIR /app
