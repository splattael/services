require 'rubygems'
require 'sinatra'
require 'RMagick'
require 'httparty'
require 'nokogiri'

CACHE={}

def cached(key, expires, &block)
  value, saved_at = CACHE[key]
  now = Time.now.to_f
  if saved_at.nil? || now - saved_at > expires
    value = block.call
    CACHE[key] = [ value, now ]
  end
  value
end

get '/petition.gif' do
  expires = 5

  content_type "image/gif"
  response['Expires'] = (Time.now + expires * 10).httpdate

  cached(:petition, expires) do
    # [ { :text => "96% / 48372 Mitzeichner (10 pro Minute)", ... } ]
    json = HTTParty.get("http://twitter.com/statuses/user_timeline/37667542.json?count=3") || []
    text = (json.detect {|hash| /(\d+)%/ =~ hash["text"] } || {})["text"]

    image = Magick::Image.new(230, 16)
    image.format = "GIF"
    draw = Magick::Draw.new
    draw.text(5, 12, text)
    draw.draw(image)

    image.to_blob
  end
end

get '/nacktscanner.gif' do
  expires = 20
  content_type "image/gif"
  response['Expires'] = (Time.now + expires * 10).httpdate

  cached(:nacktscanner, expires) do
    html = HTTParty.get("https://epetitionen.bundestag.de/index.php?action=petition;sa=details;petition=9109")
    doc = Nokogiri(html).at(".pet_det_td_4")
    mitzeichner = doc.children[0].to_s.to_i
    max = 50_000
    per_cent = mitzeichner * 100.0 / max
    text = "%.2f%% / %d gegen Nacktscanner" % [ per_cent, mitzeichner ]

    image = Magick::Image.new(230, 16)
    image.format = "GIF"
    draw = Magick::Draw.new
    draw.text(5, 12, text)
    draw.draw(image)

    image.to_blob
  end
end

get '/scawen.gif' do
  expires = 5
  content_type "image/gif"
  response['Expires'] = (Time.now + expires * 10).httpdate

  cached(:scawen, expires) do
    document = HTTParty.get("http://www.lfsforum.net/showthread.php?t=9866")

    text = document.to_s[/Posts: \d+,\d+/] || '???'

    image = Magick::Image.new(150, 16)
    image.format = "GIF"
    draw = Magick::Draw.new
    draw.text(5, 12, "Scawen's #{text}")
    draw.draw(image)

    image.to_blob
  end
end
