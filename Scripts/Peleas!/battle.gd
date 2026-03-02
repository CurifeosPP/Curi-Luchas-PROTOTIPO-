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

# control para evitar reentradas
var round_ended := false

func _ready():
	update_score_label()
	spawn_players()

# =========================
# SPAWN
# =========================
func spawn_players():
	# Instanciar P1
	p1 = alan_scene.instantiate()
	add_child(p1)
	p1.global_position = p1_spawn.global_position
	p1.input_prefix = "p1_"

	# Instanciar P2
	p2 = jesus_scene.instantiate()
	add_child(p2)
	p2.global_position = p2_spawn.global_position

# =========================
# PHYSICS
# =========================
@warning_ignore("unused_parameter")
func _physics_process(delta):
	if round_ended:
		return

	if p1 and p1.global_position.y > fall_limit:
		player_lost(p1)

	if p2 and p2.global_position.y > fall_limit:
		player_lost(p2)

# =========================
# PERDER RONDA
# =========================
func player_lost(loser):
	if round_ended:
		return

	round_ended = true
	set_physics_process(false)

	if loser == p1:
		p2_rounds += 1
	else:
		p1_rounds += 1

	update_score_label()

	# decidir si es ronda final (mejor de 3)
	var is_final := (p1_rounds >= max_rounds or p2_rounds >= max_rounds)

	# pequeño delay para sentir el KO
	await get_tree().create_timer(0.8).timeout

	if is_final:
		# --- RONDA FINAL: usamos change_scene (internamente hace fade in/out) ---
		# No hacemos fade manual aquí para evitar doble fade
		Fade.change_scene("res://Escenas/battle_final.tscn")
		return
	else:
		# --- RONDA NORMAL: hacemos fade manual y respawn ---
		await _do_round_fade_and_reset()
		return

# =========================
# TRANSICIÓN DE RONDA (NORMAL)
# =========================
func _do_round_fade_and_reset() -> void:
	# Fade IN (pantalla negra) usando el AnimationPlayer del autoload Fade
	# Nos apoyamos en que Fade expone `anim` (AnimationPlayer)
	if Fade and Fade.anim:
		Fade.anim.play("Fade Im")
		await Fade.anim.animation_finished
	else:
		# fallback: pequeño delay si no hay anim disponible
		await get_tree().create_timer(0.3).timeout

	# Liberar jugadores actuales
	if p1:
		p1.queue_free()
		p1 = null
	if p2:
		p2.queue_free()
		p2 = null

	# esperar un frame para que todo se procese
	await get_tree().process_frame

	# Respawn
	spawn_players()

	# Fade OUT (volver a juego)
	if Fade and Fade.anim:
		Fade.anim.play("Fadeout")
		await Fade.anim.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout

	# Reiniciar flags y física
	round_ended = false
	set_physics_process(true)

# =========================
# SCORE
# =========================
func update_score_label():
	score_label.text = "ALAN " + str(p1_rounds) + " - " + str(p2_rounds) + " JESUS"
