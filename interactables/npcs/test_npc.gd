extends Interactable


func _process(delta: float) -> void:
	if player:
		interaction_menu = player.interaction_menu
		interaction_menu.global_position = position + Vector2(-interaction_menu.size.x / 2, -40)
		if Input.is_action_just_pressed("interact"):
			if !interaction_menu.visible:
				if player.state_machine.current_state.name in ["Standing", "Walking", "Crouching", "CrouchWalking"]:
					interaction_menu.create_interaction_menu(interaction_menu.Type.ITEM, 1, ["Penis"])
					interaction_menu.visible = true
					interaction_active = true
			else:
				close_interaction()

	if !player and interaction_active:
		close_interaction()


func open_interaction() -> void:
	pass

func close_interaction() -> void:
	interaction_menu.visible = false
	interaction_menu.destroy_interaction_menu()
	interaction_active = false
	interaction_menu = null
