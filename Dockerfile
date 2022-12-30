FROM ruby:3.2.0-alpine AS base
ARG BUNDLER_VERSION=2.4.1
ARG BUNDLE_WITHOUT="development:test"
ARG BASE_PACKAGES="tz git vim curl"
ARG BUILD_PACKAGES="build-base sqlite"
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
RUN apk add --no-cache ${BASE_PACKAGES}
RUN mkdir /app
WORKDIR /app
RUN gem install bundler -N -v ${BUNDLER_VERSION}
RUN git config --global --add safe.directory /app

FROM base AS builder
RUN apk add --no-cache ${BUILD_PACKAGES}

FROM builder AS gems
COPY Gemfile Gemfile.lock /app/
RUN bundle install

FROM base AS app
WORKDIR /app
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY . .
