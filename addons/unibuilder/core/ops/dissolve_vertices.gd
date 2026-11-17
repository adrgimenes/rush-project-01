@tool
extends RefCounted
## Removes only degree-two, straight boundary points. Never moves geometry.
static func apply(data, selected: Dictionary) -> int:
	var removed := 0
	for vi in UBOpUtils.valid_vertices(data, selected):
		var neighbors := {}
		var incident := []
		var safe := true
		for face in data.faces:
			var i: int = face.vertices.find(vi)
			if i < 0:
				continue
			var count: int = face.vertices.size()
			if count <= 3 or face.vertices.count(vi) != 1:
				safe = false
				break
			var a: int = face.vertices[(i + count - 1) % count]
			var b: int = face.vertices[(i + 1) % count]
			neighbors[a] = true
			neighbors[b] = true
			var ab: Vector3 = data.positions[b] - data.positions[a]
			var ap: Vector3 = data.positions[vi] - data.positions[a]
			if ab.length_squared() < 0.00000001:
				safe = false
				break
			var t: float = ap.dot(ab) / ab.length_squared()
			if t <= 0.0 or t >= 1.0 or (ap - ab * t).length() > 0.00001:
				safe = false
				break
			# Preserve authored UV/paint changes at intermediate corners.
			var prev: int = (i + count - 1) % count
			var next: int = (i + 1) % count
			if face.uv_manual:
				if face.uv_coords.size() != count:
					safe = false
					break
				if face.uv_coords[i].distance_to(face.uv_coords[prev].lerp(face.uv_coords[next], t)) > 0.00001:
					safe = false
					break
			if face.color_corners.size() == count:
				if not face.color_corners[i].is_equal_approx(face.color_corners[prev].lerp(face.color_corners[next], t)):
					safe = false
					break
			incident.append([face, i, count])
		if not safe or neighbors.size() != 2 or incident.is_empty():
			continue
		for entry in incident:
			var face = entry[0]
			var i: int = entry[1]
			var vertices: PackedInt32Array = face.vertices
			vertices.remove_at(i)
			face.vertices = vertices
			if face.uv_coords.size() == entry[2]:
				var uv: PackedVector2Array = face.uv_coords
				uv.remove_at(i)
				face.uv_coords = uv
			if face.color_corners.size() == entry[2]:
				var colors: PackedColorArray = face.color_corners
				colors.remove_at(i)
				face.color_corners = colors
		removed += 1
	if removed > 0:
		UBOpUtils.remove_unused_vertices(data)
	return removed
