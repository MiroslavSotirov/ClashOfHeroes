extends Node2D

class_name Reel

export (float) var blurMultiplier : float = 0;
export (float) var maxBlurMultiplier : float = 20;
export (int) var topTileCount : int = 0;
export (int) var visibleTilesCount : int = 4;
export (int) var bottomTileCount : int = 0;
export (Dictionary) var animations = {
	hide = { name = "hide", type = Tile.AnimationType.SPINE },
	drop = { name = "drop", type = Tile.AnimationType.TIMELINE }
};

export (float) var delayPerTile = 0;
export (float) var acceleration = 380;
export (float) var maxSpeed = 200;
export (int) var initialSpeed = 0;
export (PackedScene) var tileScene;
export (bool) var auto_arrange = true;
export (Vector2) var tile_size = Vector2.ZERO;
# if true then when the reel is not spinning the spine animation will be shown instead of the static image
export (bool) var use_spine_as_static = false;
export (Dictionary) var sounds = {
	"stop": null,
	"spin": null
}

signal onstartspin;
signal onstopping;
signal onstopped;

var tiles : Array setget , _get_tiles;
var index : int = 0;
var is_spinning: bool setget , _get_is_spinning;
var _blur: float setget _set_blur;

var _buffer = [];
var _target = 0;
var _position = 0;
var _visible_tiles: Array setget , _get_visible_tiles;
var _removed_tiles = [];

var _posible_tiles = [];
var _spinning: bool = false
var _stopping: bool = false;
var _tiles_natural_positions = [];
var _speed = initialSpeed;
var _time = 0;
var _edges = { tiles = [], slot = 0 }; # the farthest a tile can fall
var _turbo: bool = false;

func get_tile_at(index):
	return self.tiles[topTileCount + index];

# returns a tile tile normal position, i.e. the position of the cell with address 
# of (reel.index, file index) in the slot grid, relative to the slot
func get_tile_default_position(tile_index: int, center: bool):
	return _get_tile_default_position(position, Vector2(1, 1), tile_index, center);
	
# returns a tile tile normal position, i.e. the position of the cell with address 
# of (reel.index, file index) in the slot grid, relative to the global origin
func get_tile_global_default_position(tile_index: int, center: bool):
	return _get_tile_default_position(global_position, global_scale, tile_index, center);

# returns the tile position relative to the slot
func get_tile_position(index):
	var tile = get_tile_at(index);

	return Vector2(tile.position.x + position.x, tile.position.y);

func get_tile_global_position(index):
	var tile = get_tile_at(index);
	
	return tile.global_position;
	
func toggle_turbo(value):
	_turbo = value

func _set_blur(val):
	for tile in self.tiles:
		tile.blur = val;

func initialize(index, posibleTiles):
	var tiles_count = topTileCount + visibleTilesCount + bottomTileCount;
	self.index = index;
	self._position = visibleTilesCount + bottomTileCount - 1;
	self._posible_tiles = posibleTiles;
	
	if (auto_arrange):
		position.x = index * tile_size.x;
	
	for i in range(tiles_count):
		var tile = tileScene.instance();
		$TileContainer.add_child(tile);
	
	_edges.slot = tile_size.y * (visibleTilesCount) + tile_size.y / 2;
	for i in range(visibleTilesCount):
		_edges.tiles.append(i * tile_size.y + tile_size.y / 2);

func set_initial_screen(server_data):
	var ids = _reverse_data(server_data);
	var top = _generate_random_data(topTileCount);
	var bottom = _generate_random_data(bottomTileCount);
	var data = bottom + ids + top;
	
	_add_to_buffer(data);

	for i in range(self.tiles.size()):
		_set_tile(self.tiles[i], i - topTileCount);
		if (use_spine_as_static): self.tiles[i].show_spine_sprite();
	
func start_spin():
	for i in range(self.tiles.size()):
		self.tiles[i].speed = initialSpeed;

	_speed = initialSpeed;
	_spinning = true;
	_removed_tiles = [];

func stop_spin(server_data, delay = 0):
	print("Stop spin is not implemented");

func replace_all_tiles(ids, animation = null, animation_type = Tile.AnimationType.SPINE):
	if (ids.size() != visibleTilesCount):
		var err = "expected %s of new tile ids, got %s";
		push_error(err % [visibleTilesCount, ids.size()]);
		return;
		
	for i in range(ids.size()):
		replace_tile(i, ids[i], animation, animation_type);

func replace_tile(index, newId, animation = null, animation_type = Tile.AnimationType.SPINE):
	if (_spinning):
		push_error("Tiles can be replaced only on a stopped reel");
		return;
		
	var i = int(_position) - index;
	var tile = self._visible_tiles[index];
	_buffer[i] = newId;
	
	_set_tile(tile, index, Vector2(0,0), animation, animation_type);

func add_tiles(data):
	_add_to_buffer(data);

	return Promise.resolve();
	
func remove_tiles(indexes):
	return Promise.resolve();

func win_popup_tiles(indexes):
	var promises = [];
	for index in indexes:
		var tile = self._visible_tiles[index];
		promises.push_back(tile.win_popup());

	yield(Promise.all(promises), "completed");

func get_tiles_with_id(id):
	var tiles = [];
	for tile in self.tiles:
		if(tile.id == id): tiles.append(tile);

	return tiles;

func _get_tile_default_position(origin: Vector2, scale: Vector2, tile_index: int, center = false):
	var x = 0 if !center else tile_size.x / 2;
	var y = tile_index * tile_size.y if !center else tile_index * tile_size.y + tile_size.y / 2;

	return origin + Vector2(x, y) * scale;

func _remove_from_buffer(indexes = []):
	if (indexes.size() == 0): return _buffer;
	
	var new_buffer = _buffer.duplicate();
	for index in indexes:
		new_buffer.remove(int(_position) - index);
	
	return new_buffer;

func _update_tile(tile):
	var pos = int(_position) - tile.index;
	var id = Globals.singletons["Slot"].invisible_tile if pos >= _buffer.size() else _buffer[pos];
	tile.set_tile(id, null);
	
func _set_tile (tile, tile_index = 0, offest = Vector2.ZERO, animation = null, animation_type = Tile.AnimationType.SPINE):
	var pos = int(_position) - tile_index;
	var id = Globals.singletons["Slot"].invisible_tile if pos >= _buffer.size() else _buffer[pos];
	var x = tile_size.x / 2 + offest.x;
	var y = tile_size.y / 2 + (tile_index) * tile_size.y + offest.y;

	tile.set_tile(id, Vector2(x, y));
	if (animation != null):
		tile.play_animation(animation_type, animation);
		yield(tile, "animation_finished");
		
	tile.show_image();

func _on_stopped():
	for tile in self._visible_tiles:
		if(tile.description.popup):
#			print("STOP POPUP")
			tile.stop_popup();
			
	emit_signal("onstopped", self.index);

func _add_to_buffer(ids):
	_buffer = _buffer + ids;

func _generate_random_data(size):
	var data = [];
	var length = len(_posible_tiles);
	for i in range(size): 
		var id = 1 if length == 0 else _posible_tiles[randi() % length];
		data.append(id)

	return data;

func _reverse_data(data):
	var reversed = data.duplicate();
	reversed.invert();
	
	return reversed;
	
func _get_tiles():
	return $TileContainer.get_children()
	
func _get_visible_tiles():
	return self.tiles.slice(topTileCount, visibleTilesCount + topTileCount - 1);

func _get_is_spinning():
	return _spinning;
