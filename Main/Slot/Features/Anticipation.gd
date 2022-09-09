extends Node

export(Resource) var spine_data;
export (Color) var darken_color = Color.black;
export (float) var extra_reel_time = 2; # the additional tile added per reel
#export(String) var effect_path = "res://Main/Slot/Features/Anticipation.tscn";

var Effect = preload("res://Main/Slot/Features/Anticipation.tscn");
var _effects = {};
var _tweens = {};

# TODO export this
var cfgs = [
	{ "id": 12, "posible_reels": [0, 1, 2, 3, 4], "activation_count": 2, "max_count": 5 }
]

signal ended;
signal ended_on_reel;
signal activated;

func _ready():
	Globals.register_singleton("Anticipation", self);
	
func show(data):
	var initial = data.reels.find(true);

	if (initial <= 0): return;

	var last = data.reels.find_last(true);
	var reels = Globals.singletons["Slot"].reels;
	var activatingReel = reels[initial - 1];
	var deactivatingReel = reels[last];
	var effects = _add_effects(data.reels, reels, initial, last);
	
	activatingReel.connect("onstopped", self, "_activate", [data, reels, effects], CONNECT_ONESHOT);
	deactivatingReel.connect("onstopped", self, "_deactivate", [data, reels], CONNECT_ONESHOT);

func parse_data(data):
	var count = {};
	var reels = [];
	var tiles = [];
	var value = false;

	for i in data.size():
		reels.append(false);
		
		for j in cfgs.size():
			var cfg = cfgs[j]
			if (cfg == null): continue;
			elif (i == 0):
				reels[i] = false
			else:
				var hasAnticipation = (_check_reel(data[i - 1], cfg, count) && cfg.posible_reels.has(i));
				reels[i] = reels[i] || hasAnticipation;
				if (hasAnticipation):
					tiles.append(cfg.id)
					value = true;
	
	return { "reels": reels, "tiles": tiles, "value": value };
#	return { "reels": [false, false, true, true, true], "tiles": [1,2,3], "value": true }; 

func _check_reel(reel_data, cfg, count):
	var mininum = cfg.activation_count if cfg.activation_count else cfg.max_count - 1;
	var maximum = cfg.max_count;
	for i in reel_data.size():
		var tile = int (reel_data[i]);

		if (tile == cfg.id):
			count[tile] = count[tile] + 1 if count.has(tile) else 1;

	return count.has(cfg.id) && count[cfg.id] >= mininum && count[cfg.id] < maximum;
	
func _activate(_i, data, reels, effects):
	for effect in effects: effect.show();
	_tint_reels(data, reels, darken_color);

	emit_signal("activated");

func _deactivate(i, data, reels):
	_tint_reels(data, reels, Color.white);

func _add_effects(data, reels, initial, last_index):
	var effects = [];
	var j = 0;
	for i in (range(data.size())):
		if (data[i]):
			j += 1;
			var effect = _add_on_reel(reels[i], initial, last_index)
			effects.append(effect);

		reels[i].add_extra_duration(extra_reel_time * j);
	return effects;

func _tint_reels(data, reels, color):
	for reel in reels:
		if (!data.reels[reel.index]):
			for tile in reel.tiles:
				if !(data.tiles.has(int(tile.id))): tile.tint(color, 0.5);

func _add_on_reel(reel, initial, last_index):
	if (!_effects.has(reel.index)):
		var e = Effect.instance();
		e.index = reel.index - initial;
		reel.add_child(e);
		_effects[reel.index] = e;
	
	var effect = _effects[reel.index];
	reel.move_child(effect, 0);
#	reel.add_extra_duration(extra_reel_time);
	reel.connect("stopeasingbegin", self, "_on_reel_stopped", [reel, effect, last_index], CONNECT_ONESHOT);
	
	return effect;

func _on_reel_stopped(reel, effect, last_index):
	yield(effect.hide(), "completed");
	emit_signal("ended_on_reel", reel.index, last_index, effect.index);

	if (reel.index == last_index):
		emit_signal("ended");

