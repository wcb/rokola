require 'librmpd'
require 'yaml'

@@mpd = MPD.new "192.168.1.48", 6600 
@@mpd.connect

songs = @@mpd.songs()

i=0

#Well, this is yaml.  I can serialize my songs (hashes) but that doesn't 
#produce the input my test server wants.
#/usr/lib/ruby/gems/1.9.1/gems/librmpd-0.1.1/data/database.yaml
puts "- &songs"

songs.each do |song|
  puts "  - &song"+i.to_s+"\n"
  puts '      file: "'+song.file+'"'
  puts '      time: '+song.time.to_s+''+"\n" unless song.time.nil?
  puts '      artist: "'+song.artist+'"'+"\n" unless song.artist.nil?
  puts '      album: "'+song.album+'"'+"\n" unless song.album.nil?
  puts '      title: "'+song.title+'"'+"\n" unless song.title.nil?
  puts '      track: '+song.track.to_s+''+"\n" unless song.track.nil?
  i=i+1
end

