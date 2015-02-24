# Generate a gallery for a colorlovers palette.
# Json spec: http://www.colourlovers.com/api/

require 'open-uri'
require 'json'
require 'uri'

# For the vector class
# (note: install gmath3D gem if not already installed)
require 'gmath3D'

SITE = "color".downcase
DOWNLOAD = true

puts "Fetching json..."

json = JSON.parse(open("http://www.colourlovers.com/api/palettes/top?format=json").readlines.join)

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />

EOF

i = 0

json.each do |palette|

  title = palette["title"].slice(0,70)
  
  if title.length == 70
    title = title.sub(/\.+$/, '') + "..."
  end
  
  uri = URI.parse(URI.encode(palette["imageUrl"]))
  extension = File.extname(uri.path).downcase
  
  # jpg, jpeg, png...
  
  next unless extension == ".jpg" || extension == ".jpeg" || extension == ".png"
  
  puts " * #{uri.to_s}"
  
  if DOWNLOAD
    `curl #{uri.to_s} -s -o scenes/images/#{SITE}-#{i}#{extension}` || next
    `mogrify -resize 500x450 scenes/images/#{SITE}-#{i}#{extension}` || next
  end
  
  x = i % 5
  z = (i / 5).floor
  
  v = GMath3D::Vector3.new(x, 0.05, -z) * 5
  v += GMath3D::Vector3.new(5, 0.5, -5)
  
  height = `identify scenes/images/#{SITE}-#{i}#{extension}`.match(/x(\d+)/)[1].to_i + 50
  margin = (512 - height) / 2

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0 0" scale="1.2 1.2 0.05">
      <![CDATA[
        <center style="margin-top: #{margin}px; font-size: 3em">
          <img src="/images/#{SITE}-#{i}#{extension}" style="max-width: 100%" />
		  <br>
          #{title}
        </center>
      ]]>
    </billboard>
	
EOF

  v.y = 0.2
  v += GMath3D::Vector3.new(1.2, 0, 0)

  palette["colors"].each do |color|
    xml += "<box style='color:##{color};' scale='0.4 0.4 0.4' position='#{v.x} #{v.y} #{v.z}' />"
    v += GMath3D::Vector3.new(0, 0.4, 0)
  end

  i += 1
end

xml += "</scene>"

File.open("./scenes/colorlovers.xml", "w") { |f| f.write xml }

puts "Visit /colorlovers.xml to see the gallery."

