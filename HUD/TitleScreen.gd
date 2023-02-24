extends Control


func _on_Start_pressed():
	var game = preload ("res://Main.tscn").instance ();
	get_tree ().get_root().add_child(game);
	hide();


