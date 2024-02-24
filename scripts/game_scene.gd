extends Node2D

# VARIABLES
var tableau_piles = []
var dragged_card = null
var drag_offset = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	# STEP 1: drag-n-drop
	set_process_unhandled_input(true)

	# STEP 2: Initialize tableau pile references
	for i in range(0, 8): # Assuming you named them TableauPile0 through TableauPile7
		tableau_piles.append(get_node("TableauPileCont/TableauPile" + str(i)))

	# STEP 3: Deal all 52 cards onto tableua
	deal_cards()

func _unhandled_input(event):
	if event is InputEventMouseMotion and dragged_card:
		dragged_card.global_position = event.global_position - drag_offset
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragged_card = null # Release the drag when the mouse button is released

func _on_card_drag_started(card, initial_mouse_position):
	print("START drag: " + str(card.rank) +"-"+ str(card.suit))
	drag_offset = initial_mouse_position - card.global_position
	dragged_card = card
	card.z_index = 1000

func _on_card_drag_ended(card):
	print("..END drag: " + str(card.rank) +"-"+ str(card.suit))
	dragged_card = null
	card.z_index = 0

func deal_cards():
	var deck = []
	
	# STEP 1: clear all cards
	for i in range(tableau_piles.size()):
		tableau_piles[i].remove_all_cards()
		
	# STEP 1: Create the standard 52 playing cards
	for suit in Enums.Suit.values():
		for rank in Enums.Rank.values():
			deck.append({"suit": suit, "rank": rank})
	
	# STEP 2: Shuffle the deck
	deck.shuffle()
	
	# STEP 3: Setup for dealing cards to tableau piles according to FreeCell rules
	var num_cards_in_columns = [7, 7, 7, 7, 6, 6, 6, 6]
	var deck_index = 0
	
	# STEP 4: Deal
	for i in range(tableau_piles.size()):
		var num_cards = num_cards_in_columns[i]
		for j in range(num_cards):
			var card_info = deck[deck_index]
			deck_index += 1
			
			var card_scene = load("res://scenes/card.tscn")
			var card_instance = card_scene.instantiate()
			
			if card_instance is Card:
				var card: Card = card_instance
				card.call_deferred("initialize", card_info["suit"], card_info["rank"])
				card.connect("card_drag_started", self._on_card_drag_started)
				card.connect("card_drag_ended", self._on_card_drag_ended)
				tableau_piles[i].add_card(card)
			else:
				print("Error: The instantiated object is not a Card.")

# (???) useful? [untested!]
func handle_card_drag(card: Card, source_pile: Control, target_pile: Control):
	# Check if move is valid based on game rules
	if card.can_move_to(target_pile.get_top_card()):
		# Remove card from source pile
		source_pile.remove_card(card)
		# Add card to target pile
		target_pile.add_card(card)
		# Update card position and visuals
		card.update_position_and_visuals()

func _on_btn_deal_pressed():
	deal_cards()
