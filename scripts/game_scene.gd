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

func deal_cards():
	# Shuffle the deck (optional)
	# Distribute cards to piles based on your game rules
	for i in 51:
		var card_scene = load("res://scenes/card.tscn") # Load the PackedScene
		var card_instance = card_scene.instantiate() # Instantiate it, which should be an instance of Card

		# Now, to make sure GDScript understands it's a Card, you can either:
		if card_instance is Card:
			var card: Card = card_instance
			# Initialize the card with suit and rank
			card.initialize(Enums.Suit.HEARTS, Enums.Rank.ACE)  # Example, you'll probably want to vary this based on actual game logic
			# Add card to a pile (choose the pile based on your rules)
			tableau_pile.add_child(card)
			# Now you can use 'card' as an instance of your Card class.
		else:
			print("Error: The instantiated object is not a Card.")
			print(card_instance.get_class()) # This should help identify what you're actually instantiating

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
