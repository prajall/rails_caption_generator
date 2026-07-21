ARG RUBY_VERSION=3.3.12
FROM ruby:$RUBY_VERSION-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    git \
    curl \
    libvips \
    libyaml-dev \
    pkg-config \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b 0.0.0.0"]