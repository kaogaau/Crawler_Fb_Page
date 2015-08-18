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
  #time_zero = Time.at(0)
  #time_new_append = Time.at(1001)
  #time_care = Time.now - 60 * 60 * 24 * 30 # only fetch posts within 30 days
  time_care = Time.new(2010, 1, 1) # only fetch posts after a specificed day
  until $leave
    total_update_time = 0
    total_add_new_posts_time = 0
    total_add_old_posts_time = 0
    need_updated_pages = myfb.db_obtain_pages(:limit => 100 ,:update_interval => 60)
    if need_updated_pages.size == 0
      puts "目前沒有需要更新之資料..."
      until need_updated_pages.size > 0
          need_updated_pages = myfb.db_obtain_pages(:limit => 100 ,:update_interval => 60)
      end
    end
    need_updated_pages.each { |page| # pick up pages should be updated
      #add_new_posts
      page_add_new_posts_time = myfb.db_add_new_posts(page['_id'],page['doc']['name'],page['latest_post_time'])
      total_add_new_posts_time += page_add_new_posts_time if page_add_new_posts_time.class == Float
      next if $leave
      #add_old_posts
      page_add_old_posts_time = myfb.db_add_old_posts(page['_id'],page['doc']['name'],page['oldest_post_time']) if page['oldest_post_time'] > time_care && page['check_old_posts']
      total_add_old_posts_time += page_add_old_posts_time if page_add_old_posts_time.class == Float
      next if $leave
    }
    need_updated_pages.each{|page|
      #update_posts
      page_update_time = myfb.db_update_posts_faster(page['_id'],page['doc']['name'])
      total_update_time += page_update_time if page_update_time.class == Float
      next if $leave
    }
    File.open("./timelog.txt", "a") { |output|  
      output.puts "完成全部粉絲團新文章增加[耗時#{total_add_new_posts_time}秒]"
      output.puts "完成全部粉絲團舊文章增加[耗時#{total_add_old_posts_time}秒]"
      output.puts "完成全部粉絲團文章更新[耗時#{total_update_time}秒]"
    }
    #$leave = true
      #1.times { 
      #next if $leave
      #myfb.db_update_posts_faster('143269825688316','媽媽餵mamaway孕婦裝.哺乳衣')
     #}
  end
end

# Main Process begins
begin
  time_start = Time.now
  File.open("./fb_page_status.txt","a+") do |output|
    output.puts "Start Crawler at #{time_start}"
  end
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
  File.open("./fb_page_status.txt","a+") do |output|
    output.puts "Stop Crawler at #{time_end}"
  end
end
