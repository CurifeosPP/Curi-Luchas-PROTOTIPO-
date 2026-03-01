extends Node

# =========================
# MODOS
# =========================

var is_local_multiplayer: bool = false
var p2_is_ai: bool = true

# =========================
# PERSONAJES
# =========================

var p1_character: String = "Alan"
var p2_character: String = "Jesus"

# =========================
# DIFICULTAD IA (JESUS)
# =========================

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

var jesus_difficulty: Difficulty = Difficulty.NORMAL

# =========================
# FUNCIONES DE DIFICULTAD
# =========================

func set_difficulty(new_difficulty: Difficulty):
	jesus_difficulty = new_difficulty

func get_difficulty_name() -> String:
	match jesus_difficulty:
		Difficulty.EASY:
			return "Fácil"
		Difficulty.NORMAL:
			return "Normal"
		Difficulty.HARD:
			return "Difícil"
	
	return "Normal"

# =========================
# RESET
# =========================

func reset():
	p1_character = "Alan"
	p2_character = "Jesus"
	p2_is_ai = true
	is_local_multiplayer = false
	jesus_difficulty = Difficulty.NORMAL
