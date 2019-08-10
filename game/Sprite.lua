Sprite = Rect:extend();

function Sprite:new(x, y, width, height, dx, dy, image, rotation)
    Sprite.super.new(self, x, y, width, height, dx, dy, {1,1,1})
    self:set_image(image);
    self.rotation = rotation or 0;
end

function Sprite:draw_specific(camera)
    scale_x = self:get_width()/self.image:getWidth();
    scale_y = self:get_height()/self.image:getHeight();
    love.graphics.draw(self.image, self:get_x() + self:get_width()/2, self:get_y() + self:get_height()/2 + camera, self.rotation, 1, 1, self:get_width()/2, self:get_height()/2);
end

function Sprite:rotate(dr)
    self.rotation = self.rotation + dr;
end

function Sprite:set_rotation(rotation)
    self.rotation = rotation;
end

function Sprite:set_image(image)
    self.image = image;
end