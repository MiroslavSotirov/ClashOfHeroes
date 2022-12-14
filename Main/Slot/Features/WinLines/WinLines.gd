extends Control

signal show_end;
export (Array, Array) var winlines = [
	[0,0,0,0,0], # 1
	[0,1,0,1,0], # 2
	[0,1,1,1,0], # 3
	[0,1,2,1,0], # 4
	[0,2,0,2,0], # 5
	[0,0,1,2,2], # 6
	[1,1,1,1,1], # 7
	[1,0,1,0,1], # 8
	[1,0,0,0,1], # 9
	[1,0,2,0,1], # 10
	[1,2,1,2,1], # 11
	[1,2,2,2,1], # 12
	[1,2,0,2,1], # 13
	[1,1,0,1,1], # 14
	[2,2,2,2,2], # 15
	[2,1,0,1,2], # 16
	[2,1,2,1,2], # 17
	[2,1,1,1,2], # 18
	[2,0,2,0,2], # 19
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
	
	if (_shown): 
		emit_signal("show_end");
		return;
	Globals.singletons["DividerAnimationPlayer"].play("Hide");
	Globals.singletons["WinlineFrameAnimationPlayer"].play("Show");
	var slot =  Globals.singletons["Slot"];
	slot.tint(Color(0.8, 0.8, 0.8, 1), 0.5, win_data);
	#Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Winline");
			
	_shown = true;
	_win_data = win_data
	var win_line_scene = preload("res://Main/Slot/Features/WinLines/WinLineFx.tscn");
	var promises = [];
	var i = 0;
	for data in winline_data:		
		var winline = win_line_scene.instance();
		$TilesContainer.add_child(winline);
		
		_effects.append(winline);
		var tiles = [];
		var lineid = data[0];
		var count = data[1];
		
		var x = 0;
		for y in winlines[lineid]:
			if(x >= count): break
			tiles.append(Vector2(x,y))
			x+=1;
			
		winline.init(winlines[lineid], tiles, i);
		i+= 1;
		
	yield(get_tree().create_timer(1.0), "timeout"); 
	emit_signal("show_end");

func loop_lines():
	for c in $TilesContainer.get_children(): c.hide();
	var i = 0;
	while _shown:
		if(!_shown): break;
		if($TilesContainer.get_child(i) != null):
			$TilesContainer.get_child(i).popup();
		yield(get_tree().create_timer(1.0), "timeout")
		if(!_shown): break;
		$TilesContainer.get_child(i).hide();
		i+=1;
		if(i >= $TilesContainer.get_child_count()): i=0;
		
func hide_lines():
	if (!_shown): return;
	Globals.singletons["DividerAnimationPlayer"].play("Show");
	Globals.singletons["WinlineFrameAnimationPlayer"].play("Hide");
	Globals.singletons["Slot"].tint(Color.white, 0.2);
	#Globals.singletons["WinlinesFadeAnimationPlayer"].play("To_Normal");
	for c in $TilesContainer.get_children():
		$TilesContainer.remove_child(c);
		
	for x in _win_data:
		for y in _win_data[x]:
			Globals.singletons["Slot"].get_tile_at(x,y).set_layer(0);

	_effects.clear();
	_shown = false;
