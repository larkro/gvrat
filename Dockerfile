# Steg 1: Byggsteg
FROM ruby:3-alpine AS builder

# Installera beroenden för att bygga applikationen
RUN apk add --no-cache build-base libxml2-dev libxslt-dev postgresql-dev git

# Sätt arbetskatalog
WORKDIR /app

# Kopiera Gemfile och Gemfile.lock
COPY Gemfile Gemfile.lock .ruby-version ./

# Installera Bundler
RUN gem install bundler

# Installera beroenden
RUN bundle config set without 'development test' && \
    bundle install 

# Kopiera resten av applikationen
COPY . .

# Steg 2: Produktionssteg
FROM ruby:3-alpine

# Installera runtime beroenden
RUN apk add --no-cache libxml2 libxslt postgresql-libs bash

# Lägg till en icke-root användare
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Sätt arbetskatalog
WORKDIR /app

# Kopiera den byggda applikationen från builder-steget
COPY --from=builder /app /app

# Ändra äganderätt för att matcha den icke-root användaren
RUN chown -R appuser:appgroup /app

# Byt till icke-root användare
USER appuser

# Exponera rätt port (justera vid behov)
EXPOSE 4567

# Starta applikationen
CMD ["ruby", "app.rb"]
