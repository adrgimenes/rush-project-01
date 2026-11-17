extends Node
const Op = preload("res://addons/unibuilder/core/ops/dissolve_vertices.gd")
func make_mesh() -> UBMeshData:
	var data := UBMeshData.new()
	data.positions = PackedVector3Array([Vector3(0,0,0), Vector3(1,0,0), Vector3(2,0,0), Vector3(2,1,0), Vector3(0,1,0)])
	var face := UBFace.new()
	face.vertices = PackedInt32Array([0,1,2,3,4])
	data.faces.append(face)
	return data
func _ready() -> void:
	var a := make_mesh()
	assert(Op.apply(a, {1:true}) == 1)
	assert(a.positions.size() == 4 and a.faces[0].vertices.size() == 4)
	assert(Op.apply(a, {0:true,1:true,2:true,3:true}) == 0)
	var b := make_mesh()
	b.positions.append(Vector3(1,-1,0))
	var branch := UBFace.new()
	branch.vertices = PackedInt32Array([0,5,1])
	b.faces.append(branch)
	assert(Op.apply(b, {1:true}) == 0)
	var c := make_mesh()
	c.faces[0].uv_manual = true
	c.faces[0].uv_coords = PackedVector2Array([Vector2(0,0),Vector2(0.5,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
	assert(Op.apply(c, {1:true}) == 1)
	assert(c.faces[0].uv_coords.size() == 4)
	var d := make_mesh()
	d.faces[0].uv_manual = true
	d.faces[0].uv_coords = PackedVector2Array([Vector2(0,0),Vector2(0.5,0.2),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
	assert(Op.apply(d, {1:true}) == 0)
	print("DISSOLVE TESTS PASSED: straight, corners, junctions, UV preservation")
	get_tree().quit()
