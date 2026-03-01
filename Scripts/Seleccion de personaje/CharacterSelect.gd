extends Control

var selecting_player := 1

func _on_character_pressed(character_name: String):

	if selecting_player == 1:
		GameData.p1_character = character_name
		selecting_player = 2
		$PlayerTurn.text = "Player 2 Select"

	else:
		GameData.p2_character = character_name
		get_tree().change_scene_to_file("res://WeaponSelect.tscn")


func _on_mode_ai_pressed():
	GameData.is_local_multiplayer = false
	GameData.p2_is_ai = true


func _on_mode_local_pressed():
	GameData.is_local_multiplayer = true
	GameData.p2_is_ai = false
