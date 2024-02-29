class_name CardUtils

enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }
enum SuitColor { RED, BLACK }

static func can_place_on_card(card_dragged, target_card) -> bool:
	var card_dragged_color = get_card_color(card_dragged.suit)
	var target_card_color = get_card_color(target_card.suit)
	
	if card_dragged.rank + 1 == target_card.rank and card_dragged_color != target_card_color:
		return true
	return false

static func get_card_color(suit: Suit) -> SuitColor:
	return SuitColor.RED if suit in [Suit.HEARTS, Suit.DIAMONDS] else SuitColor.BLACK
