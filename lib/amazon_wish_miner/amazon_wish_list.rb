class AmazonWishList

  REVEAL_OPTIONS = [:all, :purchased, :unpurchased].freeze
  SORT_OPTIONS = {date_added: "date-added", title: 'universal-title',
    price_high: 'universal-price-desc', price_low: 'universal-price',
    date_updated: 'last-updated', priority: 'priority'}.freeze

  def initialize
  end

  def self.get_wishlist(amazon_list_id, reveal = :all, sort = :date_added, tld = 'com')
    raise "invalid reveal" unless REVEAL_OPTIONS.include?(reveal)
    sort_string = SORT_OPTIONS[sort]
    raise "invalid sort" unless sort_string
    url = "http://www.amazon.#{tld}/registry/wishlist/#{amazon_list_id}"
    query_string = "?reveal=#{reveal.to_s}&sort=#{sort_string}&layout=standard"
    first_page = RestClient.get(url + query_string)
  end

end
