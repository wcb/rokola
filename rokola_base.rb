begin
  require 'md5'
rescue LoadError
  require 'digest/md5'
end

Fleakr.api_key = '173ed7a1eb0371f9368b027057456c76'
Fleakr.shared_secret = 'fa6c63b0746838cb'

def quote (str)
  str.gsub(/\\|"/) { |c| "\\#{c}" }
end

def build_library
  artists = @@mpd.artists
  library = Hash.new

  artists.each do |artist|
    #print artist + "\n"
    albums = @@mpd.albums(artist)
    album_hash = Hash.new

    albums.each do |album|
      #print "   " + album + "\n"
      titles = @@mpd.find('album',quote(album))
      tracks=Array.new

      titles.each do |song|
        if song.title != nil
          #print "   - " + title.title + "\n"
          tracks << song
        end
      end

      album_hash[album]=tracks

    end
    library[artist]=album_hash

  end
  return library
end

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
def get_artist_artwork_flickr(artist)
  photos = Fleakr.search({:text => artist, :sort => "relevance"})
  photo = photos.detect do |p| 
    !p.large.nil? and !p.large.url.nil? and matches_criteria(p.large.height.to_i, p.large.width.to_i)
  end
  url = photo.large.url unless photo.nil?
  return url
end


def get_artist_artwork_lastfm(artist)
  http = Net::HTTP.new("ws.audioscrobbler.com")
  maxcoeff = 0
  maxurl = nil
  http.start do |http|
    request = Net::HTTP::Get.new("/2.0/?method=artist.getimages&artist=#{Rack::Utils.escape(artist)}&api_key=b25b959554ed76058ac220b7b2e0a026")
    response = http.request(request)
    puts response.value
    images = response.body.scan(/<size name="original" width="(\d+)" height="(\d+)">(.*)<\/size>/n) do |i| 
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

def get_album_artwork_local(song)
  #Let's not waste our time
  return nil unless File.exist?(Sinatra::Application.public + "music/")
  #TODO: move to config
  ['folder','Folder','Album Art','album art',
   'cover','front'].each do |filename|
    ['png','gif','jpg','jpeg','bmp'].each do |ext|
      rindex=song.file.rindex('/')
      #meh
      rindex=0 if rindex.nil?
      path = song.file[0..rindex]
      image = "music/" + path + filename + "." + ext
      return image if File.exist?(Sinatra::Application.public + image)
      #TODO: Case-sensitivity of extension?
    end
  end
  return nil
end

def get_album_artwork_lastfm(song)
  http = Net::HTTP.new("ws.audioscrobbler.com")
  http.start do |http|
    request = Net::HTTP::Get.new("/2.0/?method=album.getinfo&artist="+
                                 Rack::Utils.escape(song.artist) +"&album="+
                                 Rack::Utils.escape(song.album)+
                                 "&api_key=b25b959554ed76058ac220b7b2e0a026")
    response = http.request(request)
    image = response.body[/<image size="medium">(.*)<\/image>/n,1]
    return image
  end
end
