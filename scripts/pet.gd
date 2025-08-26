extends CharacterBody2D

# 宠物类型枚举
enum PetType { Charizard, Mew, Pikachu }

# 导出变量
@export var move_speed: float = 150.0
@export var follow_distance: float = 30.0

# 宠物纹理资源
var pet_textures = {
	PetType.Charizard: preload("res://assets/pets/Charizard.png"),
	PetType.Mew: preload("res://assets/pets/Mew.png"),
	PetType.Pikachu: preload("res://assets/pets/Pikachu.png")
}

# 宠物动画速度
var pet_animation_speeds = {
	PetType.Charizard: 1.2,
	PetType.Mew: 1.0,
	PetType.Pikachu: 0.8
}

@onready var sprite = $Sprite2D
var target_position: Vector2
var current_pet_type: PetType = PetType.Charizard
var is_moving: bool = false

func initialize():
	# 初始设置为喷火龙
	change_pet_type(PetType.Charizard)
	target_position = global_position

func change_pet_type(type: PetType):
	current_pet_type = type
	if pet_textures.has(type):
		sprite.texture = pet_textures[type]
	update_scale_based_on_type()

func update_scale_based_on_type():
	match current_pet_type:
		PetType.Charizard:
			sprite.scale = Vector2(0.1, 0.1)
		PetType.Mew:
			sprite.scale = Vector2(0.1, 0.1)
		PetType.Pikachu:
			sprite.scale = Vector2(0.1, 0.1)

func set_target_position(position: Vector2):
	target_position = position
	is_moving = true

func _physics_process(delta):
	if is_moving:
		move_towards_target(delta)
	update_animation()

func move_towards_target(delta):
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if distance > follow_distance:
		velocity = direction * move_speed * pet_animation_speeds[current_pet_type]
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		is_moving = false

func update_animation():
	if velocity.length() > 0:
		# 根据移动方向翻转精灵
		if velocity.x != 0:
			sprite.flip_h = velocity.x > 0
	# 这里可以添加更复杂的动画逻辑

func get_pet_name() -> String:
	match current_pet_type:
		PetType.Charizard:
			return "喷火龙"
		PetType.Mew:
			return "梦幻"
		PetType.Pikachu:
			return "皮卡丘"
		_:
			return "未知宠物"
