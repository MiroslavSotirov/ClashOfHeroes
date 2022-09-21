extends Node

func _process(delta):
	if(Input.is_action_just_pressed("ui_home")):
		Globals.singletons["Slot"].tint(Color(0.27, 0.27, 0.27), 0.5);
		Globals.singletons["SideCharacters"].spine_play("Boy", "disappear");
		Globals.singletons["SideCharacters"].spine_play("Girl", "disappear");
		yield(Globals.get_tree().create_timer(1.5), "timeout");
		Globals.singletons["SlotAnimationPlayer"].play("ZoomIn");
		yield(Globals.get_tree().create_timer(0.5), "timeout");
		$RobotFightFx/AnimationPlayer.play("Show");
		yield(Globals.get_tree().create_timer(0.7), "timeout");
		Globals.singletons["Game"].shake += Vector2.ONE * 20.0;
		Globals.singletons["FaderBright"].tween(0.1,0.0,0.2);
		for i in 15:
			Globals.singletons["Game"].shake += Vector2.ONE * 5.0;
			yield(Globals.get_tree().create_timer(0.1), "timeout");
			
		Globals.singletons["SlotAnimationPlayer"].play("ZoomOut");
		Globals.singletons["Slot"].tint(Color.white, 1.0);
		yield(Globals.get_tree().create_timer(0.5), "timeout");
		Globals.singletons["SideCharacters"].show_chr("Boy");
		Globals.singletons["SideCharacters"].show_chr("Girl");
		yield(Globals.get_tree().create_timer(1.0), "timeout");	
