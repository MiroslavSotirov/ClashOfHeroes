extends Node

var animationPlayer : AnimationPlayer;
var fightfx : Node2D;

func _ready():
	Globals.register_singleton(name, self);
	animationPlayer = $RobotFightFx/AnimationPlayer;
	fightfx = $RobotFightFx;
