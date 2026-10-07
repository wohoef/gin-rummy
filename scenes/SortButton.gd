extends Button

func _ready() -> void:
	text = "Sort"
	pressed.connect(_on_pressed)

func _on_pressed():
	$"../PlayerHand".sort_by_value()
