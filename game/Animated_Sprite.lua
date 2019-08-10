Animated_Sprite = Sprite:extend();

function Animated_Sprite:new(x, y, width, height, dx, dy, images)
    self.images = images;
    self.index = 1;
    self.last_animated = love.timer.getTime();
    Animated_Sprite.super.new(self, x, y, width, height, dx, dy, self.images[self.index]);
end

function Animated_Sprite:tick(diff_dt)
    if(love.timer.getTime() > self.last_animated + 0.1 and self.index < 4) then
        self.last_animated = love.timer.getTime();
        self.index = self.index + 1;
    elseif(love.timer.getTime() > self.last_animated + 0.1) then
        self:die();
    end
end

function Animated_Sprite:draw_specific(camera)
    scale_x = self:get_width()/self.image:getWidth();
    scale_y = self:get_height()/self.image:getHeight();
    love.graphics.draw(self.images[self.index], self:get_x() + self:get_width()/2, self:get_y() + self:get_height()/2 + camera, self.rotation, 1, 1, self:get_width()/2, self:get_height()/2);
end
