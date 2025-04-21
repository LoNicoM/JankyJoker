-- Disable graphics and display window as this is console only for now --

function love.conf(c)
    c.window = nil
    c.graphics = nil
end