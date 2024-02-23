extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_card(card: Card):
	# Add the card to the pile data (list, array, etc.)
	# Update pile visuals (add card node as child, position it, etc.)
	if card is Card:
		print(card.rank)
	else:
		print("nope!")
