extends NPC

@export var interaction_states: PackedStringArray = ["Standing", "Walking", "Crouching", "CrouchWalking"]

var times_yelled: int = 0
var response_message: String = ""


func _ready() -> void:
	super()
	brain.speak.connect(speak)
	brain.think.connect(think)


func _process(delta: float) -> void:
	# print(response_message)
	if player:
		interaction_menu = player.interaction_menu
		interaction_menu.target_object = self
		interaction_menu.global_position = position + Vector2(-interaction_menu.size.x / 2, -40)
		if Input.is_action_just_pressed("interact"):
			if !interaction_menu.visible:
				if player.state_machine.current_state.name in interaction_states:
					response_message = ""
					interaction_menu.create_interaction_menu(interaction_menu.Type.NPC, 0, [])
					brain.process_conversation("Hello, how are you?")
					interaction_menu.visible = true
					interaction_active = true
			else:
				close_interaction()

	if !player and interaction_active:
		close_interaction()


func speak(words: String) -> void:
	response_message = words

func think(thoughts: String) -> void:
	print(thoughts)
	print(brain.mood)
