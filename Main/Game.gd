extends Control
class_name Game
export (float) var shakefalloff : float;
var current_state : String = "normal";
var shake : Vector2;

signal splash_end;

func _ready():
	Globals.register_singleton("Game", self);

func switch_to_fs_mode(splash = false, data = Globals.singletons["Networking"].lastround):

	if (current_state == "freespins"): return;
	
	JS.output("freespins", "elysiumgamefeature");
	current_state = "freespins";
	Globals.singletons["Background"].change_to("FreeSpins");
	Globals.singletons["Overlap"].change_to("FreeSpins");
	Globals.singletons["SegmentBar"].hide();
	$SlotContainer/AnimationPlayer.play("winbar_fs");

	Globals.fsm_data["in_freespins"] = true;
	Globals.singletons["Audio"].fade_to("Melody", 0, 1000, 0);
	Globals.singletons["Audio"].change_track("background", "BonusTheme", 1000, 1, 1, 1);
	if (splash):
		Globals.singletons["Audio"].play("FreeSpins");
		yield(Globals.singletons.FreeSpins.show_splash(data.freeSpinsRemaining), "completed");
		emit_signal("splash_end");
	else:
		Globals.singletons.FreeSpins.set_count(data.freeSpinsRemaining)

func switch_to_normal_mode():
	if (current_state == "normal"): return;

	JS.output("freespins", "elysiumgamefeatureend");
	Globals.fsm_data["in_freespins"] = false;
	Globals.singletons.FreeSpins.hide_counter();
	Globals.singletons["Audio"].change_track("background", "MainTheme", 1000, 1, 1, 1);
	current_state = "normal"
	$SlotContainer/AnimationPlayer.play("winbar_normal");
	Globals.singletons["Background"].change_to("Normal");
	Globals.singletons["Overlap"].change_to("Normal");
	Globals.singletons["SegmentBar"].show();

func _input(event):
	if(event is InputEventScreenTouch || event is InputEventMouseButton || event is InputEventKey):
		if(event.pressed): 
			Globals.emit_signal("skip")
#			print("Skip attempt");
	
func _process(delta):
	shake = lerp(shake, Vector2.ZERO, shakefalloff * delta) * -1.0;
	rect_position.x = shake.x * randf();
	rect_position.y = shake.y * randf();
