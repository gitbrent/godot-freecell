extends Control
class_name TableauCell

signal card_hover_tabl_start(tabl_pile : TableauCell)
signal card_hover_tabl_ended(tabl_pile : TableauCell)

@onready var panel_hover : Panel = $PanelHover
@onready var panel_normal : Panel = $PanelNormal

func _ready():
	highlight(false)

func _on_area_2d_area_entered(_area):
	emit_signal("card_hover_tabl_start", self)

func _on_area_2d_area_exited(_area):
	emit_signal("card_hover_tabl_ended", self)

func highlight(isVisible:bool):
	panel_hover.visible = isVisible
	panel_normal.visible = !isVisible
