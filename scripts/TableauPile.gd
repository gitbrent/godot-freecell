extends Control

var cards = [] # Keep track of the cards in this pile

# Offset values for card positioning
var vertical_offset = 40 # Adjust as needed for your game's visuals
var horizontal_offset = 10 # Adjust as needed for spacing between columns

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
	print('TODO:')
