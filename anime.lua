--------------------------------------------------------------------------------
------ anime.lua Copyright (C) 2012 Miguel F. Released under MIT license. ------
--------------------------------------------------------------------------------
local graphics = love.graphics
local time = love.timer

local animations = {}
local imgCache = {}

animationInstance = {
    new = function(name)
        if type(name) == 'string' then
            return {
                type = 'animation',
                id = name,
                
                setAnimation = function(self, name, playPrev)
                    if type(name) == 'string' then
                        if not playPrev == true then anime.stop(self.id) end 
                        self.id = name 
                        anime.play(name)
                    end
                end
            }
        end
    end,
}

anime = {}

function anime.define(name, img, frames, settings)
    if type(name) == 'string' then
        animations[name] = {}
        local anim = animations[name]
            
        if type(img) == 'string' then
            if imgCache[img] then anim.img = imgCache[img] 
            else
             imgCache[img] = graphics.newImage(img) 
             anim.img = imgCache[img]
        end
        else 
            anim.img = img
        end
            
        anim.frames = {}
            
        if type(frames) == 'table' then
            for i, v in ipairs(frames) do
                if type(v) == 'number' then
                    anim.frames[i] = anim.frames[v]
                elseif type(v) == 'table' then 
                    local quad = graphics.newQuad(
                        v.x or v[1],
                        v.y or v[2],
                        v.w or v[3],
                        v.h or v[4],
                        anim.img:getWidth(),
                        anim.img:getHeight()
                    )
                    local duration = v.d or v.duration or v[5]or 1/30
                        
                        
                    anim.frames[i] = {
                        quad = quad,
                        duration = duration 
                    } 
                else
                    error('Bad frame definition received')
                end
            end
                
            local _settings = type(settings) == 'table' and settings or {}
            
            anim.current = 1
            anim.direction = 1
            anim.start = time.getTime()
            anim.sleeping = _settings.noAutoPlay and true or false
            anim.settings = _settings
            
            return animationInstance.new(name)
            
        else error('Incorrect frame definition.') end 
    else
        error('Name of animation must be specified as string.') 
    end
end

function anime.update()
    for k, v in pairs(animations) do
        if not v.sleeping then 
            if time.getTime() - v.start >= v.frames[v.current].duration then
                print(time.getTime() - v.start, v.current)
                
                if v.frames[v.current + v.direction] then
                    v.current = v.current + v.direction
                    v.start = time.getTime()
                else
                    if v.settings.mode == 'loop' then
                        v.current = 1 
                        v.start = time.getTime()
                    elseif v.settings.mode == 'bounce' then
                        v.direction = v.direction * -1
                        v.current   = v.current + v.direction
                        v.start = time.getTime()
                    else
                        v.current = 1
                        v.sleeping = true
                    end
                end
            end
        end
    end
end


function anime.draw(a, x, y, r, sx, sy, ox, oy, shx, shy)
    local anim = type(a) == 'string' and animations[a] or animations[a.id] 
    
    graphics.drawq(
        anim.img,
        anim.frames[anim.current].quad,
        x,
        y,
        r,
        sx,
        sy,
        ox,
        oy,
        shx,
        shy
    )
end

function anime.stop(name)
    if type(name) == 'string' then
        local anim = animations[name]
        
        anim.current = 1
        anim.sleeping = true 
    end
end

function anime.pause(name)
    if type(name) == 'string' then
        animations[name].sleeping = true 
    end
end

function anime.play(name)
    if type(name) == 'string' then
        animations[name].sleeping = false 
    end
end

function anime.reset(name)
    if type(name) == 'string' then
        animations[name].current = 1 
    end
end

--[[NOTE:
        To make this convinient, anime's default behavior is to override the 
        default love.graphics.draw() and add support for directly drawing 
        animations. This behavior is fully optional, but is highly recommended.
        Removing it is as simple as commenting out the rest of the file.
]]
local oldDraw = graphics.draw

function graphics.draw(obj, x, y, r, sx, sy, ox, oy, kx, ky)
    if type(obj) == 'table' and obj.type == 'animation' then
        anime.draw(obj, x, y, r, sx, sy, ox, oy, kx, ky)
    else
        oldDraw(obj, x, y, r, sx, sy, ox, oy, kx, ky)
    end 
end
