# DESIGN: We use both [Control] nd [Area2D]
# ......: Control to block mouse clicks and provide DnD
#.......: Area2D for collisions (dragging csards onto other cards/free cells)
extends Node2D
class_name Card

signal card_hover_start(card_dragged, target_card)
signal card_hover_ended(card_dragged, target_card)

@onready var panel: Panel = $Panel # hover box
@onready var sprite: Sprite2D = $Sprite2D # card image

# Card properties
var suit: Enums.Suit
var rank: Enums.Rank
var suit_color#: Enums.SuitColor
var location: Vector2  # Current pile/cell position
var currently_dragging_card: Card = null
# Following are set by game_scene
var original_position = Vector2()

func initialize(suitIn: Enums.Suit, rankIn: Enums.Rank):
	# A:
	self.suit = suitIn
	self.rank = rankIn
	match suitIn:
		Enums.Suit.HEARTS, Enums.Suit.DIAMONDS:
			suit_color = Enums.SuitColor.RED
		Enums.Suit.CLUBS, Enums.Suit.SPADES:
			suit_color = Enums.SuitColor.BLACK
	self.location = Vector2.ZERO
	load_texture()
	# B:
	var card_control = self.get_node("CardControl")
	card_control.connect("card_drag_start", self._on_card_drag_start)
	card_control.connect("card_drag_ended", self._on_card_drag_ended)
	# C:
	$Panel.visible = false

func load_texture():
	# Construct texture path based on suit and rank
	var texture_path = "res://assets/cards/"
	texture_path += Enums.suit_to_string(suit) + "_" + Enums.rank_to_string(rank) + ".png"

	# Load and assign texture
	sprite.texture = ResourceLoader.load(texture_path)

func _on_card_drag_start(card_dragged, _mouse_position):
	currently_dragging_card = card_dragged

func _on_card_drag_ended(card_dragged):
	if currently_dragging_card == card_dragged:
		currently_dragging_card = null

# @desc: called when this card enters another cards Area2D
func _on_area_2d_area_entered(area):
	var hovered_card:Card = area.get_parent().get_parent() if area.get_parent().get_parent() is Card else null
	if currently_dragging_card and hovered_card:
		emit_signal("card_hover_start", currently_dragging_card, hovered_card)

func _on_area_2d_area_exited(area):
	var hovered_card:Card = area.get_parent().get_parent() if area.get_parent().get_parent() is Card else null
	if currently_dragging_card and hovered_card:
		emit_signal("card_hover_ended", currently_dragging_card, hovered_card)

func style_hovered_on():
	$Panel.visible = true

func style_hovered_off():
	$Panel.visible = false
