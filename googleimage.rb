# Generate a gallery for a colorlovers palette.

require 'open-uri'
require 'json'
require 'uri'

# For the vector class
# (note: install gmath3D gem if not already installed)
require 'gmath3D'

DOWNLOAD = true

puts "Fetching json..."

# jsrc = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test";
# json = file_get_contents($jsrc);
# jset = json_decode($json, true);
# echo $jset["responseData"]["results"][0]["url"];

# json = JSON.parse(open("https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=test").readlines.join)

json = JSON.parse(open("https://maps.googleapis.com/maps/api/staticmap?center=-15.800513,-47.91378&zoom=11&size=200x200").readlines.join)

# json = JSON.parse(open("http://www.colourlovers.com/api/palettes/top?format=json").readlines.join)

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />

EOF

i = 0
json.each do |palette|
  title = palette["title"].slice(0,70)

  x = i % 5
  z = (i / 5).floor

  v = GMath3D::Vector3.new(x, 0, -z) * 5
  v += GMath3D::Vector3.new(5, 0.5, -5)

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0 0" scale="1 1 0.1">
      <![CDATA[
        <center style="font-size: 4em; margin-top: 40px">#{title}</center>
      ]]>
    </billboard>
EOF

  v.y = 0.2
  v += GMath3D::Vector3.new(1.5, 0, 0)

  palette['colors'].each do |color|
    xml += "<box color='##{color}' scale='0.4 0.4 0.4' position='#{v.x} #{v.y} #{v.z}' />"
    v += GMath3D::Vector3.new(0, 0.4, 0)
  end

  i += 1
end

xml += "</scene>"

File.open("./scenes/googleimage.xml", "w") { |f| f.write xml }

puts "Visit /googleimage.xml to see the gallery."
