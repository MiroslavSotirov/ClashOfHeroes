extends Node2D
class_name Positioner

export (bool) var dynamic = true;

export(Dictionary) var config = {
	"default": { 
		"position": Vector2(0, 0), 
		"scale": Vector2(1, 1), 

		# x (from the Vector2) is the value set when the screen ration is equal 
		# the the layout threshold and y is the value set when the ration 
		# is equal to the thresholdEnd
		"x": Vector2(0, 0),
		"y": Vector2(0, 0),
		"scaleXY": Vector2(1, 1),
		"scaleX": Vector2(1, 1),
		"scaleY": Vector2(1, 1),
		"easing": 1.0
	},
}

func _ready():
	if (dynamic): Globals.connect("resize", self, "_on_resize");
	Globals.connect("layoutchanged", self, "_on_layout_changed");
	_on_layout_changed(Globals.current_layout);

func _on_layout_changed(layout):
	var parent = get_parent();
	var cfg = config[layout.name] if config.has(layout.name) else config.default;
	
	parent.position = _get_property_value(layout.name, 'position', Vector2.ONE);
	parent.scale = _get_property_value(layout.name, 'scale', Vector2.ONE);
#	parent.scale = cfg.scale if cfg.has("scale") else Vector2(1, 1);

func _get_property_value(layout, prop, fallback):
	if (config.has(layout) && config[layout].has(prop)): return config[layout][prop];
	if (config.has("default") && config.default.has(prop)): return config.default[prop];
	
	return fallback;

func _on_resize(resolution, layout):
	if (!config.has(layout.name)): return;
	
	var cfg = config[layout.name];
	var parent = get_parent();
	var progress = inverse_lerp(layout.threshold, layout.thresholdEnd, resolution.x / resolution.y);
	var easedProgress = ease(progress, 1.0);
	
	if (cfg.has("x")): parent.position.x = lerp(cfg.x.x, cfg.x.y, easedProgress);
	if (cfg.has("y")): parent.position.y = lerp(cfg.y.x, cfg.y.y, easedProgress);

	if (cfg.has("scaleX")): parent.scale.x = lerp(cfg.scaleX.x, cfg.scaleX.y, easedProgress);
	if (cfg.has("scaleY")): parent.scale.x = lerp(cfg.scaleY.x, cfg.scaleY.y, easedProgress);

	if (cfg.has("scaleXY")): 
		parent.scale = Vector2.ONE * lerp(cfg.scaleXY.x, cfg.scaleXY.y, easedProgress);
