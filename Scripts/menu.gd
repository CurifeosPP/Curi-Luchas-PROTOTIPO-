extends Control


func _on_jugar_pressed() -> void:
	Fade.change_scene("res://Escenas/Cinematica.tscn")


func _on_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
