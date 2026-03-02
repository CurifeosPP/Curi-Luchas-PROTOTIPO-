extends Node2D

@onready var p1_spawn = $SpawnPoints/P1Spawn
@onready var p2_spawn = $SpawnPoints/P2Spawn
@onready var score_label = $CanvasLayer/ScoreLabel

var alan_scene = preload("res://Personajes/Alan/Scripts/Alan.tscn")
var jesus_scene = preload("res://Personajes/Jesus/Scripts/Jesus.tscn")

var p1
var p2

var max_rounds: int = 2
var fall_limit: float = 1200.0
var round_ended := false

func _ready():
	GameData.reset_smash()
	update_score_label()
	spawn_players()

func spawn_players():
	p1 = alan_scene.instantiate()
	add_child(p1)
	p1.global_position = p1_spawn.global_position
	p1.input_prefix = "p1_"

	p2 = jesus_scene.instantiate()
	add_child(p2)
	p2.global_position = p2_spawn.global_position

func _physics_process(delta):
	if round_ended:
		return

	if p1 and p1.global_position.y > fall_limit:
		player_lost(p1)

	if p2 and p2.global_position.y > fall_limit:
		player_lost(p2)

func player_lost(loser):
	if round_ended:
		return

	round_ended = true
	set_physics_process(false)

	if loser == p1:
		GameData.add_smash_round("JESUS")
	else:
		GameData.add_smash_round("ALAN")

	update_score_label()

	var is_final := (
		GameData.smash_p1_rounds >= 2
		or GameData.smash_p2_rounds >= 2
	)

	await get_tree().create_timer(0.8).timeout

	if is_final:
		Fade.change_scene("res://Escenas/battle_final.tscn")
	else:
		await _do_round_fade_and_reset()

func _do_round_fade_and_reset():
	if Fade and Fade.anim:
		Fade.anim.play("Fade Im")
		await Fade.anim.animation_finished

	if p1:
		p1.queue_free()
		p1 = null
	if p2:
		p2.queue_free()
		p2 = null

	await get_tree().process_frame

	spawn_players()

	if Fade and Fade.anim:
		Fade.anim.play("Fadeout")
		await Fade.anim.animation_finished

	round_ended = false
	set_physics_process(true)

func update_score_label():
	score_label.text = "ALAN " + str(GameData.smash_p1_rounds) + " - " + str(GameData.smash_p2_rounds) + " JESUS"
