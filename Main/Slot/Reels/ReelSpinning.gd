class_name ReelSpinning extends Reel

export (Curve) var stop_easing_curve;
export (float) var stop_easing_duration = 0.5;
export (Curve) var start_easing_curve;
export (float) var start_easing_duration = 0;
#export (int) var ordering;
export (float) var turbo_factor = 6;
export (float) var speed_multiplier = 1.0;

var easing_progress = 0;
var _last_position = 0;
var _extra_duration = 0;
var _in_easing: bool = false;
var _ease_started: bool = false;

signal starteasingbegin;
signal starteasingend;
signal stopeasingbegin;

func start_spin():
	.start_spin()
	_last_position = _position;
	_in_easing = true;

func add_extra_duration(duration: float):
	if (_stopping): 
		print("Extra durration can be applied to a reel, only before it starts stopping");
	else:
		_extra_duration = duration;
	
func stop_spin(server_data, delay = 0):
	if (_in_easing): yield(self, "starteasingend");
	
	var additional_tiles = floor((delay + _extra_duration) * maxSpeed);
	var data = _reverse_data(server_data);
	var bottom = _generate_random_data(additional_tiles);
	var top = _generate_random_data(topTileCount);
	
	_extra_duration = 0;
	_target = _buffer.size() - 1 + data.size() + bottom.size();
	_add_to_buffer(bottom + data + top);
	_stopping = true;

	yield(self, "onstopped");

func _process(delta):
	if (!_spinning): return;
	if (_in_easing): return _ease(delta);
	
	var extraFactor = turbo_factor if _turbo else 1;
	_speed = min(maxSpeed, _speed + delta * acceleration) * extraFactor; # tiles per second TODO add universal speed unit
	_speed *= abs(speed_multiplier);
	var max_position = _buffer.size() - topTileCount - 1;
	var is_over = _stopping && !_in_easing && _position >= _target;
	
	if (_spinning && !is_over):
		_position = min(max_position, _position + delta * _speed);

	if (_spinning && !_stopping && _position >= max_position):
		_add_to_buffer(_generate_random_data(int(topTileCount)));

	_moveTo(_position);
	_in_easing = is_over 

func _moveTo(reel_position):
	self._blur = min(_speed * blurMultiplier, maxBlurMultiplier);
	var pos = int(reel_position);
	var extra = reel_position - pos;

	# TODO think of a way to calculate the reel size, without the tile_size
	var baseY = tile_size.y * (visibleTilesCount + bottomTileCount) - tile_size.y / 2;
	
	for i in range(tiles.size() - 1, -1, -1):
		var id_index = topTileCount - i;
		var id = _buffer[pos + id_index];
		var tile = tiles[i];
		var y;
		tile.set_tile(id);
		if(speed_multiplier > 0.0):
			if (i == tiles.size() - 1):
				y = baseY + extra * tile.get_bounds().y; 
			else:
				y = tiles[i + 1].position.y - tiles[i + 1].get_bounds().y / 2 - tile.get_bounds().y / 2;
		elif(speed_multiplier < 0.0):
			if (i == tiles.size() - 1):
				y = baseY - extra * tile.get_bounds().y; 
			else:
				y = tiles[i + 1].position.y - tiles[i + 1].get_bounds().y / 2 - tile.get_bounds().y / 2;
		
		tile.position = Vector2(tile.get_bounds().x / 2, y); 
		tile.show_image();
		tile.visible = tile.position.y > -tile.get_bounds().y / 2 && tile.position.y < baseY;

#func _set_tile (tile, tile_index = 0, offest = Vector2.ZERO, animation = null, animation_type = Tile.AnimationType.SPINE):
#	var pos = int(_position) - tile_index;
#	var id = Globals.singletons["Slot"].invisible_tile if pos >= _buffer.size() else _buffer[pos];
#	var x = tile_size.x / 2 + offest.x;
#	var y = tile_size.y / 2 + (tile_index) * tile_size.y + offest.y;
#
#	tile.set_tile(id, Vector2(x, y));
#	if (animation != null):
#		tile.play_animation(animation_type, animation);
#		yield(tile, "animation_finished");
#
#	tile.show_image();

func _ease(delta):
	var curve; var duration; var on_end; var signalName;
	var extraFactor = turbo_factor if _turbo else 1;
	
	if (_stopping):
		curve = stop_easing_curve
		duration = stop_easing_duration / extraFactor;
		on_end = "_on_stopped";
		signalName = "stopeasingbegin"
#		emit_signal("stopeasingbegin");
	else:
		curve = start_easing_curve;
		duration = start_easing_duration / extraFactor;
		on_end = "_on_started";
		signalName = "starteasingbegin"
#		emit_signal("starteasingbegin");
	
	if (_ease_started):
		emit_signal(signalName);
		_ease_started = false;
		if (sounds.stop != null): Globals.singletons["Audio"].play(sounds.stop);

	if (!curve || !duration || duration == 0):
		_ease_started = true;
		return self.call(on_end);

	var last_interpolator = easing_progress / duration;
	easing_progress += delta;
	var interpolator = easing_progress / duration;
	var last = curve.interpolate_baked(last_interpolator)
	var interpolated = curve.interpolate_baked(interpolator)
	var distance = interpolated - last;
	_speed = abs((interpolated - last) / delta) if distance != 0 else _speed;
	_speed *= abs(speed_multiplier);
	_moveTo(_position + interpolated);

	if(interpolator >= 1): self.call(on_end);
	
func _on_started():
	_in_easing = false;
	easing_progress = 0;

	emit_signal("starteasingend", self.index);

func _on_stopped():
	self._blur = 0;
	_spinning = false;
	_stopping = false;
	_in_easing = false;
	_speed = initialSpeed;
	_time = 0;
	easing_progress = 0;

	if (use_spine_as_static):
		for tile in self.tiles: tile.show_spine_sprite();

	._on_stopped();
