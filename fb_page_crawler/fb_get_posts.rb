class FbPageCrawler
  # Return a array of post hashs
  # :since: (now --- :since], should be an Time object
  # :until: (:until --- post), should be an Time object
  # :until should be larger than :since
  # hash keys: id, created_time, updated_time, message, from{id, name}
  def fb_get_posts(page_id, opts={})
    o = {
      :since => nil,
      :until => nil,
      :limit => @page_limit,
      :access_token => @access_token
    }.merge opts # TODO: rewrite opts with ruby 2.0 features
    raise 'page_id can not be empty' if page_id.nil? || page_id.empty?
    query = "/#{page_id}/posts?"
    query << "fields=id,message,created_time,updated_time,from,status_type,type,shares,likes.summary(true),comments.summary(true)" if @apply_fields
    #query = "/#{page_id}/posts?fields=id,message,created_time,updated_time,from&limit=#{o[:limit]}"
    query << "&limit=#{o[:limit]}"
    if o[:since]
      t = o[:since]
      t = Time.parse(t) if t.is_a?(String)
      query << "&since=#{t.to_i}" 
    end
    if o[:until]
      t = o[:until]
      t = Time.parse(t) if t.is_a?(String)
      query << "&until=#{t.to_i}"
    end
    # A valid access_token is required
    query << "&access_token=#{o[:access_token]}"

    @@logger.debug "fb_get_posts: page_id=#{page_id} since=#{o[:since].inspect} until=#{o[:until].inspect}"
    #File.open("./link2.txt", "a+") { |file|  file.puts query}
    data = fb_graph_get(query)
    #puts data
    raise 'No available data retrieved' if data.nil? || data.empty?
    data = JSON.parse(data)
    raise 'No available data retrieved' unless data.has_key?('data')
    result = Array(data['data'])
    #puts result
    result.each { |item| yield item } if block_given? # OPTIMIZE: improve yield performance
    result
    #puts result
    # Collect posts data from a array of fb post hash {'id' => id, 'message' => message, ...}
    # Hash[ data['data'].map{ |item|
    # [item['id'], [item['created_time'], item['updated_time'], item['message']]]
    # } ]
  rescue => ex
    @@logger.error ex.message
    @@logger.debug ex.backtrace.join("\n")
    # Return a empty array
    []
  end
end
