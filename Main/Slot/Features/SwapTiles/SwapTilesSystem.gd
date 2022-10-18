extends Node
export(Vector2) var offset : Vector2 = Vector2(0,0);
export(PackedScene) var center_slash_scene : PackedScene;
signal fx_created;
signal fx_explode;

var wild_fx_scene;
var wild_highlight_fx_scene;
var active_fxs : Array;

func _ready():
	Globals.register_singleton("SwapTilesSystem", self);

func preload_fx():
	if (wild_fx_scene == null): 
		wild_fx_scene = load("res://Main/Slot/Features/SwapTiles/SwapTilesFx.tscn");
		
func preload_highlight():
	if( wild_highlight_fx_scene == null):
		wild_highlight_fx_scene = load("res://Main/Slot/Features/SwapTiles/SwapTilesHighlightFx.tscn");

func activate_slash():
	var fx = center_slash_scene.instance();
	add_child(fx);
	$Swing/AnimationPlayer.play("Swing");
	yield($Swing/AnimationPlayer, "animation_finished")
	fx.queue_free();

func highlight(x,y):
	preload_highlight();
	var fx = wild_highlight_fx_scene.instance();
	add_child(fx);
	fx.global_position = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true) - offset;
	fx.get_node("AnimationPlayer").play("Show");

	
func activate_on(x,y, targetid):
	preload_fx();
	var fx = wild_fx_scene.instance();
	add_child(fx);
	fx.global_position = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true) - offset;
	fx.get_node("AnimationPlayer").play("Show");
	fx.look_at(Globals.singletons["SideCharacters"].get_char("Girl").global_position + Vector2(0.0,-400.0));
	#fx.get_node("SlashFx").rotation = randf() * TAU;

	Globals.singletons["Game"].shake.x += 5.0;
	Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
	Globals.singletons["Slot"].replace_tile(x, y, targetid);
