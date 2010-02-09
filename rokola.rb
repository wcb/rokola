# Gems
require 'rubygems'
require 'sinatra'
require 'json'
require 'librmpd'
require 'haml'
require 'yaml'
require 'sass'
require 'blankslate'
require 'fleakr'

# Helpers 
require 'rokola_base'

require 'config'

helpers do 
  def quote (str)
    str.gsub(/\\|"/) { |c| "\\#{c}" }
  end
  def get_current_song
    @@mpd.current_song
  end
  def get_next_song
    return nil if @@mpd.current_song.nil?
    @@mpd.playlist[@@mpd.current_song.pos.to_i+1]
  end
  def current_splash(song)
    return "spotlight.png" if song.nil? or song.artist.nil? 
    url = get_artwork_lastfm(song.artist)
    url = "spotlight.png" if url.nil?
  return url 
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

        titles.each do |title|
          if title.title != nil
            #print "   - " + title.title + "\n"
            tracks << title.title
          end
        end

        album_hash[album]=tracks

      end
      library[artist]=album_hash

    end
    return library
  end

end

configure do
  puts 'Boostrapping'
  @@mpd = MPD.new Sinatra.options.mpdhost, Sinatra.options.mpdport
  @@mpd.connect
  
  @token = 0
  
end

get '/' do
  @song = get_current_song
  @next_song = get_next_song
  puts @next_song

  @library = build_library

  @splash = current_splash(@song)
  haml :main
end

post '/' do
  params[:bob]
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end
