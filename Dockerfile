FROM ruby:3.4.4

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "app.rb"]
