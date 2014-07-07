#!/usr/bin/env ruby

require 'twitter_ebooks'
require 'probability'

# This is an example bot definition with event handlers commented out
# You can define as many of these as you like; they will run simultaneously

Ebooks::Bot.new("grampa_OFFICIAL") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV['CONSUMER_KEY']
  bot.consumer_secret = ENV['CONSUMER_SECRET']
  bot.oauth_token = ENV['OAUTH_TOKEN']
  bot.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']

  model = Ebooks::Model.load("model/grampa_OFFICIAL.model")

  def make_response(tweet, meta)
    meta[:reply_prefix] + model.make_response(tweet[:text], 130)
  end

  bot.on_message do |dm|
    # Reply to a DM
    # bot.reply(dm, "secret secrets")
  end

  bot.on_follow do |user|
    # Follow a user back
    bot.follow(user[:screen_name])
  end

  bot.on_mention do |tweet, meta|
    bot.reply(tweet, make_response(tweet, meta))
  end

  bot.on_timeline do |tweet, meta|
    # Reply to a tweet in the bot's timeline
    1.in(10) do
      bot.reply(tweet, make_response(tweet, meta))
    end
  end

  bot.scheduler.every ENV['TWEET_INTERVAL'] do
    statement = model.make_statement()
    bot.tweet(statement)
  end
end
