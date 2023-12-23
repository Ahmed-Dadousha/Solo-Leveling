extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("stats_changed", change_stats)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Control/FPSContainer/FPS.text = "FPS: "+ str(Engine.get_frames_per_second())
	
func change_stats():
	# Ammo Label
	$Control/AmmoContainer/Ammo.text = "Ammo: " + str(GameManager.ammo)
	# Health Label
	$Control/MarginContainer/healthContainer/Label.text = str(GameManager.health)
	# Progressbar value
	$Control/MarginContainer/healthContainer/ProgressBar.value = GameManager.health
	# Progressbar Color
	var stylebox: StyleBox = $Control/MarginContainer/healthContainer/ProgressBar.get("theme_override_styles/fill")
	stylebox.bg_color.h = lerp(0.0,0.3,GameManager.health/200.0)


func _on_center_container_draw():
	$CenterContainer.draw_circle(Vector2(0,0), 5.0, Color.BLACK)
