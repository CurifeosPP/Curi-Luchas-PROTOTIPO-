extends Control

@onready var history_label = $HistoryLabel

func _ready():
	update_history()

func _on_jugar_pressed() -> void:
	Fade.change_scene("res://Escenas/Cinematica.tscn")

func _on_opciones_pressed() -> void:
	# Abre la página web en el navegador
	OS.shell_open("https://github.com/CurifeosPP/Curi-Luchas-PROTOTIPO-/commits/main/")

func _on_salir_pressed() -> void:
	get_tree().quit()

func update_history():
	history_label.text = "🏆 HISTORIAL 🏆\n\n" \
	+ "ALAN: " + str(GameData.alan_total_wins) + " victorias\n" \
	+ "JESUS: " + str(GameData.jesus_total_wins) + " victorias"


func _on_opciones_2_pressed() -> void:
	OS.shell_open("https://github.com/CurifeosPP/Curi-Luchas-PROTOTIPO-")
