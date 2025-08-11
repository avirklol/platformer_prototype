extends Node
class_name AIBrain

@export var npc: NPC
@export var config: AIConfig
@export var instructions: AIInstructions

var memory: Array[Dictionary] = []
var conversation_history: Array[Dictionary] = []
var close_relationships: Array[Dictionary] = []
var player_relationship: Dictionary = {
	"relationship": "stranger",
	"knowledge": "",
	"emotions": [],
	"memories": [],
	"thoughts": ""
}
var emotions: PackedStringArray = []
var mood: String = "neutral"
var tasks: PackedStringArray = []

var previous_response_id: String = ""

var thinking: bool = false

signal speak(words: String)
signal think(thoughts: String)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


# func process_interaction(message: String) -> String:
# 	pass

# func process_thoughts(message: String) -> String:
# 	pass

func process_conversation(player_dialogue: String) -> void:
	var base_instructions: String = build_base_instructions()
	base_instructions += build_conversation_instructions()

	var player_message: Dictionary = {}
	player_message['role'] = "user"
	player_message['content'] = player_dialogue
	conversation_history.append(player_message)

	if previous_response_id:
		config.body["previous_response_id"] = previous_response_id

	config.body["input"] = player_message
	config.body["instructions"] = base_instructions
	config.body["text"]["format"]["schema"] = config.output_type["conversation"]

	var request_body = JSON.stringify(config.body)

	var process_response: Callable = func(response: Dictionary):
		if response.has("id"):
			previous_response_id = response["id"]
		var content = JSON.parse_string(response["output"][0]['content'][0]['text'])
		if content.has("dialogue"):
			speak.emit(content["dialogue"])
		if content.has("thoughts"):
			think.emit(content["thoughts"])
		if content.has("mood"):
			mood = content["mood"]
		if content.has("emotions"):
			for emotion in content["emotions"]:
				emotions.append(emotion)
			if emotions.size() > 5:
				emotions = emotions.slice(emotions.size() - 5)

	send_request(request_body, process_response)


# INSTRUCTION HELPERS ---
func build_base_instructions() -> String:
	return instructions.base.format({
		"first_name": npc.first_name,
        "last_name": npc.last_name,
		"age": npc.age,
        "gender": npc.gender,
		"country": npc.country,
		"location": npc.location,
        "occupation": npc.occupation,
		"personality": npc.personality,
        "bio": npc.bio,
		"goals": npc.goals,
        "interests": npc.interests,
		"alignment": npc.alignment,
		"current_mood": mood,
		"relationships": str(close_relationships) if !close_relationships.is_empty() else "You have no relationships.",
		"tasks": str(tasks) if !tasks.is_empty() else "You have no tasks."
	})

func build_conversation_instructions() -> String:
	return instructions.conversation.format({
		"relationship": player_relationship["relationship"],
		"knowledge": player_relationship["knowledge"] if player_relationship["knowledge"] != "" else "You have no knowledge about this person.",
		"emotions": str(player_relationship["emotions"]) if !player_relationship["emotions"].is_empty() else "You have no emotions about this person.",
		"memories": str(player_relationship["memories"]) if !player_relationship["memories"].is_empty() else "You have no memories of this person.",
		"thoughts": player_relationship["thoughts"] if player_relationship["thoughts"] != "" else "You have no thoughts about this person."
	})


# REQUEST HELPERS --
func send_request(request_body: String, on_request_completed: Callable) -> void:
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)

	var on_completed: Callable = func(result, response_code, headers, body):
		if result != HTTPRequest.RESULT_SUCCESS:
			print("Error making request: ", result)
		else:
			if response_code == 200:
				var response = JSON.parse_string(body.get_string_from_utf8())
				on_request_completed.call(response)
			else:
				var error_message = JSON.parse_string(body.get_string_from_utf8())
				print("Error making request: ", response_code, error_message)

		remove_child(http)
		http.queue_free()

	http.request_completed.connect(on_completed)

	var code = http.request(config.endpoint, config.headers, HTTPClient.Method.METHOD_POST, request_body)

	if code != OK:
		print("Error making request: ", code)

# func json_to_schema(json: String) -> AISchema.CompletionRequest:
# 	var schema: AISchema.CompletionRequest = JSON.parse(json)
# 	return schema

# func dict_to_json(dict: Dictionary) -> String:
# 	return JSON.stringify(dict)
