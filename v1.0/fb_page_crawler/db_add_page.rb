class FbPageCrawler
  # Add a new page into databse via page_name or page_id
  def db_add_page(page_id,page_name)
    raise 'page_id can not be empty' if page_id.nil? || page_id.empty?
    time_update = Time.now
    page_data = fb_get_page(page_id)
    raise 'No available data retrieved' unless page_data.has_key?('id')
    # Check if the page is in database
    coll = @mongo_db[TABLE_PAGES]
    #raise "Page \"#{page_id}\" has been in the database" unless coll.find('_id' => page_data['id']).first.nil?
    # Retrieve some posts from the target page
    page_posts = fb_get_posts(page_id, :until => time_update.to_i, :limit => 3)
    latest_post_time = page_posts.empty? ? time_update : Time.parse(page_posts.first.fetch('created_time'))
    oldest_post_time = page_posts.empty? ? time_update : Time.parse(page_posts.last.fetch('created_time'))
    
    if coll.find('_id' => page_data['id']).first.nil?
    $stderr.puts "db_add_page: adding page \"#{page_name}\" : \"#{page_id}\" into the database" 
    page_data = {'_id' => page_data['id'],
                 'latest_post_time' => latest_post_time,
                 'oldest_post_time' => oldest_post_time,
                 'last_updated' => time_update,
                 'check_new_posts' => true,
                 'check_old_posts' => true,
                 'doc' => page_data}
    #write page data into mongo databse
    coll.insert(page_data)
    #db_insert_data(coll, page_data)
    # REVIEW: some posts may get lost if posts inserting fails

    #write posts data into mongo database if any post retrieved
    coll = @mongo_db[TABLE_POSTS]
    page_posts.each { |post|
      #post = {"shares" : {"count" : 0}}.merge(post)
      #post['likes'].delete("paging")
      #post['comments'].delete("paging")
      post_data = {'_id' => post['id'],
                   'page_id' => page_data['_id'],
                   'post_time' => Time.parse(post['created_time']),
                   'last_updated' => time_update,
                   #'last_updated' => Time.at(100), # set a small value so that it will be updated quickly
                   'doc' => post}
      #coll.insert(post_data)
      db_insert_data(coll, post_data)
      # update comments
      #db_update_post_comments(post['id'])
      # update likes
      #db_update_post_likes(post['id'])
    }
    else
      $stderr.puts "db_add_page: updateing page \"#{page_name}\" : \"#{page_id}\" into the database"
      coll.update({'_id' => page_data['id']}, {'$set'=> {'doc' => page_data}})
    end

  rescue => ex
    @@logger.error ex.message
    @@logger.debug ex.backtrace.join("\n")
  end
end
