module AlchemyNews
  
  require 'rubygems'
  require 'json'
  
  
  class Api
    @@BASE_LIMIT=100
    @@BASE_URL="http://access.alchemyapi.com/calls/data/GetNews"
    @@BASE_START=Time.now - 2600*24
    @@BASE_END=Time.now
    @@BASE_SENTIMENT="neutral"
    @@BASE_SENTIMENT_SCORE=0.5
    @@BASE_COLUMNS = "enriched.url.title,enriched.url.url,enriched.url.author,enriched.url.docSentiment"
 
    attr_accessor :api_key, :search_focus,  
      :search_term, :search_type, 
      :sentiment_type, :taxonomy, 
      :limit, :start_time, :end_time
    
    def news
      @news_array
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
    @search_term = keyword
    content =  request(build_search_qs)
    
    return [] if content.nil?
    return [] if content["status"]=="ERROR"
    
    items = content["result"]["docs"]
    items.each do |item|
      
      news_items << create_news_from_data(item)
    end
    @news_array = news_items
   
    
  end
  
  def create_news_from_data(news_data)
    ni = NewsItem.new
    ni.id = news_data["id"]
    ni.title = news_data["source"]["enriched"]["url"]["title"]
    ni.url = news_data["source"]["enriched"]["url"]["url"]
    ni.sentiment_factor = news_data["source"]["enriched"]["url"]["docSentiment"]["score"]
    ni.sentiment_type = news_data["source"]["enriched"]["url"]["docSentiment"]["type"]
    ni.timestamp = news_data["timestamp"]
    ni
  end
  
  def build_search_qs
    options = {}
    start_search_time = start_time || @@BASE_START
    end_search_time = end_time || @@BASE_END
    options["start"]= @@BASE_START.to_i#start_search_time.to_i
    options["end"]= @@BASE_END.to_i#start_search_time.to_i
    options["return"] = @@BASE_COLUMNS
    options["count"]=@@BASE_LIMIT
    options["q.enriched.url.docSentiment.type"]=@sentiment_type || @@BASE_SENTIMENT
    options["return"] = @@BASE_COLUMNS
    options["q.enriched.url.text"] = @search_term
    options
  
    #https://access.alchemyapi.com/calls/data/GetNews?apikey=YOUR_API_KEY_HERE&return=enriched.url.title,enriched.url.url,enriched.url.author,enriched.url.publicationDate,enriched.url.enrichedTitle.entities,enriched.url.enrichedTitle.docSentiment,enriched.url.enrichedTitle.concepts,enriched.url.enrichedTitle.taxonomy&start=1446249600&end=1446937200&q.enriched.url.cleanedTitle=IBM&q.enriched.url.enrichedTitle.taxonomy.taxonomy_.label=technology%20and%20computing&count=25&outputMode=json
  #  ?apikey=ae1d76549294b6a08e8b9f4d0a2874f02c4b2dd5
  #  return=enriched.url.title
   # start=1446249600
   #end=1446937200
   # q.enriched.url.enrichedTitle.entities.entity=|text=IBM,type=company|
  #  q.enriched.url.enrichedTitle.docSentiment.type=positive
  #  q.enriched.url.enrichedTitle.taxonomy.taxonomy_.label=technology%20and%20computing
  #count=25#
  #outputMode=json"
  
  end
    
  private
  
    attr_accessor :news_array
  
    def inflate_options(options)
  		options['apikey'] = @api_key
  		options['outputMode'] = 'json'
  		url = '?'
  		options.each { |h,v|
  			url += h + '=' + v.to_s + '&'
  		}
      url
    end
    
    def request(options)
      if @api_key.nil?
      
        out = {status:"Error",message: "You need to configure the API KEY."}.to_json
        return  parse_body(out)
      end
  		#Insert the base URL
  		url = @@BASE_URL + inflate_options(options)
     	uri = URI.parse(url)
  		request = Net::HTTP::Get.new(uri.request_uri)
  		request['Accept-Encoding'] = 'identity'
  		res = Net::HTTP.start(uri.host, uri.port) do |http|
  			http.request(request)
  		end

  		return JSON.parse(res.body)
  	end
    
   
    
  end
  
end