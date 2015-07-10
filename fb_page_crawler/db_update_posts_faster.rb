class FbPageCrawler
  # Update some posts within database
  # :update_threshold indicates a threshold and only posts newer then it will be updated
  # :update_interval indicates an interval to avoid frequency facebook querying
  def db_update_posts_faster(opts={})
    now_1 = Time.now
    find_opts = {
      #:newborn => false,
      #:update_threshold => @update_threshold,
      #:update_interval => @update_interval,
      #:limit => 3,
      :sort => ['post_time', :ascending], # use :ascending to retrieve outdated posts
      :fields => {'doc' => 1,'post_time' => 1}
      #:fields => {'updated_time' => 1, 'doc.likes.summary.total_count' => 1, 'doc.shares.count' => 1,'post_time' => 1}
    }.merge opts # TODO: rewrite opts with ruby 2.0 features
    arr = Array.new(0)
    find_target = {"page_id"=>'209251989898'}
    coll = @mongo_db[TABLE_POSTS]
    posts = coll.find(find_target, find_opts).to_a
    t_new = posts.last.fetch('post_time')
    t_old = posts.first.fetch('post_time')
    puts "#{t_old} to #{t_new}"
    now_2 = Time.now
    new_post = fb_get_posts('209251989898',{:limit => 300,:since=>t_old,:until=>t_new})
    #$stderr.puts "db_update_posts: #{posts.size} posts are updated" if posts.size > 0
    puts "#{new_post.last.fetch('created_time')} to #{new_post.first.fetch('created_time')}"
    now_3 = Time.now
    posts.each do |ele|
      arr << ele['doc']
    end
    new_post.each do |ele|
            ele['likes'].delete("paging")
            ele['comments'].delete("paging")
    end
    now_4 = Time.now
    #puts new_post.first
    #puts arr.first
    #change_post = new_post - arr
    #puts new_post.size
    #puts arr.size
    #puts change_post.size
    puts now_2 - now_1
    puts now_3 - now_2
    puts now_4 - now_3
  rescue => ex
    @@logger.error ex.message
    @@logger.debug ex.backtrace.join("\n")
  end
end
