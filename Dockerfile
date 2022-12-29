FROM ruby:3.2.0-slim-bullseye AS builder

ARG BUILD_PACKAGES="git vim curl build-essential pkg-config libsqlite3-dev sqlite3"
RUN apt update -qq && apt install -y ${BUILD_PACKAGES}
RUN gem install bundler -N -v 2.4.1

RUN mkdir /app
WORKDIR /app
COPY . .

RUN bundle install --jobs 8 --retry 5

FROM ruby:3.2.0-slim-bullseye AS app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app

WORKDIR /app
