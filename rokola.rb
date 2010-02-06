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
  def current_song
  @@mpd.current_song
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
end

get '/' do
  @song = current_song
  @splash = current_splash(@song)
  haml :main
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end