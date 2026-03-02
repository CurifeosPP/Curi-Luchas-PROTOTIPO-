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

	# 🔥 YA NO ACTIVAMOS MODO VIDA
	# Porque estos personajes ya están hechos solo para vida

	# 🔥 ESCUCHAR MUERTE
	p1.tree_exited.connect(_on_player_dead.bind("JESUS"))
	p2.tree_exited.connect(_on_player_dead.bind("ALAN"))

func _on_player_dead(winner_name):

	if fight_ended:
		return

	fight_ended = true

	if result_label:
		result_label.text = "🔥 " + winner_name + " GANA 🔥"

	Fade.change_scene("res://Escenas/menu.tscn")
