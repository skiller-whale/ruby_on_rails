FROM ruby:2.6.0-alpine
RUN apk update && apk add --no-cache build-base git libxml2-dev libxslt-dev nodejs sqlite-dev tzdata yarn

RUN mkdir /src
WORKDIR /src

RUN gem install bundler -v 1.17.2
RUN gem install rake -v 13.0.0
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

COPY package.json package.json
COPY yarn.lock    yarn.lock
RUN yarn install

COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
