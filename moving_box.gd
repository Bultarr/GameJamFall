extends CharacterBody2D

@export var move_speed: float = 200.0  # Speed of the movement
var target_position: Vector2  # Target position for movement
var is_moving: bool = false  # Track if the box is currently moving
var has_been_hit: bool = false  # Collision flag

func _ready():
	target_position = position  # Initialize the target position as the current position

func _physics_process(delta):
	# If the box is moving, smoothly interpolate towards the target position
	if is_moving:
		# Calculate the direction to the target position
		var direction = (target_position - position).normalized()
		velocity = direction * move_speed

		# Use move_and_slide without passing arguments
		move_and_slide()

		# Stop moving once close enough to the target
		if position.distance_to(target_position) < 1.0:
			is_moving = false  # Stop moving when close enough
			velocity = Vector2.ZERO  # Reset velocity to stop the box
			has_been_hit = false  # Reset the hit flag when it reaches the target

# Function to be called by the player when hit, to move the box
func move_away_from_player(player_position: Vector2):
	if not has_been_hit:  # Only move if it hasn't been hit yet
		var direction = (position - player_position).normalized()  # Get the direction opposite to the player
		target_position = position + direction * 200  # Move 200 pixels in the opposite direction
		is_moving = true  # Start moving
		has_been_hit = true  # Set the hit flag to true
