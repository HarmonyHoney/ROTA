tool
extends Node2D

export var is_act := false setget set_is_act
export var array_mesh : ArrayMesh

export var polygon_path : NodePath = "." setget set_polygon_path
onready var polygon_node : Polygon2D = get_node_or_null(polygon_path)
export var mesh_path : NodePath = "." setget set_mesh_path
onready var mesh_node = get_node_or_null(mesh_path)

func set_is_act(arg := is_act):
	is_act = arg
	if is_act and Engine.editor_hint:
		act()

func set_polygon_path(arg := polygon_path):
	polygon_path = arg
	polygon_node = get_node_or_null(polygon_path)

func set_mesh_path(arg := mesh_path):
	mesh_path = arg
	mesh_node = get_node_or_null(mesh_path)

func act():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.add_color(Color(1, 1, 1))
	st.add_uv(Vector2(0, 0))
	
	var gon = polygon_node.polygon
	var gs = gon.size()
	
	for i in gs:
		var n = posmod(i + 1, gs)
		var tri = PoolVector3Array([Vector3.ZERO, Vector3(gon[i].x, gon[i].y, 0), Vector3(gon[n].x, gon[n].y, 0)])
		st.add_triangle_fan(tri)
	
	array_mesh = st.commit()
	
	if mesh_node is MeshInstance2D:
		mesh_node.set_deferred("mesh", array_mesh)
	elif mesh_node is MultiMeshInstance2D:
		mesh_node.multimesh.set_deferred("mesh", array_mesh)
