import os


boilerplate = """
local enemy_list ={}
local item_list  ={}


function load_entity(insert_table, path)
    local tmp_entity = require(path)
    
    insert_table[ tmp_entity.name ] = tmp_entity
end


"""



with open("entity_info_loader.lua","w") as fh:
    fh.write(boilerplate)

    fh.write("\n--loading enemies")
    for file in os.listdir("../Rogue/generated/enemies"):
        fh.write("load_entity( enemy_list, \"generated.enemies."+file.replace(".lua","")+"\")\n")


    fh.write("\n--loading items\n")
    for file in os.listdir("../Rogue/generated/items"):
        fh.write("load_entity( item_list, \"generated.items."+file.replace(".lua","")+"\")\n")

    fh.write("\nreturn {enemy_list, item_list}")