extends CharacterBody2D

@export var speed = 400
@export var stretch_factor = 0.2  # Factor to control how much the sprite stretches
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stretching_line: Line2D = $StretchingLine  # Reference to the Line2D node
@onready var moving_box: CharacterBody2D = $"../MovingBox"  # Correct path to MovingBox

@onready var character_wait: Timer = $CharacterWait
var can_move: bool = true

var target_position: Vector2 = position
@export var damping_factor = 0.9  # Factor to control how quickly the speed decreases
var line_length: float = 0.0  # Length of the line that will be stretched

# Variable to stop the drawing of a line
var is_line_active: bool = true  # Control variable for the line
var collision_occurred: bool = false  # Flag to check if a collision has occurred

func _ready():
	# Connect the timer's timeout signal to the function to enable movement
	character_wait.timeout.connect(_on_character_wait_timeout)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()  # Set target to mouse position
			can_move = false  # Disable movement until timer finishes
			is_line_active = true

func _physics_process(delta):
	# Move towards the target position
	if position.distance_to(target_position) > 10:
		# Set the velocity towards the target
		velocity += position.direction_to(target_position) * speed / 20
	else:
		velocity = Vector2.ZERO  # Stop moving when close enough to target

	# Move and handle collisions
	move_and_slide()

	# Check for collisions and apply damping
	if is_on_floor() or is_on_wall() or is_on_ceiling():  # Modify this based on your needs
		velocity *= damping_factor  # Reduce the velocity instead of stopping it
		stretching_line.clear_points()  # Clear the line when hitting a surface
		if !collision_occurred:  # Check if we already started the timer
			#print("Collision occurred, starting timer")
			collision_occurred = true  # Set the flag to true
			character_wait.start()  # Start the timer
			is_line_active = false  # Disable line drawing

	# Update the Line2D's end point to move towards the target position
	update_stretching_line(delta)

	# Always stretch towards the mouse, regardless of movement
	stretch_towards_mouse()
	
	# Detect collisions with the box and move it
	detect_box_collision()

# Function to stretch the sprite slightly towards the mouse and rotate it
func stretch_towards_mouse():
	var mouse_pos = get_global_mouse_position()
	var direction = position.direction_to(mouse_pos)

	# Stretching based on direction towards the mouse
	sprite_2d.scale.x = 1 + direction.x * stretch_factor
	sprite_2d.scale.y = 1 + direction.y * stretch_factor
	
	# Rotate sprite to look at the mouse position
	sprite_2d.look_at(mouse_pos)
	sprite_2d.rotation += deg_to_rad(90)

# Function to update the Line2D to stretch from the player to the mouse position
func update_stretching_line(delta):
	if is_line_active:
		stretching_line.clear_points()  # Clear previous points
		
		# Start point at player's position (relative to itself)
		stretching_line.add_point(Vector2.ZERO)

		# Calculate the direction from player to target position
		var direction = (target_position - position).normalized()
		
		# Calculate the distance from the player to the target position
		var distance = position.distance_to(target_position)

		# Incrementally move the line length towards the target distance
		line_length = lerp(line_length, distance, 0.1) + 40 # Adjust this factor for speed of stretching

		# Get the new end point of the line based on the updated length
		var new_end_point = position + direction * line_length

		# Set the end point of the line to the new end point
		stretching_line.add_point(new_end_point - position)  # End point in local coordinates

func _on_character_wait_timeout() -> void:
	can_move = true
	collision_occurred = false  # Reset the collision flag

# Detect collision with the box
func detect_box_collision():
	# Create a query for the player's collision shape
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = $CollisionShape2D.shape
	query.transform = Transform2D(0, position)  # Set transform to player's position

	# Get bodies that overlap with the player
	var result = space_state.intersect_shape(query)

	for collision in result:
		if collision.collider is CharacterBody2D and collision.collider == moving_box:
			moving_box.move_away_from_player(position)
