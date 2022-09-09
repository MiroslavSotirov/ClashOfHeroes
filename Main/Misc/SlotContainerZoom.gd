extends Control

export (Vector2) var zoomamount : Vector2;
export (Vector2) var yoffset : Vector2;

func _ready():
	Globals.register_singleton("SlotContainerZoom", self);
	Globals.connect("resize", self, "_on_resize");

func _on_resize(resolution, layout):
	var global_size = get_global_rect().size;
	var scale = clamp(min(global_size.x / layout.viewport.x, global_size.y / layout.viewport.y), 0, 1);
	
	rect_scale = Vector2.ONE * scale;
	rect_pivot_offset = rect_size/2;
