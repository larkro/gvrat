app:	## Run the sinatra app
	rackup

reek:   ## Reek gvrat_parser
	reek app.rb

lint:	## Lint things
	make erblint
	make standardrb

docker:	## Build docker image
	docker build -t mccc/gvrat .

erblint:	## Lint erb/html, erblint views/*
	erblint views/*

standardrb: ## Lint ruby code, standardrb app.rb 
	standardrb app.rb

help:   ## Display this output.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean help app reek lint erblint standardrb
.DEFAULT_GOAL := help
