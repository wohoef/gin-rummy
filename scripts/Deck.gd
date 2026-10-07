extends Node2D

var game_manager

func _ready() -> void:
	game_manager = $"../GameManager"

func draw_card(hand):
	var card_xy = game_manager.draw_card()
	if card_xy:
		var card_scene = preload("res://scenes/Card.tscn")
		var new_card = card_scene.instantiate()
		new_card.set_card_image(card_xy[0], card_xy[1])
		hand.add_child(new_card)
		new_card.global_position = global_position
		return new_card
	else:
		return null

func spawn_card_back(hand):
	var card_scene = preload("res://scenes/Card.tscn")
	var new_card = card_scene.instantiate()
	hand.add_child(new_card)
	new_card.global_position = global_position
	return new_card
