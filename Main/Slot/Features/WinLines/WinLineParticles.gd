extends Line2D
export (Array, Texture) var textures;
var positions = [];
var _counter = 0.1;

func _ready():
	pass;
	
func init(line, id):
	add_point(Vector2(-200.0, 0.0));
	var x = 0;
	for y in line:
		var pos = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true);
		if(x == 0): 
			global_position = pos;
			add_point(Vector2.ZERO);
		else: add_point(to_local(pos));
		positions.append(to_local(pos))
		x+= 1;
	add_point(positions[len(positions)-1]+Vector2(200.0, 0.0));
	global_position.y += id * 5.0;
	$AnimationPlayer.play("Show");

func _process(delta):
	_counter -= delta;
	if(_counter < 0.0):
		_counter += 0.1;
		texture = textures[randi()%len(textures)];
