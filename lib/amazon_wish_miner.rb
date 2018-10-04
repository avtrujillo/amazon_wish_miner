class AmazonWishList

  REVEAL_OPTIONS = [:all, :purchased, :unpurchased].freeze
  SORT_OPTIONS = [:date_added, :title, :price_high, :price_low, :date_updated, :priority].freeze

  def initialize
  end

  def self.get_wishlist(amazon_user_id, tld, reveal, sort)
    url = "http://www.amazon.#{tld}/registry/wishlist/#{amazon_user_id}"
    query_string = "?#{reveal}&#{sort}&layout=standard"
    first_page = HTTParty.get(url + query_string)
  end

end
