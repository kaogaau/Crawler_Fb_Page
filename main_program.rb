#!/usr/bin/env ruby
require './fb_page_crawler'
require './config_tmp.rb'
require 'time'

def db_init(myfb, pages)
  pages.each { |e|
    #puts "Adding page \"#{e}\" into database"
    myfb.db_add_page(e)
  }
end

def main
  myfb = FbPageCrawler.new
  myfb.app_id = APP_ID
  myfb.app_secret = APP_SECRET
  myfb.fb_get_token!
  #myfb.access_token = APP_TOKEN # set access_token if you have a valid one

  #page_ids = ['mcdonalds.tw','kfctaiwan','mosburger.tw','PizzaHut.TW',
  #            'pec21c','Dominos.tw','BurgerKingTW','119109161438728']

  # for initialization
  #db_remove(myfb)
  #myfb.db_add_page(page_id) # Add a page into database
  #db_init(myfb, page_ids) # Add pages into database

  $leave = false
#  Signal.trap('INT'){
#    $leave = true
#    puts ' ********** Waitting program to terminate ********** '
#  }

  time_zero = Time.at(0)
  time_new_append = Time.at(1001)
  #time_care = Time.now - 60 * 60 * 24 * 30 # only fetch posts within 30 days
  time_care = Time.new(2010, 1, 1) # only fetch posts after a specificed day
  until $leave
    total_update_time = 0
    myfb.db_obtain_pages(:limit => 100 ,:update_interval => 60).each { |page| # pick up pages should be updated
      puts "Updating #{page['_id']} : #{page['doc']['name']}"
      puts "Checking new posts for #{page['_id']} : #{page['doc']['name']}"
      myfb.db_add_new_posts(page['_id'], page['latest_post_time'])
      #next if $leave
      #if page['oldest_post_time'] > time_care && page['check_old_posts']
       # puts "Checking old posts for #{page['_id']} : #{page['doc']['name']}"
       # myfb.db_add_old_posts(page['_id'], page['oldest_post_time']) 
      #end
      next if $leave
      page_update_time = myfb.db_update_posts_faster(page['_id'],page['doc']['name'])
      puts "\"#{page['doc']['name']}\" : 完成粉絲團文章更新[耗時#{page_update_time}秒]"
      total_update_time += page_update_time if page_update_time.class == Float
    }
    puts "完成全部粉絲團文章更新[耗時#{total_update_time}秒]"
    $leave = true
      #1.times { 
      #next if $leave
      #myfb.db_update_posts_faster('143269825688316','媽媽餵mamaway孕婦裝.哺乳衣')
     #}

=begin
    # update existing posts

    1.times { 
      next if $leave
      myfb.db_update_posts(:update_threshold => 60 * 60 * 2, :update_interval => 60 * 5) 
    }
    # update existing posts
    5.times {
      next if $leave
      myfb.db_update_posts(:update_threshold => 60 * 60 * 24 * 3, :update_interval => 60 * 60 * 2)
    }
    # update existing posts
    1.times {
      next if $leave
      myfb.db_update_posts(:update_threshold => 60 * 60 * 24 * 14, :update_interval => 60 * 60 * 24 * 3)
    }
    # update existing posts
    0.times {
      next if $leave
      myfb.db_update_posts(:update_threshold => 60 * 60 * 24 * 60, :update_interval => 60 * 60 * 24 * 14)
    }
    # update posts just appended recently
    100.times {
      next if $leave
      myfb.db_update_posts(:newborn => true)
    }
=end
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
