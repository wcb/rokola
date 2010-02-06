require 'md5'

Fleakr.api_key = '173ed7a1eb0371f9368b027057456c76'
Fleakr.shared_secret = 'fa6c63b0746838cb'

def matches_criteria(height,width)
  height > 525 and width > 850 and height < 800
end

#WIP
def resize_image(path)
  
end

#WIP
def get_cached_image(song, url)
  path = "public/images/" + song.id.to_s + ".jpg"
  if File.exists? path
    return path
  else
  end
end

## WIP, very unreliable. Should be last resort. 
def get_artwork_flickr(artist)
  photos = Fleakr.search({:text => artist, :sort => "relevance"})
  photo = photos.detect do |p| 
    !p.large.nil? and !p.large.url.nil? and matches_criteria(p.large.height.to_i, p.large.width.to_i)
  end
  url = photo.large.url unless photo.nil?
  return url
end


def get_artwork_lastfm(artist)
  http = Net::HTTP.new("ws.audioscrobbler.com")
  maxcoeff = 0
  maxurl = nil
  http.start do |http|
    request = Net::HTTP::Get.new("/2.0/?method=artist.getimages&artist=#{Rack::Utils.escape(artist)}&api_key=b25b959554ed76058ac220b7b2e0a026")
    response = http.request(request)
    puts response.value
    images = response.body.scan(/<size name="original" width="(\d+)" height="(\d+)">(.*)<\/size>/u) do |i| 
      coeff = 0
      width = i[0].to_i
      height = i[1].to_i
      url = i[2]
      coeff= Math.sqrt(width**2 + height**2)
      if coeff > maxcoeff and matches_criteria(height, width)
        maxcoeff = coeff 
        maxurl = url 
      end
    end
  end
  return maxurl
end