extends Control
class_name TableauPile

signal card_hover_tabl_start(tabl_pile : TableauPile)
signal card_hover_tabl_ended(tabl_pile : TableauPile)

@onready var panel_hover : Panel = $PanelHover
@onready var panel_normal : Panel = $PanelNormal

var cards: Array[Card]
var horizontal_offset = 0

# =====================================

func _ready():
	highlight(false)

func get_card_count():
	return cards.size()

func add_card(card: Card):
	if card is Card:
		#print("[TABL] added card: {" + Enums.human_readable_card(card) + "} with position: ", card.position)
		#add_child(card)
		#card.position = Vector2(horizontal_offset, cards.size() * Enums.Y_OFFSET)
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

func _on_area_2d_area_entered(_area):
	emit_signal("card_hover_tabl_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_tabl_ended", self)

func highlight(isVisible:bool):
	panel_hover.visible = isVisible
	panel_normal.visible = !isVisible

# DEBUG: called from debug button in `game_scene`
func reset_card_positions_in_pile():
	for i in range(cards.size()):
		var card = cards[i]
		card.position = Vector2(horizontal_offset, i * Enums.Y_OFFSET)
