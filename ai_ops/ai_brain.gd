extends Node
class_name AIBrain

@export var npc: NPC
@export var config: AIConfig


var memory: Dictionary = {}
var conversation_history: Array[Dictionary] = []
var new_message: Dictionary = {}

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

func make_request(message: String, player_interaction: bool = true) -> void:
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)

	new_message['role'] = "user"
	new_message['content'] = message
	conversation_history.append(new_message)
	print(conversation_history)

	config.body["input"] = conversation_history
	config.body["instructions"] = config.instructions
	if previous_response_id:
		config.body["previous_response_id"] = previous_response_id
	config.body["text"]["format"]["schema"] = config.output_type["interaction"] if player_interaction else config.output_type["thoughts"]

	var request_body = JSON.stringify(config.body)

	var on_request_completed: Callable = func(result, response_code, headers, body):
		if result != HTTPRequest.RESULT_SUCCESS:
			print("Error making request: ", result)
			return null
		else:
			var response = JSON.parse_string(body.get_string_from_utf8())
			if response.has("id"):
				previous_response_id = response["id"]
			var content = JSON.parse_string(response["output"][0]['content'][0]['text'])

			if content.has("dialogue"):
				speak.emit(content.dialogue)
			if content.has("thoughts"):
				think.emit(content["thoughts"])

		remove_child(http)
		http.queue_free()

		conversation_history = []

	http.request_completed.connect(on_request_completed)

	var code = http.request(config.endpoint, config.headers, HTTPClient.Method.METHOD_POST, request_body)

	if code != OK:
		print("Error making request: ", code)





# func json_to_schema(json: String) -> AISchema.CompletionRequest:
# 	var schema: AISchema.CompletionRequest = JSON.parse(json)
# 	return schema

# func dict_to_json(dict: Dictionary) -> String:
# 	return JSON.stringify(dict)
