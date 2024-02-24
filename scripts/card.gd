extends Node2D
class_name Card

signal card_drag_started(card, initial_mouse_position)
signal card_drag_ended(card)

@onready var sprite = $Sprite2D # card image
# Card properties
var suit: Enums.Suit
var rank: Enums.Rank
var location: Vector2  # Current pile/cell position
var dragging = false
var drag_offset = Vector2()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("card_drag_started", self, get_global_mouse_position())
		else:
			emit_signal("card_drag_ended", self)

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
