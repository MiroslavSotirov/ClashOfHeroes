extends Node2D
class_name Tile

enum AnimationType { SPINE, TIMELINE };

export (float) var blur : float setget _setblur;
export (Vector2) var scale_multiplier : Vector2 = Vector2.ONE;


signal spinespriteshown
signal imageshown
signal hide_end
signal animation_finished(name);

var speed: int;
var _invisible_tile: int = 0
var description: TileDescription
var id = 0;
var _hidden = false;
var index = 0;
var _tween = null;
var popup_counter := 0;

func _ready():
	_invisible_tile = Globals.singletons["Slot"].invisible_tile;
	$Image.material = $Image.material.duplicate();

func set_tile(_id, initial_position = null):
	# there could be more than one tile for the same tile id, though most of the time is one
	var posibleTiles = _get_tiles_with_id(Globals.tiles, abs(_id))
	var variant  = randi() % len(posibleTiles);
	description = posibleTiles[variant];
	$SpineSprite.scale.x = description.tile_scale.x;
	$SpineSprite.scale.y = description.tile_scale.y;
	$Image.scale.x = description.tile_scale.x;
	$Image.scale.y = description.tile_scale.y;
	position = initial_position if initial_position != null else position
	if (abs(_id) != abs(id)): 
		$SpineSprite.set_new_state_data(description.spine_data);
	else:
		return $SpineSprite.reset_pose();

	id = _id;
	var direction = sign(id);
	var tile_width = description.image_size.x / description.size_x;
	var tile_height = description.image_size.y / description.size_y;

	var x = tile_width / 2 * (description.size_x - 1) if description.size_x > 1 else 0;
	var y = tile_height / 2 * (description.size_y - 1) if description.size_y > 1 else 0;

	$Image.offset.x = -direction * x + description.image_offset.x;
	$Image.offset.y = -direction * y + description.image_offset.y;
	$SpineSprite.position.x = (-direction * x) * description.tile_scale.x + description.image_offset.x;
	$SpineSprite.position.y = (-direction * y) * description.tile_scale.y + description.image_offset.y;
	set_layer(0);

func get_spine():
	return $SpineSprite;

func hide(animationType = AnimationType.SPINE, animation = "hide", timescale = 1.0):
	if (_hidden): return Promise.resolve();
	_hidden = true;
	play_animation(animationType, animation, 1, timescale);
	return yield(self, "animation_finished");
	
func win_popup():
	# TODO fix the mess with the description
	modulate = Color.white;
	return popup(AnimationType.SPINE, description.spine_win_anim, description.spine_win_anim_animation_repeat, 1);

func stop_popup():
	if (description.stop_popup_sfx != ""): Globals.singletons["Audio"].play(description.stop_popup_sfx);
	return popup(AnimationType.SPINE, description.spine_popup_anim, 1, description.popup_z_change);
	
func popup(animationType = AnimationType.SPINE, animation = "popup", times = -1, z_index = description.popup_z_change):
	set_layer(z_index);
	play_animation(animationType, animation, times);

	yield(self, "animation_finished");
	set_layer(0);

func tint(color: Color, duration = 0.0, easing = Tween.EASE_IN_OUT):
	if (_tween == null):
		_tween = Tween.new();
		add_child(_tween);

	_tween.interpolate_property(self, "modulate", self.modulate, color, duration, Tween.TRANS_LINEAR, easing);
	_tween.start();
	yield(_tween, "tween_all_completed");
#	_tween.queue_free();

func reel_stopped(index):
	pass

func show_spine_sprite():
	if ($SpineSprite.visible || description.id == _invisible_tile): return;

	$SpineSprite.visible = false;
	yield(VisualServer,"frame_post_draw");
	$SpineSprite.visible = true;
	$Image.visible = false;
	$SpineSprite.set_skin(description.skin);
	$SpineSprite.reset_pose();

func spine_play_then_loop(anim, loopanim):
	show_spine_sprite();
	$SpineSprite.play_anim_then_loop(anim, loopanim)
	
func set_layer(i):
	if (i != z_index):
		z_index = i;

func play_animation(type = AnimationType.SPINE, name = null, times = 1, timescale_override = null, has_delay = true):
	if (name == null): return push_error("No animation name was provided");
	if (times < 0): return loop_animaiton(type, name, timescale_override, has_delay);
	if (description.id == _invisible_tile || times == 0):
		return call_deferred("_on_animation_finished", name);

	if (type == AnimationType.SPINE ):
		#print("I am playing spine animation.... ", name);
		show_spine_sprite();
		$SpineSprite.play_anim(name, false, timescale_override, has_delay);
		yield($SpineSprite, "animation_complete");
		return play_animation(type, name, times - 1, timescale_override, has_delay);
		
	if (type == AnimationType.TIMELINE && $AnimationPlayer.has_animation(name)):
		$AnimationPlayer.play(name);
		yield($AnimationPlayer, "animation_finished");
		return play_animation(type, name, times - 1, timescale_override, has_delay);
		
	print("I don't know what type of animation to play.... ", name);
	return call_deferred("_on_animation_finished", name);

func loop_animaiton(type = AnimationType.SPINE, name = null, timescale_override = null, has_delay = true):
	if (type == AnimationType.SPINE ):
		#print("I am playing spine animation.... ", name);
		show_spine_sprite();
		$SpineSprite.set_skin(description.skin);
		$SpineSprite.play_anim(name, true, timescale_override);
		return;
	else:
		pass; # TODO
	
func _on_animation_finished(name, track = null, __ = null):
	if (track == null):
		emit_signal("animation_finished", name);
	else:
		var spine_anim_name = track.get_animation().get_anim_name();
		emit_signal("animation_finished", spine_anim_name);

func show_image():
	if (description.id == _invisible_tile):
		$Image.visible = false;
		emit_signal("imageshown");
		return;

	$Image.texture = self.description.static_image;

	$SpineSprite.visible = false;
	$Image.visible = true;
	_hidden = false;
	set_layer(0);
	emit_signal("imageshown");

func update_position(pos):
	position.x += pos.x;
	position.y += pos.y;
	
	return position;

func get_bounds():
	var width = description.bounds.x if description.bounds.x != 0 else description.image_size.x * description.tile_scale.x;
	var height = description.bounds.y if description.bounds.y != 0 else description.image_size.y * description.tile_scale.y;
	
	return Vector2(width, height);
	
func _setblur(val):
	if(id == _invisible_tile || abs(val - blur) < 0.25): return;
	blur = val * description.blurScale;

	$Image.material.set_shader_param( "dir", Vector2(0.0, blur));
	$Image.material.set_shader_param( "quality", int(blur / 15));
	
func _get_tiles_with_id(tiles, id):
	var filteredTiles = [];
	for tile in tiles:
		if (tile.id == abs(id)):
			filteredTiles.append(tile);

	if (len(filteredTiles) == 0):
		push_error("no tile with id" + id as String);
		return tiles;

	return filteredTiles;
