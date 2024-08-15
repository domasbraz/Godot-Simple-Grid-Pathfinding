extends TileMap

var astargrid = AStarGrid2D.new()

const main_layer = 0
const main_source = 1
const path_atlas_coords = Vector2i(1, 1) 
@onready var character = $Character

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_grid()
	set_unit_to_map(Vector2i(0,0), character)
	#show_path()
	move_to_position(Vector2i(7, 1), character)
	
func setup_grid():
	var tile_size = get_tileset().tile_size
	var tilemap_size = get_used_rect().end - get_used_rect().position
	var map_rect = Rect2i(Vector2i(), tilemap_size)
	
	astargrid.region = map_rect
	astargrid.cell_size = tile_size
	
	#prevents diagonal movement
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astargrid.update()
	
	#sets solid tiles
	for cell in get_used_cells(main_layer):
		if (is_spot_solid(cell)):
			astargrid.set_point_solid(cell, true)
			
#sets unit postion to grid coordinates
func set_unit_to_map(map_position: Vector2i, unit: CharacterBody2D):
	unit.global_position = map_to_local(map_position)
	
#visualises route
func show_path():
	var start_path = Vector2i(0, 0)
	var end_path = Vector2i(7, 1)
	
	var path_taken = astargrid.get_id_path(start_path, end_path)
	
	for cell in path_taken:
		set_cell(main_layer, cell, main_source, path_atlas_coords)
	
#checks if tile at coordinate is set to solid
func is_spot_solid(spot: Vector2i) -> bool:
	return get_cell_tile_data(main_layer, spot).get_custom_data("is_solid")

#generates a path for the unit to move
func move_to_position(new_position: Vector2i, unit: CharacterBody2D):
	
	var start_position = local_to_map(unit.global_position)
	var end_position = new_position
	
	var path = astargrid.get_id_path(start_position, end_position)
	
	for coords in path:
		await move_unit(coords, unit)
		
#IMPORTANT! must use await keyword when calling
#gradually moves unit to new coordinates
func move_unit(new_position_map: Vector2i, unit: CharacterBody2D):
	
	var new_position_local: Vector2 = map_to_local(new_position_map)
	
	while unit.global_position != new_position_local:
		
		if unit.global_position.x < new_position_local.x:
			unit.global_position.x += 1
		
		elif unit.global_position.x > new_position_local.x:
			unit.global_position.x -= 1
	
		elif unit.global_position.y < new_position_local.y:
			unit.global_position.y += 1
			
		elif unit.global_position.y > new_position_local.y:
			unit.global_position.y -= 1
			
		await get_tree().create_timer(.01).timeout
			
	#unit.global_position = new_pos
	
	#var coords = local_to_map(unit.global_position)
	#print(coords)

#unused
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
