extends Line2D
export (Array, Texture) var textures;
var tilepositions = [];
var positions = [];
var _counter = 0.1;
var _time = 0.0;

func _ready():
	pass;
	
func init(line, tilepositions, id):
	positions.append(Vector2(-300.0, 0.0));
	var x = 0;
	for y in line:
		var pos = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true);
		if(x == 0): global_position = pos;
		positions.append(to_local(pos))
		x+= 1;
	positions.append(positions[len(positions)-1]+Vector2(200.0, 0.0))
	self.tilepositions = tilepositions;
	global_position.y += id * 5.0;
	popup();

func popup():
	visible = true;
	$AnimationPlayer.stop();
	$AnimationPlayer.play("Show");
	for pos in tilepositions:
		var tile = Globals.singletons["Slot"].get_tile_at(pos.x, pos.y);
		tile.set_layer(3);
		tile.win_popup();
		
func hide():
	visible = false;
	for pos in tilepositions:
		var tile = Globals.singletons["Slot"].get_tile_at(pos.x, pos.y);
		tile.modulate = Color(0.2, 0.2, 0.2, 1);
		
	

func _process(delta):
	if(!visible): return;
	_counter -= delta;
	if(_counter < 0.0):
		_counter += 0.1;
		texture = textures[randi()%len(textures)];
		
	_time += delta*5.0;
	if(_time < 1.0):
		add_point(get_pos_in_line(_time));

func get_pos_in_line(t):
	var ln = len(positions)-1;
	var n = floor(ln*t);
	var f = fmod(t, 1.0/ln) * ln;

	return lerp(positions[n], positions[n+1], f);

func clear_points():
	_time = 0.0;
	.clear_points();
