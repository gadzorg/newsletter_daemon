# NewsletterDaemon Gadz.org
[![Build Status](https://travis-ci.org/gadzorg/newsletter_daemon.svg?branch=master)](https://travis-ci.org/gadzorg/newsletter_daemon) [![Code Climate](https://codeclimate.com/github/gadzorg/newsletter_daemon/badges/gpa.svg)](https://codeclimate.com/github/gadzorg/newsletter_daemon) [![Test Coverage](https://codeclimate.com/github/gadzorg/newsletter_daemon/badges/coverage.svg)](https://codeclimate.com/github/gadzorg/newsletter_daemon/coverage) [![Dependency Status](https://gemnasium.com/badges/github.com/gadzorg/newsletter_daemon.svg)](https://gemnasium.com/github.com/gadzorg/newsletter_daemon)

Receive orders over RabbitMQ to manage Mailchimp lists

## Setup
After cloning this repository ,install dependencies with `bundle install`

Set the Configuration files `/config/config.yml`, you can use `/config/config.template.yml`as an helper.

## Usage
Just run `/bin/worker` as an executable to start the bot. Logs are printed in STDOUT

To change environment use the environment variable `RAKE_ENV` or `NLD_ENV`. Accepted values are : `development`,`test`,`production`

To stop the bot use CTRL+C or send an interruption signal SINGINT to the process  with `kill -2`

## Behaviour

All received message must be valid with Gadz.org SOA Message Format in order to be processed

This bot subscribes to the following routing keys :
 - `request.newsletter.update`


## ToDo
 - Multiple Mailchimp accounts
