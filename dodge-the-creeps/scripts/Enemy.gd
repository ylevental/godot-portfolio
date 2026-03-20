extends RigidBody2D

var color: Color = Color.RED
var shape_type: int = 0  # 0=circle, 1=diamond, 2=square
var spin_speed: float = 0.0

func _ready():
	# Random enemy appearance
	shape_type = randi() % 3
	spin_speed = randf_range(-3.0, 3.0)
	var hue = randf_range(0.0, 0.12)  # red-orange-yellow range
	color = Color.from_hsv(hue, 0.9, 1.0)
	$Polygon2D.color = color
	# Set polygon shape based on type
	match shape_type:
		0:  # Circle-ish (octagon)
			var pts = PackedVector2Array()
			for i in range(8):
				var angle = i * TAU / 8.0
				pts.append(Vector2(cos(angle), sin(angle)) * 20.0)
			$Polygon2D.polygon = pts
		1:  # Diamond
			$Polygon2D.polygon = PackedVector2Array([
				Vector2(0, -24), Vector2(16, 0),
				Vector2(0, 24), Vector2(-16, 0)
			])
		2:  # Square
			$Polygon2D.polygon = PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16),
				Vector2(16, 16), Vector2(-16, 16)
			])

func _process(delta):
	$Polygon2D.rotation += spin_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
