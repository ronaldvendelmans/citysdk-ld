#!/usr/local/bin/ruby

require 'json'

dbconf = JSON.parse(File.read('../db.json'))

database = "postgres://#{dbconf['db_user']}:#{dbconf['db_pass']}@#{dbconf['db_host']}/#{dbconf['db_name']}"
command = "sequel -m migrations #{database}"

system command