extends Node2D

# NODES
@onready var timer:Timer = $Timer
@onready var infobox_moves:Label = $InfoRect/HBoxContainer/HBoxContMoves/Value
@onready var infobox_timer:Label = $InfoRect/HBoxContainer/HBoxContElapsed/Value
@onready var infobox_score:Label = $InfoRect/HBoxContainer/HBoxContScore/Value
@onready var main_menu:MainMenu = $MainMenu
@onready var game_panel_winner:Node2D = $GamePanelWinner
@onready var audio_shuffle:AudioStreamPlayer = $AudioShuffle
@onready var audio_card_play:AudioStreamPlayer = $AudioCardPlay
@onready var audio_card_nope:AudioStreamPlayer = $AudioCardNope
@onready var audio_btn_click:AudioStreamPlayer = $AudioBtnClick
@onready var placeholder_deal:Sprite2D = $Placeholder_Deal

# VARIABLES
var drag_offset : Vector2 = Vector2()
#
var card_deck : Array[Card] = []
var free_cells : Array[FreeCell] = []
var fnda_cells : Array[FoundationCell] = []
var tableau_piles : Array[TableauPile] = []
#
var dragging_cards : Array[Card] = []
var card_dragged : Card = null
var card_target : Card = null
var hovered_free_cell : FreeCell = null
var hovered_fnda_cell : FoundationCell = null
var hovered_tabl_pile : TableauPile = null
var is_tween_running : bool = false
#
var game_prop_moves : int = 0
var game_prop_timer : int = 0
var game_prop_score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# STEP 1: drag-n-drop
	set_process_unhandled_input(true)
	
	# STEP 2: Init free-cell-pile
	for i in 4:
		var free_cell:FreeCell = get_node("TopContainer/FreeCellPile/FreeCell" + str(i))
		free_cell.connect("card_hover_free_start", self._on_card_hover_free_start)
		free_cell.connect("card_hover_free_ended", self._on_card_hover_free_ended)
		free_cells.append(free_cell)
	
	# STEP 3: Init foundation-cell-pile
	for i in 4:
		var fnda_cell:FoundationCell = get_node("TopContainer/FoundationPile/FoundationCell" + str(i))
		fnda_cell.connect("card_hover_fnda_start", self._on_card_hover_fnda_start)
		fnda_cell.connect("card_hover_fnda_ended", self._on_card_hover_fnda_ended)
		fnda_cells.append(fnda_cell)
	
	# STEP 4: Init tableau-piles
	for i in range(0, 8): # Assuming you named them TableauPile0 through TableauPile7
		var tabl_pile:TableauPile = get_node("TableauPileCont/TableauPile" + str(i))
		tabl_pile.connect("card_hover_tabl_start", self._on_card_hover_tabl_start)
		tabl_pile.connect("card_hover_tabl_ended", self._on_card_hover_tabl_ended)
		tableau_piles.append(tabl_pile)
	
	# STEP 5: Connect menu buttons
	main_menu.connect("button_pressed_newgame", self.deal_cards)
	main_menu.connect("button_pressed_debug", self._on_btn_debug_pressed)

# =============================================================================

static func compare_cards_z_index(a, b):
	return a.z_index < b.z_index

func get_card_count(container):
	var count = 0
	for child in container.get_children():
		if child is Card:
			count += 1
	return count

func get_top_fnda_card(fnda_cell: FoundationCell):
	var top_card:Card = null
	for child in fnda_cell.get_children():
		if child is Card:
			top_card = child
	return top_card

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
		for free_card in free_cell.get_children():
			if free_card is Card and free_card == card:
				return -2
	
	# STEP 3: check foundation-cells
	for fnda_cell in fnda_cells:
		for fnda_card in fnda_cell.get_children():
			if fnda_card is Card and fnda_card == card:
				return -3
	
	# LAST:
	return -1

func is_valid_drag_start(card: Card, card_pile_index: int, sequence_length: int) -> bool:
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
	var available_spaces = 0
	for free_cell in free_cells:
		if get_card_count(free_cell) == 0:
			available_spaces += 1
	
	# Ensure there's enough space to move the sequence.
	if sequence_length > available_spaces + 1:
		print("[RULE]: not enough free cells")
		return false
	
	# Example sequence check (assuming descending sequence without suit check):
	var card_index = card_pile.find(card)
	for i in range(card_index, card_pile.size() - 1):
		if card_pile[i].rank - 1 != card_pile[i + 1].rank:  # Ensure descending order.
			return false  # Sequence is broken, invalid drag.
	
	return true  # Valid sequence

func move_card_sequence(tgt_card: Card, free_cell: FreeCell, fnda_cell: FoundationCell, tabl_pile: TableauPile):
	for idx in range(dragging_cards.size()):
		var src_card = dragging_cards[idx]
		var target_position = Vector2()
		var target_container = null
		
		if free_cell:
			target_container = free_cell
			target_position = Vector2(free_cell.global_position.x + Enums.CARD_POSITION.x, free_cell.global_position.y + Enums.CARD_POSITION.y)
		elif fnda_cell:
			target_container = fnda_cell
			target_position = Vector2(fnda_cell.global_position.x + Enums.CARD_POSITION.x, fnda_cell.global_position.y + Enums.CARD_POSITION.y)
		elif tabl_pile:
			target_container = tabl_pile
			target_position = Vector2(tabl_pile.global_position.x, tabl_pile.global_position.y)
		elif tgt_card:
			target_container = tgt_card.get_parent()
			target_position = Vector2(tgt_card.global_position.x, tgt_card.global_position.y + (Enums.Y_OFFSET * (idx+1)))
		
		# Now that you have the target position, create and configure the tween
		if (target_position.x + target_position.y > 0):
			# A: Set tween flag
			is_tween_running = true
			# B: Re-parent the card *NOW*
			# IMPORTANT: Move now (not in tween_done method) b/c setting `global_position` first causes 
			# - the associated target's `_on_area_2d_area_exited()` method to fire, 
			# - which is processed *AFTER* the tween_done() method completes (leaving the hover effect on)
			var restore_pos = src_card.global_position
			src_card.get_parent().remove_child(src_card)
			target_container.add_child(src_card)
			src_card.global_position = restore_pos
			var tween = get_tree().create_tween()
			tween.tween_property(src_card, "global_position", target_position, 0.5)
			tween.tween_callback(_on_move_card_seq_tween_completed.bind(src_card, tgt_card, free_cell, fnda_cell, tabl_pile))
		else:
			_on_move_card_seq_tween_completed(src_card, tgt_card, free_cell, fnda_cell, tabl_pile)

func _on_move_card_seq_tween_completed(src_card, tgt_card, free_cell, fnda_cell, tabl_pile):
	# STEP 1: Add points, play audio/animation effects
	var new_pile_index = identify_card_pile(tgt_card)
	if new_pile_index > -1:
		game_prop_score += 10
		src_card.show_points(10)
		audio_card_play.play()
		_on_card_hover_ended(src_card, tgt_card)
	elif tabl_pile:
		game_prop_score += 10
		src_card.show_points(10)
		audio_card_play.play()
	elif free_cell and free_cells.size() > 0:
		if dragging_cards.size() == 1:
			# FIXME: dont give credit when moving from one freecell to another!
			game_prop_score += 10
			src_card.show_points(10)
			audio_card_play.play()
		else:
			print("ERROR: Cannot move more than one card to a Free Cell!")
			#print("free_cells", free_cells)
			#print("dragging_cards", dragging_cards)
			#break
	elif fnda_cell and src_card:
		game_prop_score += 100
		src_card.show_points(100)
		fnda_cell.play_card_added_anim()
		audio_card_play.play()
	
	# STEP 2: If moving the last card in the sequence, reset the dragging cards array and other properties
	if dragging_cards.size() > 0 and src_card == dragging_cards.back():
		dragging_cards.clear()
		reset_card_z_indices()
		game_prop_moves += 1
		update_game_props()
		check_for_win_condition()
	
	# LAST
	is_tween_running = false
	#print("[_on_move_card_seq_tween_completed] is_tween_running = ", is_tween_running)
	
func on_return_cards_tween_completed():
	is_tween_running = false
	reset_card_z_indices()

# =============================================================================

#region Card_Drag_and_Hover

func get_draggable_sequence(card: Card) -> Array[Card]:
	var cards:Array[Card] = []
	var card_pile_index:int = identify_card_pile(card)

	# Free Cells are index -2	
	if card_pile_index == -2:
		return [card]

	var card_pile = tableau_piles[card_pile_index].get_children()
	var start_index = card_pile.find(card)
	
	if is_valid_drag_start(card, card_pile_index, range(start_index, card_pile.size()).size()):
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
			#print("[card_in_sequence.z_index]: " + Enums.human_readable_card(card_in_sequence) + " at `" + str(card_in_sequence.z_index) + "`")
	else:
		#print("[is_valid_drag_start]: Invalid card or sequence")
		card_dragged = null  # Explicitly ensure dragging isn't started

func _on_drag_in_progress(card, mouse_position):
	if card == card_dragged:
		var draggable_sequence = get_draggable_sequence(card)
		var new_position = mouse_position - drag_offset
		for each_card in draggable_sequence:
			each_card.global_position = new_position + Vector2(0, draggable_sequence.find(each_card) * Enums.Y_OFFSET)
			# Y_OFFSET is a constant that determines how much each subsequent card is offset vertically

func _on_card_drag_ended(card):
	var do_return_cards = false
	
	if card == card_dragged:
		#print("[..END drag]: " + Enums.human_readable_card(card) + " at " + str(card.z_index))
		#print("[..END drag]: ", hovered_fnda_cell)
		if card_target and CardUtils.can_place_on_card(card_dragged, card_target):
			print("[TABL Valid Move]: ", Enums.human_readable_card(card_dragged), " onto ", Enums.human_readable_card(card_target))
			move_card_sequence(card_target, null, null, null)
		elif hovered_free_cell and dragging_cards.size() == 1:
			print("[FREE Valid Move]: ", Enums.human_readable_card(card_dragged), " onto FREE CELL")
			move_card_sequence(null, hovered_free_cell, null, null)
			hovered_free_cell = null
		elif hovered_fnda_cell and dragging_cards.size() == 1:
			if get_card_count(hovered_fnda_cell) == 0:
				# If the foundation cell is empty, only an Ace can be placed
				if card_dragged.rank == Enums.Rank.ACE:
					print("[FNDA valid] An Ace can be placed here.")
					move_card_sequence(card_dragged, null, hovered_fnda_cell, null)
				else:
					#print("[FNDA--nope] Only an Ace can be placed on an empty foundation cell.")
					do_return_cards = true
			else:
				# If the foundation cell is not empty, check if the card follows the suit and is in order
				var top_card = get_top_fnda_card(hovered_fnda_cell)
				if card_dragged.suit == top_card.suit and card_dragged.rank == top_card.rank + 1:
					print("[FNDA valid] Card can be placed here.")
					move_card_sequence(card_dragged, null, hovered_fnda_cell, null)
				else:
					print("Card cannot be placed here: ", hovered_fnda_cell)
					do_return_cards = true
		elif hovered_tabl_pile:
			if get_card_count(hovered_tabl_pile) == 0:
				# RULE: VALID = Moving any 1 card to an empty tabelau
				# RULE: VALID = There must be enough free cells to hold cards other than the first
				var total_free_cells = 0
				for cell in free_cells:
					if get_card_count(cell) == 0:
						total_free_cells += 1
				if total_free_cells >= dragging_cards.size() - 1:
					move_card_sequence(null, null, null, hovered_tabl_pile)
				else:
					print("[hovered_tabl_pile] card cannot be placed here: ", hovered_tabl_pile)
					do_return_cards = true
			else:
				print("[hovered_tabl_pile] else: ", get_card_count(hovered_tabl_pile))
				do_return_cards = true
		else:
			do_return_cards = true
		
		if do_return_cards:
			for card_in_sequence in dragging_cards:
				# NOTE: only tween if position changed, otherwise, this kneecaps the dbl-click to move feature!
				if card_in_sequence.global_position.distance_to(card_in_sequence.original_position) > 1:  # Using a tolerance of 1 pixel
					is_tween_running = true
					var tween = get_tree().create_tween()
					tween.tween_property(card_in_sequence, "global_position", card_in_sequence.original_position, 0.5)
					tween.tween_callback(on_return_cards_tween_completed)
					audio_card_nope.play()
		
		# Resets
		card_dragged = null # Ensure to reset this regardless of condition to prevent stuck states
		hovered_fnda_cell = null
		hovered_tabl_pile = null

func _on_card_hover_start(src_card: Card, tgt_card: Card):
	# STEP 0: Bail; dont highlight if tween animation is the trigger
	if is_tween_running:
		return

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
	# STEP 0: Bail; dont highlight cells if tween animation is the trigger
	if is_tween_running or get_card_count(free_cell) > 0:
		return
	
	# STEP 1: Un-highlight previous cell if any (prevent highlighting of *two* cells if user holds cover over both, etc.)
	if hovered_free_cell:
		hovered_free_cell.highlight(false)
	
	# STEP 2: Store foundation cell
	hovered_free_cell = free_cell
	
	# STEP 3:
	# NOTE: No logic needed to decide if this highlight is valid (the free_cell script only emits hover if unoccupied!)
	hovered_free_cell.highlight(true)

func _on_card_hover_free_ended(free_cell: FreeCell):
	if hovered_free_cell == free_cell:
		hovered_free_cell = null
		free_cell.highlight(false)

func _on_card_hover_fnda_start(fnda_cell: FoundationCell):
	#print("[_on_card_hover_fnda_start] is_tween_running = ", is_tween_running)
	# STEP 0: Bail; dont highlight cells if tween animation is the trigger
	if is_tween_running:
		return

	# STEP 1: Un-highlight previous cell if any (prevent highlighting of *two* cells if user holds cover over both, etc.)
	if hovered_fnda_cell:
		hovered_fnda_cell.highlight(false)

	# STEP 2: Store foundation cell
	hovered_fnda_cell = fnda_cell
	
	# STEP 3:
	# TODO: only highlight if valid!
	hovered_fnda_cell.highlight(true)

func _on_card_hover_fnda_ended(fnda_cell: FoundationCell):
	#print("_on_card_hover_tabl_ended")
	# NOTE: Dont do below (it'll be done in `_on_card_drag_ended()`
	# hovered_fnda_cell = null
	fnda_cell.highlight(false)

func _on_card_double_clicked(card: Card):
	var pile_index = identify_card_pile(card)
	if pile_index >= 0:
		var pile = tableau_piles[pile_index]
		if card == pile.get_children().back():  # Using .back() to get the last card in the pile
			# Check for valid foundation moves
			for fnda_cell in fnda_cells:
				if get_card_count(fnda_cell) == 0 and card.rank == Enums.Rank.ACE:
					# Move Ace to empty foundation cell
					dragging_cards = [card]
					move_card_sequence(null, null, fnda_cell, null)
					return
				elif get_card_count(fnda_cell) > 0:
					var top_fnda_card = get_top_fnda_card(fnda_cell)
					if top_fnda_card.suit == card.suit and top_fnda_card.rank + 1 == card.rank:
						# Sequentially correct card to non-empty foundation
						dragging_cards = [card]
						move_card_sequence(null, null, fnda_cell, null)
						return
			
			# If no foundation move is made, check for FreeCell move
			for free_cell in free_cells:
				if get_card_count(free_cell) == 0:
					dragging_cards = [card]
					move_card_sequence(null, free_cell, null, null)
					return
			#print("[move-to-free] No available FreeCells")
		else:
			#print("[FYI] The card is not the top card of its pile and cannot be moved to a FreeCell.")
			pass
	else:
		#print("[FYI] The card is not in a tableau pile.")
		pass

func _on_card_hover_tabl_start(pile: TableauPile):
	# TODO: Only highlight when move is valid
	if get_card_count(pile) == 0:
		hovered_tabl_pile = pile
		#print("_on_card_hover_tabl_start")
		pile.highlight(true)

func _on_card_hover_tabl_ended(pile: TableauPile):
	#print("_on_card_hover_tabl_ended")
	pile.highlight(false)

#endregion

# =============================================================================

func update_game_props():
	infobox_moves.text = str(game_prop_moves)
	infobox_timer.text = "%02d:%02d" % [int(float(game_prop_timer) / 60.0), int(game_prop_timer % 60)]
	infobox_score.text = str(game_prop_score)

func check_for_win_condition():
	var total_cards_in_foundation = 0

	# Iterate through each foundation cell to count the cards
	for fnda_cell in fnda_cells:
		total_cards_in_foundation += get_card_count(fnda_cell)

	# Check if the total number of cards in foundation cells equals 52
	if total_cards_in_foundation == 52:
		game_panel_winner.visible = true
		print("[GAME] Congratulations! You've won the game!!")
		# Implement any additional win logic here (e.g., displaying a win message, stopping the timer, etc.)
	else:
		#print("[FYI] Keep going! Not all cards are in foundation cells yet. (" + str(52 - total_cards_in_foundation) + " left)")
		pass

func reset_card_z_indices():
	for i in range(tableau_piles.size()):
		var pile:TableauPile = tableau_piles[i]
		for j in range(pile.get_child_count()):
			var pile_card = pile.get_child(j)
			if pile_card is Card:
				pile_card.z_index = j
	
	for i in range(free_cells.size()):
		var pile:FreeCell = free_cells[i]
		for j in range(pile.get_child_count()):
			var pile_card = pile.get_child(j)
			if pile_card is Card:
				pile_card.z_index = j
	
	for i in range(fnda_cells.size()):
		var pile = fnda_cells[i]
		for j in range(pile.get_child_count()):
			var pile_card = pile.get_child(j)
			if pile_card is Card:
				pile_card.z_index = j

func clear_all_cards():
	var pile_containers:Array = [free_cells, fnda_cells, tableau_piles]
	
	for pile in pile_containers:
		for container in pile:
			for card in container.get_children():
				if card is Card:
					container.remove_child(card)
					card.queue_free()
	
	card_deck.clear()

func deal_cards():
	const num_cards_in_columns:Array[int] = [7, 7, 7, 7, 6, 6, 6, 6]
	const animation_time:float = 0.15  # Time it takes for each card to move to its pile
	var initial_position:Vector2 = placeholder_deal.global_position
	var deck_builder:Array = []
	
	# STEP 1: audio & cleanup
	clear_all_cards()
	game_panel_winner.visible = false
	placeholder_deal.visible = true
	audio_shuffle.play()
	
	# STEP 2: Create and shuffle deck of 52 playing cards
	for suit in Enums.Suit.values():
		for rank in Enums.Rank.values():
			deck_builder.append({"suit": suit, "rank": rank})
	deck_builder.shuffle()
	
	# STEP 3: Instantiate all cards at the origin location
	for card_info in deck_builder:
		var card_scene = load("res://scenes/card.tscn")
		var card:Card = card_scene.instantiate()
		if card is Card:
			add_child(card) # IMPORTANT: add to scene or resources from `@onready` wont be ready! (adding to scene fires its `_ready()` and other init behavior!)
			card.initialize(card_info["suit"], card_info["rank"])
			# OLD: card.call_deferred("initialize", card_info["suit"], card_info["rank"])
			card_deck.append(card)
	
	# STEP 4: Setup and run animations for all cards
	for pile_index in range(tableau_piles.size()):
		var num_cards = num_cards_in_columns[pile_index]
		for card_index in range(num_cards):
			var card = card_deck[pile_index + card_index * tableau_piles.size()]  # Calculate index based on interleave
			card.connect("card_hover_start", self._on_card_hover_start)
			card.connect("card_hover_ended", self._on_card_hover_ended)
			var control_node = card.get_node("CardControl")
			control_node.connect("card_drag_start", self._on_card_drag_start)
			control_node.connect("drag_in_progress", self._on_drag_in_progress)
			control_node.connect("card_drag_ended", self._on_card_drag_ended)
			control_node.connect("card_double_clicked", self._on_card_double_clicked)
			# move card to tableau from game_scene
			remove_child(card)
			tableau_piles[pile_index].add_child(card)
			card_deck.append(card)
			# Tween into place
			card.global_position = initial_position
			var tween:Tween = get_tree().create_tween()
			var target_position = tableau_piles[pile_index].global_position + Vector2(0, card_index * Enums.Y_OFFSET)
			tween.tween_property(card, "global_position", target_position, animation_time*(card_index+1))
			tween.play()
	
	# STEP 5: Reset z-indexes
	reset_card_z_indices()
	
	# STEP 6: Clear game props
	game_prop_timer = 0
	game_prop_moves = 0
	game_prop_score = 0
	update_game_props()

	# STEP 7: Hide face deal placeholder card ater cards have tweened	
	await get_tree().create_timer(1.0).timeout
	placeholder_deal.visible = false

func _on_btn_deal_pressed():
	deal_cards()

func _on_btn_pause_pressed():
	# TODO:
	pass

# DEV/DEBUG TOOL
func sort_and_move_cards_to_foundation(move_suit:Enums.Suit, target_fnda:FoundationCell):
	# Filter all clubs from the deck
	var move_cards = []
	for card in card_deck:
		if card.suit == move_suit:
			move_cards.append(card)
	
	# Sort the cards by rank
	move_cards.sort_custom(self.compare_ranks)
	
	# Assuming foundation[0] is designated for clubs
	for move_card in move_cards:
		#print("[DEBUG] moving move_card: ", Enums.human_readable_card(move_card))
		dragging_cards = [move_card]
		move_card_sequence(null, null, target_fnda, null)
	
	print("[DEV-TOOL] Moved all cards to foundation in sorted order.", target_fnda)

# Custom comparison method for sorting
func compare_ranks(a: Card, b: Card) -> bool:
	return a.rank < b.rank

func _on_btn_debug_pressed():
	sort_and_move_cards_to_foundation(Enums.Suit.CLUBS, fnda_cells[1])
	sort_and_move_cards_to_foundation(Enums.Suit.DIAMONDS, fnda_cells[2])
	sort_and_move_cards_to_foundation(Enums.Suit.HEARTS, fnda_cells[3])
	await get_tree().create_timer(1.5).timeout
	for pile_index in range(tableau_piles.size()):
		var pile = tableau_piles[pile_index]
		for card_index in range(pile.get_children().size()):
			var pile_card = pile.get_child(card_index)
			if pile_card is Card:
				pile_card.position = Vector2(0, card_index * Enums.Y_OFFSET)

func _on_timer_timeout():
	game_prop_timer += 1
	update_game_props()

func _on_btn_main_menu_pressed():
	audio_btn_click.play()
	main_menu.visible = true
