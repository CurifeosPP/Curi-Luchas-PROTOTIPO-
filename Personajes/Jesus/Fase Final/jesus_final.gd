extends CharacterBody2D

# =========================
# DIFICULTAD
# =========================

enum Difficulty { EASY, NORMAL, HARD }

@export var base_speed: float = 180.0
@export var gravity: float = 1200.0
@export var jump_force: float = -450.0
@export var attack_range: float = 80.0
@export var base_cooldown: float = 1.0

@export var attack_damage: float = 10.0

# =========================
# VIDA
# =========================

@export var max_health: float = 100.0
var health: float = 100.0

# =========================
# VARIABLES
# =========================

var speed: float
var attack_cooldown: float

var target: CharacterBody2D
var is_attacking := false
var can_attack := true
var facing_direction := 1

var knockback_velocity := Vector2.ZERO

# =========================
# NODOS
# =========================

@onready var attack_area: Area2D = $Area2D
@onready var attack_visual: Sprite2D = $Area2D/AttackVisual
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar = get_node_or_null("CanvasLayer/HealthBar")

@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

# POSICIONES
var hitbox_pos_right: Vector2
var hitbox_pos_left: Vector2

# =========================
# READY
# =========================

func _ready():

	configure_difficulty()

	attack_area.monitoring = false
	attack_visual.visible = false

	hitbox_pos_right = attack_area.position
	hitbox_pos_left = Vector2(-160, -15)

	health = max_health
	update_health_bar()

	attack_area.body_entered.connect(_on_attack_body_entered)

	find_target()

# =========================
# DIFICULTAD
# =========================

func configure_difficulty():

	match GameData.jesus_difficulty:

		GameData.Difficulty.EASY:
			speed = base_speed * 0.7
			attack_cooldown = base_cooldown * 1.5

		GameData.Difficulty.NORMAL:
			speed = base_speed
			attack_cooldown = base_cooldown

		GameData.Difficulty.HARD:
			speed = base_speed * 1.3
			attack_cooldown = base_cooldown * 0.6

# =========================
# TARGET
# =========================

func find_target():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

# =========================
# PHYSICS
# =========================

func _physics_process(delta):

	if target == null:
		find_target()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	ai_logic()

	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)

	move_and_slide()

# =========================
# IA
# =========================

func ai_logic():

	var dx = target.global_position.x - global_position.x
	var dy = target.global_position.y - global_position.y

	# Dirección
	if dx != 0:
		facing_direction = sign(dx)
		sprite.flip_h = facing_direction == -1

		if facing_direction == 1:
			attack_area.position = hitbox_pos_right
		else:
			attack_area.position = hitbox_pos_left

	# Saltar si el jugador está arriba
	if dy < -60 and is_on_floor():
		velocity.y = jump_force

	# Movimiento
	if abs(dx) > attack_range:
		velocity.x = facing_direction * speed
	else:
		velocity.x = 0
		if can_attack:
			attack()

# =========================
# ATAQUE
# =========================

func attack():

	if is_attacking:
		return

	is_attacking = true
	can_attack = false

	attack_area.monitoring = true
	attack_visual.visible = true

	await get_tree().create_timer(0.25).timeout

	attack_area.monitoring = false
	attack_visual.visible = false

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true
	is_attacking = false

# =========================
# GOLPEAR
# =========================

func _on_attack_body_entered(body):

	if body == self:
		return

	if body.has_method("receive_hit"):
		hit_sound.play()
		body.receive_hit(attack_damage, facing_direction)

# =========================
# RECIBIR DAÑO
# =========================

func receive_hit(damage: float, attacker_direction: int):

	hurt_sound.play()

	health -= damage
	update_health_bar()

	if health <= 0:
		queue_free()

# =========================
# UI VIDA
# =========================

func update_health_bar():
	if health_bar:
		health_bar.value = health
