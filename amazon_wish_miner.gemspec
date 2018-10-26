Gem::Specification.new do |s|
  s.name        = 'amazon_wish_miner'
  s.version     = '0.1.4'
  s.date        = '2018-10-03'
  s.summary     = 'Scrapes one or more Amazon wish lists'
  s.description = 'Modeled after Amazon Wish Lister http://doitlikejustin.github.io/amazon-wish-lister/'
  s.author      = 'Alexander V. Trujillo'
  s.files       = [
    'lib/amazon_wish_miner.rb', 'lib/amazon_wish_miner/amazon_wish_list.rb',
    'lib/amazon_wish_miner/amazon_wish.rb'
  ]
  s.homepage    = 'https://github.com/avtrujillo/amazon_wish_miner'
  s.license     = 'MIT'

  s.add_runtime_dependency 'rest-client',  '~> 2'
  s.add_runtime_dependency 'nokogiri',  '~> 1.8'
end
