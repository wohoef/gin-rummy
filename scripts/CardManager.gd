extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 2
const COLLISION_MASK_DISCARD_PILE = 4
const CLICK_DISTANCE = 5   # moved less than this many pixels = a click, not a drag


var card_being_dragged = null
var screen_size
var player_hand_reference
var game_manager_reference
var drag_start_mouse_position


func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	game_manager_reference = $"../GameManager"

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)
		player_hand_reference.update_hand_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			raycast_at_cursor()
		else:
			if card_being_dragged:
				end_drag(card_being_dragged)

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD| COLLISION_MASK_DECK|COLLISION_MASK_DISCARD_PILE
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var layer = result[0].collider.collision_layer
		if layer & COLLISION_MASK_CARD:
			# Card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				start_drag(card_found)
		elif layer & COLLISION_MASK_DECK:
			if game_manager_reference.state == game_manager_reference.State.PLAYER_DRAW:
				# Deck clicked
				var new_card = $"../Deck".draw_card(player_hand_reference)
				if new_card:
					player_hand_reference.add_card_to_hand(new_card)
					game_manager_reference.state = game_manager_reference.State.PLAYER_DISCARD
		elif layer & COLLISION_MASK_DISCARD_PILE:
			if game_manager_reference.state == game_manager_reference.State.PLAYER_DRAW:
				var card = $"../DiscardPile".draw_card(player_hand_reference)
				if card:
					player_hand_reference.add_card_to_hand(card)
					game_manager_reference.state = game_manager_reference.State.PLAYER_DISCARD

func start_drag(card):
	card_being_dragged = card
	card_being_dragged.z_index = 2
	drag_start_mouse_position = get_global_mouse_position()

func end_drag(card):
	card_being_dragged = null
	var was_click = get_global_mouse_position().distance_to(drag_start_mouse_position) < CLICK_DISTANCE
	var is_discard_phase = game_manager_reference.state == game_manager_reference.State.PLAYER_DISCARD

	if is_discard_phase and (was_click or is_mouse_over_discard_pile()):
		discard_card(card)
	else:
		card.z_index = 1
		player_hand_reference.update_hand_position()
		player_hand_reference.animate_card_to_position(card, card.position_in_hand)

func discard_card(card):
	player_hand_reference.remove_card_from_hand(card)
	$"../DiscardPile".add_card(card)
	game_manager_reference.start_villain_turn()

func is_mouse_over_discard_pile():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_DISCARD_PILE
	return space_state.intersect_point(parameters).size() > 0
