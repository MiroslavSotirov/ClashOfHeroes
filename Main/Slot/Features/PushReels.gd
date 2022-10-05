extends Node2D
signal start_push;
signal start_spin;

func _ready():
	Globals.register_singleton(name, self);

func play_anim():
	visible = true;
	$Robot.reset_pose();
	$Robot.play_anim("fall", false);
	yield(Globals.get_tree().create_timer(0.05), "timeout");
	$Crash.play_anim("animation", false);
	yield(Globals.get_tree().create_timer(0.1), "timeout");
	Globals.singletons["Game"].shake.y += 20.0;
	Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
	yield($Robot, "animation_completed");
	$Robot.play_anim("push", false);
	yield(Globals.get_tree().create_timer(0.8), "timeout");
	Globals.singletons["Game"].shake.x += 20.0;
	emit_signal("start_push");
	yield($Robot, "animation_completed");
	$Robot.play_anim("fly", false);
	$Robot.reset_pose();
	yield(Globals.get_tree().create_timer(0.3), "timeout");
	for i in 5:
		Globals.singletons["Game"].shake.y += 8.0;
		if(i==3):	emit_signal("start_spin");
		yield(Globals.get_tree().create_timer(0.1), "timeout");
	Globals.singletons["Game"].shake.y -= 50.0;
