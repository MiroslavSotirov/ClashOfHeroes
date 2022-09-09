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
		wild_fx_scene = load("res://Main/Slot/Components/WildFx.tscn");

func activate_on(x,y):
	var fx = wild_fx_scene.instance();
	add_child(fx);
	active_fxs.append(fx);
	fx.global_position = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true) - offset;
	fx.play_anim_then_loop("popup", "idle");
	fx.get_node("SlashFx").rotation = randf() * TAU;
#	Globals.singletons["Audio"].play("Electricity");
	Globals.singletons["Game"].shake.y += 5.0;
	Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
	yield(fx,"animation_complete");
	emit_signal("fx_created");
	

func activate_all():
	Globals.singletons["Game"].shake += Vector2.ONE * 20.0;
	Globals.singletons["FaderBright"].tween(0.5,0.0,0.5);
	for fx in active_fxs:
		var wild = fx.get_node("Wild");
		wild.play_anim_then_loop("popup", "idle");
		fx.get_node("AnimationPlayer").play("Show")
	
func deactivate_all():
	for fx in active_fxs.duplicate():
		deactivate(fx);
#		yield(get_tree().create_timer(0.1), "timeout");
		
func deactivate(fx):
	active_fxs.erase(fx);
	fx.play_anim("close", false);
	fx.get_node("AnimationPlayer").play("Hide")
	yield(fx,"animation_complete");
	fx.queue_free();
