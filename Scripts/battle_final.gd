extends Node2D

@onready var p1_spawn = $SpawnPoints/P1Spawn
@onready var p2_spawn = $SpawnPoints/P2Spawn
@onready var result_label = $CanvasLayer/ResultLabel

var alan_scene = preload("res://Personajes/Alan/Scripts/Alan.tscn")
var jesus_scene = preload("res://Personajes/Jesus/Scripts/Jesus.tscn")

var p1
var p2

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

	# 🔥 ACTIVAR MODO VIDA
	p1.enable_health_mode()
	p2.enable_health_mode()

	# 🔥 ESCUCHAR MUERTE
	p1.tree_exited.connect(_on_player_dead.bind("JESUS"))
	p2.tree_exited.connect(_on_player_dead.bind("ALAN"))

func _on_player_dead(winner_name):

	result_label.text = "🔥 " + winner_name + " GANA 🔥"

	await get_tree().create_timer(2.0).timeout

	# Volver al menú o reiniciar
	Fade.change_scene("res://Escenas/menu.tscn")
