Rect = Object:extend();

function Rect:new(x, y, width, height, dx, dy, color)
    self.x = x;
    self.y = y;
    self.width = width;
    self.height = height;
    self.dx = dx or 0;
    self.dy = dy or 0;
    self.color = color;
    self.static = false;
    self.alive = true;
end

function Rect:set_position(x, y)
    self.x = x;
    self.y = y;
end

function Rect:tick(dt_diff)
    if(self.alive) then
        self:move(self.dx * dt_diff, self.dy * dt_diff);
    end
end

function Rect:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy;
end

function Rect:get_x()
    return self.x;
end

function Rect:get_y()
    return self.y;
end

function Rect:get_dx()
    return self.dx;
end

function Rect:get_dy()
    return self.dy;
end

function Rect:set_dx(dx)
    self.dx = dx;
end

function Rect:set_dy(dy)
    self.dy = dy;
end

function Rect:get_width()
    return self.width;
end

function Rect:get_height()
    return self.height;
end

function Rect:set_color(color)
    self.color = color;
end

function Rect:get_color(color)
    return self.color;
end

function Rect:set_static(static)
    self.static = static;
end

function Rect:die()
    self.alive = false
end

function Rect:draw(camera)
    if(self.alive) then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1);
        if(self.static) then
            camera = 0;
        end
        self:draw_specific(camera);
    end
end

function Rect:draw_specific(camera)
    love.graphics.rectangle("fill", self:get_x(), self:get_y() + camera, self:get_width(), self:get_height());
end

function Rect:check_collision(Rect)
    if( self:get_x() < Rect:get_x() + Rect:get_width() and
        self:get_x() + self:get_width() > Rect:get_x() and
        self:get_y() < Rect:get_y() + Rect:get_height() and
        self:get_y() + self:get_height() >  Rect:get_y()) then
        return true;
    end
    return false;
end