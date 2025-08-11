extends Resource
class_name AIConfig

enum Provider {
	OPENAI,
	GOOGLE,
	VENICE
}


@export var provider: Provider = Provider.OPENAI
@export var temperature: float = 0.7
@export var max_words: int = 10
@export var instructions: String = ""

var output_type: Dictionary = {
	"conversation": {
		"type": "object",
		"properties": {
			"thoughts": {
				"type": "string",
				"description": "Your thoughts about what the person just said to you. This should be a single sentence."
			},
			"dialogue": {
				"type": "string",
				"description": "Your response to the person. This should be a single sentence of less than {max_words} words.".format({"max_words": max_words})
			},
			"emotions": {
				"type": "array",
				"description": "A list of emotions you are feeling. This should be a list of strings.",
				"items": {
					"type": "string",
					"description": "An emotion you are feeling. This should be a single word."
				}
			},
			"mood": {
				"type": "string",
				"description": "Your mood. This should be a single word based on your current emotions about the conversation."
			},
            "person":{
                "type": "object",
                "properties": {
                    "relationship": {
                        "type": "string",
                        "enum": ["friend", "enemy", "customer", "client", "employer", "parent", "child", "sibling", "spouse", "partner", "acquaintance", "stranger"],
                        "description": "Your relationship with the person based on the interactions you've had with them. Who are they to you?"
                    },
                    "knowledge": {
                        "type": "string",
                        "description": "Additional information you'd like to remember about the person."
                    },
                },
                "required": ["relationship", "knowledge"],
                "additionalProperties": false
			},
		"required": ["thoughts", "dialogue", "emotions", "relationship", "person"],
		"additionalProperties": false
		},
    },
	"thoughts": {
		"type": "object",
		"properties": {
			"thoughts": {
				"type": "string",
				"description": "Your thoughts about your existing memory. This should be a single sentence."
			},
			"emotions": {
				"type": "array",
				"description": "A list of emotions you are feeling. This should be a list of strings.",
				"items": {
					"type": "string",
					"description": "An emotion you are feeling. This should be a single word."
				}
			}
		},
		"required": ["thoughts", "emotions"],
		"additionalProperties": false
	}
}

var request_data: Dictionary = {
	"endpoints": {
		Provider.OPENAI: "https://api.openai.com/v1/responses",
		Provider.GOOGLE: "https://api.google.com/v1/chat/completions",
		Provider.VENICE: "https://api.venice.com/v1/chat/completions"
	},
	"keys": {
		Provider.OPENAI: "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",
		Provider.GOOGLE: "AIzaSyDsG0bjDTs5v4YWeRJyX84TlBC-ZSj_2hI",
		Provider.VENICE: "dcM129cIvkV8NMVXkGtXaaj2vhTUksQuOJahevDd3_"
	},
	"schemas": {
		Provider.OPENAI: {
			"headers": [
				"Authorization: Bearer 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",
				"Content-Type: application/json"
			],
			"body": {
				"model": "gpt-4.1-nano",
				"instructions": null,
				"input": [],
				"temperature": temperature,
				"previous_response_id": null,
				"text": {
					"format": {
						"type": "json_schema",
						"name": "output",
						"schema": null
					}
				}
			}

		},
		Provider.GOOGLE: "",
		Provider.VENICE: ""
	}
}

var endpoint: String = request_data["endpoints"][provider]
var api_key: String = request_data["keys"][provider]
var body: Dictionary = request_data["schemas"][provider]["body"]
var headers: PackedStringArray = request_data["schemas"][provider]["headers"]
