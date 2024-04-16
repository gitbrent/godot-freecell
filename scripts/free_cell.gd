extends Control
class_name FreeCell

signal card_hover_free_start(free_cell : FreeCell)
signal card_hover_free_ended(free_cell : FreeCell)

@onready var glow_card : Sprite2D = $GlowCard
@onready var border_animation_1 = $BorderAnimation1
@onready var border_animation_2 = $BorderAnimation2
@onready var border_animation_fire_t = $BorderAnimationFireT
@onready var border_animation_fire_r = $BorderAnimationFireR
@onready var border_anim_gr_16_bit = $BorderAnimGr16bit

var card_in_cell : Card = null

# =====================================

func _ready():
	highlight(false)

func is_empty():
	return not card_in_cell

func get_curr_card():
	#print("[free_cell] card_in_cell: ", card_in_cell)
	return card_in_cell

func add_card(card: Card):
	if card is Card:
		#print("[FreeCell] added card: {" + Enums.human_readable_card(card_in_cell) + "} with position: ", card.position)
		add_child(card)
		card.position = Enums.CARD_POSITION
		card_in_cell = card
		glow_card.visible = false
	else:
		print("[tableau] attempted to add a non-Card node to the pile.")

func remove_card(card: Card):
	if card == card_in_cell:
		remove_child(card)
		card_in_cell = null

func remove_all():
	if card_in_cell:
		remove_card(card_in_cell)

func _on_area_2d_area_entered(_area):
	if not card_in_cell:
		emit_signal("card_hover_free_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_free_ended", self)

func highlight(isVisible:bool):
	glow_card.visible = isVisible
	# TODO: WIP: better animations
	border_animation_1.visible = isVisible
	border_animation_2.visible = isVisible
	border_animation_fire_t.visible = isVisible
	border_animation_fire_r.visible = isVisible
	border_anim_gr_16_bit.visible = isVisible
