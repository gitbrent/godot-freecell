extends Control
class_name FreeCell

signal card_hover_free_start(free_cell : FreeCell)
signal card_hover_free_ended(free_cell : FreeCell)

@onready var glow_card : Sprite2D = $GlowCard
@onready var border_animation_1 : AnimatedSprite2D = $BorderAnimation1
@onready var border_animation_2 = $BorderAnimation2
@onready var border_animation_fire_t = $BorderAnimationFireT
@onready var border_animation_fire_r = $BorderAnimationFireR
@onready var border_anim_gr_16_bit = $BorderAnimGr16bit
@onready var border_anim_green_8 = $BorderAnimGreen8
@onready var border_anim_grn_new = $BorderAnimGrnNew

func _ready():
	highlight(false)

func _on_area_2d_area_entered(_area):
	emit_signal("card_hover_free_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_free_ended", self)

func highlight(isVisible:bool):
	glow_card.visible = isVisible
	# TODO: WIP: better animations
	#border_animation_1.visible = isVisible
	#border_animation_2.visible = isVisible
	#border_animation_fire_t.visible = isVisible
	#border_animation_fire_r.visible = isVisible
	#border_anim_gr_16_bit.visible = isVisible
	#border_anim_green_8.visible = isVisible
	border_anim_grn_new.visible = isVisible
