#!/usr/bin/env ruby
require './fb_page_crawler'
#require './config/fb_config'
require './config_tmp.rb'
require 'time'
require 'mongo'
require 'json'
include Mongo
def mongo_link(mongo_host,mongo_port,mongo_dbname,mongo_user_name,mongo_user_pwd)
  client = MongoClient.new(mongo_host, mongo_port)
  client.add_auth(mongo_dbname, mongo_user_name, mongo_user_pwd, mongo_dbname)
  mongo_db = client[mongo_dbname] 
end
def main
  myfb = FbPageCrawler.new
  myfb.app_id = APP_ID
  myfb.app_secret = APP_SECRET
  #myfb.access_token = APP_TOKEN # set access_token if you have a valid one
  myfb.fb_get_token!
  mongo_db = mongo_link('127.0.0.1',27017,'fb_rawdata','admin','12345')
  coll = mongo_db['pages_list']
  pages_list = JSON.parse(coll.find_one().to_json)
  pages_list.delete("_id")
  pages_list.each do |page_id,page_name|
    page_id = page_id.strip
    #puts "Adding #{page_name} : #{page_id} into page database"
    myfb.db_add_page(page_id,page_name) # Add a page into database
  end
end

# Main Process begins
begin
  time_start = Time.now
  puts "Start: #{time_start}"
  puts "========================================"
  main
rescue => ex
  $stderr.puts ex.message
  $stderr.puts ex.backtrace.join("\n")
ensure
  time_end = Time.now
  puts "========================================"
  puts "End: #{time_end}"
  puts "Time cost: #{time_end - time_start}"
end
