# Generate a gallery from an image gallery subreddit. Requires imagemagick to be installed in your
# path. Assumes the billboards are rendered at 512x512.

require 'open-uri'
require 'json'
require 'uri'

# For the vector class
# (note: install gmath3D gem if not already installed)
require 'gmath3D'

SUBREDDIT = "aww".downcase
DOWNLOAD = true

puts "Fetching /r/#{SUBREDDIT} as json..."

json = JSON.parse(open("http://www.reddit.com/r/#{SUBREDDIT}.json").readlines.join)

puts "Downloading and resizing images..."

`rm scenes/images/r-#{SUBREDDIT}-* 2>/dev/null` if DOWNLOAD

xml = "<scene>\n"
xml += <<-EOF
  <spawn position="0 0 0" />

EOF

i = 0
json["data"]["children"].each do |child|
  story = child["data"]

  title = story["title"].slice(0,70)
  
  # to do..
  # why check title is sliced exactly 70 chars? 
  # eg. no sub needed for shorter length titles.
  # why is title not space or dot padded first?
  
  if title.length == 70
    title = title.sub(/\.+$/, '') + "..."
  end

  uri = URI.parse(story["url"])
  extension = File.extname(uri.path).downcase

  # jpg, jpeg, png...
  
  next unless extension == ".jpg" || extension == ".jpeg" || extension == ".png"

  puts " * #{uri.to_s}"

  if DOWNLOAD
    `curl #{uri.to_s} -s -o scenes/images/r-#{SUBREDDIT}-#{i}#{extension}` || next
    `mogrify -resize 500x450 scenes/images/r-#{SUBREDDIT}-#{i}#{extension}` || next
  end
  
  x = i % 5
  z = (i / 5).floor

  v = GMath3D::Vector3.new(x, 0, -z) * 5
  v += GMath3D::Vector3.new(5, 1.5, -5)

  height = `identify scenes/images/r-#{SUBREDDIT}-#{i}#{extension}`.match(/x(\d+)/)[1].to_i
  margin = (512 - 40 - height) / 2

  xml += <<-EOF
    <billboard position="#{v.x} #{v.y} #{v.z}" rotation="0 0 0" scale="3 3 0.3">
      <![CDATA[
        <center style="margin-top: #{margin}px; font-size: 2em">
          <img src="/images/r-#{SUBREDDIT}-#{i}#{extension}" style="max-width: 100%" /><br />
          #{title}
        </center>
      ]]>
    </billboard>
EOF

  i += 1
end

xml += "</scene>"

File.open("./scenes/r-#{SUBREDDIT}.xml", "w") { |f| f.write xml }

puts "Visit /r-#{SUBREDDIT}.xml to see the gallery."
