class_name SpriteChanger extends Node

export (String) var initial = "Normal"
var _current = initial;

var _previous = null;
var _tween = null;
var _states = ["Normal", "Special", "FreeSpins"];

var current setget , _get_current;

signal animation_finished;
signal transition_finished;

func _ready():
	Globals.register_singleton(name, self);

func maybe_change_to(condition, state, otherwise, duration = 1.0, easing = Tween.EASE_IN_OUT):
	var next = state if condition else otherwise;
	change_to(next, duration, easing);
		
func change_to(state, duration = 1.0, easing = Tween.EASE_IN_OUT):
	if (state == _current): return;

	if (_tween == null):
		_tween = Tween.new();
		add_child(_tween);

	var sprite = get_node(state);
	
	move_child(sprite, 1);
	sprite.z_as_relative = true;
	sprite.modulate = Color(1, 1, 1, 0);
	sprite.visible = true;
	
	_tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1, 1, 1, 1), duration, Tween.TRANS_LINEAR, easing);
	_tween.start();
	yield(_tween, "tween_all_completed");
	move_child(sprite, 0);
	if (_current != null):
		var old_sprite = get_node(_current);
		old_sprite.visible = false;

	_previous = _current;
	_current = state;
	
	emit_signal("transition_finished");
	
func change_to_previous(duration = 1.0, easing = Tween.EASE_IN_OUT):
	if (_previous == null): return;
	change_to(_previous, duration, easing);

func hide(duration = 1.0, easing = Tween.EASE_IN_OUT):
	if (_current == null): return;
	var sprite = get_node(_current);
	if (sprite == null): return;
	
	if (_tween == null):
		_tween = Tween.new();
		add_child(_tween);
	
	_tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1, 1, 1, 0), duration, Tween.TRANS_LINEAR, easing);
	_tween.start();
	yield(_tween, "tween_all_completed");

	sprite.visible = false;
	_previous = _current;
	_current = null;
	
	emit_signal("hide_finished");
	
func _get_current():
	return _current;
