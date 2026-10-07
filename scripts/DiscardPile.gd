extends Node2D

var cards = []  # every discarded card, the last one is on top
var deck_reference

func _ready() -> void:
	deck_reference = $"../Deck"


func add_card(card):
	var previous_top = null
	if cards.size() > 0:
		previous_top = cards[-1]

	cards.append(card)
	card.reparent(self)
	card.modulate = Color.WHITE
	card.z_index = 3   # fly over the cards in your hand
	card.get_node("Area2D").collision_layer = 0

	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", Vector2.ZERO, 0.2)
	tween.tween_callback(hide_if_covered.bind(previous_top))

# Hide the old top card once the new one has landed on it
func hide_if_covered(card):
	if card and card in cards:
		card.visible = false

func draw_card(hand):
	if cards.size() == 0:
		return null
	var card = cards.pop_back()
	
	if cards.size() > 0:
		cards[-1].visible = true
		
	card.get_node("Area2D").collision_layer = 1
	card.z_index = 1
	card.reparent(hand)
	
	return card

func show_draw_from_deck(value, suit):
	var card = deck_reference.spawn_card_back(self)
	card.set_card_image(value, suit)
	add_card(card)
