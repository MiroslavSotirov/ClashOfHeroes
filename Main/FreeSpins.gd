extends Node2D

var _count = 0;

func _ready():
	Globals.register_singleton("FreeSpins", self);
	Globals.connect("layoutchanged", self, "_on_layout_changed");
	_on_layout_changed(Globals.current_layout);

func show_splash(count: int):
	$Splash.visible = true;
	$Splash/Logo/Label.text = str(count);
	$Splash/AnimationPlayer.play("ShowBg");
	$Splash/Logo/Sprite.play_anim("popup", false, 0.8);
	yield($Splash/Logo/Sprite, "animation_complete");

	$Splash/Logo/Sprite.play_anim("idle", true);
	$Splash/AnimationPlayer.play("Show")
	yield($Splash/AnimationPlayer, "animation_finished");
	
	$Splash/ClickWaiter.enabled = true;
	yield($Splash/ClickWaiter, "pressed");
	
	$Splash/Logo/Sprite.play_anim("close", false);
	$Splash/AnimationPlayer.play("HideBg");
	set_count(count);
	
	yield(get_tree().create_timer(2.0), "timeout");
	$Splash.visible = false;

func set_count(value: int):
	if (value == _count || value < 0): return;

	_count = value;
	var text = str(_count);
	var isVisible = value > 0;
	
	$Counter.visible = true;
	$Counter/Landscape/Label.text = text;
	$Counter/Portrait/Label.text = text;
	$Counter/Landscape/Label.visible = isVisible;
	$Counter/Portrait/Label.visible = isVisible;

func hide_counter():
	$Counter.visible = false;

func _on_layout_changed(layout):
	var isPotrait = layout.name == "portrait";
	$Counter/Landscape.visible = !isPotrait;
	$Counter/Portrait.visible = isPotrait;
