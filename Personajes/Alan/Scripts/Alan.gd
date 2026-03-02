extends CharacterBody2D

# =========================
# CONFIGURACIÓN
# =========================

@export var speed: float = 250.0
@export var jump_force: float = -500.0
@export var gravity: float = 1200.0
@export var input_prefix: String = "p1_"

@export var normal_texture: Texture2D
@export var block_texture: Texture2D

@export var attack_damage: float = 10.0
@export var base_knockback: float = 200.0
@export var knockback_scaling: float = 5.0

# =========================
# ESTADOS
# =========================

var is_blocking: bool = false
var is_attacking: bool = false
var is_crouching: bool = false
var facing_direction: int = 1

var percent: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

# =========================
# NODOS
# =========================

@onready var attack_area: Area2D = $Area2D
@onready var attack_visual: Sprite2D = $Area2D/AttackVisual
@onready var sprite: Sprite2D = $Sprite2D
@onready var percent_label: Label = $CanvasLayer/PercentLabel

@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

var hitbox_pos_right: Vector2
var hitbox_pos_left: Vector2

# =========================
# READY
# =========================

func _ready():

	# 🔥 IMPORTANTE PARA QUE JESUS LO DETECTE
	add_to_group("player")

	attack_area.monitoring = false
	attack_visual.visible = false

	hitbox_pos_right = attack_area.position
	hitbox_pos_left = Vector2(-160, -15)

	update_percent_label()
	attack_area.body_entered.connect(_on_attack_body_entered)

# =========================
# PHYSICS
# =========================

func _physics_process(delta):

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	handle_movement()
	handle_actions()

	# Knockback
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)

	move_and_slide()

# =========================
# MOVIMIENTO
# =========================

func handle_movement():

	var direction = 0

	if Input.is_action_pressed(input_prefix + "izquierda"):
		direction -= 1

	if Input.is_action_pressed(input_prefix + "derecha"):
		direction += 1

	velocity.x = direction * speed

	if direction != 0:
		facing_direction = direction
		sprite.flip_h = (facing_direction == -1)

		if facing_direction == 1:
			attack_area.position = hitbox_pos_right
		else:
			attack_area.position = hitbox_pos_left

	if Input.is_action_just_pressed(input_prefix + "saltar") and is_on_floor():
		if not is_crouching:
			velocity.y = jump_force

# =========================
# ACCIONES
# =========================

func handle_actions():

	is_crouching = Input.is_action_pressed(input_prefix + "agachar") and is_on_floor()
	is_blocking = Input.is_action_pressed(input_prefix + "bloquear")

	update_block_sprite()

	if Input.is_action_just_pressed(input_prefix + "atacar"):
		attack()

# =========================
# BLOQUEO
# =========================

func update_block_sprite():
	if is_blocking and block_texture:
		sprite.texture = block_texture
	elif normal_texture:
		sprite.texture = normal_texture

# =========================
# ATAQUE
# =========================

func attack():
	if is_attacking:
		return

	is_attacking = true

	attack_area.monitoring = true
	attack_visual.visible = true

	await get_tree().create_timer(0.2).timeout

	attack_area.monitoring = false
	attack_visual.visible = false

	await get_tree().create_timer(0.1).timeout

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
# RECIBIR GOLPE
# =========================

func receive_hit(damage: float, attacker_direction: int):

	if is_blocking:
		damage *= 0.3

	hurt_sound.play()

	percent += damage
	update_percent_label()

	var force = base_knockback + (percent * knockback_scaling)
	var direction = Vector2(attacker_direction, -0.5).normalized()

	knockback_velocity = direction * force

# =========================
# UI
# =========================

func update_percent_label():
	percent_label.text = str(int(percent)) + "%"
