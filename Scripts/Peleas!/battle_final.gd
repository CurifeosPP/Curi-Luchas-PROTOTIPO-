extends Node2D

@onready var p1_spawn = $SpawnPoints/P1Spawn
@onready var p2_spawn = $SpawnPoints/P2Spawn
@onready var result_label = get_node_or_null("CanvasLayer/ResultLabel")

var alan_scene = preload("res://Personajes/Alan/Fase final/Alan-FINAL.tscn")
var jesus_scene = preload("res://Personajes/Jesus/Fase Final/JesusFINAL.tscn")

var p1
var p2
var fight_ended := false

func _ready():
	spawn_players()

func spawn_players():

	p1 = alan_scene.instantiate()
	add_child(p1)
	p1.global_position = p1_spawn.global_position
	p1.input_prefix = "p1_"

	p2 = jesus_scene.instantiate()
	add_child(p2)
	p2.global_position = p2_spawn.global_position

	p1.tree_exited.connect(_on_player_dead.bind("JESUS"))
	p2.tree_exited.connect(_on_player_dead.bind("ALAN"))

func _on_player_dead(winner_name):

	if fight_ended:
		return

	fight_ended = true

	GameData.add_serious_round(winner_name)

	if result_label:
		result_label.text = "🔥 " + winner_name + " GANA 🔥"

	await get_tree().create_timer(1.5).timeout

	# 🔥 VERIFICAR SI ALGUIEN LLEGÓ A 3
	var final_winner = GameData.reached_three()

	if final_winner != "":
		# 🔥 FINAL DEFINITIVO
		if final_winner == "ALAN":
			Fade.change_scene("res://Escenas/final_alan.tscn")
		else:
			Fade.change_scene("res://Escenas/final_jesus.tscn")
		return

	# 🔥 SI NO LLEGÓ A 3, VERIFICAR EMPATE
	if GameData.is_tied():
		Fade.change_scene("res://Escenas/battle_final.tscn")
	else:
		Fade.change_scene("res://Escenas/menu.tscn")
