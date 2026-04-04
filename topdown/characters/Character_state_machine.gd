extends Node


@onready var movement_path: Array[Vector3] = []
@export var walking_speed: float = 5
@export var peeking_speed: float = 1
@export var running_speed: float = 8
@export var current_movement_speed: float = 10.0 #knife run speed
@onready var Health : float = 100
@onready var TurnActions: Array = []
@onready var Action_list : Array[String] = ['Sprint', 'Walk', 'Sneak', 'Peek',  'Hold', 'Ability1', 'Ability2', "Ability3", 'Ability4']



enum CharacterState {
	WAIT,
	WALK,
	RUN,
	SPRINT,
	PEEK,
	HOLD,
	ABILITY1,
	ABILITY2,
	ABILITY3,
	ABILITY4,
	DONE
}

@onready var CurrentState = CharacterState.WAIT
