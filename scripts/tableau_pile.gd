extends Control
class_name TableauPile

signal card_hover_tabl_start(tabl_pile : TableauPile)
signal card_hover_tabl_ended(tabl_pile : TableauPile)

@onready var panel_hover:Panel = $PanelHover
@onready var panel_normal:Panel = $PanelNormal

var cards = []
var vertical_offset = 40
var horizontal_offset = 0

func get_card_count():
	return cards.size()

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

func _on_area_2d_area_entered(_area):
	emit_signal("card_hover_tabl_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_tabl_ended", self)

func highlight(isVisible:bool):
	$PanelHover.visible = isVisible
	$PanelNormal.visible = !isVisible
