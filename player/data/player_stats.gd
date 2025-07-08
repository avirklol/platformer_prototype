extends Node
class_name PlayerStats

@export var health: int = 100
@export var stamina: int = 100
@export var tech_points: int = 10
@export var attack: int = 10
@export var defense: int = 5
@export var force: Dictionary = {
    "walk": 100.0,
    "run": 200.0,
    "crouch": 50.0,
    "climb": 75.0,
    "jump": 300.0,
}
@export var high_fall_velocity: float = 350.0
@export var max_fall_velocity: float = 750.0
@export var experience: int = 0
@export var level: int = 1
