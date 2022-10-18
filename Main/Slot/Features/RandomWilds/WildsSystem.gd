extends Node
export(Vector2) var offset : Vector2 = Vector2(0,300);
signal fx_created;
signal fx_explode;

var wild_fx_scene;
var active_fxs : Array;

func _ready():
	Globals.register_singleton("WildsSystem", self);

func preload_resources():
	if (wild_fx_scene == null): 
		wild_fx_scene = load("res://Main/Slot/Features/RandomWilds/RandomWildFx.tscn");

func activate_on(x,y):
	preload_resources();
	var fx = wild_fx_scene.instance();
	add_child(fx);
	active_fxs.append(fx);
	fx.global_position = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true) - offset;
	#fx.play_anim_then_loop("popup", "idle");
	fx.get_node("SlashFx").rotation = randf() * TAU;

	Globals.singletons["Game"].shake.y += 2.0;
	Globals.singletons["Audio"].play("JuniorMech");
	Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
	
func deactivate_all():
	for fx in active_fxs.duplicate():
		deactivate(fx);
	
	for pos in Globals.singletons["Networking"].lastround.parsed.randomwild_data.tiles:
		Globals.singletons["Slot"].replace_tile(pos.x, pos.y, 10);
		
func deactivate(fx):
	active_fxs.erase(fx);
	fx.queue_free();
