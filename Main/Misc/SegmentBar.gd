extends Node

#export (int) var amount = -1 setget set_amount, get_amount;
export (int) var nodecount = 5;
signal amountupdated(value);

var _updating = false;
var _amount = -1;
var _goal = _amount;

const ANIMATIONS = {
	0: {"idle": "idle_nosegments", "popup": "popup_nosegments"},
	1: {"idle": "idle_slot1", "popup": "popup_slot1"},
	2: {"idle": "idle_slot2", "popup": "popup_slot2"},
	3: {"idle": "idle_slot3", "popup": "popup_slot3"},
	4: {"idle": "idle_slot4", "popup": "popup_slot4"},
	5: {"idle": "idle_slot5", "popup": "popup_slot5"},
	"final": {"idle": "idle_fullsegments", "popup": "popup_fullsegments"},
};

func _ready():
	Globals.register_singleton("SegmentBar", self);
	$AnimationPlayer.play("idle");
	$Shield.visible = false;

#func _process(delta):
#	if Input.is_action_just_pressed("ui_page_up"):
#		var next = 0 if _amount == nodecount else _amount + 1;
#		update(next);

func reset(value = 0):
	var v = min(nodecount, int(value));
	print("reseting to ", v)
	_initialise(v);

func update(value, speed = null, delay = 0):
	var v = min(nodecount, int(value));
	# if the value is not valid, nothing happens
	if (v == _amount || v < 0 || !is_instance_valid(self) || get_parent() == null): return;
	var _speed = speed if speed != null else max(1 + (v - _amount - 1) * 0.35, 1);
	
	# the amount is set for the first time
	if (_amount == -1):
		_initialise(v);
		return;

	_goal = v;
	if (_updating): return;
	
	_updating = true;
	yield(get_tree().create_timer(delay), "timeout");
	var next = _amount + 1 if v > _amount else v;
	yield(self._set_amount(next, _speed), "completed");
	_updating = false;
	
	if (_amount != _goal):
		update(_goal, _speed);
	else:
		emit_signal("amountupdated", _amount);
		var animation = ANIMATIONS.final.idle if _goal == nodecount else ANIMATIONS[_goal].idle;
		$Shield.play_anim(animation, true);

func get_amount(): return _amount;

func wait_to_update():
	if (!_updating): return Promise.resolve();
	yield(self, "amountupdated");

func show():
	$FadePlayer.play("show");

func hide():
	$FadePlayer.play("hide");

func _set_amount(value, speed = 1):
	var v = int(value);
	_amount = v;

	$Shield.reset_pose();
	$Shield.play_anim(ANIMATIONS[v].popup, false, speed);
	if (v != 0):
		Globals.singletons["Audio"].play("SideShieldSlot");
	else:
		Globals.singletons["Audio"].play("SideShieldNoSegment2");
	
	yield($Shield, "animation_complete");

	if (v == nodecount): 
		$Shield.play_anim(ANIMATIONS.final.popup, false);
		Globals.singletons["Audio"].play("SideShieldSlot2");
		
		yield($Shield, "animation_complete");
		
func _initialise(inital_value):
	var v = int(inital_value);
	$Shield.visible = true;
	$FadePlayer.play("show");
	$Shield.reset_pose();
	if (v == 0 || v < 0 || v > nodecount):
		_amount = 0;
#		$FadePlayer.play("show");
		
		$Shield.play_anim_then_loop(ANIMATIONS[0].popup, ANIMATIONS[0].idle);
	else:
		_amount = v;
#		$FadePlayer.play("show");
		$Shield.play_anim(ANIMATIONS[v].idle, true);
