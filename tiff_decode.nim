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


proc process_ifd_entry(): ifd_entry =
  let tag = stream.readInt16()
  let field_type = stream.readInt16()
  let type_count = stream.readInt32()
  let value_file_offset = stream.readInt32()
  result = ifd_entry(tag: tag, field_type: field_type, type_count: type_count, value_file_offset: value_file_offset)

# Process image file header
var byteorder: array[2, char]
discard stream.readData(byteorder.addr, 2)
assert byteorder == ['I', 'I'] # only play with little endian to begin with
let forty_two = stream.readInt16()
let byte_offset = stream.readInt32()
let ifh = image_file_header(byteorder: byteorder, forty_two: forty_two, byte_offset: byte_offset)

# Set position to the byte offset (first image file directory)
setPosition(stream, byte_offset)


var num_fields = stream.readInt16()
var ifd_entries = newSeq[ifd_entry](num_fields)
for i in countup(1, num_fields):
  var ifd_entry = process_ifd_entry()
  echo ifd_entry
  ifd_entries.add(ifd_entry)
var offset = stream.readInt32()
  
echo offset


setPosition(stream, 8)
for i in countup(1, 90750):
  var val = stream.readUInt8()
  echo val


# var byteorder: array[2, char]
# discard stream.readData(byteorder.addr, 2)
# echo "byteorder: ", byteorder
# 
# var forty_two = stream.readInt16()
# echo "fortytwo: ", fortytwo
# var forty_two_swap: int16
# swapEndian16(addr(forty_two_swap), addr(fortytwo))
# echo "fortytwo_swap: ", forty_two_swap
# 
# var offset_ifd = stream.readInt32()
# echo "offset_ifd: ", offset_ifd
# var offset_ifd_swap: int32
# swapEndian16(addr(offset_ifd_swap), addr(offset_ifd))
# echo "offset_ifd_swap: ", offset_ifd_swap
# 
# setPosition(stream, offset_ifd)
# 
# var num_dirs = stream.readInt16()
# 
# var tag = stream.readInt16()
# var field_type = stream.readInt16()
# var num_vals = stream.readInt32()
# var offset = stream.readInt32()
# 
# echo "num_dirs: ", num_dirs
# echo "tag: ", tag
# echo "field_type: ", field_type
# echo "num_vals: ", num_vals
# echo "offset: ", offset



