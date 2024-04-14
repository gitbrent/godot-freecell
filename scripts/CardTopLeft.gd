extends Sprite2D

# Variables
var direction = 1  # 1 for right, -1 for left
var angle = 0.0  # Current rotation angle in radians
var parent_width = 0
var sprite:Sprite2D
var sprite_width = 100+88

func _ready():
	parent_width = get_parent().get_size().x
	sprite = get_parent().get_node("CardL")
	sprite_width = sprite.get_rect().size.x * sprite.scale.x

func _process(delta):
	# STEP 1: position
	position.x += 2 * direction

	# Check if reached edge and change direction
	var minX = 0 + sprite_width / 2
	var maxX = position.x + sprite_width / 2

	if position.x < minX or maxX > parent_width:
		direction *= -1

	# STEP 2: rotate
	angle += delta * direction * PI
	rotation = angle
