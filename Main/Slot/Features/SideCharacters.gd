extends Node

signal animation_finished(name);

export (bool) var hide_on_portrait = true;

func _ready():
	Globals.register_singleton(name, self);
	Globals.connect("layoutchanged", self, "_on_layout_changed");
	_on_layout_changed(Globals.current_layout);
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished");

func show_chr(chr):
	var character = get_node(chr);
	if (character == null):
		print("no such character", character);
		return;

	character.visible = true;
	character.play_anim("disappear", true);
	character.set_timescale(3.0, false);
	character.reset_pose();
	character.get_animation_state().get_current(0).set_reverse(true);
	yield(character, "animation_completed")
	character.reset_pose();
	character.play_anim("idle", true, 0.5);
	
func hide_chr(chr):
	var character = get_node(chr);
	if (character == null):
		print("no such character", character);
		return;

	character.visible = true;
	character.play_anim("disappear", true);
	character.set_timescale(3.0, false);
	yield(character, "animation_completed")
	character.visible = false;
	
func play(anim, delay = 0.0):
	if (delay > 0.0):
		 yield(get_tree().create_timer(delay), "timeout");
	$AnimationPlayer.play(anim);

func spine_play(character, anim, idle = "idle", loop = false, speed = 1.0):
	get_node(character).reset_pose();
	if (idle == null):
		get_node(character).play_anim(anim, loop);
	else:
		get_node(character).play_anim_then_loop(anim, idle);
		
	if(speed != 1.0): get_node(character).set_timescale(speed, false);
	
func get_char(character):
	return get_node(character);

func _on_animation_finished(name, track = null, __ = null):
	if (track == null):
		emit_signal("animation_finished", name);
	else:
		var spine_anim_name = track.get_animation().get_anim_name();
		emit_signal("animation_finished", spine_anim_name);

func _on_layout_changed(layout):
	if (!hide_on_portrait): return;
	
	if (layout.name == "portrait"):
		hide_chars();
	else:
		show_chars();

func show_chars():
	if($AnimationPlayerRoot.assigned_animation != "Show"):
		$AnimationPlayerRoot.play("Show");

func hide_chars():
	if($AnimationPlayerRoot.assigned_animation != "Hide"):
		$AnimationPlayerRoot.play("Hide");
