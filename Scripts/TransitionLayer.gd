extends CanvasLayer


func animate():
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	$".".visible = false
	
func animate_reverse():
	$AnimationPlayer.play_backwards("fade")
	await $AnimationPlayer.animation_finished
	$".".visible = false
