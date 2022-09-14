class_name WinTile extends Node2D

func init(_position):
	position = _position;
	$AnimationPlayer.play("Show");
	yield($AnimationPlayer, "animation_finished");

func loop():
	$AnimationPlayer.play("fx");

