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
  def get_playlist
    @@mpd.playlist
  end
  def get_current_song
    @@mpd.current_song
  end
  def get_current_position
    pos=@@mpd.status["song"]
    return 0 if pos.nil?
    return pos.to_i
  end
  def get_next_song
    return nil if @@mpd.current_song.nil?
    @@mpd.playlist[@@mpd.current_song.pos.to_i+1]
  end
  def current_splash(song)
    #gets a background
    return "spotlight.png" if song.nil? or song.artist.nil? 
    url = get_artist_artwork_lastfm(song.artist)
    url = "spotlight.png" if url.nil?
    return url 
  end
  def album_artwork(song)
    return "test.png" if song.nil? or song.artist.nil?
    #First we will try to see if we have local artwork in public/music
    image = get_album_artwork_local(song)
    return image unless image.nil?
    #No sah.  We shall scrobble.
    puts "No local album art.\n"
    return get_album_artwork_lastfm(song)
  end
  def validate_queue_end
    #if the end of the queue is *before* the current position, it needs to be
    #re-initialized.
    pos=get_current_position
    if pos>@@queue_end
      @@queue_end=get_current_position+1
    end
  end
  def enqueue(path)
    begin
      @@mpd.add(path)
    rescue
      return
    end
    validate_queue_end
    @@mpd.move(get_playlist.length-1,@@queue_end)
    @@queue_end+=1
  end
end

configure do
  puts 'Boostrapping'
  @@mpd = MPD.new Sinatra.options.mpdhost, Sinatra.options.mpdport
  puts 'Connecting to MPD'
  @@mpd.connect
  puts 'Done.'
  puts 'Building library'
  @@library = build_library
  puts 'Done. '#bell
  @@queue_end = 0
  @token = 0
end

get '/' do
  @song = get_current_song
  @next_song = get_next_song

  #Gets the whole playlist.  If this lags, we can use song_with_id( songid )
  @playlist = get_playlist
  @playlist_position = get_current_position

  @cover = album_artwork(@song)

  @splash = current_splash(@song)

  haml :main
end

get '/add/*.*' do
  path = params["splat"].join('.')
  puts "Queueing" + path

  enqueue(path)

  redirect('/')
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end
