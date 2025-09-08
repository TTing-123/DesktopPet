extends Control

# 免费API提供商枚举
enum API_PROVIDER {
	LOCAL_LM_STUDIO,   # 本地模型
}

# API配置
var api_config = {
	API_PROVIDER.LOCAL_LM_STUDIO: {
		"name": "LM Studio本地模型",
		"url": "http://localhost:1234/v1/chat/completions",
		"headers": ["Content-Type: application/json"],
		"model": "local-model",
		"requires_auth": false
	}
}

# 暴露属性
@export var user_message_color: Color = Color("#007acc")
@export var ai_message_color: Color = Color("#2ecc71")

# UI节点引用
@onready var chat_display: RichTextLabel = $ColorRect/MarginContainer/VBoxContainer/ChatDisplay
@onready var user_input: TextEdit = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/UserInput
@onready var send_button: Button = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/SendButton
@onready var status_label: Label = $ColorRect/MarginContainer/VBoxContainer/StatusLabel
@onready var provider_button: OptionButton = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/ProviderButton
@onready var retry_button: Button = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/RetryButton
@onready var clear_button: Button = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/ClearButton
@onready var back_button: Button = $ColorRect/BackButton
@onready var http_request = $HTTPRequest

# 当前设置
var current_provider = API_PROVIDER.LOCAL_LM_STUDIO
var conversation_history = []
var processing_message = false
var last_user_message = ""

signal exited

func _ready():
	# 连接信号
	send_button.pressed.connect(_on_send_button_pressed)
	provider_button.item_selected.connect(_on_provider_changed)
	http_request.request_completed.connect(_on_request_completed)
	user_input.focus_entered.connect(_on_input_focus_entered)
	user_input.focus_exited.connect(_on_input_focus_exited)
	retry_button.pressed.connect(_on_retry_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# 设置提供商选项
	setup_provider_options()
	
	# 隐藏滚动条
	chat_display.get_v_scroll_bar().hide()
	
	# 初始化
	update_status()

func setup_provider_options():
	provider_button.clear()
	for provider in api_config:
		provider_button.add_item(api_config[provider].name)
	
	# 设置默认选中项
	provider_button.select(0)

func _on_send_button_pressed():
	process_message()

func _on_retry_button_pressed():
	process_message(last_user_message)

func _on_clear_button_pressed():
	chat_display.text = ""

func _on_back_button_pressed():
	exited.emit()

func _on_provider_changed(index):
	current_provider = index
	update_status()

func process_message(custom_message = null):
	if processing_message:
		return
		
	var message = custom_message if custom_message else user_input.text.strip_edges()
	if message == "":
		return
	
	add_user_message(message)
	last_user_message = message
	user_input.text = ""
	
	conversation_history.append({"role": "user", "content": message})
	
	set_processing(true)
	call_remote_api()

func call_remote_api():
	var config = api_config[current_provider]
	var headers = PackedStringArray(config.headers.duplicate())
	
	# 准备请求体 - 使用OpenAI兼容格式
	var body_data = JSON.stringify({
		"model": config.model,
		"messages": conversation_history,
		"temperature": 0.7,
		"max_tokens": 500,
		"stream": false
	})
	
	var error = http_request.request(config.url, headers, HTTPClient.METHOD_POST, body_data)
	if error != OK:
		handle_api_error("请求发送失败: " + str(error))
		set_processing(false)

func _on_request_completed(_result, response_code, _headers, body):
	set_processing(false)
	
	if response_code != 200:
		handle_api_error("API错误: " + str(response_code))
		return
	
	var response = parse_response(body)
	if response:
		add_ai_message(response)
		conversation_history.append({"role": "assistant", "content": response})
	else:
		handle_api_error("响应解析失败")

func _on_input_focus_entered():
	# 输入框获得焦点时，设置单行模式暂时禁用，允许换行
	pass

func _on_input_focus_exited():
	# 输入框失去焦点时，恢复设置
	pass

func parse_response(body):
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON解析错误: ", json.get_error_message())
		return null
	
	var data = json.get_data()
	
	if data and data.has("choices") and data["choices"].size() > 0:
		var choice = data["choices"][0]
		if choice.has("message") and choice["message"].has("content"):
			var content = choice["message"]["content"]
			# 直接清理响应
			content = content.replace("\\(", "").replace("\\)", "")  # 去除LaTeX标记
			content = content.replace("```", "")  # 去除代码块标记
			content = content.strip_edges()  # 去除首尾空白
			return content
	
	return null

func handle_api_error(error_msg):
	print(error_msg)
	status_label.text = "❌ " + error_msg
	
	# 模拟一个简单的本地响应作为后备
	var last_message = conversation_history[-1]["content"] if conversation_history.size() > 0 else ""
	var fallback_response = generate_fallback_response(last_message)
	add_ai_message(fallback_response)
	conversation_history.append({"role": "assistant", "content": fallback_response})

func generate_fallback_response(_user_message: String) -> String:
	return "请求失败"
	# 简单的本地后备响应生成
	#var responses = [
		#"我正在使用本地模式为您服务～",
		#"这个问题很有趣！让我想想...",
		#"由于API连接问题，我使用本地模式回复您。",
		#"您好！我是本地AI助手。"
	#]
	
	# 根据用户消息内容生成更相关的响应
	#if user_message.contains("你好") or user_message.contains("hello"):
		#return "您好！我是本地AI助手，很高兴为您服务。"
	#elif user_message.contains("帮助") or user_message.contains("help"):
		#return "我可以回答您的问题或进行聊天对话。请告诉我您需要什么帮助？"
	#elif user_message.contains("名字") or user_message.contains("name"):
		#return "我是运行在您本地计算机上的AI助手。"
	#else:
		#return responses[randi() % responses.size()]

func set_processing(processing):
	processing_message = processing
	user_input.editable = !processing
	send_button.disabled = processing
	retry_button.disabled = processing
	clear_button.disabled = processing
	
	if processing:
		status_label.text = "🔄 请求中..."
	else:
		update_status()

func update_status():
	var config = api_config[current_provider]
	status_label.text = "✅ " + config.name
	status_label.add_theme_color_override("font_color", Color.GREEN)

func add_user_message(message: String):
	var formatted_message = message.replace("\n", " ")
	var color_hex = user_message_color.to_html(false)
	var formatted_text = "[right][color=#%s]%s[/color][/right]\n\n" % [color_hex, formatted_message]
	chat_display.text += formatted_text

func add_ai_message(message: String):
	var formatted_message = message.replace("\n", " ")
	var color_hex = ai_message_color.to_html(false)
	var formatted_text = "[color=#%s]%s[/color]\n\n" % [color_hex, formatted_message]
	chat_display.text += formatted_text

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if user_input.has_focus():
				if event.ctrl_pressed or event.shift_pressed:
					user_input.insert_text_at_caret("\n")
					get_tree().get_root().set_input_as_handled()
				else:
					process_message()
					get_tree().get_root().set_input_as_handled()
