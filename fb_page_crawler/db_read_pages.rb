class FbPageCrawler
  # Return a array of all pages
  # {'_id', 'doc' => {'name', 'username'}}
  # It seems like db_rerad_pages.rb is not used
  def db_read_pages
    coll = @mongo_db[TABLE_PAGES]
    coll.find({},{}).to_a
  end
end
