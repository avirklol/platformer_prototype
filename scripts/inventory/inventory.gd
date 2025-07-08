extends Resource
class_name Item

@xport v

@export var items: Array[Item] = []

func add_item(item: Item):
	items.append(item)

func remove_item(item: Item):
	items.erase(item)
