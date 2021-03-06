require 'cinch'
require 'yaml'
require 'redis'

$config = YAML.load_file(File.join('config', 'config.yml'))
$stdout.sync = true

class PollingPlugin
  include Cinch::Plugin

  timer $config['irc']['poll_interval'], :method => :timed

  def timed
    socket = $config['redis']['socket']
    redis = Redis.new(:path => "#{socket}")
    key = "#{$config['redis']['namespace']}:messages"
    while redis.llen(key) > 0
      Channel($config['irc']['channel']).send(redis.lpop(key))
    end
    redis.quit
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = $config['irc']['server']
    c.port = $config['irc']['port']
    c.password = $config['irc']['server_password']
    c.channels = [[$config['irc']['channel'], $config['irc']['channel_password']].compact.join(' ')]
    c.nick = $config['irc']['nickname']
    c.realname = $config['irc']['nickname']
    c.messages_per_second = 1
    c.user = $config['irc']['nickname']
    c.plugins.plugins = [PollingPlugin]
    c.verbose = $config['irc']['verbose']
  end
  on :message, /@[Gg]it[Ll]ab [Ii]nfo/ do |m|
    m.reply "#{m.user.nick}, this is the place where we can interact with GitLab!"
  end
  on :message, /@[Gg]it[Ll]ab [Ww]hats [Uu]p/ do |m|
    m.reply "#{m.user.nick}, the sky?"
  end

end

bot.start
