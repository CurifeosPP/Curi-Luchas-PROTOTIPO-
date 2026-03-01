extends Node

# --- Modo ---
var is_local_multiplayer: bool = false

# --- Player 1 ---
var p1_character: String = ""
var p1_weapon: String = ""

# --- Player 2 ---
var p2_character: String = ""
var p2_weapon: String = ""
var p2_is_ai: bool = true

func reset():
	p1_character = ""
	p1_weapon = ""
	p2_character = ""
	p2_weapon = ""
	p2_is_ai = true
