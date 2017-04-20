require_relative 'message_formatter'
require 'fileutils'
require 'redis'
require 'sinatra'
require 'yaml'

config = YAML.load_file(File.join('config', 'config.yml'))

set :port, config['web']['port']
set :bind, config['web']['bind']

post '/commit' do

   # redis = Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])
   # /var/run/redis/redis.sock
   redis = Redis.new(:path => "#{config['redis']['socket']}")
   messages = MessageFormatter.messages(request.body.read)

   msg_file = File.join(File.dirname(__FILE__), '../tmp/msg.txt')
   if !File.file?(msg_file)
       File.new(msg_file, "w")
   end

   # TRIM STRINGS TO COMPARE
   contents = File.read(msg_file)
   contents.to_s
   contents.strip!

   current_msg = messages.to_s
   current_msg.strip!

   # CHECK IF PREV MSG IS EQUAL TO THE CURRENT, IF YES DO NOT SEND IT - IN CASE GITLAB TRIGGERS HOOK TWICE
   if contents != current_msg
     messages.each { |msg|
          redis.rpush("#{config['redis']['namespace']}:messages", "#{msg}")
      }
   end

  File.truncate(msg_file, 0)
  File.write(msg_file, "#{current_msg}")

  redis.quit
end
