extends Node2D

# Declare variables
@onready var free_cell_pile = $TopContainer/FreeCellPile
@onready var foundation_pile = $TopContainer/FoundationPile
@onready var tableau_pile = $TableauPile

# Called when the node enters the scene tree for the first time.
func _ready():
	deal_cards()
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_pile(position: Vector2) -> Control:
	# Create a pile Control node, add it as child, and configure (drag-n-drop, visuals, etc.)
	var pile = Control.new()
	add_child(pile)
	pile.position = position
	# ... further pile setup ...
	return pile

func deal_cards():
	# Shuffle the deck (optional)
	# Distribute cards to piles based on your game rules
	for i in 51:
		var card:Node2D = load("res://scenes/card.tscn").instantiate()
		# Add card to a pile (choose the pile based on your rules)
		tableau_pile.add_card(card)

func handle_card_drag(card: Card, source_pile: Control, target_pile: Control):
	# Check if move is valid based on game rules
	if card.can_move_to(target_pile.get_top_card()):
		# Remove card from source pile
		source_pile.remove_card(card)
		# Add card to target pile
		target_pile.add_card(card)
		# Update card position and visuals
		card.update_position_and_visuals()

# Other functions for game logic, player turns, win/lose conditions, etc.
