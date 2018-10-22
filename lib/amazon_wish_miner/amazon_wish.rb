class AmazonWish

  def self.parse_wishes_from_pages(page_responses)
    list_items = self.list_items_from_response(page_responses)
    wish_ids = self.draps_from_list_items(list_items)
    # wishes_from_ids(wish_ids)
  end

  def self.list_items_from_response(page_responses)
    page_responses.each_with_object(Array.new) do |response, list_items|
      page = Nokogiri::HTML(response)
      page.css('ul#g-items li').each do |li|
        list_items << li
      end
    end
  end

  def self.draps_from_list_items(list_items)
    list_items.each_with_object(Array.new) do |li, wish_ids|
      drap = li['data-reposition-action-params']
      wish_ids << external_id_from_drap(drap)
    end
  end

  def self.external_id_from_drap(drap)
    attrs = drap.split(',')
    attr_substrings = attrs.map { |elem| elem.split(':') }
    ied_attr = attr_substrings.find { |ss| ss.include?("{\"itemExternalId\"")}
    id_string = ied_attr.last
    ids_arr = id_string.split('|')
    ids_arr.first
  end

  # parsing item info from the item's own url rather than from the wishlist
  #=> means that we can reuse the method below to scrape item info

  def self.wishes_from_ids
  end

end
