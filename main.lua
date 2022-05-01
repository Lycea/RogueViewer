json = require("json")
ui = require("SimpleUi.SimpleUI")


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

--------------------
--color settings

colors = {
  blocking     = {0,0,1},
  non_blocking = {0,1,1},
  entity       = {1,0,0},
  item         = {0,1,0}
}


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



function love.load()
  ui.init()

  ui.SetSpecialCallback( ui.AddCheckbox("show enemies",0,0,false), function() show_enemies = not show_enemies end )
  ui.SetSpecialCallback( ui.AddCheckbox("show items",0,25,false),  function() show_items = not show_items end )

  ui.SetSpecialCallback(ui.AddCheckbox("debug",0,50,false), enable_debug)

  ui.AddSlider(0, --the start vaule
               0, 75, --the position
               100, 30, --size
               0,5) --min max
end


function love.draw()
  love.graphics.rectangle("line",grid_start.x,grid_start.y,1000,1000)

  if mouse_pos.x >= grid_start.x and mouse_pos.y >= grid_start.y then

    x_grid = mouse_pos.x - grid_start.x
    y_grid = mouse_pos.y - grid_start.y

    row   = math.floor( y_grid / pixel_size)
    col   = math.floor( x_grid / pixel_size)

    love.graphics.rectangle("line",grid_start.x + col*pixel_size, grid_start.y +row * pixel_size, pixel_size, pixel_size)
    

  end

  if loaded_file then
    draw_grid()
  end

  ui.draw()
end

function love.update()
  ui.update()
end


function love.filedropped(file)
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
  
end


function love.mousemoved(x,y)
 mouse_pos.x = x
 mouse_pos.y = y
end
