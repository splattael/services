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
  text = cached(:petition, 5) do
    json = HTTParty.get("http://twitter.com/statuses/user_timeline/37667542.json?count=1")
    ((json || [])[0] || {})["text"] || "no text"
  end

  image = Magick::Image.new(140, 16)
  image.format = "JPG"
  draw = Magick::Draw.new
  draw.text(5, 12, text)
  draw.draw(image)

  content_type "image/gif"
  image.to_blob

end
