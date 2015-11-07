require 'helper'

class TestAlchemyNewsApi < Test::Unit::TestCase
  should "set up the API and run a mock query" do
    
    stub_request(:any, /.*alchemyapi.*/).to_return(:body => File.read("test/stub.txt") )
    
    key = "thisisafakekey"
    api = AlchemyNews::Api.new(key)
    search = api.search("Trudeau")
    
    assert api.news.count==5
    
    assert api.news.first.title.index("Canada")>0
  end
  
 
  
end
