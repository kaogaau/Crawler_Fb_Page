class FbPageCrawler
  def db_read_page(page_id)
    raise 'page_id can not be empty' if page_id.nil? || page_id.empty?
    coll = @mongo_db[TABLE_PAGES]
    # Check if the page_id is number id
    if fb_is_numberid?(page_id)
      page = coll.find('_id' => page_id).first
    else
      page = coll.find('doc.username' => page_id).first
    end
      page
  end
end
