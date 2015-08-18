class FbPageCrawler
  # Add new posts into databse via page_id
  # page_id should be the number id, not username id
  # latest_time should be Time object
  def db_add_new_posts(page_id, page_name,latest_time, opts={})
    now_1 = Time.now
    puts "\"#{page_name}\" : 進行粉絲團新文章增加..."
    raise 'page_id can not be empty' if page_id.nil? || page_id.empty?
    time_update = Time.now
    # Retrieve new posts from the target page
    page_posts = fb_get_new_posts(page_id, latest_time, {:limit => 300}.merge(opts))
    #puts page_posts
    latest_post_time = page_posts.empty? ? latest_time : Time.parse(page_posts.first.fetch('created_time'))
    latest_post_time = latest_time if latest_post_time < latest_time

    # update page data in mongo databse
    coll = @mongo_db[TABLE_PAGES]
    coll.update({'_id' => page_id}, 
                {'$set' => {'latest_post_time' => latest_post_time, 'last_updated' => time_update}})

    # write posts data into mongo database if any post retrieved
    # REVIEW: the posts will be lost if page_update fails
    coll = @mongo_db[TABLE_POSTS]
    page_posts.each { |post|
      #post = {"shares" => {"count" => 0}}.merge(post)
      #post['likes'].delete("paging")
      #post['comments'].delete("paging")
      post_data = {'_id' => post['id'],
                   'page_id' => page_id,
                   'post_time' => Time.parse(post['created_time']),
                   #'last_updated' => time_update,
                   'last_updated' => Time.at(500), # set a small value so that it will be updated quickly
                   'doc' => post}
      #coll.insert(post_data)
      db_insert_data(coll, post_data)
      #res = coll.update({'_id' => post['id']}, post_data)
      #coll.insert(post_data) if res.has_key?('updatedExisting') && res['updatedExisting'] == false
      #@@logger.debug "db_add_new_posts: post_id=#{post['id']} response:#{res.inspect}"

      # update comments
      #db_update_post_comments(post['id'])
      # update likes
      #db_update_post_likes(post['id'])
    }
    now_2 = Time.now
    $stderr.puts "\"#{page_name}\" : 完成粉絲團新文章增加[#{page_posts.size}篇][耗時#{now_2 - now_1}秒]" #if page_posts.size > 0
    return now_2 - now_1
  rescue => ex
    @@logger.error ex.message
    @@logger.debug ex.backtrace.join("\n")
  end
end
