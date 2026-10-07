extends Button

var game_manager
var player_hand

func _ready() -> void:
	game_manager = $"../GameManager"
	player_hand = $"../PlayerHand"
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	var kind = ""
	if game_manager.state == game_manager.State.PLAYER_DISCARD:
		kind = Rules.knock_type(player_hand.hand_data())
	visible = kind != ""
	text = "Gin" if kind == "gin" else "Knock"

func _on_pressed():
	game_manager.player_knock(player_hand.hand_data())
