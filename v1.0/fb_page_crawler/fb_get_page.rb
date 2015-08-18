class FbPageCrawler
  # Return a array of post hash by a post_id
  # post hash: id, from{id, name}, message, shares{count}, likes{data,count}, created_time
  def fb_get_page(page_id)
    raise 'page_id can not be empty' if page_id.nil? || page_id.empty?
    query = "/#{page_id}?"
    # A valid access_token is required
    query << "&access_token=#{@access_token}"

    data = fb_graph_get(query)
    raise 'No available data retrieved' if data.nil? || data.empty?
    data = JSON.parse(data)
    raise 'No available data retrieved' if data.nil? || data.empty?
    data
  rescue => ex
    @@logger.error ex.message
    @@logger.debug ex.backtrace.join("\n")
    # Return a empty hash
    {}
  end
end
