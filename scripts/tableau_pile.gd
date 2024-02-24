extends Control

var cards = [] # Keep track of the cards in this pile
var vertical_offset = 40
var horizontal_offset = 10

func add_card(card: Card):
	if card is Card:
		add_child(card) # Add the card to this node
		var card_position = Vector2(horizontal_offset, cards.size() * vertical_offset)
		card.position = card_position
		cards.append(card)
		#print("Added card with position: ", card.position, " in column ", column_index)
	else:
		print("Attempted to add a non-Card node to the tableau pile.")

func remove_card(card: Card):
	remove_child(card)
	cards.erase(card)

func remove_all_cards():
	while cards.size() > 0:
		var card = cards[0]
		remove_card(card)
