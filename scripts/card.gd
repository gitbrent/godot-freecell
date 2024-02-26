# DESIGN: We use both [Control] nd [Area2D]
# ......: Control to block mouse clicks and provide DnD
#.......: Area2D for collisions (dragging csards onto other cards/free cells)
extends Node2D
class_name Card

# Card properties
@onready var sprite = $Sprite2D # card image
var suit: Enums.Suit
var rank: Enums.Rank
var suit_color#: Enums.SuitColor
var location: Vector2  # Current pile/cell position
var dragging = false
var drag_offset = Vector2()
var original_position = Vector2()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func initialize(suitIn: Enums.Suit, rankIn: Enums.Rank):
	self.suit = suitIn
	self.rank = rankIn
	match suitIn:
		Enums.Suit.HEARTS, Enums.Suit.DIAMONDS:
			suit_color = Enums.SuitColor.RED
		Enums.Suit.CLUBS, Enums.Suit.SPADES:
			suit_color = Enums.SuitColor.BLACK
	self.location = Vector2.ZERO
	load_texture()

func load_texture():
	# Construct texture path based on suit and rank
	var texture_path = "res://assets/cards/"
	texture_path += Enums.suit_to_string(suit) + "_" + Enums.rank_to_string(rank) + ".png"

	# Load and assign texture
	sprite.texture = ResourceLoader.load(texture_path)
	#print('loaded texture: ' + texture_path)

# Checks if one card can be placed on another according to FreeCell rules
func can_place_on_card(dragged_card, target_card) -> bool:
	if dragged_card.rank + 1 == target_card.rank and dragged_card.suit_color != target_card.suit_color:
		return true
	return false

func _on_area_2d_area_entered(area):
	var dragged_card = area.get_parent().get_parent()
	if dragged_card is Card:
		var can_place = can_place_on_card(dragged_card, self)
		# FIXME: print('TODO:')
		#if can_place:
			#print("Can place ", Enums.human_readable_card(dragged_card), " on ", Enums.human_readable_card(self))
		#else:
			#print("Cannot place ", Enums.human_readable_card(dragged_card), " on ", Enums.human_readable_card(self))

func _on_area_2d_area_exited(area):
	# Handle any cleanup or UI feedback reset when a card is no longer dragging over
	pass # Replace with function body.
