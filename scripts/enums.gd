extends Node

enum SuitColor {
	RED,
	BLACK
}

enum Suit {
	HEARTS,		# RED
	DIAMONDS,	# RED
	CLUBS, 		# BLACK
	SPADES 		# BLACK
}

enum Rank { 
	TWO = 2,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING,
	ACE
}

# Helper functions for converting enum values to strings
func suitcolor_to_string(suitColorIn) -> String:
	if suitColorIn == Enums.SuitColor.RED:
		return "red"
	elif suitColorIn == Enums.SuitColor.BLACK:
		return "black"
	else:
		return "unknown"

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

# Helper functions for converting enum values to strings
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

# Returns true if the suit is red
func is_suit_red(suit: int) -> bool:
	return suit == Suit.HEARTS or suit == Suit.DIAMONDS

# Helper function to check if two suits are of opposite colors
func are_suits_opposite_colors(suit1: int, suit2: int) -> bool:
	return is_suit_red(suit1) != is_suit_red(suit2)

# [Brent]: Helper func
func human_readable_card(card: Card) -> String:
	return "" + rank_to_string(card.rank) +"/"+ suit_to_string(card.suit) +" (" + suitcolor_to_string(card.suit_color) +")"
