extends Resource
class_name TileDescription

export(int) var id := 0;
export(int) var size_x := 1;
export(int) var size_y := 1;
export(Resource) var spine_data;
export(bool) var popup := false;
export(int) var popup_z_change := 0;
export(bool) var popup_wait := false;
export(String) var image_creation_animation := "popup";
export(String) var skin := "default";
export(String) var spine_popup_anim := "popup";
export(float) var spine_popup_anim_speed := 1.0;
export(String) var stop_popup_sfx := "";
export(String) var win_popup_sfx := "";
export(String) var spine_idle_anim := "";
export(String) var spine_win_anim := "popup";
export(int) var spine_win_anim_animation_repeat := 1;
export(Vector2) var image_offset : Vector2;
# the size of the "canvas" on which the tile is drawn
export(Vector2) var image_size : Vector2 = Vector2(100.0, 100.0); 
# the bounding box used when arranging the tiles on the reel in other words 
# the tile position in the reel is set according the the bounds of the previous tile. 
# If not set theimage_size is used
export(Vector2) var bounds : Vector2 = Vector2.ZERO; 
#export(Vector2) var tile_offset : Vector2;
export(Vector2) var tile_scale : Vector2 = Vector2.ONE;
export(Array) var posible_reels := [];
export(int) var max_count := 0;
export(float) var blurScale := 1;

var static_image : ImageTexture;
