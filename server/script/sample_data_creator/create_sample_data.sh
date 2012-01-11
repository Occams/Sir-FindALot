#!/bin/sh
RAILS_ENV=production bundle exec rails runner script/sample_data_creator/create_sample_data.rb
