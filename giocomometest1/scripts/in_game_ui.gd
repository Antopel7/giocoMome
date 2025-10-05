extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.aggiorna_ui.connect(_on_aggiorna)

func _on_aggiorna(valore):
	$LabelCalorometro.text = str(valore)
