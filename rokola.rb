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

helpers do 
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
end

configure do
  puts 'Boostrapping'
  @@mpd = MPD.new 'localhost', 6600
  @@mpd.connect
  
  @token = 0
  
end

get '/' do
  @song = get_current_song
  @next_song = get_next_song
  puts @next_song
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