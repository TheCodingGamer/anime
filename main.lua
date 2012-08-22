--[[
    Simple example of using the anime library. Released into the public domain.
--]]
require 'anime'

function love.load()
    betty = anime.define(
        'betty_walking_down',
        'betty.png', 
        {
            { x = 5, y = 10, w = 45, h = 45, d = .45 },
            { 5, 60, 45, 45, .45 },
            1,
            { 5, 153, 45, 45, .45 }
        },
        {
            mode = 'loop'
        }
    )
    
    betty = anime.define(
        'betty_walking_up',
        'betty.png',
        {
            
            { 103, 60, 45, 45, .45},
            { 103, 10, 45, 45, .45},
            { 103, 153, 45, 45, .45}
        },
        {
            mode = 'bounce', noAutoPlay = false
        }
    )
end

function love.draw()
    love.graphics.draw(betty, 10, 10)
end

function love.update(dt)
    anime.update()
end

function love.keypressed(key)
    if key == 'down' then
        betty:setAnimation('betty_walking_down')
    elseif key == 'up' then
        betty:setAnimation('betty_walking_up')
    end
end
