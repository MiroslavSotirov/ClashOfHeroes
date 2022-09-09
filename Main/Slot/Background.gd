class_name Background extends SpriteChanger

func activate_lightnings():
	$Lightings.visible = true;
	$Lightings.frame = 0;
	$Lightings.play("active");
	Globals.singletons["Audio"].play("Boom");
	yield($Lightings,  "animation_finished");

	$Lightings.visible = false;
	emit_signal("animation_finished");
