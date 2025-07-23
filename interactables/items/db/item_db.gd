extends Node
class_name ItemDB

# The string values for the ItemType in the parsed ItemData.
# Used to build the item_db dictionary of dictionaries.
# Ensure that this list of strings reflects the ItemType enum correctly if more item types are added.
const item_type_names: Array[String] = [
	"WEAPON",
	"ARMOR",
	"TOOL",
	"CONSUMABLE",
	"KEY",
	"RESOURCE"
]

var item_db: Dictionary = {}


func _ready() -> void:
    var item_folder_path = "res://interactables/items/"
    var dir = DirAccess.open(item_folder_path)

    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()

        while file_name != "":
            if file_name.ends_with(".tres"):
                var item_path = item_folder_path + file_name
                var item_resource = load(item_path)

                if item_resource is ItemData:
                    var item_type_name = item_type_names[item_resource.type]

                    if not item_db.has(item_type_name):
                        item_db[item_type_name] = {}
                    item_db[item_type_name][item_resource.name] = item_resource
            file_name = dir.get_next()


func get_item(item_type: String = "", item_name: String = "", item_rarity: int = -1) -> ItemData:
    var items_with_rarity: Array[ItemData] = []

    if item_type:
        item_type = item_type.to_upper()
        if item_db.has(item_type):
            if item_name:
                if item_db[item_type].has(item_name):
                    return item_db[item_type][item_name]
            elif item_rarity >= 0:
                for item_data in item_db[item_type].values():
                    if item_data.rarity == item_rarity:
                        items_with_rarity.append(item_data)
                if items_with_rarity:
                    return items_with_rarity.pick_random()
            else:
                return item_db[item_type].values().pick_random()
    elif item_name:
        for type in item_db.keys():
            if item_db[type].has(item_name):
                return item_db[type][item_name]
    elif item_rarity >= 0:
        for type in item_db.keys():
            for item in item_db[type].values():
                if item.rarity == item_rarity:
                    items_with_rarity.append(item)
        if items_with_rarity:
            return items_with_rarity.pick_random()
    else:
        var random_type: String = item_db.keys().pick_random()

        return item_db[random_type].values().pick_random()

    return null
