FROM ruby:2.3.8

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:1.17.3
RUN bundle install

COPY . .