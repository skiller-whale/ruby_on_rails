# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# alpine 3.19 + sqlite3 gem has issues: https://github.com/sparklemotion/sqlite3-ruby/issues/434
ARG RUBY_VERSION=3.2.3
FROM registry.docker.com/library/ruby:$RUBY_VERSION-alpine3.18 as base

RUN apk update && apk add --no-cache build-base git  shared-mime-info sqlite-dev tzdata gcompat


# Rails app lives here
WORKDIR /src

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["sh", "-c", "rake db:prepare && bundle exec puma -C config/puma.rb"]
