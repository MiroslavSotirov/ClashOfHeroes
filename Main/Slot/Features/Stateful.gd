extends Node
class_name Stateful
var _stake = 0;
var _state = {};

func _ready():
	Globals.register_singleton("Stateful", self);

func init(last_round, stake):
	update_state_from_round(last_round);
	set_stake(stake);

func update_state(state, value = null):
	if !state: return null;
	for i in state:
		var k = float(i) if float(i) != 0 else i;
		_state[k] = state[i]

	return get_value(value) if value else null;
	
func update_state_from_round(data, value = null):
	if (!data.has("features")): return null;
	var map = null;
	for feature in data.features:
		if feature.type == "StatefulMap":
			map = feature.data.map;

	return update_state(map, value);
	
func set_stake(stake, value = null):
	_stake = float(stake);
	return get_value(value) if value else null;
	
func get_value(value, stake = _stake):
	return _state[stake][value] if _state.has(stake) && _state[stake].has(value) else null;

func log_state():
	print(_stake);
	print(_state);
	print(_state[_stake]);
