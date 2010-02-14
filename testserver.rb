#Ruby is too beautiful not to have test cases.  Shall we?

require 'rubygems'
require 'librmpd'
require 'mpdserver'

puts 'Launching server'

server = MPDTestServer.new 6600
server.audit = true
server.start

@@mpd = MPD.new '127.0.0.1', 6600
puts 'Connecting to MPD'
@@mpd.connect
puts 'Done.'

@@mpd.add('Astral_Projection/Dancing_Galaxy/1.Dancing_Galaxy.ogg')
@@mpd.add('Carbon_Based_Lifeforms/Hydroponic_Garden/02.Tensor.ogg')
@@mpd.add('Shpongle/Are_You_Shpongled/1.Shpongle_Falls.ogg')
@@mpd.add('Shpongle/Nothing_Lasts..._But_Nothing_Is_Lost/20.Falling_Awake.ogg')
@@mpd.add('Astral_Projection/Dancing_Galaxy/4.No_One_Ever_Dreams.ogg')
@@mpd.add('Carbon_Based_Lifeforms/Hydroponic_Garden/07.Exosphere.ogg')

@@mpd.repeat=true

@@mpd.play()

sleep
