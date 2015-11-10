module AlchemyNews
  
  require 'rubygems'
  require 'json'

  class Client
    
    @@BASE_LIMIT=25
    
    @@BASE_START=Time.now - 2600*24*7
    @@BASE_END=Time.now
    @@BASE_SENTIMENT="neutral"
    @@BASE_SENTIMENT_SCORE=0.5
    @@BASE_COLUMNS = "enriched.url.title,enriched.url.url,enriched.url.author,enriched.url.docSentiment"
 
    attr_accessor :api_key, :search_focus,  
      :search_term, :search_type, 
      :sentiment_type, :taxonomy, 
      :limit, :start_time, :end_time
    
    def news
      @news_array || []
    end
  
    def self.sentiment_types
       [:positive, :negative, :neutral, :any]
    end
  
    def self.search_focii
        [:title, :body]
    end
    
  def initialize(api_key)
    @api_key = api_key
  end
  
  def search(keyword)
    news_items = []
    @search_term = CGI::escape(keyword)
    content =  Connection.request(@api_key, build_search_qs)
    
    return [] if content.nil? or  content["status"]=="ERROR" or !content.has_key? "result"
    return if !content["result"].has_key? "docs"
    items = content["result"]["docs"]
    items.each do |item|
      news_items << create_news_from_data(item)
    end
    @news_array = news_items
  end
  
  
  def build_search_qs
    options = {}
    start_search_time = start_time || @@BASE_START
    end_search_time = end_time || @@BASE_END
    options["start"]= @@BASE_START.to_i#start_search_time.to_i
    options["end"]= @@BASE_END.to_i#start_search_time.to_i
    options["return"] = @@BASE_COLUMNS
    options["count"]=@@BASE_LIMIT
    options["q.enriched.url.docSentiment.type"]=@sentiment_type  unless @sentiment_type.nil?
    options["return"] = @@BASE_COLUMNS
    options["q.enriched.url.text"] = @search_term
    options
  end
    
  def create_news_from_data(news_data)
    ni = NewsItem.new
    ni.id = news_data["id"]
    ni.title = news_data["source"]["enriched"]["url"]["title"]
    ni.url = news_data["source"]["enriched"]["url"]["url"]
    ni.sentiment_factor = news_data["source"]["enriched"]["url"]["docSentiment"]["score"]
    ni.sentiment_type = news_data["source"]["enriched"]["url"]["docSentiment"]["type"]
    ni.timestamp = news_data["timestamp"]
    ni.concepts = []
    if news_data["source"]["enriched"]["url"].has_key? "concepts"
      news_data["source"]["enriched"]["url"]["concepts"].each do |concept|
        c = Concept.new
        c.type_hierarchy = concept["knowledgeGraph"]["typeHierarchy"]
        c.relevance = concept["relevance"]
        c.relevant_text = concept["text"]
        ni.concepts << c
      end
      
    end    
  
    
    ni
  end
    
    
  private
  
    attr_accessor :news_array
  
   
    
   
  end
  
end