extends StaticBody3D

@export_multiline var paper_text = "Hello World"

func interaction_text() -> String:
	return "[E] Investigar armário"

func interact(player: Node3D) -> void:
	player.show_paper(paper_text)
