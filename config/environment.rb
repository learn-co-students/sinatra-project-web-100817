require 'bundler/setup'
Bundler.require

require_all('app/')
require_all('lib/')

set :database, {adapter: "sqlite3", database: "db/database.sqlite3"}