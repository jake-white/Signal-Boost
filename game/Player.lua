Player = Sprite:extend();

function Player:new(x, y, width, height, dx, dy, image, num)
    Player.super.new(self, x, y, width, height, dx, dy, image)
    self.num = num
    self.cooldown = 0;
end

function Player:tick(dt_diff)
    Player.super.tick(self, dt_diff);
    if(self.num == 1) then --player 1
        if love.keyboard.isDown("w") then
            self:move(0, -2 * dt_diff);
        elseif love.keyboard.isDown("s") then
            self:move(0, 2 * dt_diff);
        end
    elseif(self.num == 2) then --player 2
        if love.keyboard.isDown("i") then
            self:move(0, -2 * dt_diff);
        elseif love.keyboard.isDown("k") then
            self:move(0, 2 * dt_diff);
        end
    end
end

function Player:shoot()
    shoot:stop();
    shoot:play();
    speed = 0; rotation = 0;
    if(self.num == 1) then
        speed = 4
        rotation = 0
    elseif(self.num == 2) then
        speed = -4
        rotation = math.pi
    end
    bullet = Bullet(self:get_x() + self:get_width(), self:get_y() + self:get_height()/2, 8, 3, speed, 0, bullet_image, rotation);
    table.insert(bullets, bullet);
end