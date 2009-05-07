require 'rubygems'
require 'sinatra'
require 'RMagick'
require 'httparty'

CACHE={}

def cached(key, expires, &block)
  value, saved_at = CACHE[key]
  now = Time.now.to_f
  if value.nil? || now - saved_at > expires
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
    json = HTTParty.get("http://twitter.com/statuses/user_timeline/37667542.json?count=1")
    text = ((json || [])[0] || {})["text"] || "no text"

    image = Magick::Image.new(140, 16)
    image.format = "GIF"
    draw = Magick::Draw.new
    draw.text(5, 12, text)
    draw.draw(image)

    image.to_blob
  end

end
