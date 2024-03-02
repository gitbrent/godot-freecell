extends Control

var cards = []
var vertical_offset = 40
var horizontal_offset = 0

func add_card(card: Card):
	if card is Card:
		#print("[TABL] added card: {" + Enums.human_readable_card(card) + "} with position: ", card.position)
		add_child(card)
		card.position = Vector2(horizontal_offset, cards.size() * vertical_offset)
		cards.append(card)
	else:
		print("[tableau] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	#print("[TABL] remove: ", Enums.human_readable_card(card))
	remove_child(card)
	cards.erase(card)

func remove_all_cards():
	while cards.size() > 0:
		remove_card(cards[0])

# TODO: new signal for hovering over empty tableau
