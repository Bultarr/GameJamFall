extends Area2D
@onready var animation_player: AnimationPlayer = $"../Door/AnimationPlayer"

@export var move_speed: float = 200.0  # Speed of the movement
var has_been_hit: bool = false  # Collision flag

func _ready():
	# Initialize any necessary settings
	print("Lever is ready and waiting for the player.")

func _physics_process(delta):
	# Check for overlapping bodies
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is CharacterBody2D and body.name == "CharacterBody2D":  # Adjust according to your player's name
			activate_lever()  # Call function to handle interaction

# Function to handle interaction with the lever
func activate_lever():
	if not has_been_hit:  # Only activate if it hasn't been hit yet
		print("Worked")  # Print message when player interacts with the lever
		has_been_hit = true  # Set the hit flag to true
		animation_player.play("DoorOpen")
