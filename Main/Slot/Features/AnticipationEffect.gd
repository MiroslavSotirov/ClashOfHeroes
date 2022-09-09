extends Node2D

var index: int;

func _ready():
	$SpineAnimation.visible = false;
	
func show():
	$SpineAnimation.visible = true;
	$SpineAnimation.play_anim("animation", true, 3.5);
	$AnimationPlayer.play("show");

func hide():
	$AnimationPlayer.play("hide");
	yield($AnimationPlayer, "animation_finished");
	$SpineAnimation.visible = false;
