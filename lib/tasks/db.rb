require 'heroku'
require 'heroku/command'
require 'heroku/command/db'
require 'taps'

namespace :db do
  desc 'Pull and anonymize'
  task :pullanon
    heroku = Heroku::Client.new('heroku@clixtr.com','cb9a36285bf5257f')
    info = heroku.database_session('picbounce')
    opts = {:indexes_first => true, :database_url => ENV['DATABASE_URL'], :default_chunksize => 1000, :remote_url => info['url'], :session_uri => info['session'], :resume => false}
    opts[:remote_url].gsub!('taps3','taps19')
    
    ENV["NO_DUMP_MARSHAL_ERRORS"] = "YES"

    Taps::Pull.new(opts[:database_url], opts[:remote_url], opts).run
  end
end
