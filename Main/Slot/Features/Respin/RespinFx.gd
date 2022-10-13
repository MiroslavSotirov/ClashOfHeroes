extends Node2D
signal start_spin;

func _ready():
	Globals.register_singleton(name, self);

func play_anim():
	visible = true;
	$Crash.visible = false;
	$Respin.visible = false;
	$Robot.play_anim("fall", false);
	$Robot.reset_pose();
	yield(Globals.get_tree().create_timer(0.05), "timeout");
	Globals.singletons["Background"].change_to("Special", 0.5);
	Globals.singletons["FlameAnimationPlayer"].play("Show");
	$Crash.play_anim("animation", false);
	$Crash.visible=true;
	yield(Globals.get_tree().create_timer(0.1), "timeout");
	
	Globals.singletons["Game"].shake.y += 20.0;
	Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
	yield(Globals.get_tree().create_timer(0.9), "timeout");
	$Robot.play_anim("fly", false);
	yield(Globals.get_tree().create_timer(0.3), "timeout");
	for i in 5:
		Globals.singletons["Game"].shake.y += 8.0;
		yield(Globals.get_tree().create_timer(0.1), "timeout");
	Globals.singletons["Game"].shake.y -= 50.0;

	emit_signal("start_spin");
	$Respin.visible = true;
	$Respin.play_anim("popup", false);
	yield($Respin, "animation_completed")
	$Respin.play_anim("close", false);
	yield($Respin, "animation_completed")
	$Respin.visible = false;

