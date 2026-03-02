extends Node2D

@onready var p1_spawn = $SpawnPoints/P1Spawn
@onready var p2_spawn = $SpawnPoints/P2Spawn
@onready var score_label = $CanvasLayer/ScoreLabel

var alan_scene = preload("res://Personajes/Alan/Scripts/Alan.tscn")
var jesus_scene = preload("res://Personajes/Jesus/Scripts/Jesus.tscn")

var p1
var p2

var p1_rounds: int = 0
var p2_rounds: int = 0
var max_rounds: int = 2

var fall_limit: float = 1200.0

func _ready():
	update_score_label()
	spawn_players()

# =========================
# SPAWN
# =========================

func spawn_players():

	p1 = alan_scene.instantiate()
	add_child(p1)
	p1.global_position = p1_spawn.global_position
	p1.input_prefix = "p1_"

	p2 = jesus_scene.instantiate()
	add_child(p2)
	p2.global_position = p2_spawn.global_position

# =========================
# PHYSICS
# =========================

func _physics_process(delta):

	if p1 and p1.global_position.y > fall_limit:
		player_lost(p1)

	if p2 and p2.global_position.y > fall_limit:
		player_lost(p2)

# =========================
# PERDER RONDA
# =========================

func player_lost(loser):

	set_physics_process(false)

	if loser == p1:
		p2_rounds += 1
	else:
		p1_rounds += 1

	update_score_label()

	await get_tree().create_timer(1.0).timeout

	check_match_end()

# =========================
# SCORE
# =========================

func update_score_label():
	score_label.text = "ALAN " + str(p1_rounds) + " - " + str(p2_rounds) + " JESUS"

# =========================
# FIN / TRANSICIONES
# =========================

func check_match_end():

	# 🔥 SI ALGUIEN LLEGA A 2 → IR A RONDA FINAL (OTRA ESCENA)
	if p1_rounds >= max_rounds or p2_rounds >= max_rounds:

		score_label.text = "⚠️ FINAL ROUND ⚠️"

		await get_tree().create_timer(1.5).timeout

		# 🔥 CAMBIO DE ESCENA CON FADE
		Fade.change_scene("res://Escenas/battle_final.tscn")
		return

	# 🔥 SIGUIENTE RONDA NORMAL
	await get_tree().create_timer(1.0).timeout
	reset_round()

# =========================
# RESET
# =========================

func reset_round():

	if p1:
		p1.queue_free()

	if p2:
		p2.queue_free()

	await get_tree().process_frame

	spawn_players()
	set_physics_process(true)
