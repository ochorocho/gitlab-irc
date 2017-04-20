require_relative 'test_helper'
require_relative '../lib/message_formatter'

describe MessageFormatter do
  def setup
    MessageFormatter.stub :short_url, 'http://tinyurl.com/myrk6wj' do
      @messages = MessageFormatter.messages(IO.read('test/support/commit_advanced.json'))
    end
  end

  it 'must return the correct number of messages' do
    @messages.size.must_equal 2, 'wrong number of returned messages'
  end

  it 'must contain the correct repo name' do
    @messages.each { |msg| msg.include?('server-administration'.capitalize).must_equal true, "Wrong repo name" }
  end

  it 'must contain the correct git branch' do
    @messages.each { |msg| msg.include?('(master)').must_equal true, 'wrong git branch' }
  end

  it 'must contain short urls' do
    @messages.each { |msg| msg.end_with?('http://tinyurl.com/myrk6wj').must_equal true, "No short URL  ------- #{msg.to_s}" }
  end

  it 'must contain the correct authors' do
    @messages[0].include?('Your Name').must_equal true, 'Wrong author for commit #1'
    @messages[1].include?('Your Name').must_equal true, 'Wrong author for commit #2'
  end

  it 'must contain the correct commit message' do
    @messages[0].include?('FIRST COMMIT').must_equal true, 'Wrong ci message for commit #1'
    @messages[1].include?('SECOND COMMIT').must_equal true, 'Wrong ci message for commit #2'
  end
end
