extends Node2D

class_name Card

# card image
@onready var sprite = $Sprite2D

# Card properties
var suit: Enums.Suit
var rank: Enums.Rank
var location: Vector2  # Current pile/cell position
var dragging = false
var drag_offset = Vector2()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:  # Start drag
			print("[card.gd]: Card clicked! " + rank_to_string(rank) +"-"+ suit_to_string(suit))
			z_index = get_parent().get_child_count()  # bring the card to front on drag start
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else:  # Release drag
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() + drag_offset

# Depending on your game's rules, you may want to add constraints to dragging 
# (e.g., only allowing certain cards to be moved or snapping cards back to their original position 
# if not dropped on a valid target). 
# For this, you can expand the logic within the _input_event method or introduce new methods to handle these rules.

func initialize(suitIn: Enums.Suit, rankIn: Enums.Rank):
	self.suit = suitIn
	self.rank = rankIn
	self.location = Vector2.ZERO
	load_texture()

func load_texture():
	# Construct texture path based on suit and rank
	var texture_path = "res://assets/cards/"
	texture_path += suit_to_string(suit) + "_" + rank_to_string(rank) + ".png"

	# Load and assign texture
	sprite.texture = ResourceLoader.load(texture_path)
	#print('loaded texture: ' + texture_path)

# Helper functions for converting enum values to strings
func suit_to_string(suitIn: Enums.Suit) -> String:
	if suitIn == Enums.Suit.HEARTS:
		return "hearts"
	elif suitIn == Enums.Suit.DIAMONDS:
		return "diamonds"
	elif suitIn == Enums.Suit.CLUBS:
		return "clubs"
	elif suitIn == Enums.Suit.SPADES:
		return "spades"
	else:
		return "unknown"

func rank_to_string(rankIn: Enums.Rank) -> String:
	match rankIn:
		Enums.Rank.TWO: return "02"
		Enums.Rank.THREE: return "03"
		Enums.Rank.FOUR: return "04"
		Enums.Rank.FIVE: return "05"
		Enums.Rank.SIX: return "06"
		Enums.Rank.SEVEN: return "07"
		Enums.Rank.EIGHT: return "08"
		Enums.Rank.NINE: return "09"
		Enums.Rank.TEN: return "10"
		Enums.Rank.JACK: return "jack"
		Enums.Rank.QUEEN: return "queen"
		Enums.Rank.KING: return "king"
		Enums.Rank.ACE: return "ace"
	return "unknown"

# ???
func can_move_to(other_card: Card) -> bool: 
	# Basic check for FreeCell rules: alternating colors and descending rank 
	if (suit != other_card.suit and rank == other_card.rank + 1): 
		return true 
	else: 
		return false
