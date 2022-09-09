extends Control

signal show_end;

var _win_data = [];
var _effects = {};

var _shown = false;

func _ready():
	Globals.register_singleton("WinLines", self);
	yield(Globals, "allready")
	rect_position = Globals.singletons["Slot"].get_node("ReelContainer").rect_position;
	rect_size = Globals.singletons["Slot"].get_node("ReelContainer").rect_size;
	$TilesContainer.z_index = 2;
	
func show_lines(win_data):
	print(win_data)
	if (_shown): return;
	
	var slot =  Globals.singletons["Slot"];
	slot.tint(Color(0.27, 0.27, 0.27, 1), 0.5, win_data);
	Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Winline");
	
	_shown = true;
	_win_data = win_data
	var win_line_scene = preload("res://Main/Slot/Components/WinlineTile.tscn");
	var promises = [];
	for i in win_data:
		for j in win_data[i]:
			var wintile = win_line_scene.instance();
			$TilesContainer.add_child(wintile);
			_effects[i] = _effects[i] if _effects.has(i) else [];
			_effects[i].append(wintile);
			var pos = slot.get_tile_default_position(i, j, true);
			promises.append(wintile.init(pos));
	
	yield(Promise.all(promises), "completed");
	emit_signal("show_end");

func loop_lines():

	for i in _effects:
		yield(get_tree().create_timer(0.06), "timeout")
		for effect in _effects[i]:
			effect.loop()

func hide_lines():
	if (!_shown): return;
	Globals.singletons["Slot"].tint(Color.white, 0.2, _win_data);
	Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Normal");
	for c in $TilesContainer.get_children():
		$TilesContainer.remove_child(c);

	_effects = {};
	_shown = false;
