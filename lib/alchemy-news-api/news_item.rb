module AlchemyNews
  class NewsItem
    attr_accessor  :id, :timestamp,:title, :url, :sentiment_factor, :sentiment_type, :taxonomy, :concepts
  
    def to_s
      title
    end
    
  end
end