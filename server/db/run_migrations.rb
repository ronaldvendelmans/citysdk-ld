#!/usr/bin/env ruby

require 'json'

dbconf = JSON.parse(File.read('../config.json'))

database = "postgres://#{dbconf['db_user']}:#{dbconf['db_pass']}@#{dbconf['db_host']}/#{dbconf['db_name']}"

if ARGV[0] then
    command = "sequel -m migrations -M #{ARGV[0]} #{database}"
else
    command = "sequel -m migrations #{database}"
end

print `#{command}`
