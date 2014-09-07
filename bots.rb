#!/usr/bin/env ruby

require 'twitter_ebooks'
require 'probability'

Ebooks::Bot.new("grampa_OFFICIAL") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV['CONSUMER_KEY']
  bot.consumer_secret = ENV['CONSUMER_SECRET']
  bot.oauth_token = ENV['OAUTH_TOKEN']
  bot.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']

  model = Ebooks::Model.load("model/grampa_OFFICIAL.model")

  bot.on_follow do |user|
    # Follow a user back
    bot.scheduler.in '10s' do
      bot.follow(user[:screen_name])
    end
  end

  bot.on_mention do |tweet, meta|
    # Unfollow if they ask me to
    if tweet[:text].downcase.include?('unfollow')
      bot.twitter.unfollow(tweet[:user][:screen_name])
    else
      response = meta[:reply_prefix] + model.make_response(tweet[:text], 130)
      bot.scheduler.in '10s' do
        bot.reply(tweet, response)
      end
    end
  end

  bot.on_timeline do |tweet, meta|
    # Reply to a tweet in the bot's timeline
    1.in(100) do
      response = meta[:reply_prefix] + model.make_response(tweet[:text], 130)
      bot.scheduler.in '10s' do
        bot.reply(tweet, response)
      end
    end
  end

  bot.scheduler.every ENV['TWEET_INTERVAL'] do
    statement = model.make_statement()
    bot.tweet(statement)
  end
end
