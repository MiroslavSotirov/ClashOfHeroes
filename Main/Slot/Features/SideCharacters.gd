extends Node

signal animation_finished(name);

export (bool) var hide_on_portrait = true;

func _ready():
	Globals.register_singleton(name, self);
	Globals.connect("layoutchanged", self, "_on_layout_changed");
	_on_layout_changed(Globals.current_layout);
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished");
	#$Character.connect("animation_complete", self, "_on_animation_finished");

func electrify_sword():
	Globals.singletons["Audio"].play("Electricity4");

func electrify():
	#CharacterLanding
	Globals.singletons["Audio"].play("CharacterLanding", 0.6);
	
func show_chr(chr):
	get_node(chr).visible = true;
	get_node(chr).play_anim("disappear", true);
	get_node(chr).get_animation_state().get_current(0).set_reverse(true);
	yield(get_node(chr), "animation_completed")
	get_node(chr).reset_pose();
	get_node(chr).play_anim("idle", true, 0.5);

func lightning_show(type = "intro"):
	pass
	
func play(anim, delay = 0.0):
	if (delay > 0.0):
		 yield(get_tree().create_timer(delay), "timeout");
	$AnimationPlayer.play(anim);

func spine_play(character, anim, idle = "idle", loop = false):
	get_node(character).reset_pose();
	if (idle == null):
		get_node(character).play_anim(anim, loop);
	else:
		get_node(character).play_anim_then_loop(anim, idle);
	
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
	
	var anim = $AnimationPlayerRoot;
	if (layout.name == "portrait" && anim.assigned_animation != "Hide"): anim.play("Hide");
	elif (anim.assigned_animation != "Show"): anim.play("Show");

