Animated_Sprite = Sprite:extend();

function Sprite:new(x, y, width, height, dx, dy, images)
    Animated_Sprite.super.new(self, x, y, width, height, dx, dy, images[1])
    self.images = images;
end