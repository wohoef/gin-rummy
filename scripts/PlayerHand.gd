extends Node2D

const CARD_WIDTH = 50
const MELD_COLORS = [
	Color(1, 1, 0.6),      # soft yellow
	Color(0.7, 0.85, 1),   # soft blue
	Color(0.7, 1, 0.7),    # soft green
]

var screen_size
var center_screen_x
var hand_y_position
var hand = []

var deck_reference
var card_manager_reference
var discard_pile_reference

func _ready() -> void:
	screen_size = get_viewport_rect()
	center_screen_x = screen_size.size.x / 2
	hand_y_position = screen_size.size.y * 0.7
	deck_reference = $"../Deck"
	card_manager_reference = $"../CardManager"
	discard_pile_reference = $"../DiscardPile"

func show_draw_from_deck(value, suit):
	var card = deck_reference.spawn_card_back(self)
	card.set_card_image(value, suit)
	add_card_to_hand(card)

func add_card_to_hand(card):
	card.position_in_hand = null
	hand.insert(0, card)
	update_hand_position()

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func update_hand_position():
	hand.sort_custom(func(a, b): return a.position.x < b.position.x)
	var card_being_dragged = card_manager_reference.card_being_dragged
	for i in range(hand.size()):
		var card = hand[i]
		if card == card_being_dragged:
			continue
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		if card.position_in_hand != new_position:
			card.position_in_hand = new_position
			animate_card_to_position(card, new_position)
	highlight_melds()

func hand_data():
	return hand.map(func(c): return [c.value, c.suit])
	
func highlight_melds():
	for card in hand:
		card.modulate = Color.WHITE
	var melds = Rules.find_melds(hand_data())
	for m in range(melds.size()):
		var color = MELD_COLORS[m % MELD_COLORS.size()]
		for i in melds[m]:
			hand[i].modulate = color

func discard_card_at(index):
	var card = hand[index]
	remove_card_from_hand(card)
	discard_pile_reference.add_card(card)

func calculate_card_position(index):
	var total_width = (hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func remove_card_from_hand(card):
	hand.erase(card)
	update_hand_position()

func sort_by_value():
	hand.sort_custom(compare_by_value)
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		hand[i].position_in_hand = new_position
		animate_card_to_position(hand[i], new_position)
	highlight_melds()

# Lowest value first; if the values are equal, sort by suit
func compare_by_value(a, b):
	if a.value != b.value:
		return a.value < b.value
	return a.suit < b.suit
