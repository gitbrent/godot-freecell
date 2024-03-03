###
### TODO:
### - implement drag onto empty tableau pile
### - FIXME: free-cell cards z-index stuck at 1006 (reset_z_indexes has no affect!)
### - use `tween` to move card to free-cell when using double-click
### - timer and score
### - check for win condition (foundation cards = 52)

extends Node2D

# NODES
@onready var score = $LeftControl/InfoRect/VBoxContainer/HBoxContMoves/Score

# VARIABLES
const Y_OFFSET : int = 40
var drag_offset : Vector2 = Vector2()
#
var card_deck : Array = []
var tableau_piles : Array = []
var free_cells : Array = []
var fnda_cells : Array = []
#
var card_dragged : Card = null
var dragging_cards : Array = []
var card_target : Card = null
var hovered_free_cell : FreeCell = null
var hovered_fnda_cell : FoundationCell = null
#
var game_prop_moves : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# STEP 1: drag-n-drop
	set_process_unhandled_input(true)

	# STEP 2: Init free-cell-pile
	for i in 4:
		var free_cell = get_node("TopContainer/FreeCellPile/FreeCell" + str(i))
		free_cell.connect("card_hover_free_start", self._on_card_hover_free_start)
		free_cell.connect("card_hover_free_ended", self._on_card_hover_free_ended)
		free_cells.append(free_cell)
	
	# STEP 3: Init foundation-cell-pile
	for i in 4:
		var fnda_cell = get_node("TopContainer/FoundationPile/FoundationCell" + str(i))
		fnda_cell.connect("card_hover_fnda_start", self._on_card_hover_fnda_start)
		fnda_cell.connect("card_hover_fnda_ended", self._on_card_hover_fnda_ended)
		fnda_cells.append(fnda_cell)

	# STEP 4: Init tableau-piles
	for i in range(0, 8): # Assuming you named them TableauPile0 through TableauPile7
		var tabl_pile = get_node("TableauPileCont/TableauPile" + str(i))
		tabl_pile.connect("card_hover_tabl_start", self._on_card_hover_tabl_start)
		tabl_pile.connect("card_hover_tabl_ended", self._on_card_hover_tabl_ended)
		tableau_piles.append(tabl_pile)

	# STEP 5: Deal all 52 cards onto tableau
	deal_cards()
	
# =============================================================================

static func compare_cards_z_index(a, b):
	return a.z_index < b.z_index

func identify_card_pile(card: Card) -> int:
	if not card:
		return -1

	# STEP 1: check tableau
	for pile_index in range(tableau_piles.size()):
		var pile = tableau_piles[pile_index]
		for pile_card in pile.get_children():
			if pile_card is Card and pile_card.suit == card.suit and pile_card.rank == card.rank:
				return pile_index
	
	# STEP 2: check free-cells
	for free_cell in free_cells:
		if free_cell.get_curr_card() == card:
			return -2
	
	# STEP 3: check foundation-cells
	for fnda_cell in fnda_cells:
		if fnda_cell.get_top_card() == card:
			return -3
	
	# LAST:
	return -1

func is_valid_drag_start(card: Card, card_pile_index: int) -> bool:
	# free cell index is -2
	if card_pile_index == -2:
		return true
	elif card_pile_index == -3:
		return false
	
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

func move_card_sequence(tgt_card: Card, free_cell: FreeCell, fnda_cell: FoundationCell):
	for src_card in dragging_cards:
		# STEP 1: Remove card from its source pile
		var old_pile_index = identify_card_pile(src_card)
		if old_pile_index > -1:
			tableau_piles[old_pile_index].remove_card(src_card)
			#print("[move] removed from TABL: " + Enums.human_readable_card(src_card))
		else:
			for cell in free_cells:
				cell.remove_card(src_card)
		
		# STEP 2: Add card to its new pile
		var new_pile_index = identify_card_pile(tgt_card)
		if new_pile_index > -1:
			tableau_piles[new_pile_index].add_card(src_card)
		elif free_cell and free_cells.size() > 0:
			if dragging_cards.size() == 1:
				free_cell.add_card(src_card)
				#print("FIXME: double-click only makes card vanish!")
				var brent = free_cell.get_curr_card()
				print("[FREE] card: ", Enums.human_readable_card(brent))
				#print(brent.z_index)
				break  # Since only one card can be moved to a free cell, break after moving
			else:
				print("ERROR: Cannot move more than one card to a Free Cell!")
				break
		elif fnda_cell and src_card:
			#print("[move] to FNDA: " + Enums.human_readable_card(src_card))
			fnda_cell.add_card(src_card)
			break
		
	# Reset dragging cards array
	dragging_cards.clear()
	
	# Reset z-indexes and other properties as needed
	reset_card_z_indices()
	
	# Increment move counter
	game_prop_moves += 1
	update_game_props()
	
	# Check for win
	check_for_win_condition()

# =============================================================================

func get_draggable_sequence(card: Card) -> Array:
	var cards:Array = []
	var card_pile_index:int = identify_card_pile(card)

	# Free Cells are index -2	
	if card_pile_index == -2:
		return [card]

	var card_pile = tableau_piles[card_pile_index].get_children()
	var start_index = card_pile.find(card)
	
	if is_valid_drag_start(card, card_pile_index):
		for i in range(start_index, card_pile.size()):
			var current_card = card_pile[i]
			if current_card is Card:
				cards.append(current_card)
				# Optionally, add additional validation here if needed
				# For example, checking if the sequence remains valid after the first card
			else:
				break  # Exit if we encounter a non-Card or invalid sequence	
	
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
	var do_return_cards = false
	
	if card == card_dragged:
		print("[..END drag]: " + Enums.human_readable_card(card) + " at " + str(card.z_index))
		#print("[..END drag]: ", hovered_fnda_cell)
		if card_target and CardUtils.can_place_on_card(card_dragged, card_target):
			print("[TABL Valid Move]: ", Enums.human_readable_card(card_dragged), " onto ", Enums.human_readable_card(card_target))
			move_card_sequence(card_target, null, null)
		elif hovered_free_cell and dragging_cards.size() == 1:
			print("[FREE Valid Move]: ", Enums.human_readable_card(card_dragged), " onto FREE CELL")
			move_card_sequence(null, hovered_free_cell, null)
			hovered_free_cell = null
		elif hovered_fnda_cell and dragging_cards.size() == 1:
			if hovered_fnda_cell.is_empty():
				# If the foundation cell is empty, only an Ace can be placed
				if card_dragged.rank == Enums.Rank.ACE:
					print("[FNDA valid] An Ace can be placed here.")
					move_card_sequence(card_dragged, null, hovered_fnda_cell)
				else:
					print("[FNDA--nope] Only an Ace can be placed on an empty foundation cell.")
					do_return_cards = true
			else:
				# If the foundation cell is not empty, check if the card follows the suit and is in order
				var top_card = hovered_fnda_cell.get_top_card()
				if card_dragged.suit == top_card.suit and card_dragged.rank == top_card.rank + 1:
					print("[FNDA valid] Card can be placed here.")
					move_card_sequence(card_dragged, null, hovered_fnda_cell)
				else:
					print("Card cannot be placed here.")
					do_return_cards = true
		# TODO: tableau is empty & free cell count is okay
		# elif: *NEW RULE* ^^^^
		else:
			do_return_cards = true
		
		if do_return_cards:
			for card_in_sequence in dragging_cards:
				# NOTE: only tween if position changed, otherwise, this kneecaps the dbl-click to move feature!
				if card_in_sequence.global_position.distance_to(card_in_sequence.original_position) > 1:  # Using a tolerance of 1 pixel
					var tween = get_tree().create_tween()
					tween.tween_property(card_in_sequence, "global_position", card_in_sequence.original_position, 0.5)
					tween.tween_callback(reset_card_z_indices)
		
		# Resets
		dragging_cards.clear()
		card_dragged = null # Ensure to reset this regardless of condition to prevent stuck states
		hovered_fnda_cell = null
		#??? reset_card_z_indices()

func _on_card_hover_start(src_card: Card, tgt_card: Card):
	# RULE: Only the top-most (the card completely visible) card is a valid target
	var pile_tab = tableau_piles[identify_card_pile(tgt_card)]
	var last_child_index = pile_tab.get_child_count() - 1
	if tgt_card and tgt_card == pile_tab.get_child(last_child_index):
		#print("[HOVER]_on_card_hover_start: " + Enums.human_readable_card(tgt_card))
		card_target = tgt_card
	
	if card_target and CardUtils.can_place_on_card(src_card, card_target):
		card_target.style_hovered_on()

func _on_card_hover_ended(_src_card: Card, tgt_card: Card):
	tgt_card.style_hovered_off()
	
	if card_target == tgt_card:
		#print("  [END]_on_card_hover_ended: " + Enums.human_readable_card(src_card))
		card_target = null

func _on_card_hover_free_start(free_cell: FreeCell):
	#print("[HOVER] free_cell ..... ", free_cell)
	hovered_free_cell = free_cell

func _on_card_hover_free_ended(free_cell: FreeCell):
	if hovered_free_cell == free_cell:
		hovered_free_cell = null

func _on_card_hover_fnda_start(fnda_cell: FoundationCell):
	# STEP 1: Store foundation cell
	hovered_fnda_cell = fnda_cell
	
	# STEP 2:
	# TODO: only highlight if valid!
	fnda_cell.highlight(true)

func _on_card_hover_fnda_ended(fnda_cell: FoundationCell):
	# NOTE: Dont do below (it'll be done in `_on_card_drag_ended()`
	# hovered_fnda_cell = null
	fnda_cell.highlight(false)

func _on_request_move_to_freecell(card: Card):
	var pile_index = identify_card_pile(card)
	if pile_index >= 0:
		var pile = tableau_piles[pile_index]
		if card == pile.get_children().back():  # Using .back() to get the last card in the pile
			for free_cell in free_cells:
				if free_cell.is_empty():
					dragging_cards = [card]
					move_card_sequence(null, free_cell, null)
					return  # Exit after moving the card to prevent checking other free cells
			#print("[move-to-free] No available FreeCells")
		else:
			#print("[FYI] The card is not the top card of its pile and cannot be moved to a FreeCell.")
			pass
	else:
		#print("[FYI] The card is not in a tableau pile.")
		pass

func _on_card_hover_tabl_start(pile: TableauPile):
	print("_on_card_hover_tabl_start")
	pile.highlight(true)

func _on_card_hover_tabl_ended(pile: TableauPile):
	print("_on_card_hover_tabl_ended")
	pile.highlight(false)

# =============================================================================

func update_game_props():
	score.text = str(game_prop_moves)

func check_for_win_condition():
	var total_cards_in_foundation = 0

	# Iterate through each foundation cell to count the cards
	for fnda_cell in fnda_cells:
		total_cards_in_foundation += fnda_cell.get_card_count()

	# Check if the total number of cards in foundation cells equals 52
	if total_cards_in_foundation == 52:
		print("[GAME] Congratulations! You've won the game!!")
		# Implement any additional win logic here (e.g., displaying a win message, stopping the timer, etc.)
	else:
		print("[FYI] Keep going! Not all cards are in foundation cells yet. (" + str(52 - total_cards_in_foundation) + " left)")

func reset_card_z_indices():
	for i in range(tableau_piles.size()):
		var pile = tableau_piles[i]
		for j in range(pile.get_child_count()):
			var card = pile.get_child(j)
			card.z_index = j
	
	for i in range(free_cells.size()):
		var pile = free_cells[i]
		var card = pile.get_child(0)
		card.z_index = 1
	
	for i in range(fnda_cells.size()):
		var pile = fnda_cells[i]
		for j in range(pile.get_child_count()):
			var card = pile.get_child(j)
			card.z_index = j

func clear_deck():
	card_deck = []
	for i in range(tableau_piles.size()):
		tableau_piles[i].remove_all_cards()
	for i in range(free_cells.size()):
		free_cells[i].remove_all()
	for i in range(fnda_cells.size()):
		fnda_cells[i].remove_all_cards()

func deal_cards():
	var deck = []

	# STEP 1: clear all cards
	clear_deck()
	
	# STEP 2: Create the standard 52 playing cards
	for suit in Enums.Suit.values():
		for rank in Enums.Rank.values():
			deck.append({"suit": suit, "rank": rank})
	
	# STEP 3: Shuffle the deck
	deck.shuffle()
	
	# STEP 4: Setup for dealing cards to tableau piles according to FreeCell rules
	var num_cards_in_columns = [7, 7, 7, 7, 6, 6, 6, 6]
	var deck_index = 0
	
	# STEP 5: Deal
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
				control_node.connect("request_move_to_freecell", self._on_request_move_to_freecell)
				tableau_piles[i].add_card(card)
				card_deck.append(card)
			else:
				print("Error: The instantiated object is not a Card.")
	
	# STEP 6: Reset z-indexes
	reset_card_z_indices()
	
	# STEP 6: Clear game props
	game_prop_moves = 0
	update_game_props()

func _on_btn_deal_pressed():
	deal_cards()

func _on_btn_pause_pressed():
	sort_and_move_clubs_to_foundation()
	#for pile in tableau_piles:
	#	pile.highlight(true)

# DEV/DEBUG TOOL
func sort_and_move_clubs_to_foundation():
	# Filter all clubs from the deck
	var clubs_cards = []
	for card in card_deck:
		if card.suit == Enums.Suit.CLUBS:
			clubs_cards.append(card)
	
	# Sort the clubs by rank
	clubs_cards.sort_custom(self.compare_ranks)
	
	# Assuming foundation[0] is designated for clubs and has an 'add_card' method
	for club_card in clubs_cards:
		#print("[DEBUG] moving club_card: ", Enums.human_readable_card(club_card))
		dragging_cards = [club_card]
		move_card_sequence(null, null, fnda_cells[0])
	
	print("[DEV-TOOL] Moved all clubs to foundation[0] in sorted order.")
	reset_card_z_indices()

# Custom comparison method for sorting
func compare_ranks(a: Card, b: Card) -> bool:
	return a.rank < b.rank
