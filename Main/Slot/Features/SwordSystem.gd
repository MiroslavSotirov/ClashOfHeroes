extends Node
export(Vector2) var offset : Vector2 = Vector2(0,300);
signal sword_fallen;
signal sword_explode;

var active_swords : Array;
var _resources = null;
func _ready():
	Globals.register_singleton("SwordSystem", self);

func preload_resources():
	if (_resources != null): return;
	_resources = {
		"sword": load("res://Main/Slot/Components/FallingSword.tscn"),
		"rocks": load("res://Main/Slot/Components/FallingSwordRocks.tscn")
	}

func fall_sword_on(reelid):
	Globals.singletons["Audio"].play("SwordImpact", 0.4);
	var sword = _resources.sword.instance();
	$SwordContainer.add_child(sword);
	active_swords.append(sword);
	sword.global_position = Globals.singletons["Slot"].get_tile_global_default_position(reelid, Globals.visibleTilesCount-1, true) - offset;
	
	yield(get_tree().create_timer(0.3), "timeout");
	var rocks = _resources.rocks.instance();
	add_child(rocks);
	rocks.global_position = sword.global_position;
	rocks.play_anim("Rocks", false);
	Globals.singletons["Game"].shake.y += 10.0;
	yield(rocks,"animation_complete");
	rocks.queue_free();
	emit_signal("sword_fallen");
	
func explode_swords():
	Globals.singletons["Audio"].play("SwordBreak");
	yield(get_tree().create_timer(0.1), "timeout");
	for sword in active_swords.duplicate():
		explode_sword(sword);
		yield(get_tree().create_timer(0.05), "timeout");
		
func explode_sword(sword):
	active_swords.erase(sword);
	sword.play_anim("step3", false);
	yield(get_tree().create_timer(0.3), "timeout");
	var pos = sword.global_position;
	$SwordContainer.remove_child(sword);
	add_child(sword);
	sword.global_position = pos;
	Globals.singletons["FaderBright"].tween(0.3,0.0,0.5);
	Globals.singletons["Game"].shake += Vector2.ONE * 12.0;
	yield(sword,"animation_complete");
	sword.queue_free();

#func _process(delta):
#	if(Input.is_action_just_pressed("ui_left")):
#		var character = Globals.singletons["SideCharacter"].get_char();
#		character.play_anim_then_loop("FS_lifting", "FS_idle");
#		yield(get_tree().create_timer(1), "timeout");
#		fall_sword_on(3)
#		yield(get_tree().create_timer(0.1), "timeout");
#		fall_sword_on(1)
#		yield(get_tree().create_timer(0.1), "timeout");
#		fall_sword_on(2)
#		yield(get_tree().create_timer(0.1), "timeout");
#		fall_sword_on(4)
#		yield(get_tree().create_timer(2.0), "timeout");
#		character.play_anim("FS_thrusting", false);
#		yield(get_tree().create_timer(0.5), "timeout");
#		explode_swords();
#		yield(character, "animation_complete");
#		character.play_anim_then_loop("FS_back", "idle1");
#		yield(get_tree().create_timer(0.5), "timeout");

