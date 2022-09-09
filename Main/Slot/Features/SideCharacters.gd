extends Node

signal animation_finished(name);

export (bool) var hide_on_portrait = true;

func _ready():
	Globals.register_singleton(name, self);
	Globals.connect("layoutchanged", self, "_on_layout_changed");
	_on_layout_changed(Globals.current_layout);
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished");
	$Character.connect("animation_complete", self, "_on_animation_finished");

func electrify_sword():
	$SwordEffect/AnimationPlayer.play("show");
	$SwordEffect/effect1.frame = 0;
	$SwordEffect/effect2.frame = 0;
	$SwordEffect/effect1.play("active");
	$SwordEffect/effect2.play("active");
	Globals.singletons["Audio"].play("Electricity4");

func electrify():
	#CharacterLanding
	Globals.singletons["Audio"].play("CharacterLanding", 0.6);
	$LightingBolt.frame = 0;
	$LightingBolt.visible = true;
	$LightingBolt.play("hit");
	yield($LightingBolt,  "animation_finished")
	$LightingBolt.visible = false;

func lightning_show(type = "intro"):
	$Lightning/AnimationPlayer.play("Show");

	if (type == "intro"):
		$Character.play_anim("RW_appear", false, 2);
		yield($Character, "animation_complete");
		$Character.play_anim("idle1", true);
	else:
		$Character.play_anim_then_loop("respin_lifting", "idle1");
	
	yield(Globals.get_tree(), "idle_frame");
	$Character.setup_pose_trigger = true;

func play(anim, delay = 0.0):
	if (delay > 0.0):
		 yield(get_tree().create_timer(delay), "timeout");
	$AnimationPlayer.play(anim);

func spine_play(anim, idle = "idle1", loop = false):
	$Character.reset_pose();
	if (idle == null):
		$Character.play_anim(anim, loop);
	else:
		$Character.play_anim_then_loop(anim, idle);
	
func get_char():
	return $Character;

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

