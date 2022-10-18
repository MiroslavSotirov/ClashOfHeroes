extends Control

signal pressed;

func _ready():
	Globals.register_singleton("Intro", self);

func show():
	$Elements/Logo/SpineSprite.play_anim_then_loop('popup', "idle");
	Globals.singletons["Audio"].play("LogoPopup");
	Globals.singletons["Audio"].play_after("BothAppear", 1000);
	$Elements/RobotLeft.play_anim_then_loop('fall', "front_idle");
	$Elements/RobotRight.play_anim_then_loop('fall', "front-idle");
	yield(Globals.get_tree().create_timer(0.05), "timeout");
	$Elements/CrashLeft.play_anim("animation", false);
	$Elements/CrashRight.play_anim("animation", false);
	$Elements/CrashLeft.visible = true;
	$Elements/CrashRight.visible = true;
	Globals.singletons["Game"].shake.y += 60.0;
	yield(get_tree().create_timer(1), "timeout");
	show_chr("Boy");
	show_chr("Girl");
	$Elements/Message/AnimationPlayer.play("show");
	$ClickWaiter.connect("pressed", self, "emit_signal", ["pressed"], CONNECT_ONESHOT);
	$ClickWaiter.enabled = true;

func show_chr(chr):
	chr = "Elements/"+chr;
	get_node(chr).visible = true;
	get_node(chr).play_anim("disappear", true);
	get_node(chr).set_timescale(3.0, false);
	get_node(chr).reset_pose();
	get_node(chr).get_animation_state().get_current(0).set_reverse(true);
	yield(get_node(chr), "animation_completed")
	get_node(chr).reset_pose();
	get_node(chr).play_anim("idle", true, 0.5);
