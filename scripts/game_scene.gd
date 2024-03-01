extends Node2D

# NODES
@onready var score = $LeftControl/InfoRect/VBoxContainer/HBoxContMoves/Score

# VARIABLES
const Y_OFFSET = 40
var drag_offset : Vector2 = Vector2()
var tableau_piles = []
var card_deck = []
var free_cells : Array = []
#
var card_dragged : Card = null
var dragging_cards : Array = []
var card_target : Card = null
var hovered_free_cell : FreeCell = null
#
var game_prop_moves : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# STEP 1: drag-n-drop
	set_process_unhandled_input(true)

	# STEP 2: Initialize tableau pile references
	for i in range(0, 8): # Assuming you named them TableauPile0 through TableauPile7
		tableau_piles.append(get_node("TableauPileCont/TableauPile" + str(i)))

	# STEP 3: Deal all 52 cards onto tableau
	deal_cards()
	
	# STEP 4: Init free-cell-pile
	for i in 4:
		var free_cell = get_node("TopContainer/FreeCellPile/FreeCell" + str(i))
		free_cell.connect("card_hover_free_start", self._on_card_hover_free_start)
		free_cell.connect("card_hover_free_ended", self._on_card_hover_free_ended)
		free_cells.append(free_cell)

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
		return true # (assumption is that this comes from free-cell)

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

func get_draggable_sequence(card: Card) -> Array:
	var cards:Array = []
	var card_pile_index:int = identify_card_pile(card)

	# Free Cells are index -1	
	if card_pile_index == -1:
		return [card]

	var card_pile = tableau_piles[card_pile_index].get_children()
	var start_index = card_pile.find(card)
	
	# Assuming valid drag start checks if the sequence from this card onwards is valid
	if is_valid_drag_start(card, card_pile_index):
		for i in range(start_index, card_pile.size()):
			var current_card = card_pile[i]
			if current_card is Card:
				cards.append(current_card)
				# Optionally, add additional validation here if needed
				# For example, checking if the sequence remains valid after the first card
			else:
				break  # Exit if we encounter a non-Card or invalid sequence	
	
	#print("[drag_start] cards.size: ", cards.size())
	return cards

func _on_card_drag_start(card:Card, initial_mouse_position):
	var sequence = get_draggable_sequence(card)
	if sequence.size() > 0:
		drag_offset = initial_mouse_position - card.global_position
		card_dragged = card
		dragging_cards = sequence
		for card_in_sequence in dragging_cards:
			card_in_sequence.original_position = card_in_sequence.global_position
			card_in_sequence.z_index += 1000  # Temporarily increase z_index for visibility
	else:
		#print("[is_valid_drag_start]: Invalid card or sequence")
		card_dragged = null  # Explicitly ensure dragging isn't started

func _on_drag_in_progress(card, mouse_position):
	if card == card_dragged:
		var draggable_sequence = get_draggable_sequence(card)
		var new_position = mouse_position - drag_offset
		for each_card in draggable_sequence:
			each_card.global_position = new_position + Vector2(0, draggable_sequence.find(each_card) * Y_OFFSET)
			# Y_OFFSET is a constant that determines how much each subsequent card is offset vertically

func _on_card_drag_ended(card):
	if card == card_dragged:
		#print("..END drag: " + str(card.rank) +"-"+ str(card.suit) + " at " + str(card.z_index))
		if card_target and CardUtils.can_place_on_card(card_dragged, card_target):
			print("[TABL Valid Move]: ", Enums.human_readable_card(card_dragged), " onto ", Enums.human_readable_card(card_target))
			move_card_sequence(card_target, null)
		elif hovered_free_cell and dragging_cards.size() == 1:
			print("[FREE Valid Move]: ", Enums.human_readable_card(card_dragged), " onto FREE CELL")
			move_card_sequence(null, hovered_free_cell)
			hovered_free_cell = null
		else:
			#print("Invalid move: ", Enums.human_readable_card(src_card), " onto ", Enums.human_readable_card(tgt_card))
			# Return all cards to their original positions
			for card_in_sequence in dragging_cards:
				var tween = get_tree().create_tween()
				tween.tween_property(card_in_sequence, "global_position", card_in_sequence.original_position, 0.5)
				tween.tween_callback(reset_card_z_indices)
		
		dragging_cards.clear()
		card_dragged = null # Ensure to reset this regardless of condition to prevent stuck states

func _on_card_hover_start(src_card: Card, tgt_card: Card):
	# RULE: Only the top-most (the card completely visible) card is a valid target
	var pile_tab = tableau_piles[identify_card_pile(tgt_card)]
	var last_child_index = pile_tab.get_child_count() - 1
	if tgt_card and tgt_card == pile_tab.get_child(last_child_index):
		#print("[HOVER]_on_card_hover_start: " + Enums.human_readable_card(tgt_card))
		card_target = tgt_card

	if card_target and CardUtils.can_place_on_card(src_card, card_target):
		card_target.style_hovered_on()

func _on_card_hover_ended(src_card: Card, tgt_card: Card):
	tgt_card.style_hovered_off()
	
	if card_target == tgt_card:
		#print("  [END]_on_card_hover_ended: " + Enums.human_readable_card(src_card))
		card_target = null

func _on_card_hover_free_start(free_cell: FreeCell):
	#print("[HOVER] free_cell ..... ", free_cell)
	hovered_free_cell = free_cell

func _on_card_hover_free_ended(free_cell: FreeCell):
	if hovered_free_cell == free_cell:
		#print('[HOVER] BYE BYE!!!')
		hovered_free_cell = null

func move_card_sequence(tgt_card: Card, free_cell: FreeCell):
	var new_pile_index = -1
	if tgt_card:
		new_pile_index = identify_card_pile(tgt_card)
	elif free_cell:
		# For free cells, we'll assume only one card can be moved, which is handled separately.
		pass

	for src_card in dragging_cards:
		# STEP 1: Remove card from its source pile
		var old_pile_index = identify_card_pile(src_card)
		if old_pile_index > -1:
			tableau_piles[old_pile_index].remove_card(src_card)
		else:
			# Assuming src_card could be in a free cell, attempt to remove it
			for cell in free_cells:
				cell.remove_card(src_card)

		# STEP 2: Move card to the new pile, if a target card is specified
		if new_pile_index != -1:
			tableau_piles[new_pile_index].add_card(src_card)
		elif free_cell and free_cells.size() > 0:
			# If moving to a free cell, ensure only one card is moved
			if dragging_cards.size() == 1:
				free_cell.add_card(src_card)
				break  # Since only one card can be moved to a free cell, break after moving
			else:
				print("ERROR: Cannot move more than one card to a Free Cell!")
				break

	# Reset dragging cards array
	dragging_cards.clear()

	# Reset z-indexes and other properties as needed
	reset_card_z_indices()

	# Increment move counter
	game_prop_moves += 1
	update_game_props()

func update_game_props():
	score.text = str(game_prop_moves)	

func reset_card_z_indices():
	for i in range(tableau_piles.size()):
		var pile = tableau_piles[i]
		for j in range(pile.get_child_count()):
			var card = pile.get_child(j)
			card.z_index = j

	for i in range(free_cells.size()):
		var pile = free_cells[i]
		var card = pile.get_child(0)
		card.z_index = 0
	
	# TODO: same for Founadtions??

func deal_cards():
	var deck = []

	# STEP 1: clear all cards
	card_deck = []
	for i in range(tableau_piles.size()):
		tableau_piles[i].remove_all_cards()
	for i in range(free_cells.size()):
		free_cells[i].remove_all()
		
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
				card.connect("card_hover_start", self._on_card_hover_start)
				card.connect("card_hover_ended", self._on_card_hover_ended)
				var control_node = card.get_node("CardControl")
				control_node.connect("card_drag_start", self._on_card_drag_start)
				control_node.connect("drag_in_progress", self._on_drag_in_progress)
				control_node.connect("card_drag_ended", self._on_card_drag_ended)
				tableau_piles[i].add_card(card)
				card_deck.append(card)
			else:
				print("Error: The instantiated object is not a Card.")
	
	# STEP 5:
	reset_card_z_indices()
	
	# STEP 6:
	game_prop_moves = 0
	update_game_props()

func _on_btn_deal_pressed():
	deal_cards()
