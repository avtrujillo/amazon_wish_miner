class AmazonWish

  attr_reader :title, :id

  def initialize(id, title)
    @title = title
    @id = id
  end

  def url
    "https://www.amazon.com/dp/#{@id}"
  end

  def self.parse_wishes_from_pages(page_responses)
    list_items = self.list_items_from_response(page_responses)
    wish_ids = self.draps_from_list_items(list_items)
    wishes_from_ids(wish_ids)
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

  def self.wishes_from_ids(ids)
    ids.map do |id|
      self.item_from_id(id)
    end
  end

  def self.item_from_id(id)
    item_url = 'https://www.amazon.com/dp/' + id
    response = RestClient.get(item_url)
    page = Nokogiri::HTML(response)
    title = get_title_from_page(page)
    # not a typo, css selectors are
    #=> case sensetive, and we need to capture e.g. both "productTitle" and "ebookProductTitle"
    # price = page.css('priceblock_ourprice')
    # TODO: parse prices
    # description = parse_feature_bullets(page.css('div#feature-bullets'))
    # TODO: get description parsing to work for different types of items
    AmazonWish.new(id, title)
  end

  def self.parse_feature_bullets(feature_bullets_div)
    bullets = feature_bullets_div.css('ul li')
  end

  def self.get_title_from_page(page)
    span_title = page.css('span[id$="roductTitle"]').children.text.strip
    return span_title unless span_title == ""
    meta_title = page.css('meta[name="title"]')[0].attribute('content').value
  end

  def self.trim_title(untrimmed_title)
    chars = untrimmed_title.chars
    chars.drop_while(&TITLE_TRIMMER).reverse.drop_while(&TITLE_TRIMMER).reverse.join
  end

end
