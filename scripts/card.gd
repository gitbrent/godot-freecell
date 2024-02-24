extends Node2D

class_name Card

# card image
@onready var sprite = $Sprite2D

# Card properties
var suit: Enums.Suit
var rank: Enums.Rank
var location: Vector2  # Current pile/cell position

func initialize(suit: Enums.Suit, rank: Enums.Rank):
	self.suit = suit
	self.rank = rank
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
	match rank:
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
