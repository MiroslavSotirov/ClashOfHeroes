extends Control

var in_big_win : bool = true;
var in_super_win : bool = false;
var in_mega_win : bool = false;
var in_total_win : bool = false;
var transition : bool = false;

var big_win_limit : float = 50;
var super_win_limit : float = 100;
var mega_win_limit : float = 200;

var bangup_factor : float = 1;
var sum_min_scale: float = 0.8;
var sum_max_scale: float = 1.3;

var shown = false;
var tween : Tween;
var amount : float;
var target : float;

var skippable : bool = false;
var first_time : bool = true;

signal HideEnd;

func _ready():
	Globals.register_singleton("BigWin", self);
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 20);
	yield(Globals, "allready");
	Globals.connect("skip", self, "skip");


func show_win(target, is_total = false):
	if(shown): return;
	if(first_time): 
		add_child_below_node($Background, load("res://Main/Slot/Features/BigWin/BigWinAnimation.tscn").instance());
		first_time = false;
	shown = true;
	in_big_win = !is_total;
	in_super_win = false;
	in_mega_win = false;
	in_total_win = is_total;
	
	amount = 0;
	self.target = target;
	$CounterText.visible = false;
	$CounterText.rect_scale = Vector2.ZERO;
	$BigWinAnimation.reset_pose();
	$BigWinAnimation.visible = false;
	$BigWinAnimation.position = Vector2(0, -100);
	$BigWinAnimationPlayer.play("Show");
	Globals.singletons["Audio"].fade("Melody", 1, 0, 500, 0);
	Globals.singletons["Audio"].change_track("background", "BigWin", 500, 1, 1, 0);
	yield($BigWinAnimationPlayer, "animation_finished");
	$BigWinAnimation.visible = true;
	
	$BigWinAnimation.reset_pose();
	if(is_total): $BigWinAnimation.play_anim("start_totalwin", false, 0.8);
	else: $BigWinAnimation.play_anim_then_loop("start_bigwin", "loop_bigwin");
	yield($BigWinAnimation, "animation_completed");
	if(is_total): $BigWinAnimation.play_anim("loop_totalwin", true);
	
	Globals.singletons["Audio"].loop("CoinsEndless");
	$CounterText.text = Globals.format_money(0);
#	$MoneyParticles.emitting = true
	$CounterText.visible = true;
	$BigWinAnimationPlayer.play("ShowCounter");
	
	tween = Tween.new();
	add_child(tween);
	var time = min(1.0 + (self.target / self.bangup_factor), 20.0);
	var scale = lerp(sum_min_scale, sum_max_scale, min(1, target / (mega_win_limit - big_win_limit)));
	
	tween.interpolate_method(self, "set_text", 0, self.target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	tween.interpolate_property($CounterText, "rect_scale", Vector2.ONE, Vector2.ONE * scale, time, Tween.TRANS_LINEAR, Tween.EASE_IN);
	tween.start();
	tween.connect("tween_all_completed", self, "hide");
	skippable = true;
	
func skip():
	if(!skippable): return;
	tween.playback_speed = 30;

func set_text(v):
	amount = v;
	$CounterText.text = Globals.format_money(v);
	if(transition): return;
	
	if(in_total_win):
		pass;
	else:
		if(in_big_win):
			if(v >= super_win_limit): switch_to_superwin();
		elif(in_super_win):
			if(v >= mega_win_limit): switch_to_megawin();

func switch_to_superwin():
	transition = true;
	yield($BigWinAnimation, "animation_completed");
	Globals.singletons["Audio"].change_track("background", "SuperWin", 500, 1, 1);
	$BigWinAnimation.play_anim_then_loop("start_superwin", "loop_superwin");
	yield($BigWinAnimation, "animation_completed");
	in_big_win = false;
	in_super_win = true;
	transition = false;
	
func switch_to_megawin():
	print("switch to megawin");
	transition = true;
	yield($BigWinAnimation, "animation_completed");
	Globals.singletons["Audio"].change_track("background", "MegaWin", 500, 1, 1);
	$BigWinAnimation.play_anim_then_loop("start_megawin", "loop_megawin");
	yield($BigWinAnimation, "animation_completed");
	in_super_win = false;
	in_mega_win = true;
	transition = false;
	
func hide():
	Globals.singletons["Audio"].stop("CoinsEndless");
	skippable = false;
#	$MoneyParticles.emitting = false;
	tween.queue_free();
	shown = false;
	yield($BigWinAnimation, "animation_completed");
	if(transition): yield($BigWinAnimation, "animation_completed");
	if(in_big_win): $BigWinAnimation.play_anim("end_bigwin", false);
	elif(in_super_win): $BigWinAnimation.play_anim("end_superwin", false);
	elif(in_mega_win): $BigWinAnimation.play_anim("end_megawin", false);
	elif(in_total_win): $BigWinAnimation.play_anim("end_totalwin", false);
	var main_theme = "MainTheme" if !Globals.fsm_data["in_freespins"] else "BonusTheme";
	Globals.singletons["Audio"].change_track("background", main_theme, 1500, 1, 1);
	
	yield($BigWinAnimation, "animation_completed");
	$BigWinAnimationPlayer.play("Hide");
	
	yield($BigWinAnimationPlayer, "animation_finished");
	emit_signal("HideEnd");
