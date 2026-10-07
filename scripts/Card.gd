extends Node2D

const CARD_BACK = preload("res://assets/back_card.png")
const CARD_FRONT = preload("res://assets/1.2 Poker cards.png")

var suit = -1
var value = -1
var position_in_hand

func _ready() -> void:
	var area = $Area2D
	area.collision_layer = 0              # clear all layers first
	area.set_collision_layer_value(1, true)  # put the card on layer 1
	area.collision_mask = 0          

func set_card_image(column: int, row: int) -> void:
	$CardImage.texture = CARD_FRONT
	var card_width = 48    # width of one card in your sheet, in pixels
	var card_height = 64   # height of one card
	$CardImage.region_enabled = true
	$CardImage.region_rect = Rect2(column * card_width, row * card_height, card_width, card_height)
	suit = row
	value = column
	
func show_back():
	$CardImage.texture = CARD_BACK
	$CardImage.region_enabled = false
	suit = -1
	value = -1
