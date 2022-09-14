extends SpineSprite
class_name SpineSpriteExtension

export(String) var skin;
export(String) var startanimation;
export(bool) var loop = true;
export(float) var timescale = 1 setget set_timescale;

var current_anim : String;
var currently_looping : bool;

func _ready():
	if(startanimation): play_anim(startanimation, loop);
	if(skin): set_skin(skin);

# Used to change the tiles 
func set_new_state_data(data, newskin = null, playanim = false):
	skeleton_data_res = data;
	
#	self.animation_state_data_res = data;
#	#yield(VisualServer, "frame_post_draw");
#	if(newskin): set_skin(newskin);	
#	set_children_material();
#	update_children_color();
#	reset_pose();
#	if(playanim): play_anim(current_anim, currently_looping);
	pass;
		
func set_skin(skin):
	if (skeleton_data_res == null): return;

	var skeleton = get_skeleton();
	if (skeleton_data_res.find_skin(skin) != null):
		skeleton.set_skin_by_name(skin);
	else:
		var default_skin = "EN" if skeleton_data_res.find_skin("EN") != null else "default";
		skeleton.set_skin_by_name(default_skin);
		
	if(get_skeleton().get_data().find_skin(skin) == null):
		if(get_skeleton().get_data().find_skin("EN") != null):
			skin = "EN";
		else:
			skin = "default";
	get_skeleton().set_skin_by_name(skin);

func play_anim(anim, loop, timescale_override = null):
	current_anim = anim;
	if(get_animation_state() != null):
		get_animation_state().clear_tracks();
		get_animation_state().set_animation(current_anim, loop);
	currently_looping = loop;
	if (timescale_override != null): set_timescale(timescale_override, false);
	else: set_timescale(timescale);
	
func play_anim_then_loop(anim, loopanim):
	play_anim(anim, false);
	yield(self, "animation_completed");
	if(current_anim == anim): play_anim(loopanim, true);

func stop():
	get_animation_state().clear_tracks();
	pass;

func set_timescale(scale, permanent=true):
	scale = float(scale);
	if(get_animation_state()):
		get_animation_state().set_time_scale(scale);
	if(permanent): timescale = scale;

func reset_pose():
	if (get_skeleton()): 
		get_skeleton().set_bones_to_setup_pose();
		get_skeleton().set_slots_to_setup_pose();


func has_animation(name):
	return !!get_skeleton().get_data().find_animation("appear");
