extends Node2D
export (bool) var autohide = true;

var _shown = true;

func _process(delta):
	if (!autohide): return;

	var inFreeSpins = "in_freespins" in Globals.fsm_data && Globals.fsm_data["in_freespins"];
#	var hasWinShown = Globals.singletons["WinBar"].shown || Globals.singletons["TotalWinBar"].shown;
	
	if (inFreeSpins):
		if (_shown): 
			$AnimationPlayer.play("Hide");
			_shown = false;
	else:
		if(!_shown):
			$AnimationPlayer.play("Show");
			_shown = true;
