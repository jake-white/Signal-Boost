Animated_Sprite = Sprite:extend();

function Animated_Sprite:new(x, y, width, height, dx, dy, images)
    self.images = images;
    Animated_Sprite.super.new(self, x, y, width, height, dx, dy, self.images[1])
end