extends Node

func _ready():
	# 获取当前显示器的尺寸
	var screen_index = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen_index)
	var screen_position = DisplayServer.screen_get_position(screen_index)
	
	# 获取窗口尺寸
	var window_size = get_window().size
	
	# 计算右下角位置（相对于当前显示器）
	var position_x = screen_position.x + screen_size.x - window_size.x - 20
	var position_y = screen_position.y + screen_size.y - window_size.y - 70
	
	# 设置窗口位置
	get_window().position = Vector2i(position_x, position_y)
