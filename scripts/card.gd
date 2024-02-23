extends Node2D

class_name Card

# card image
@onready var sprite = $Sprite2D  # Assuming the Sprite is a child node named "Sprite"

# Card properties
var suit: Enums.Suit
var rank: Enums.Rank
var is_face_up: bool
var location: Vector2  # Current pile/cell position

# Card texture or sprite path
var texture_path: String

func initialize(suit: Enums.Suit, rank: Enums.Rank):
	self.suit = suit
	self.rank = rank
	self.is_face_up = false
	self.location = Vector2.ZERO

#func set_texture_path(path: String):
#	self.texture_path = path

func load_texture(sprite: Sprite2D):
	if not is_face_up:
		return  # No texture needed for face-down cards

	# Construct texture path based on suit and rank
	var texture_path = "res://assets/cards/"
	texture_path += suit_to_string(suit) + "_" + rank_to_string(rank) + ".png"

	# Load and assign texture
	sprite.texture = ResourceLoader.load(texture_path)

# Helper functions for converting enum values to strings
func suit_to_string(suit: Enums.Suit) -> String:
	if suit == Enums.Suit.HEARTS:
		return "hearts"
	elif suit == Enums.Suit.DIAMONDS:
		return "diamonds"
	elif suit == Enums.Suit.CLUBS:
		return "clubs"
	elif suit == Enums.Suit.SPADES:
		return "spades"
	else:
		return "unknown"

func rank_to_string(rank: Enums.Rank) -> String:
	return str(int(rank))  # Convert Rank enum value to string directly

func flip():
	self.is_face_up = !self.is_face_up
	load_texture(sprite)

func can_move_to(other_card: Card) -> bool: 
	# Basic check for FreeCell rules: alternating colors and descending rank 
	if is_face_up and other_card.is_face_up and (suit != other_card.suit and rank == other_card.rank + 1): 
		return true 
	else: 
		return false

# Other utility functions as needed, like comparing cards, getting value, etc.
