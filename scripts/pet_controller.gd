# PetController.gd
extends Node

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var idle: Sprite2D = $"../Idle"
@onready var run: Sprite2D = $"../Run"
@onready var attack: Sprite2D = $"../Attack"
@onready var hurt: Sprite2D = $"../Hurt"

var current_sprite: Sprite2D
var animations = ["idle", "run", "attack"]
var timer: Timer
var is_idle_period: bool = true

func _ready():
	$"../../DialogBox".exited.connect(_on_dialog_box_exited)
	
	show_sprite(idle)
	
	# 创建定时器
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true  # 确保定时器只触发一次
	
	# 立即开始播放idle动画并启动定时器
	call_deferred("initialize_animations")

func initialize_animations():
	start_idle_period()

func _on_timer_timeout():
	if is_idle_period:
		# idle期结束，切换到随机动画期
		start_random_period()
	else:
		# 随机动画期结束，切换回idle期
		start_idle_period()

func start_idle_period():
	is_idle_period = true
	switch_to_animation("idle")
	print("开始idle期 (3秒)")
	# 设置3秒后触发
	timer.start(3.0)

func start_random_period():
	is_idle_period = false
	
	# 从可用动画中排除idle并随机选择一个
	var available_anims = animations.duplicate()
	available_anims.erase("idle")
	
	if available_anims.size() > 0:
		var random_anim = available_anims[randi() % available_anims.size()]
		switch_to_animation(random_anim)
		print("开始随机动画期 (2秒)")
	else:
		# 如果没有其他动画可用，继续idle
		switch_to_animation("idle")
		print("没有其他动画可用，继续idle")
	
	# 设置2秒后触发
	timer.start(2.0)

func hide_all_sprites():
	idle.visible = false
	run.visible = false
	attack.visible = false
	hurt.visible = false

func show_sprite(sprite: Sprite2D):
	hide_all_sprites()
	sprite.visible = true
	current_sprite = sprite

func play_animation(anim_name: String):
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		print("动画不存在: ", anim_name)

func switch_to_animation(anim_name: String):
	match anim_name:
		"idle":
			show_sprite(idle)
		"run":
			show_sprite(run)
		"attack":
			show_sprite(attack)
		"hurt":
			show_sprite(hurt)
	
	play_animation(anim_name)
	print("切换到动画: ", anim_name)

func _on_dialog_box_exited():
	switch_to_animation("idle")
