extends Node2D

func _ready():
	$Left.play_anim("animation", true, 0.4);
	$Right.play_anim("animation", true, 0.4);
