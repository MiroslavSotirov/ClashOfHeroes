extends Node

signal animation_finished(name);

func _ready():
	Globals.register_singleton(name, self);

func play(anim, delay = 0.0):
	if (delay > 0.0): yield(get_tree().create_timer(delay), "timeout");
	$AnimationPlayer.play(anim);

func spine_play(anim, idle = "idle", loop = false):
	$SpineSprite.reset_pose();
	if (idle == null):
		$SpineSprite.play_anim(anim, loop);
	else:
		$SpineSprite.play_anim_then_loop(anim, idle);
	
func get_spine_sprite():
	return $SpineSprite;

func _on_animation_finished(name, track = null, __ = null):
	if (track == null):
		emit_signal("animation_finished", name);
	else:
		var spine_anim_name = track.get_animation().get_anim_name();
		emit_signal("animation_finished", spine_anim_name);
