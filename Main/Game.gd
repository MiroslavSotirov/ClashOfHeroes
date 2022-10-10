extends Control
class_name Game
export (float) var shakefalloff : float;
var current_state : String = "normal";
var shake : Vector2;

signal splash_end;

func _ready():
	Globals.register_singleton("Game", self);

func _input(event):
	if(event is InputEventScreenTouch || event is InputEventMouseButton || event is InputEventKey):
		if(event.pressed): 
			Globals.emit_signal("skip")
#			print("Skip attempt");
	
func _process(delta):
	shake = lerp(shake, Vector2.ZERO, shakefalloff * delta) * -1.0;
	rect_position.x = shake.x * randf();
	rect_position.y = shake.y * randf();
