extends CanvasLayer

@onready var anim = $AnimationPlayer
var changing_scene = false

func _ready():
	# Cuando el juego inicia, revelar pantalla
	anim.play("Fadeout")

func change_scene(path: String) -> void:
	if changing_scene:
		return
		
	changing_scene = true
	
	anim.play("Fade Im")
	await anim.animation_finished
	
	get_tree().change_scene_to_file(path)
	
	anim.play("Fadeout")
	await anim.animation_finished
	
	changing_scene = false
