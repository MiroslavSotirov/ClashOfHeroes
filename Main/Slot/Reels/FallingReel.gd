extends Reel
class_name FallingReel

signal oncleared;

var _filling: bool = false; # true when the screen is being filled with the new tiles /the spin result/

func stop_spin(server_data, _delay = 0):
	var data = _reverse_data(server_data);
	var top = _generate_random_data(topTileCount);
	
	_add_to_buffer(data + top);

	if (!_filling): yield(self, "oncleared");

	_stopping = true;
	_position = _buffer.size() - topTileCount - 1;

	for i in range(self._visible_tiles.size()): 
		_set_tile(self._visible_tiles[i], i, Vector2(0, (-visibleTilesCount - 2) * tile_size.y));
	
	call_deferred("_fill");
	yield(self, "onstopped");

func add_tiles(data):
	if (_removed_tiles.size() == 0): return Promise.resolve();
	var new_tiles = _reverse_data(data.slice(0, _removed_tiles.size() - 1));

	_buffer = _buffer.slice(0, int(_position)) + _reverse_data(data.slice(0, _removed_tiles.size() - 1));
	var offsets = _get_tiles_offset(_reverse_data(_removed_tiles));
	for i in range(self._visible_tiles .size()):
		_set_tile(self._visible_tiles[i], i, offsets[i]);

	_removed_tiles = [];
	_shift();
	return yield(self, "onstopped");
	
func remove_tiles(indexes):
	indexes.sort();
	_removed_tiles = indexes;
	_buffer =  _remove_from_buffer(indexes);
	
	var promises = [];
	for index in indexes:
		var tile = self._visible_tiles[index];
		promises.push_back(tile.hide(animations.hide.type, animations.hide.name, 2.0));

	yield(Promise.all(promises), "completed");

func _process(delta):
	if (!_spinning): return;
	
	var fallen_tiles = 0;
	_time = _time + delta;

	for i in range(visibleTilesCount):
		if ((visibleTilesCount - i) * delayPerTile > _time): continue;
		var tile = self.tiles[i + topTileCount];
		var limit = _edges.tiles[i] if _filling else _edges.slot;

		if (tile.position.y >= limit):
			_on_drop(tile, i);
			fallen_tiles += 1;
		else:
			tile.speed = min(maxSpeed, tile.speed + delta * acceleration);
			tile.update_position(Vector2(0, min(limit - tile.position.y, tile.speed)));

	if (fallen_tiles == visibleTilesCount):
		_on_clear();

func _shift():
	_spinning = true;
	_filling = true;
	_stopping = true;
	
func _get_tiles_offset(removed_tiles):
	var offsets = [];
	for i in range(visibleTilesCount):
		offsets.append(Vector2(0, 0));

	for index in removed_tiles:
		for j in range(offsets.size()):
			var tile_position = _get_tile_pos(j , offsets[j]);
			var removed_tile_position = _get_tile_pos(index);
	
			if tile_position <= removed_tile_position:
				offsets[j].y = offsets[j].y - tile_size.y;
	
	return offsets;

func _get_tile_pos(index, offset = Vector2(0, 0), size = self.tile_size):
	var y = index * size.y + size.y / 2 + offset.y;
	
	return Vector2(0, y);

func _on_drop(tile, i):
	if (_filling && tile.speed > initialSpeed): 
		tile.play_animation(animations.drop.type, animations.drop.name);
		Globals.singletons["Audio"].play_time_rate("Reel Stop 3", 0.5, 100);
	tile.speed = initialSpeed;
	
func _on_stopped():
	_spinning = false;
	_stopping = false;
	_time = 0;

#	TODO 0.5 is the duration of the drop animation
	yield(get_tree().create_timer(0.5), "timeout");
	for i in range(self.tiles.size()):
		var tile = self.tiles[i]
		_set_tile(tile, i - topTileCount);

	._on_stopped();

func _fill():
	_filling = true;
	
func _on_clear():
	if (!_filling):
		_time = 0;
		emit_signal("oncleared", self.index);
	else:
		_filling = false;
		_on_stopped();
