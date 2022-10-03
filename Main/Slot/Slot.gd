extends Control

export (String) var reel_spin_sfx : String;
export (String) var reel_stop_sfx : String;
export (float) var reel_stop_volume : float;
export (String) var reel_start_sfx : String;

export (Array) var availableTiles : Array = [];
export (Array, NodePath) var reels : Array = [];
export (Dictionary) var sounds = { "start":"", "spin": "", "stop": "" };
export (bool) var testSpinStart : bool setget _test_spin_start_set;
export (bool) var testSpinStop : bool setget _test_spin_stop_set;
export (float) var reelStartDelay = 0.0;
export (float) var reelStopDelay = 0.0;
export (int) var invisible_tile = 0;

var allspinning : bool setget , _get_allspinning;
var spinning : bool setget , _get_spinning;
#var stopped : bool setget , _get_stopped;
#var stopping : bool setget , _get_stopping;

var targetdata : Array = [];
var reels_spinning : int = 0;
var reels_should_be_spinning : int = 0;

signal apply_tile_features(spindata, reeldata);
signal onstartspin;
signal onstopping;
signal onstopped;
signal ontilesremoved;

func _ready():
	Globals.register_singleton("Slot", self);
	testSpinStart = false;
	testSpinStop = false;
	yield(Globals, "allready")
	for i in range(len(reels)):
		print(i);
		reels[i] = get_node(reels[i]);
		reels[i].initialize(i, availableTiles);
		reels[i].connect("onstopped", self, "_on_reel_stopped");

	Globals.visibleTilesCount = reels[0].visibleTilesCount;
	Globals.visibleReelsCount = len(reels);

#func assign_tiles(tiles_array):
#	if (tiles_array.size() != reels.size()):
#		push_error("Tiles data cannot be set due to mismatching reels count");
#
#	for i in range(tiles_array.size()):
#		reels[i].assign_tiles(tiles_array[i])

func set_initial_screen(data):
	var init_data = parse_spin_data(data);
	for i in range(len(reels)):
		reels[i].set_initial_screen(init_data[i]);
	
#func _on_reel_stopping_anim(index):
#		if(index == len(self.reels) - 1):
#			Globals.singletons["Audio"].fade(reel_spin_sfx, 1, 0, 300)
		
func _on_reel_stopped(index):
	reels_spinning -= 1;
#	if(reels_spinning == 0): emit_signal("onstopped");

func _test_spin_start_set(val):
	if(!val): return;
	start_spin();
	testSpinStart = false;

func _test_spin_stop_set(val):
	if(!val): return;
	stop_spin();
	testSpinStop = false;

func start_spin(reels_to_spin = []):
	if (self.spinning): return;
	if (sounds.start): Globals.singletons["Audio"].play(self.sounds.start);
	if (sounds.spin): 
		Globals.singletons["Audio"].loop(sounds.spin, 0);
		# TODO for the fade use the reel easing duration?
		Globals.singletons["Audio"].fade_to(sounds.spin, 1, 500);
		reels[len(reels)-1].connect("stopeasingbegin", Globals.singletons["Audio"], "fade_to", [sounds.spin, 0, 500, 1], CONNECT_ONESHOT);
	
	if(reels_to_spin.empty()): reels_to_spin = range(len(reels));
	reels_should_be_spinning = len(reels_to_spin);
	reels_spinning = 0;
	for i in reels_to_spin:
		if (reelStartDelay > 0): yield(get_tree().create_timer(reelStartDelay), "timeout");
		reels[i].start_spin();
		reels_spinning += 1;

	emit_signal("onstartspin");
	
func stop_spin(data = null):
	var end_data = parse_spin_data(data);
	var promises = [];
	var delay = reelStartDelay + reelStopDelay;
	var reelsstopping = 0;
	for i in range(len(reels)):
#		if (delay > 0): yield(get_tree().create_timer(delay), "timeout");
		if(reels[i].is_spinning):
			promises.push_back(reels[i].stop_spin(end_data[i], delay * reelsstopping));
			reelsstopping += 1;
	
	yield(Promise.all(promises), "completed");

	emit_signal("onstopped");

func _get_spinning():
	return reels_spinning > 0;
	
func _get_allspinning():
	#for reel in reels: 
	#	if(!reel.is_spinning): return false

	return reels_should_be_spinning == reels_spinning;
	
#func _get_stopped():
#	for reel in reels: if(!reel.stopped): return false;
#	for reel in reels: print(reel);
#	return true;
	
#func _get_stopping():
#	for reel in reels: if(reel.stopping): return true;
#	for reel in reels: print(reel);
#	return false;
	
func parse_spin_data(data):
#	return [ [-101,0,0,0],[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0], [1,1,1,1]];

	if (data == null): return get_safe_spin_data();
	if (!("view" in data)): return get_safe_spin_data();
#	emit_signal("apply_tile_features", data, spind ata); #TODO check what this signal is doing
	if (!("features" in data)): return data.view;
	
	var view = data.view.duplicate(true);

	for feature in data.features:
		if(feature.type == "FatTile"):
			var tiles_count = reels[feature.data.x].visibleTilesCount;
			var height = tiles_count - abs(feature.data.y);
			var width = feature.data.w;
			var direction = 1 if feature.data.y + feature.data.h <= tiles_count else -1;
			var i = feature.data.x;
			var j = feature.data.y + feature.data.h - 1 if direction == 1 else max(0, feature.data.y);
			
			# it is possible that the fat tiles are not in the initial tile view but added as a special feature
			if (view[i][j] != feature.data.tileid): continue;

			for k in range(height):
				for l in range(width):
					if (k == 0 && l == 0):
						view[i][j] = view[i][j] * direction;
					else:
						view[i + l][j - k * direction] = invisible_tile;

#	return [[5, 5, 5, 5], [6, 0, 6, 0], [0, 7, 0, 7], [8, 11, 0, 0], [9, 9, 9, 9], [7, 8, 9, 7]]
	return view;

func get_safe_spin_data():
	var spindata = [];
	for i in range(len(reels)):
		spindata.append([]);
		for n in range(reels[i].visibleTilesCount):
			spindata[i].append(self.availableTiles[i]);

	return spindata; 

func get_tile_at(x, y):
	return reels[x].get_tile_at(y);

func add_data(data):
	var end_data = parse_spin_data(data);
	var size = end_data.size();
	var promises = Mapper.callOnElements(reels, "add_tiles", end_data);

	yield(Promise.all(promises), "completed");

func replace_tile(reel, tile_index, new_id, animation = null, animation_type = Tile.AnimationType.SPINE):
	reels[reel].replace_tile(tile_index, new_id, animation, animation_type);

func replace_tiles(data, animation = null, animation_type = Tile.AnimationType.SPINE):
	for i in data.keys():
		reels[i].replace_all_tiles(data[i], animation, animation_type);
#		promises.push_back(reels[i].popup_tiles(data[i]));

func get_tiles_with_id(id):
	var tiles = [];
	for reel in reels:
		tiles.append_array(reel.get_tiles_with_id(id));
	return tiles;
	
func win_popup_tiles(data):
	var promises = [];
	for i in data.keys():
		promises.push_back(reels[i].win_popup_tiles(data[i]));
	
	yield(Promise.all(promises), "completed");
	
func remove_tiles(data):
	var promises = [];
	for i in data.keys():
		promises.push_back(reels[i].remove_tiles(data[i]));
	
	yield(Promise.all(promises), "completed");
	emit_signal("ontilesremoved");

# the tiles that should be skipped when tinting the slot can be passed as a dictionary 
# in which the keys are the reels indexes and the values are an array of tiles indexes, 
# example: {1: [0, 2 ], 4: [1,2,3]} - tiles 0 and 2 on reel 1 and 1,2,3 on reel 4 will be skipped
# of an array of tile ids, example: [10, 11] - all tiles/if any/ with ids of 10 or 11 will be skipped
func tint(color: Color, duration = 0.0, skip = {}, easing = Tween.EASE_IN_OUT):
	for i in range(reels.size()):
		for j in range(reels[i].visibleTilesCount):
			var tile = reels[i].get_tile_at(j);
			var skip_is_array = typeof(skip) == 19;
			var skip_tile = skip.has(int(tile.id)) if skip_is_array else skip.has(i) && skip[i].has(j);
			if (!skip_tile): tile.tint(color, duration);
				
# some backend data reference tiles by their overall index in the slot /not in their reel/ 
# so this metod converts this index into the tile addres, "address" being the index of the reel 
# and the index of the tile on this reel.
func get_tile_address(index):
	var y = int(index) % Globals.visibleTilesCount;
	var x = int(index / Globals.visibleTilesCount);

	return Vector2(x, y);
	
func get_tiles_addresses(indexes, group = false):
	if (!group):
		var addresses = [];
		for index in indexes: 
			addresses.append(get_tile_address(index));
		return addresses;
	else:
		var reels = {}
		for index in indexes:
			var address = get_tile_address(index);
			var x = int(address.x);
			var y = int(address.y);
			reels[x] = reels[x] if (x in reels) else [];
			reels[x].append(y);
		
		return reels

func get_tile_position(reelindex, tileindex):
	return reels[reelindex].get_tile_position(tileindex);

func get_tile_global_position(reelindex, tileindex):
	return reels[reelindex].get_tile_global_position(tileindex);
	
func get_tile_default_position(reelindex, tileindex, center = false):
	return reels[reelindex].get_tile_default_position(tileindex, center);

func get_tile_global_default_position(reelindex, tileindex, center = false):
	return reels[reelindex].get_tile_global_default_position(tileindex, center); 

func get_all_tiles():
	var tiles := [];
	for reel in reels: tiles.append_array(reel._visible_tiles);
	return tiles;
	
func toggle_turbo(value):
	for reel in reels:
		reel.toggle_turbo(value);
