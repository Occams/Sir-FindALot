#!/bin/sh
touch "cronjob_stat_pack_worked"
bundle exec rails runner "Stat.pack!"
