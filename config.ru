require 'bundler'
Bundler.require
require './part4'

set :title, "Just Do It!"
set :fonts, %w[ Anton ]

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

run Sinatra::Application
