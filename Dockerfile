FROM ruby:3.3.6-alpine AS base
ARG BUNDLER_VERSION=2.5.23
ARG BUNDLE_WITHOUT="development:test"
ARG BASE_PACKAGES="tz git vim curl imagemagick ttf-liberation msttcorefonts-installer fontconfig libc6-compat gcompat"
ARG BUILD_PACKAGES="build-base sqlite"
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN apk add --no-cache ${BASE_PACKAGES}
RUN mkdir /app
WORKDIR /app
RUN update-ms-fonts && fc-cache -f
RUN git config --global --add safe.directory /app
RUN gem update --system --no-document && \
    gem install -N bundler -v ${BUNDLER_VERSION}

FROM base AS builder
RUN apk add --no-cache ${BUILD_PACKAGES}

FROM builder AS gems
COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle install

FROM base AS app
WORKDIR /app
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY . .
