class AmazonWish

  def self.parse_wishes_from_pages(page_responses)
    wish_ids = []
    page_responses.each do |response|
      page = Nokogiri::HTML(response)
      lis = page.css('ul#g-items li')
      lis.each do |li|
        drap = li['data-reposition-action-params']
        wish_ids << external_id_from_drap(drap)
      end
    end
    wishes_from_ids(wish_ids)
  end

  def self.list_items_from_response(page_responses)
    page_responses.each_with_object(Array.new) do |response, list_items|
      page = Nokogiri::HTML(response)
      list_items += page.css('ul#g-items li')
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
    ied_attr = attr_substrings.find { |ss| ss.include?("itemExternalId")}
    asin_string = ied_attr.find {|elem| elem.include?("ASIN")}
    id_numbers_string = asin.split(':')[1]
    id_numbers_arr = id_numbers_string.split('|')
    id_numbers_arr.first
  end

end
