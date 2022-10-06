extends Control

signal show_end;
export (Array, Array) var winlines = [
	[0,0,0,0,0], # 1
	[0,1,0,1,0],
	[0,1,1,1,0],
	[0,1,2,1,0],
	[0,2,0,2,0],
	[0,0,1,2,2],
	[1,1,1,1,1],
	[1,0,1,0,1],
	[1,0,0,0,1],
	[1,0,2,0,1], # 10
	[1,2,1,2,1],
	[1,2,2,2,1],
	[1,2,0,2,0],
	[1,1,0,1,1],
	[2,2,2,2,2],
	[2,1,0,1,2],
	[2,1,2,1,2],
	[2,1,1,1,2],
	[2,0,2,0,2],
	[2,2,1,0,0] # 20
];

var _win_data = [];
var _effects = [];

var _shown = false;

func _ready():
	Globals.register_singleton("WinLines", self);
	yield(Globals, "allready")
	rect_position = Globals.singletons["Slot"].get_node("ReelContainer").rect_position;
	rect_size = Globals.singletons["Slot"].get_node("ReelContainer").rect_size;
	$TilesContainer.z_index = 2;
	
func show_lines(winline_data, win_data):
	print(winline_data, win_data)
	if (_shown): 
		emit_signal("show_end");
		return;
	
	var slot =  Globals.singletons["Slot"];
	slot.tint(Color(0.27, 0.27, 0.27, 1), 0.5, win_data);
	#Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Winline");
	for x in win_data:
		for y in win_data[x]:
			Globals.singletons["Slot"].get_tile_at(x,y).set_layer(3);
			
	_shown = true;
	_win_data = win_data
	var win_line_scene = preload("res://Main/Slot/Features/WinLines/WinLineFx.tscn");
	var promises = [];
	var i = 0;
	for line in winline_data:
		var winline = win_line_scene.instance();
		$TilesContainer.add_child(winline);
		winline.init(winlines[line], i);
		_effects.append(winline);
		i+= 1;
		yield(get_tree().create_timer(0.06), "timeout"); 
		
	yield(get_tree().create_timer(0.06), "timeout"); 
	emit_signal("show_end");

func loop_lines():
	pass;

func hide_lines():
	if (!_shown): return;
	Globals.singletons["Slot"].tint(Color.white, 0.2, _win_data);
	#Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Normal");
	for c in $TilesContainer.get_children():
		$TilesContainer.remove_child(c);
		
	for x in _win_data:
		for y in _win_data[x]:
			Globals.singletons["Slot"].get_tile_at(x,y).set_layer(0);

	_effects.clear();
	_shown = false;
