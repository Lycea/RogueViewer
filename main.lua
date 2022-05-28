json = require("json")
ui = require("SimpleUi.SimpleUI")

--extend the package path to contain rogue for searching lua file includes ...
package.path=package.path..";".."../Rogue/?.lua"
print(package.path)
os.execute("python3 generate_entity_info_loader.py")

infos = require("entity_info_loader")

print(infos)

entity_infos = infos[1]
item_infos = infos[2]

print("\nloaded entities:")
for name, _ in pairs(entity_infos) do
  print("   loaded ",name)
end

print("\nloaded items:")
for name, _ in pairs(item_infos) do
  print("   loaded ",name)
end


mouse_pos ={x=0,y=0}

grid_start={x=250,y=0}
pixel_size = 10




grid= {}
items = {}
entities = {}

loaded_file = nil
debug_view = false

show_enemies = true
show_items = true

show_tile_info = false
edit_tiles = false

--------------------
--color settings

colors = {
  blocking     = {0,0,1},
  non_blocking = {0,1,1},
  entity       = {1,0,0},
  item         = {0,1,0}
}


ui_elements ={
}

moved_tile = {x=0,y=0}
selected_tile={x=0,y=0}


tile_info ={}

clicked = false

function selected_pos()
  if mouse_pos.x >= grid_start.x and mouse_pos.y >= grid_start.y then

    x_grid = mouse_pos.x - grid_start.x
    y_grid = mouse_pos.y - grid_start.y

    moved_tile.y   = math.max( math.floor( y_grid / pixel_size) , 0)
    moved_tile.x   = math.max( math.floor( x_grid / pixel_size) , 0)
  end
end



function get_tile_info(selected)
  tile_info ={}
  tile_info["entities"] = {}
  tile_info["items"] = {}
  tile_info["block"] = {}

  entity_info =""
  for _,entity in pairs(entities) do
      if entity.x == selected.x and entity.y == selected.y  then
          entity_info= entity.name.." "
          if entity.fighter then
            entity_info= entity_info.."hp("..entity.fighter.hp..")"
            entity_info= entity_info.." ".."max_hp("..entity.fighter.max_hp..")"
            entity_info= entity_info.." ".."power("..entity.fighter.power..")"
            entity_info= entity_info.." ".."def("..entity.fighter.defense..")"
          end
          table.insert(tile_info["entities"], entity_info)
      end
      
      entity_info = ""
  end

  item_info = ""
  for _,item in pairs(items) do
    if item.x == selected.x and item.y == selected.y then
      item_info = item.name .." "
      table.insert(tile_info["items"],item_info)
    end
  end
end




function reset_grid()
  grid = nil
  grid = {}

  entities = {}
  items    = {}
end

function enable_debug()
  debug_view = not debug_view
end

function enable_entity_info()
end

function draw_grid()
  for id, tile in pairs(grid) do
    if tile.state == "wall" then
      love.graphics.setColor(unpack(colors.blocking))
      love.graphics.rectangle("fill",grid_start.x + tile.x * pixel_size, grid_start.y + tile.y * pixel_size, pixel_size, pixel_size)
    elseif tile.state == "floor" then
      love.graphics.setColor(unpack(colors.non_blocking))
      love.graphics.rectangle("fill",grid_start.x + tile.x * pixel_size, grid_start.y + tile.y * pixel_size, pixel_size, pixel_size)
    end
  end

  if show_items then
    for id, item in pairs(items) do
      love.graphics.setColor(unpack(colors.item))
      love.graphics.rectangle("fill",grid_start.x + item.x * pixel_size, grid_start.y + item.y * pixel_size, pixel_size, pixel_size)
    end
  end

  if show_enemies then
    for id, enemy in pairs(entities) do
      love.graphics.setColor(unpack(colors.entity))
      love.graphics.rectangle("fill",grid_start.x + enemy.x * pixel_size, grid_start.y + enemy.y * pixel_size, pixel_size, pixel_size)
    end
  end
end


function draw_tile_info()
  y = 300
  for name, infos in pairs(tile_info) do
    love.graphics.print(name,10,y)
    for k,value in pairs(infos ) do
      --print(k,value)
      love.graphics.print(value,30,y+20)
      y=y+20
    end
    y=y+20
  end
end

function mode_value_change(new_value)
  --print("val cahge to:  "..new_value)
  if new_value == "mob" then
    ui.SetVisibiliti(ui_elements.mob_spinner,true)
    ui.SetVisibiliti(ui_elements.item_spinner,false)

  elseif new_value == "item" then
    ui.SetVisibiliti(ui_elements.mob_spinner,false)
    ui.SetVisibiliti(ui_elements.item_spinner,true)

  else
    ui.SetVisibiliti(ui_elements.mob_spinner,false)
    ui.SetVisibiliti(ui_elements.item_spinner,false)
  end
end


function init_mode_slider()
  mode_slider = ui.AddSlider(0, --the start vaule
  0, 125, --the position
  100, 30, --size
  0,5) --min max


  ui_elements.mode_slider = mode_slider

  slider_obj = ui.GetObject(mode_slider)
  slider_obj.setPrecision(slider_obj, 0)
  slider_obj.setCustomLabels(slider_obj,{[0] = "delete","wall","floor","mob","item" , "stairs"})

  ui.AddGroup({ui_elements.mode_slider},"edit slider",false)

  ui.SetEventCallback(mode_slider, mode_value_change, "onChange")
end



function love.load()
  if pcall(require, "lldebugger") then
	  debuger = require("lldebugger") 
	  debuger.on = stub_function--debuger.start
	  debuger.off = stub_function--debuger.stop
end
debuger.start()



  ui.init()

  ui.SetSpecialCallback( ui.AddCheckbox("show enemies",0,0,false), function() show_enemies = not show_enemies  end )
  ui.SetSpecialCallback( ui.AddCheckbox("show items",0,25,false),  function() show_items = not show_items end )
  ui.SetSpecialCallback( ui.AddCheckbox("show tile info",0,50,false),  function() show_tile_info = not show_tile_info end )
  ui.SetSpecialCallback( ui.AddCheckbox("edit tiles",0,75,false),  
          function() 
            edit_tiles = not edit_tiles
            ui.SetGroupVisible("edit slider", edit_tiles) 
          end )

  ui.SetSpecialCallback(ui.AddCheckbox("debug",0,100,false), enable_debug)
          
  init_mode_slider()
  
  mob_list ={}
  item_list ={}
  for key ,_ in pairs(entity_infos) do   table.insert( mob_list,key )end
  for key ,_ in pairs(item_infos) do   table.insert( item_list,key )end

  ui_elements.mob_spinner  = ui.AddSpinner(mob_list  , 0, 150, 50,50)
  ui.SetVisibiliti(  ui_elements.mob_spinner ,false)
  ui_elements.item_spinner = ui.AddSpinner(item_list ,0, 175, 50,50)
  ui.SetVisibiliti(  ui_elements.item_spinner ,false)
end


function love.draw()
  love.graphics.rectangle("line",grid_start.x,grid_start.y,1000,1000)

  
  
  love.graphics.rectangle("line",grid_start.x + moved_tile.x * pixel_size,
                                 grid_start.y + moved_tile.y * pixel_size,
                                 pixel_size, pixel_size)
  
  love.graphics.rectangle("line",grid_start.x + selected_tile.x * pixel_size,
                                 grid_start.y + selected_tile.y * pixel_size,
                                 pixel_size, pixel_size)



  if show_tile_info then
    draw_tile_info()
  end

  if loaded_file then
    draw_grid()
  end

  ui.draw()
end



-------------------------------------------
--  EDIT HELPER FUNCTIONS
-------------------------------------------

function delete_tile()
  ui.SetVisibiliti(ui_elements.mob_spinner,false)
  ui.SetVisibiliti(ui_elements.item_spinner,false)

  print("delete")
  
  --check if we have an item or an entity on the field
  for i, entity in pairs(entities) do
    if entity.x == selected_tile.x and entity.y == selected_tile.y then
      print("removed entity")
        entities[i] = nil
      return 
    end
  end

  for i ,item in pairs(items) do
    if item.x == selected_tile.x and item.y == selected_tile.y then
      print("removed item")
      items[i] = nil
      return
    end
  end

  for id,tile in pairs(grid) do
    if tile.x == selected_tile.x and tile.y == selected_tile.y then
      print("removed tile")
      grid[id] = nil
    end
  end

end

function add_tile( selected_mode )

  
end

function edit_tile( )
  ui.SetVisibiliti(ui_elements.mob_spinner,false)
  ui.SetVisibiliti(ui_elements.item_spinner,false)

  print("edit")
end


flu_tile_editing ={
  delete = delete_tile,
  edit   = edit_tile,
  _meta  = {
    __index = function() return add_tile end
  }
}

setmetatable(flu_tile_editing, flu_tile_editing._meta)



function handle_tile_editing()
  
  selected_mode = ui.GetValue( ui_elements.mode_slider)
  flu_tile_editing[ selected_mode ](selected_mode)
end




-------------------------------------------
--   MAIN CALLBACKS
-------------------------------------------


function love.update()
  if edit_tiles and clicked then
    --first check what to do

    if mouse_pos.x >= grid_start.x then
      handle_tile_editing()   
    end

    clicked = false
  end


  ui.update()
end


function love.filedropped(file)

  items    = {}
  entities = {}

  print(file:getFilename(),string.find( file:getFilename() ,".json" ))

  if string.find( file:getFilename() ,".json" ) then

    loaded_file = file:getFilename()
    file:open("r")
    
    save_file = json.decode(file:read())

    if save_file["map"] ~= nil then
      for _, tile in pairs(save_file.map.tiles) do
        if tile.blocked == true then
          tile.state = "wall"  
          table.insert(grid,tile)
        else
          tile.state = "floor" 
          table.insert(grid,tile)
        end
      end
    end

    --load up entities
    if save_file["entities"] ~= nil then
      for id, entity in pairs(save_file.entities) do
        if entity.item then
          entity.state = "item"
          table.insert(items,entity)
        else
          entity.state = "entity"
          table.insert(entities, entity)
        end
      end
    end
  else

  end
end

function love.mousepressed(x,y,btn)
  selected_tile.x,selected_tile.y = moved_tile.x,moved_tile.y

  get_tile_info(selected_tile)

  clicked = true
end


function love.mousemoved(x,y)
 mouse_pos.x = x
 mouse_pos.y = y

 selected_pos()
end
