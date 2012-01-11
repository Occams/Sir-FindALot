#!/bin/sh
touch "cronjob_stat_down_worked"
bundle exec rails runner "Parkingramp.stat_down"
