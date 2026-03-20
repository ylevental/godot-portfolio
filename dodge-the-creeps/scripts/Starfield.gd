extends Node2D

var stars: Array = []
const NUM_STARS = 80
const SCREEN = Vector2(480, 720)

func _ready():
	for i in range(NUM_STARS):
		stars.append({
			"pos": Vector2(randf() * SCREEN.x, randf() * SCREEN.y),
			"speed": randf_range(10.0, 60.0),
			"size": randf_range(0.5, 2.0),
			"brightness": randf_range(0.2, 0.8)
		})

func _process(delta):
	for star in stars:
		star.pos.y += star.speed * delta
		if star.pos.y > SCREEN.y:
			star.pos.y = 0
			star.pos.x = randf() * SCREEN.x
	queue_redraw()

func _draw():
	for star in stars:
		var c = Color(0.7, 0.8, 1.0, star.brightness)
		draw_circle(star.pos, star.size, c)
