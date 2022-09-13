extends Control

signal pressed;

func _ready():
	Globals.register_singleton("Intro", self);
	$Elements/IntroCharacter.visible = false;

func show():
	$Elements/Logo/SpineSprite.play_anim_then_loop('popup', "idle");
	Globals.singletons["Audio"].play("LogoPopup", 0.5);
	yield(get_tree().create_timer(1), "timeout");
		
	$Elements/Message/AnimationPlayer.play("show");
	$ClickWaiter.connect("pressed", self, "emit_signal", ["pressed"], CONNECT_ONESHOT);
	$ClickWaiter.enabled = true;
