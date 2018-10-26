class AmazonWishList

  attr_accessor :id, :wishes

  REVEAL_OPTIONS = [:all, :purchased, :unpurchased].freeze
  SORT_OPTIONS = {date_added: "date-added", title: 'universal-title',
    price_high: 'universal-price-desc', price_low: 'universal-price',
    date_updated: 'last-updated', priority: 'priority'}.freeze

  def initialize(id, wishes)
    @id = id
    @wishes = wishes
  end

  # TODO: https://www.amazon.com/hz/wishlist/ls/2WHUDN1UIDVUT/ref=cm_sw_r_cp_ep_ws_8xNVBb731TTMS,
  #=> https://www.amazon.com/gp/registry/wishlist/2WHUDN1UIDVUT/ref=cm_sw_r_cp_ep_ws_8xNVBb731TTMS,
  #=> and https://www.amazon.com/registry/wishlist/2WHUDN1UIDVUT/ref=cm_sw_r_cp_ep_ws_8xNVBb731TTMS
  #=> appear to be functionally the same. Code should reflect this when it is
  #=> given links as arguments.

  def self.get_wishlist(amazon_list_id, reveal = :all, sort = :date_added, tld = 'com')
    raise "invalid reveal" unless REVEAL_OPTIONS.include?(reveal)
    raise "invalid sort" unless SORT_OPTIONS[sort]

    query_params = {reveal: reveal.to_s, sort_string: SORT_OPTIONS[sort]}
    # lek is nil for the first page
    url_without_qstring = "http://www.amazon.#{tld}/hz/wishlist/ls/#{amazon_list_id}"

    pages = self.get_all_wishlist_pages(url_without_qstring, query_params)
    wishes = AmazonWish.parse_wishes_from_pages(pages)
    AmazonWishList.new(amazon_list_id, wishes)
  end

  def self.get_all_wishlist_pages(url_without_qstring, query_params)
    responses = Array.new
    loop do
      response = self.get_wishlist_page(url_without_qstring, query_params)
      responses << response
      return responses if response.body.include?("Find a gift") # as of the
      #=> time this was written, this phrase appears only on the last page
      lek = self.find_lek_from_response(response)
      query_params[:lek] = lek # the rest of the query_params hash stays the same
    end
  end

  def self.get_wishlist_page(url_without_qstring, query_params)
    query_string = self.page_query_string(query_params)
    RestClient.get(url_without_qstring + query_string)
  end

  def self.page_query_string(query_params)
    "?reveal=#{query_params[:reveal]}&layout=standard&sort=#{query_params[:sort_string]})" +
    (query_params[:lek] ? "&lek=#{query_params[:lek]}&type=wishlist&ajax=true" : '')
  end

  def self.find_lek_from_response(response)
    # As of the time of writing this, "lastEvaluatedKey", abbreviated as "lek",
    # is used to keep track of what portions of the wishlist have already been
    # loaded, and is sent in the query string of ajax calls to get the next page
    start_of_lek = response.body.split('name="lastEvaluatedKey" value="')[1]
    start_of_lek.split('" class="lastEvaluatedKey"')[0]
  end

  def self.wishlist_from_url(url)
    url = check_for_redirect(url)
    id_start = url.split('/wishlist/')[1]
    id = id_start.split('/').find { |str| str != 'ls' }
    get_wishlist(id)
  end

  def self.check_for_redirect(url)
    begin
      response = RestClient::Request.execute(method: :get, url: url, max_redirects: 0)
    rescue RestClient::ExceptionWithResponse => err
      if err.response.code / 100 == 3
        url = err.response.headers[:location]
        retry
      else
        raise err
      end
    end
    url
  end



end
