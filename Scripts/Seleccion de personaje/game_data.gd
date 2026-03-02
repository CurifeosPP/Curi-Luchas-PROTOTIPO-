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
# PUNTAJE GLOBAL
# =========================

var p1_score: int = 0
var p2_score: int = 0

# Smash
var smash_p1_rounds: int = 0
var smash_p2_rounds: int = 0

# Control desempate
var in_tiebreaker: bool = false

# =========================
# DIFICULTAD
# =========================

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

var jesus_difficulty: Difficulty = Difficulty.NORMAL

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
# SMASH
# =========================

func reset_smash():
	smash_p1_rounds = 0
	smash_p2_rounds = 0

func add_smash_round(winner: String):
	if winner == "ALAN":
		smash_p1_rounds += 1
		p1_score += 1
	else:
		smash_p2_rounds += 1
		p2_score += 1

# =========================
# SERIO
# =========================

func add_serious_round(winner: String):
	if winner == "ALAN":
		p1_score += 1
	else:
		p2_score += 1

# =========================
# ESTADO DEL MATCH
# =========================

func is_tied() -> bool:
	return p1_score == p2_score

func has_winner() -> bool:
	return p1_score != p2_score and not is_tied()

# =========================
# RESET TOTAL
# =========================

func reset():
	p1_character = "Alan"
	p2_character = "Jesus"
	p2_is_ai = true
	is_local_multiplayer = false
	jesus_difficulty = Difficulty.NORMAL
	p1_score = 0
	p2_score = 0
	in_tiebreaker = false
	reset_smash()
	
	# =========================
# CONDICIÓN DE VICTORIA FINAL
# =========================
func reached_three() -> String:
	var winner := ""

	if p1_score >= 3:
		alan_total_wins += 1
		winner = "ALAN"

	elif p2_score >= 3:
		jesus_total_wins += 1
		winner = "JESUS"

	if winner != "":
		# 🔥 RESET SOLO DEL MATCH, NO DEL HISTORIAL
		p1_score = 0
		p2_score = 0
		in_tiebreaker = false
		reset_smash()

	return winner
	# =========================
# HISTORIAL DE VICTORIAS
# =========================

var alan_total_wins: int = 0
var jesus_total_wins: int = 0
