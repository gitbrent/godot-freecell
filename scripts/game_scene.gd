extends Node2D

# VARIABLES
var tableau_piles = []
var dragged_card : Card = null
var drag_offset : Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	# STEP 1: drag-n-drop
	set_process_unhandled_input(true)

	# STEP 2: Initialize tableau pile references
	for i in range(0, 8): # Assuming you named them TableauPile0 through TableauPile7
		tableau_piles.append(get_node("TableauPileCont/TableauPile" + str(i)))

	# STEP 3: Deal all 52 cards onto tableua
	deal_cards()

func _on_drag_in_progress(card, mouse_position):
	if card == dragged_card:  # Ensure this is the card you're currently dragging
		var new_position = mouse_position - drag_offset
		card.global_position = new_position

static func compare_cards_z_index(a, b):
	return a.z_index < b.z_index

func identify_card_pile(card: Card) -> int:
	for pile_index in range(tableau_piles.size()):
		var pile = tableau_piles[pile_index]
		for pile_card in pile.get_children():  # Assuming each pile is a parent node to its cards
			if pile_card is Card and pile_card.suit == card.suit and pile_card.rank == card.rank:
				return pile_index  # Return the index of the pile that contains the card
	return -1  # Return -1 or any indicator to signify the card was not found in any pile

func is_valid_drag_start(card: Card, card_pile_index: int) -> bool:
	#print("Checking if valid drag start for: ", card.rank, card.suit, " in pile ", card_pile_index)

	if card_pile_index == -1:
		return false  # Card is not in any recognized pile.

	var card_pile = tableau_piles[card_pile_index].get_children()  # Assuming piles are parent nodes to cards.

	# Check if the card is the last in the pile.
	if card == card_pile[card_pile.size() - 1]:
		return true

	# Additional checks for valid sequences go here.
	# Example sequence check (assuming descending sequence without suit check):
	var card_index = card_pile.find(card)
	for i in range(card_index, card_pile.size() - 1):
		if card_pile[i].rank - 1 != card_pile[i + 1].rank:  # Ensure descending order.
			return false  # Sequence is broken, invalid drag.
	
	return true  # Valid sequence

func _on_attempt_drag_start(card, initial_mouse_position):
	var card_pile_index = identify_card_pile(card)

	# Check if the card is the last one in its pile or part of a valid sequence.
	if is_valid_drag_start(card, card_pile_index):
		#print("START drag: " + str(card.rank) + "-" + str(card.suit) + " at " + str(card.z_index))
		drag_offset = initial_mouse_position - card.global_position
		dragged_card = card
		card.original_position = card.global_position
		card.z_index = 1000  # Temporarily boost z_index for dragging visibility
	else:
		#print("[is_valid_drag_start]: Invalid card or sequence")
		dragged_card = null  # Explicitly ensure dragging isn't started

func _on_card_drag_ended(card):
	# IMPORTANT: this method is trigged for all cards under the cursor
	# e.g.: release mouse button over another card and *BOTH* will call this function!
	if card == dragged_card:
		#print("..END drag: " + str(card.rank) +"-"+ str(card.suit) + " at " + str(card.z_index))
		var tween = get_tree().create_tween()
		tween.tween_property(card, "global_position", card.original_position, 0.5)
		tween.tween_callback(reset_card_z_indices)
	
	# Ensure to reset this regardless of condition to prevent stuck states
	dragged_card = null

func reset_card_z_indices():
	for i in range(tableau_piles.size()):
		var pile = tableau_piles[i]
		for j in range(pile.get_child_count()):
			var card = pile.get_child(j)
			card.z_index = j
			#print("card.z_index: ", card.z_index)

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
				var control_node = card.get_node("CardControl")
				control_node.connect("attempt_drag_start", self._on_attempt_drag_start)
				control_node.connect("drag_in_progress", self._on_drag_in_progress)
				control_node.connect("card_drag_ended", self._on_card_drag_ended)
				tableau_piles[i].add_card(card)
				card.add_to_group("cards")
			else:
				print("Error: The instantiated object is not a Card.")
	
	# STEP 5:
	reset_card_z_indices()

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
