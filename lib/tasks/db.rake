require 'heroku'
require 'heroku/command'
require 'heroku/command/db'
require 'taps/config'
require 'taps/operation'

    def uri_hash_to_url(uri)
      uri_parts = {
        :scheme   => uri['scheme'],
        :userinfo => userinfo_from_uri(uri),
        :password => uri['password'],
        :host     => uri['host'] || '127.0.0.1',
        :port     => uri['port'],
        :path     => "/%s" % uri['path'],
        :query    => uri['query'],
      }

      URI::Generic.build(uri_parts).to_s
    end

def parse_database_yml
      return "" unless File.exists?(Dir.pwd + '/config/database.yml')

      environment = ENV['RAILS_ENV'] || ENV['MERB_ENV'] || ENV['RACK_ENV']
      environment = 'development' if environment.nil? or environment.empty?

      conf = YAML.load(File.read(Dir.pwd + '/config/database.yml'))[environment]
      case conf['adapter']
        when 'sqlite3'
          return "sqlite://#{conf['database']}"
        when 'postgresql'
          uri_hash = conf_to_uri_hash(conf)
          uri_hash['scheme'] = 'postgres'
          return uri_hash_to_url(uri_hash)
        else
          return uri_hash_to_url(conf_to_uri_hash(conf))
      end
    rescue Exception => ex
      puts "Error parsing database.yml: #{ex.message}"
      puts ex.backtrace
      ""
end


namespace :db do
  desc 'Pull and anonymize'
  task :pullanon do
    heroku = Heroku::Client.new('heroku@clixtr.com','cb9a36285bf5257f')
    info = heroku.database_session('picbounce')
    database_url =  ENV['DATABASE_URL'] || parse_database_yml
    puts "Importing anonomized data to: #{database_url}"
    opts = {:indexes_first => true, :database_url => database_url, :default_chunksize => 1000, :remote_url => info['url'], :session_uri => info['session'], :resume => false}


    opts[:remote_url].gsub!('taps3','taps19') if RUBY_VERSION >= '1.9'
    
    ENV["NO_DUMP_MARSHAL_ERRORS"] = "YES"

    Taps::Pull.new(opts[:database_url], opts[:remote_url], opts).run
  end
end
