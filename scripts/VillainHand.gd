extends Node2D

const CARD_WIDTH = 50
var hand = []   # face-down card nodes, no real values
var deck_reference
var discard_pile_reference


func _ready() -> void:
	deck_reference = $"../Deck"
	discard_pile_reference = $"../DiscardPile"

func show_draw_from_deck():
	add_card(deck_reference.spawn_card_back(self))

func show_draw_from_discard():
	add_card(discard_pile_reference.draw_card(self))

func show_discard(value, suit):
	var card = take_random_card()
	card.set_card_image(value, suit)
	discard_pile_reference.add_card(card)

func add_card(card):
	card.show_back()
	card.position_in_hand = null
	card.get_node("Area2D").collision_layer = 0
	card.reparent(self)
	hand.append(card)
	update_hand_position()

func take_random_card():
	var card = hand.pick_random()
	hand.erase(card)
	update_hand_position()
	return card

func reveal(villain_cards):
	for i in range(hand.size()):
		hand[i].set_card_image(villain_cards[i][0], villain_cards[i][1])

func update_hand_position():
	var total_width = (hand.size() - 1) * CARD_WIDTH
	for i in range(hand.size()):
		var x = get_viewport_rect().size.x / 2 + i * CARD_WIDTH - total_width / 2
		var tween = get_tree().create_tween()
		tween.tween_property(hand[i], "position", Vector2(x, 60), 0.1)
