extends Node

enum State { PLAYER_DRAW, PLAYER_DISCARD, VILLAIN_TURN, ROUND_OVER }

var state = State.PLAYER_DRAW
var cards = []
var villain_hand = []
var player_hand = []

var villain_hand_reference
var player_hand_reference
var discard_pile_reference


func _ready() -> void:
	for i in range(13):
		for j in range(4):
			cards.append([i, j])
	cards.shuffle()
	
	villain_hand_reference = $"../VillainHand"
	player_hand_reference = $"../PlayerHand"
	discard_pile_reference = $"../DiscardPile"
	deal.call_deferred()

func draw_card():
	if cards.size() > 0:
		var card_drawn = cards[0]
		cards.erase(card_drawn)
		return card_drawn
	else:
		return null

func deal():
	for i in range(10):
		var card_data = draw_card()
		player_hand.append(card_data)

		player_hand_reference.show_draw_from_deck(card_data[0], card_data[1])

		villain_hand.append(draw_card())
		villain_hand_reference.show_draw_from_deck()
	var first_discard = draw_card()
	discard_pile_reference.show_draw_from_deck(first_discard[0], first_discard[1])


func start_villain_turn():
	state = State.VILLAIN_TURN
	await get_tree().create_timer(0.5).timeout
	
	if randi() % 2 == 0 and discard_pile_reference.cards.size() > 0:
		var top = discard_pile_reference.cards[-1]
		villain_hand.append([top.value, top.suit])
		villain_hand_reference.show_draw_from_discard()
	else:
		var data = draw_card()
		if data:
			villain_hand.append(data)
			villain_hand_reference.show_draw_from_deck()
	
	await get_tree().create_timer(0.5).timeout
	
	var discard = villain_hand.pop_at(randi() % villain_hand.size())
	villain_hand_reference.show_discard(discard[0], discard[1])

	state = State.PLAYER_DRAW

func player_knock(hand):
	if state != State.PLAYER_DISCARD:
		return
	var kind = Rules.knock_type(hand)
	if kind == "":
		return

	# Discard the highest unmatched card
	var index = Rules.knock_discard_index(hand)
	var knocker_hand = hand.duplicate()
	if index != -1:
		player_hand_reference.discard_card_at(index)
		knocker_hand.remove_at(index)

	state = State.ROUND_OVER

	# The knocker's melds and deadwood
	var knocker_melds = Rules.meld_cards(knocker_hand)
	var knocker_deadwood = Rules.deadwood_points(Rules.deadwood_cards(knocker_hand))

	# The villain arranges its hand, then lays off (not allowed against gin)
	var villain_arranged = Rules.best_arrangement(villain_hand)
	var villain_deadwood = Rules.deadwood_cards(villain_arranged)
	if kind == "knock":
		villain_deadwood = Rules.lay_off(villain_deadwood, knocker_melds)

	villain_hand_reference.reveal(villain_arranged)

	print("Player went ", kind, " with ", knocker_deadwood, " deadwood")
	print("Knocker melds after lay-off: ", knocker_melds)
	print("Villain deadwood left: ", villain_deadwood, " = ", Rules.deadwood_points(villain_deadwood), " points")
