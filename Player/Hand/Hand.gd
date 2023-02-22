extends Area2D

var tip_position

signal tip_touched


func _on_Tip_body_entered(body):
	emit_signal("tip_touched", body)
