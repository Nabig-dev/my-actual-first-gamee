\
\
"\n\tStandard MIDI File reader/writer by Yui Kinomoto @arlez80\n"

class_name SMF

const control_number_bank_select_msb: int = 0
const control_number_modulation: int = 1
const control_number_breath_controller: int = 2
const control_number_foot_controller: int = 4
const control_number_portamento_time: int = 5
const control_number_data_entry_msb: int = 6
const control_number_volume: int = 7
const control_number_balance: int = 8
const control_number_pan: int = 10
const control_number_expression: int = 11

const control_number_bank_select_lsb: int = 32
const control_number_modulation_lsb: int = 33
const control_number_breath_controller_lsb: int = 34
const control_number_foot_controller_lsb: int = 36
const control_number_portamento_time_lsb: int = 37
const control_number_data_entry_lsb: int = 38
const control_number_channel_volume_lsb: int = 39
const control_number_calance_lsb: int = 40
const control_number_pan_lsb: int = 42
const control_number_expression_lsb: int = 43
const control_number_effect_control1: int = 44
const control_number_effect_control2: int = 45

const control_number_hold: int = 64
const control_number_portament: int = 65
const control_number_portamento: int = 65
const control_number_sostenuto: int = 66
const control_number_soft_pedal: int = 67
const control_number_legato_foot_switch: int = 68
const control_number_freeze: int = 69
const control_number_sound_variation: int = 70
const control_number_timbre: int = 71
const control_number_release_time: int = 72
const control_number_attack_time: int = 73
const control_number_brightness: int = 74
const control_number_vibrato_rate: int = 75
const control_number_vibrato_depth: int = 76
const control_number_vibrato_delay: int = 77

const control_number_source_note: int = 84

const control_number_high_res_velovity_prefix: int = 88

const control_number_reverb_send_level: int = 91
const control_number_tremolo_depth: int = 92
const control_number_chorus_send_level: int = 93
const control_number_celeste_depth: int = 94
const control_number_phaser_depth: int = 95

const control_number_data_increment: int = 96
const control_number_data_decrement: int = 97
const control_number_nrpn_lsb: int = 98
const control_number_nrpn_msb: int = 99
const control_number_rpn_lsb: int = 100
const control_number_rpn_msb: int = 101
const control_number_tkool_loop_point: int = 111
const control_number_all_sound_off: int = 120
const control_number_all_note_off: int = 123

const rpn_control_number_pitch_bend_sensitivity: int = 0
const rpn_control_number_channel_fine_tune: int = 1
const rpn_control_number_channel_cource_tune: int = 2
const rpn_control_number_tune_program_change: int = 3
const rpn_control_number_tune_bank_select: int = 4
const rpn_control_number_modulation_sensitivity: int = 5

const rpn_control_number_3D_azimuth_angle: int = 0
const rpn_control_number_3D_elevation_angle: int = 1
const rpn_control_number_3D_gain: int = 2
const rpn_control_number_3D_distance_ratio: int = 3
const rpn_control_number_3D_maximum_distance: int = 4
const rpn_control_number_3D_gain_at_maximum_distance: int = 5
const rpn_control_number_3D_referance_distance_raito: int = 6
const rpn_control_number_3D_pan_spread_angle: int = 7
const rpn_control_number_3D_roll_angle: int = 8

const manufacture_id_universal_nopn_realtime_sys_ex: int = 126
const manufacture_id_universal_realtime_sys_ex: int = 127
const manufacture_id_kawai_musical_instruments_mfg_co_ltd: int = 64
const manufacture_id_roland_corporation: int = 65
const manufacture_id_korg_inc: int = 66
const manufacture_id_yamaha_corporation: int = 67
const manufacture_id_casio_computer_co_ltd: int = 68
const manufacture_id_kamiya_studio_co_ltd: int = 70
const manufacture_id_akai_electric_co_ltd: int = 71

enum MIDIEventType{
	note_off = 128, 
	note_on = 144, 
	polyphonic_key_pressure = 160, 
	control_change = 176, 
	program_change = 192, 
	channel_pressure = 208, 
	pitch_bend = 224, 
	system_event = 240, 
}

enum MIDISystemEventType{
	sys_ex = 65536, 
	divided_sys_ex = 65537, 

	sequence_number = 0, 
	text_event = 1, 
	copyright = 2, 
	track_name = 3, 
	instrument_name = 4, 
	lyric = 5, 
	marker = 6, 
	cue_point = 7, 

	midi_channel_prefix = 32, 
	midi_port_prefix = 33, 
	end_of_track = 47, 

	set_tempo = 81, 

	smpte_offset = 84, 

	beat = 88, 
	key = 89, 

	unknown = 65535, 
}

class MIDIChunkData:
	var id: String
	var size: int
	var stream: StreamPeerBuffer

class SMFParseResult:
	var error: int = OK
	var data: SMFData = null

	func _init():
		pass

class SMFData:
	var format_type: int
	var track_count: int
	var timebase: int
	var tracks: Array

	func _init(_format_type: int = 0, _track_count: int = 0, _timebase: int = 480, _tracks: Array = []):
		self.format_type = _format_type
		self.track_count = _track_count
		self.timebase = _timebase
		self.tracks = _tracks

class MIDITrack:
	var track_number: int
	var events: Array

	func _init(_track_number: int = 0, _events: Array = []):
		self.track_number = _track_number
		self.events = _events

class MIDIEventChunk:
	var time: int
	var channel_number: int
	var event: MIDIEvent

	func _init(_time: int = 0, _channel_number: int = 0, _event = null):
		self.time = _time
		self.channel_number = _channel_number
		self.event = _event

class MIDIEvent:
	var type: int

class MIDIEventNoteOff extends MIDIEvent:
	var note: int
	var velocity: int

	func _init(_note: int = 0, _velocity: int = 0):
		self.type = MIDIEventType.note_off
		self.note = _note
		self.velocity = _velocity

class MIDIEventNoteOn extends MIDIEvent:
	var note: int
	var velocity: int

	func _init(_note: int = 0, _velocity: int = 0):
		self.type = MIDIEventType.note_on
		self.note = _note
		self.velocity = _velocity

class MIDIEventPolyphonicKeyPressure extends MIDIEvent:
	var note: int
	var value: int

	func _init(_note: int = 0, _value: int = 0):
		self.type = MIDIEventType.polyphonic_key_pressure
		self.note = _note
		self.value = _value

class MIDIEventControlChange extends MIDIEvent:
	var number: int
	var value: int

	func _init(_number: int = 0, _value: int = 0):
		self.type = MIDIEventType.control_change
		self.number = _number
		self.value = _value

class MIDIEventProgramChange extends MIDIEvent:
	var number: int

	func _init(_number: int = 0):
		self.type = MIDIEventType.program_change
		self.number = _number

class MIDIEventChannelPressure extends MIDIEvent:
	var value: int

	func _init(_value: int = 0):
		self.type = MIDIEventType.channel_pressure
		self.value = _value

class MIDIEventPitchBend extends MIDIEvent:
	var value: int

	func _init(_value: int = 0):
		self.type = MIDIEventType.pitch_bend
		self.value = _value

class MIDIEventSystemEvent extends MIDIEvent:
	var args: Dictionary

	func _init(_args: Dictionary = {}):
		self.type = MIDIEventType.system_event
		self.args = _args

var last_event_type: int = 0

func read_file(path: String) -> SMFParseResult:
	
	
	
	
	

	var result: = SMFParseResult.new()
	var f: = File.new()

	var err: int = f.open(path, f.READ)
	if err != OK:
		result.error = err
		return result
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.set_data_array(f.get_buffer(f.get_len()))
	stream.big_endian = true
	f.close()

	result.data = self._read(stream)
	if result.data == null:
		result.error = ERR_PARSE_ERROR
	return result

func read_data(data: PoolByteArray) -> SMFParseResult:
	
	
	
	
	

	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.set_data_array(data)
	stream.big_endian = true

	var result: = SMFParseResult.new()
	result.data = self._read(stream)
	if result.data == null:
		result.error = ERR_PARSE_ERROR
	return result

func _read(input: StreamPeerBuffer) -> SMFData:
	
	
	
	
	

	var header: MIDIChunkData = self._read_chunk_data(input)
	if header.id != "MThd" and header.size != 6:
		print("expected MThd header")
		return null

	var smf: SMFData = SMFData.new()

	smf.format_type = header.stream.get_u16()
	smf.track_count = header.stream.get_u16()
	smf.timebase = header.stream.get_u16()

	for i in range(0, smf.track_count):
		var track = self._read_track(input, i)
		if track == null:
			return null
		smf.tracks.append(track)

	return smf

func _read_track(input: StreamPeerBuffer, track_number: int) -> MIDITrack:
	
	
	
	
	
	

	var track_chunk: MIDIChunkData = self._read_chunk_data(input)
	if track_chunk.id != "MTrk":
		print("Unknown chunk: " + track_chunk.id)
		return null

	var stream: StreamPeerBuffer = track_chunk.stream
	var time: int = 0
	var events: Array = []

	while 0 < stream.get_available_bytes():
		var delta_time: int = self._read_variable_int(stream)
		time += delta_time
		var event_type_byte: int = stream.get_u8()

		var event: MIDIEvent
		if self._is_system_event(event_type_byte):
			var args = self._read_system_event(stream, event_type_byte)
			if args == null: return null
			event = MIDIEventSystemEvent.new(args)
		else:
			event = self._read_event(stream, event_type_byte)
			if event == null: return null

			
			if (event_type_byte & 128) == 0:
				event_type_byte = self.last_event_type

		events.append(MIDIEventChunk.new(time, event_type_byte & 15, event))

	return MIDITrack.new(track_number, events)

func _is_system_event(b: int) -> bool:
	
	
	
	
	

	return (b & 240) == 240

func _read_system_event(stream: StreamPeerBuffer, event_type_byte: int):
	
	
	
	
	
	

	if event_type_byte == 255:
		var meta_type: int = stream.get_u8()
		var size: int = self._read_variable_int(stream)

		match meta_type:
			MIDISystemEventType.sequence_number:
				return {"type": MIDISystemEventType.sequence_number, "number": stream.get_u16()}
			MIDISystemEventType.text_event, MIDISystemEventType.copyright, MIDISystemEventType.track_name, MIDISystemEventType.instrument_name, MIDISystemEventType.lyric, MIDISystemEventType.cue_point, MIDISystemEventType.marker:
				return {"type": meta_type, "text": self._read_string(stream, size)}

			MIDISystemEventType.midi_channel_prefix:
				if size != 1:
					print("MIDI Channel Prefix length is not 1 byte")
					return null
				return {"type": MIDISystemEventType.midi_channel_prefix, "channel": stream.get_u8()}
			MIDISystemEventType.midi_port_prefix:
				if size != 1:
					print("MIDI Port Prefix length is not 1 byte")
					return null
				return {"type": MIDISystemEventType.midi_port_prefix, "port": stream.get_u8()}
			MIDISystemEventType.end_of_track:
				if size != 0:
					print("End of track with unknown data")
					return null
				return {"type": MIDISystemEventType.end_of_track}
			MIDISystemEventType.set_tempo:
				if size != 3:
					print("Tempo length is not 3 bytes")
					return null
				
				var bpm: int = stream.get_u8() << 16
				bpm |= stream.get_u8() << 8
				bpm |= stream.get_u8()
				return {"type": MIDISystemEventType.set_tempo, "bpm": bpm}
			MIDISystemEventType.smpte_offset:
				if size != 5:
					print("SMPTE length is not 5 bytes")
					return null
				var hr: int = stream.get_u8()
				var mm: int = stream.get_u8()
				var se: int = stream.get_u8()
				var fr: int = stream.get_u8()
				var ff: int = stream.get_u8()
				return {
					"type": MIDISystemEventType.smpte_offset, 
					"hr": hr, 
					"mm": mm, 
					"se": se, 
					"fr": fr, 
					"ff": ff, 
				}
			MIDISystemEventType.beat:
				if size != 4:
					print("Beat length is not 4 bytes")
					return null
				var numerator: int = stream.get_u8()
				var denominator: int = stream.get_u8()
				var clock: int = stream.get_u8()
				var beat32: int = stream.get_u8()
				return {
					"type": MIDISystemEventType.beat, 
					"numerator": numerator, 
					"denominator": denominator, 
					"clock": clock, 
					"beat32": beat32, 
				}
			MIDISystemEventType.key:
				if size != 2:
					print("Key length is not 2 bytes")
					return null
				var sf: int = stream.get_u8()
				var minor: int = stream.get_u8() == 1
				return {
					"type": MIDISystemEventType.key, 
					"sf": sf, 
					"minor": minor, 
				}
			_:
				return {
					"type": MIDISystemEventType.unknown, 
					"meta_type": meta_type, 
					"data": stream.get_partial_data(size)[1], 
				}
	elif event_type_byte == 240:
		var size: int = self._read_variable_int(stream)
		return {
			"type": MIDISystemEventType.sys_ex, 
			"manifacture_id": stream.get_u8(), 
			"data": stream.get_partial_data(size - 1)[1], 
		}
	elif event_type_byte == 247:
		var size: int = self._read_variable_int(stream)
		return {
			"type": MIDISystemEventType.divided_sys_ex, 
			"manifacture_id": stream.get_u8(), 
			"data": stream.get_partial_data(size - 1)[1], 
		}

	print("Unknown system event type: %x" % event_type_byte)
	return null

func _read_event(stream: StreamPeerBuffer, event_type_byte: int) -> MIDIEvent:
	
	
	
	
	
	

	var param: int = 0

	if (event_type_byte & 128) == 0:
		
		param = event_type_byte
		event_type_byte = self.last_event_type
	else:
		param = stream.get_u8()
		self.last_event_type = event_type_byte

	var event_type: int = event_type_byte & 240

	match event_type:
		128:
			return MIDIEventNoteOff.new(param, stream.get_u8())
		144:
			var velocity: int = stream.get_u8()
			if velocity == 0:
				return MIDIEventNoteOff.new(param, velocity)
			else:
				return MIDIEventNoteOn.new(param, velocity)
		160:
			return MIDIEventPolyphonicKeyPressure.new(param, stream.get_u8())
		176:
			return MIDIEventControlChange.new(param, stream.get_u8())
		192:
			return MIDIEventProgramChange.new(param)
		208:
			return MIDIEventChannelPressure.new(param)
		224:
			return MIDIEventPitchBend.new(param | (stream.get_u8() << 7))

	print("unknown event type: %d" % event_type_byte)
	return null

func _read_variable_int(stream: StreamPeerBuffer) -> int:
	
	
	
	
	

	var result: int = 0

	while true:
		var c: int = stream.get_u8()
		if (c & 128) != 0:
			result |= c & 127
			result <<= 7
		else:
			result |= c
			break

	return result

func _read_chunk_data(stream: StreamPeerBuffer) -> MIDIChunkData:
	
	
	
	
	

	var mcd: MIDIChunkData = MIDIChunkData.new()
	mcd.id = self._read_string(stream, 4)
	mcd.size = stream.get_32()
	var new_stream: StreamPeerBuffer = StreamPeerBuffer.new()
	new_stream.set_data_array(stream.get_partial_data(mcd.size)[1])
	new_stream.big_endian = true
	mcd.stream = new_stream

	return mcd

func _read_string(stream: StreamPeerBuffer, size: int) -> String:
	
	
	
	
	
	

	return stream.get_partial_data(size)[1].get_string_from_ascii()

func write(smf: SMF, running_status: bool = false):
	
	
	
	
	
	

	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = true
	
	if stream.put_data("MThd".to_ascii()) != OK:
		return null

	stream.put_u32(6)
	stream.put_u16(smf.format_type)
	stream.put_u16(len(smf.tracks))
	stream.put_u16(smf.timebase)

	for t in smf.tracks:
		if not self._write_track(stream, t, running_status):
			return null

	return stream.data_array

class TrackEventSorter:
	
	
	

	static func sort(a, b):
		if a.time < b.time:
			return true
		return false

func _write_variable_int(stream: StreamPeerBuffer, i: int):
	
	
	
	
	

	var numbers: Array = []

	while true:
		var v: int = i & 127
		i >>= 7
		numbers.append(v)
		if i == 0:
			break

	for i in range(numbers.size() - 1):
		stream.put_u8(numbers.pop_back() | 128)
	stream.put_u8(numbers.pop_back())

func _write_track(stream: StreamPeerBuffer, track, running_status: bool) -> bool:
	
	
	
	
	
	

	var events: Array = track.events.duplicate()
	events.sort_custom(TrackEventSorter, "sort")

	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	buf.big_endian = true
	var time: int = 0
	var last_event_type_seq: int = - 2

	for ec in events:
		var event_omit: bool = false
		var current_event_type: int = - 1
		self._write_variable_int(buf, ec.time - time)
		time = ec.time
		var e = ec.event
		match e.type:
			MIDIEventType.note_off:
				current_event_type = 128 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.note)
				buf.put_u8(e.velocity)
			MIDIEventType.note_on:
				current_event_type = 144 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.note)
				buf.put_u8(e.velocity)
			MIDIEventType.polyphonic_key_pressure:
				current_event_type = 160 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.note)
				buf.put_u8(e.value)
			MIDIEventType.control_change:
				current_event_type = 176 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.number)
				buf.put_u8(e.value)
			MIDIEventType.program_change:
				current_event_type = 192 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.number)
			MIDIEventType.channel_pressure:
				current_event_type = 208 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.value)
			MIDIEventType.pitch_bend:
				current_event_type = 224 | ec.channel_number
				if running_status:
					event_omit = current_event_type == last_event_type_seq
				if not event_omit:
					buf.put_u8(current_event_type)
				buf.put_u8(e.value & 127)
				buf.put_u8((e.value >> 7) & 127)
			MIDIEventType.system_event:
				self._write_system_event(buf, e)
				current_event_type = - 3
		last_event_type_seq = current_event_type

	var track_size: int = buf.get_size()
	if stream.put_data("MTrk".to_ascii()) != OK:
		push_error("cant write track")
		return false
	stream.put_u32(track_size)
	if stream.put_data(buf.data_array) != OK:
		push_error("cant write track")
		return false

	return true

func _write_system_event(stream: StreamPeerBuffer, event):
	
	
	
	
	

	event = event.args
	match event.type:
		MIDISystemEventType.sys_ex:
			stream.put_u8(240)
			self._write_variable_int(stream, event.data.size() + 1)
			stream.put_u8(event.manifacture_id)
			if stream.put_data(event.data) != OK:
				push_error("cant write event data")
				breakpoint
		MIDISystemEventType.divided_sys_ex:
			stream.put_u8(247)
			self._write_variable_int(stream, event.data.size() + 1)
			stream.put_u8(event.manifacture_id)
			if stream.put_data(event.data) != OK:
				push_error("cant write event data")
				breakpoint

		MIDISystemEventType.text_event:
			stream.put_u8(255)
			stream.put_u8(1)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write text event")
				breakpoint
		MIDISystemEventType.copyright:
			stream.put_u8(255)
			stream.put_u8(2)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write copyright text")
				breakpoint
		MIDISystemEventType.track_name:
			stream.put_u8(255)
			stream.put_u8(3)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write track name text")
				breakpoint
		MIDISystemEventType.instrument_name:
			stream.put_u8(255)
			stream.put_u8(4)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write instrument name")
				breakpoint
		MIDISystemEventType.lyric:
			stream.put_u8(255)
			stream.put_u8(5)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write lyric text")
				breakpoint
		MIDISystemEventType.marker:
			stream.put_u8(255)
			stream.put_u8(6)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write marker text")
				breakpoint
		MIDISystemEventType.cue_point:
			stream.put_u8(255)
			stream.put_u8(7)
			self._write_variable_int(stream, event.text.to_ascii().size())
			if stream.put_data(event.text.to_ascii()) != OK:
				push_error("cant write cue point")
				breakpoint

		MIDISystemEventType.midi_channel_prefix:
			stream.put_u8(255)
			stream.put_u8(32)
			stream.put_u8(1)
			stream.put_u8(event.prefix)
		MIDISystemEventType.midi_port_prefix:
			stream.put_u8(255)
			stream.put_u8(33)
			stream.put_u8(1)
			stream.put_u8(event.prefix)
		MIDISystemEventType.end_of_track:
			stream.put_u8(255)
			stream.put_u8(47)
			stream.put_u8(0)
		MIDISystemEventType.set_tempo:
			stream.put_u8(255)
			stream.put_u8(81)
			stream.put_u8(3)
			stream.put_u8((event.bpm >> 16) & 255)
			stream.put_u8((event.bpm >> 8) & 255)
			stream.put_u8(event.bpm & 255)
		MIDISystemEventType.smpte_offset:
			stream.put_u8(255)
			stream.put_u8(84)
			stream.put_u8(5)
			stream.put_u8(event.hr)
			stream.put_u8(event.mm)
			stream.put_u8(event.se)
			stream.put_u8(event.fr)
			stream.put_u8(event.ff)
		MIDISystemEventType.beat:
			stream.put_u8(255)
			stream.put_u8(88)
			stream.put_u8(4)
			stream.put_u8(event.numerator)
			stream.put_u8(event.denominator)
			stream.put_u8(event.clock)
			stream.put_u8(event.beat32)
		MIDISystemEventType.key:
			stream.put_u8(255)
			stream.put_u8(89)
			stream.put_u8(2)
			stream.put_u8(event.sf)
			stream.put_u8(1 if event.minor else 0)
		MIDISystemEventType.unknown:
			stream.put_u8(255)
			stream.put_u8(event.meta_type)
			stream.put_u8(len(event.data))
			if stream.put_data(event.data) != OK:
				push_error("cant write event data")
				breakpoint
		_:
			push_error("not implemented! %d" % event.type)
			breakpoint
