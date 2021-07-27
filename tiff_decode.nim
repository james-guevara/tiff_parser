import streams
import os
import endians

type
  image_file_header* = object
    byteorder*: array[2, char] # "II" is little-endian and "MM" is big-endian
    forty_two*: int16 # arbitrary number
    byte_offset*: int32 # offset to first IFD

  image_file_directory* = object
    num_fields*: int16 # number of directory entries (or number of fields)
    ifd_entries*: seq[ifd_entry]

  ifd_entry* = object
    tag*: int16
    field_type*: int16
    type_count*: int32 # number of values (bytes) in the type_ 
    value_file_offset*: int32 # file offset of the value for the field (there may not be an offset and the value could be stored in this field instead if it fits into these 4 bytes)


let stream = newFileStream(paramStr(1), mode = fmRead)


# Process image file header
var byteorder: array[2, char]
discard stream.readData(byteorder.addr, 2)
assert byteorder == ['I', 'I'] # only play with little endian to begin with
let forty_two = stream.readInt16()
let byte_offset = stream.readInt32()
let ifh = image_file_header(byteorder: byteorder, forty_two: forty_two, byte_offset: byte_offset)

# Set position to the byte offset (first image file directory)
setPosition(stream, byte_offset)

proc process_ifd_entry(): ifd_entry =
  let tag = stream.readInt16()
  let field_type = stream.readInt16()
  let type_count = stream.readInt32()
  let value_file_offset = stream.readInt32()
  result = ifd_entry(tag: tag, field_type: field_type, type_count: type_count, value_file_offset: value_file_offset)


proc process_ifd(): image_file_directory =
  let num_fields = stream.readInt16()
  var ifd_entries = newSeq[ifd_entry](num_fields)
  for i in countup(1, num_fields):
    let ifd_entry = process_ifd_entry()
    echo ifd_entry
    ifd_entries.add(ifd_entry)
  result = image_file_directory(num_fields: num_fields, ifd_entries: ifd_entries)



proc process_tiff(): seq[image_file_directory] =
  var counter = 0
  var offset: int32 = -1
  var ifds = newSeq[image_file_directory]()
  while offset != 0:
    let ifd = process_ifd()
    offset = stream.readInt32()
    setPosition(stream, offset)
    echo "offset: ", offset
    counter += 1
    echo "counter: ", counter
    ifds.add(ifd)
  return ifds

var ifds = process_tiff()
echo ifds

var ifd = ifds[0]
echo "\n\n\n\n\n\n"
var ifd_entries = ifd.ifd_entries






# Locate ifd_entries with certain tags in them
# Which tags? (and corresponding tag numbers)
# ImageWidth (256), ImageLength (257), StripOffsets (273), RowsPerStrip (278), StripByteCounts (279)
# Get the pixel values
# Run a mean function on them
var imageWidth: int32
var imageLength: int32
var stripOffsets: int32
var rowsPerStrip: int32
var stripByteCounts: int32
var bitsPerSample: int32
for ifd_entry in ifd_entries:
  var value = ifd_entry.value_file_offset
  var tag = ifd_entry.tag
  if tag == 256:
    imageWidth = value
  elif tag == 257:
    imageLength = value
  elif tag == 273:
    stripOffsets = value
  elif tag == 278:
    rowsPerStrip = value
  elif tag == 279:
    stripByteCounts = value
  elif tag == 258:
    bitsPerSample = value

echo "imageWidth: ", imageWidth
echo "imageLength: ", imageLength
echo "stripOffsets: ", stripOffsets
echo "rowsPerStrip: ", rowsPerStrip
echo "stripByteCounts: ", stripByteCounts
echo "bitsPerSample: ", bitsPerSample

# (For my test image:)
# imageWidth: 375
# imageLength: 242
# stripOffsets: 8
# rowsPerStrip: 242
# stripByteCounts: 90750

# go to stripOffsets first, then get all pixels (not split up this time, can be split up later on)
# annoying things to take care of later: endianness (is it annoying?), strips that aren't contiguous 


import arraymancer
import sequtils

# var numPixels = imageLength*imageWidth.int
# var a = toSeq(1..numPixels).toTensor().reshape(imageLength.int, imageWidth.int)

# echo a[0,0]

# get pixels (assuming bitsPerSample is 8 which it is in this case, need to handle other cases)
var s = newSeq[seq[uint8]](imageLength)
for i in 0 ..< imageLength:
  s[i].newSeq(imageWidth)

setPosition(stream, stripOffsets)

for i in countup(0, imageLength - 1):
  for j in countup(0, imageWidth - 1):
    s[i][j] = stream.readUint8()

# echo s

# for i in countup(1, stripByteCounts):
#   echo i


import nigui


app.init()
var window = newWindow()
window.width = imageWidth
window.height = imageLength

var image = newImage()
image.resize(imageLength, imageWidth)

for i in countup(0, imageLength - 1):
  for j in countup(0, imageWidth - 1):
    var val = s[i][j]
    # echo val
    image.canvas.setPixel(i, j, rgb(val, val, val))

var image2 = newImage()
image2.resize(2, 2)
# Creates a new bitmap
image2.canvas.setPixel(0, 0, rgb(255, 0, 0))
image2.canvas.setPixel(0, 1, rgb(255, 0, 0))
image2.canvas.setPixel(1, 1, rgb(0, 255, 0))
image2.canvas.setPixel(1, 0, rgb(0, 0, 255))

saveToJpegFile(image, "testing_E.jpg")

window.show()
app.run()

