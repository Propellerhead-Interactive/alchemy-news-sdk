module AlchemyNews
  
  require 'rubygems'
  require 'json'
  
  class Connection
    
    @@BASE_URL="http://access.alchemyapi.com/calls/data/GetNews"
    
    def self.inflate_options(key, options)
  		options['apikey'] = key
  		options['outputMode'] = 'json'
  		url = ''
  		options.each { |h,v|
  			url += h + '=' + v.to_s + '&'
  		}
      url
    end
    
    def self.request(key, options)
      if key.nil?
    
        out = {status:"Error",message: "You need to configure the API KEY."}.to_json
        puts out
        return  JSON.parse(out)
      end
  		#Insert the base URL
  		url = @@BASE_URL + "?" + Connection.inflate_options(key, options)
     	uri = URI.parse(url)
      puts url
  		request = Net::HTTP::Get.new(uri.request_uri)
  		request['Accept-Encoding'] = 'identity'
  		res = Net::HTTP.start(uri.host, uri.port) do |http|
  			http.request(request)
  		end

  		return JSON.parse(res.body)
    end
  end
    
    
  
  
end