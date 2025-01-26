require "spec_helper"

RSpec.describe "base" do
  it "should reset the database each time"

  # CREATE TABLE `redis_0` (`key` varchar(255), `value` varchar(255), `timestamp` integer);
  # CREATE TABLE learned ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, message TEXT, server VARCHAR(255), channel VARCHAR(255) , message_id INTEGER);
  # CREATE TABLE messages ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, username VARCHAR(255), message TEXT , server VARCHAR(255), channel VARCHAR(255), `message_id` integer);
  # CREATE TABLE train_accidents ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, server VARCHAR(255), channel VARCHAR(255);
end
