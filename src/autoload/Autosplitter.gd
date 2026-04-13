extends Node

# Scannable chunk of memory with a known layout, to be used to drive a LiveSplit autosplitter

#  0-15 - Header         - 16 bytes - String literal which we can scan for
# 16-23 - Iteration rate -  8 bytes - Engine.iterations_per_second
# 24-31 - Time           -  8 bytes - The value of the in-game save timer (in frames)
# 32-47 - Map name       - 16 bytes - The current map according to Shared.map_name
# 48-55 - Final time     -  8 bytes - The final time of the speedrun (in frames) when completed, 0 otherwise
# 56    - Is title       -  1 byte  - Are we on the title screen?
# 57    - Is hub         -  1 byte  - Are we in a hub world?

var buf := PoolByteArray()

func _init() -> void:
	buf.resize(80)
	buf.fill(0)

	# Write header
	buf.set( 0, ord('r'))
	buf.set( 1, ord('o'))
	buf.set( 2, ord('t'))
	buf.set( 3, ord('a'))
	buf.set( 4, ord('_'))
	buf.set( 5, ord('a'))
	buf.set( 6, ord('s'))
	buf.set( 7, ord('r'))
	buf.set( 8, ord('_'))
	buf.set( 9, ord('d'))
	buf.set(10, ord('a'))
	buf.set(11, ord('t'))
	buf.set(12, ord('a'))
	buf.set(13, ord('('))
	buf.set(14, ord(':'))

	# Write iteration rate, shouldn't change
	_write_int64(16, Engine.iterations_per_second)
	
	# We start on the title
	set_title(true)


func set_time(count: int) -> void:
	_write_int64(24, count)

func set_map_name(map: String) -> void:
	_write_string(32, map, 16)

func set_final_time(frame_count: int) -> void:
	_write_int64(48, frame_count)

func set_title(is_title: bool) -> void:
	buf.set(56, 1 if is_title else 0)

func set_hub(is_hub: bool) -> void:
	buf.set(57, 1 if is_hub else 0)


# Writes a 64 bit integer into the buffer at the given index
func _write_int64(idx: int, val: int) -> void:
	for i in range(8):
		var byte := (val >> (i * 8)) & 0xFF
		buf.set(idx + i, byte)

# Writes a string into the buffer at the given index
func _write_string(idx: int, val: String, max_byte_length := -1) -> void:
	var bytes := val.to_utf8()
	var length := bytes.size()
	if length > max_byte_length - 1:
		length = max_byte_length - 1
	for i in range(length):
		buf.set(idx + i, bytes[i])
	buf.set(idx + length, 0)
