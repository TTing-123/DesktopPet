extends CanvasLayer

@onready var status_label = $Control/StatusLabel
@onready var pet_selection = $Control/PetSelection
@onready var pet = $"../Pet"

# 按钮引用
@onready var charizard_button = $Control/PetSelection/PetButton1
@onready var mew_button = $Control/PetSelection/PetButton2
@onready var pikachu_button = $Control/PetSelection/PetButton3

func _ready():
	# 连接按钮信号
	charizard_button.pressed.connect(_on_charizard_button_pressed)
	mew_button.pressed.connect(_on_mew_button_pressed)
	pikachu_button.pressed.connect(_on_pikachu_button_pressed)
	
	# 设置按钮图标（如果有的话）
	update_ui()

func _process(delta):
	update_status_label()

func update_status_label():
	var status_text = "宠物: " + pet.get_pet_name()
	status_text += "\n状态: " + ("移动中" if pet.is_moving else "待机中")
	status_text += "\n位置: " + str(pet.global_position.round())
	status_label.text = status_text

func _on_charizard_button_pressed():
	pet.change_pet_type(pet.PetType.Charizard)
	update_ui()

func _on_mew_button_pressed():
	pet.change_pet_type(pet.PetType.Mew)
	update_ui()

func _on_pikachu_button_pressed():
	pet.change_pet_type(pet.PetType.Pikachu)
	update_ui()

func update_ui():
	# 更新按钮选中状态
	charizard_button.modulate = Color.WHITE
	mew_button.modulate = Color.WHITE
	pikachu_button.modulate = Color.WHITE
	
	match pet.current_pet_type:
		pet.PetType.Charizard:
			charizard_button.modulate = Color.YELLOW
		pet.PetType.Mew:
			mew_button.modulate = Color.YELLOW
		pet.PetType.Pikachu:
			pikachu_button.modulate = Color.YELLOW
