extends Node
export(Vector2) var offset;
var animationPlayer : AnimationPlayer;
var fightfx : Node2D;

func _ready():
	Globals.register_singleton(name, self);
	animationPlayer = $RobotFightFx/AnimationPlayer;
	fightfx = $RobotFightFx;

#{data:{from:4, positions:[0, 1, 2, 3, 4, 5, 6, 7, 8], tileid:10}, id:0, type:ExpandingWild}
func set_pos(x,y):
	$RobotFightFx.global_position = Globals.singletons["Slot"].get_tile_global_default_position(x, y, true)+offset;
