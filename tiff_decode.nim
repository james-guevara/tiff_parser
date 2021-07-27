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


# Locate ifd_entries with certain tags in them




