extends Control
class_name FoundationCell

var free_cell_hover_style = preload("res://styles/free_cell_hover.tres")
var free_cell_normal_style = preload("res://styles/free_cell_normal.tres")

signal card_hover_fnda_start(fnda_cell : FoundationCell)
signal card_hover_fnda_ended(fnda_cell : FoundationCell)

@onready var panel_hover : Panel = $PanelHover
@onready var panel_normal : Panel = $PanelNormal
@onready var animation_green_star_l : AnimatedSprite2D = $AnimationGreenStarL
@onready var animation_green_star_r : AnimatedSprite2D = $AnimationGreenStarR
@onready var border_anim_gr16bit : AnimatedSprite2D = $BorderAnimGr16bit
@onready var border_anim_rainbow : AnimatedSprite2D = $BorderAnimRainbow

func _ready():
	highlight(false)
	# Set to last (empty) frame, so all we have to do is call `play` whenever needed and thats it!
	animation_green_star_l.frame = 11
	animation_green_star_r.frame = 11

func _on_area_2d_area_entered(_area):
	emit_signal("card_hover_fnda_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_fnda_ended", self)

func play_card_added_anim():
	animation_green_star_l.play()
	animation_green_star_r.play()

func highlight(isVisible:bool):
	panel_hover.visible = isVisible
	panel_normal.visible = !isVisible
	#border_anim_gr16bit.visible = isVisible
	border_anim_rainbow.visible = isVisible
