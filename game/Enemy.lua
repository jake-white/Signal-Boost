Enemy = Sprite:extend();
function load_enemies()    
    enemy_types = {"assets/enemy.png", "assets/enemy_2.png", "assets/enemy_3.png", "assets/enemy_4.png"};
    enemy_images = {};
    for i,v in ipairs(enemy_types) do
        new_enemy = love.graphics.newImage(v);
        new_enemy:setFilter("nearest", "nearest");
        table.insert(enemy_images, new_enemy);
    end
end


function Enemy:new(x, y, width, height, dx, dy, type)
    Enemy.super.new(self, x, y, width, height, dx, dy, enemy_images[type])
    self.type = type
    if(self.type == 1) then
        if(self:get_x() + self:get_width()/2 > res_x/2) then
            self.dx = -1;
            self:set_rotation(3*math.pi/2)
        else
            self.dx = 1;
            self:set_rotation(math.pi/2);
        end
    elseif(self.type == 2) then
        if(self:get_x() + self:get_width()/2 > res_x/2) then
            self.dx = -0.5;
            self.dy = 0.5;
            self:set_rotation(5*math.pi/4)
        else
            self.dx = 0.5;
            self.dy = 0.5;
            self:set_rotation(-math.pi/4);
        end
    elseif(self.type == 3 or self.type == 4) then
        self.target_x = res_x/2 + love.math.random(-50, 50);
        self.target_y = self:get_y() + love.math.random(30, 50);
    end
end

function Enemy:tick(diff_dt)
    if(self.type == 1) then
        if(self:get_x() + self:get_width()/2 < res_x/4) then
            self.dx = math.abs(self.dx);
            self:set_rotation(math.pi/2);
        elseif(self:get_x() + self:get_width()/2 > 3*res_x/4) then
            self.dx = -math.abs(self.dx);
            self:set_rotation(3*math.pi/2);
        end
    end
    if(self.type == 2) then
        if(self:get_x() + self:get_width()/2 < res_x/4) then
            self.dx = math.abs(self.dx);
            self:set_rotation(-math.pi/4)
        elseif(self:get_x() + self:get_width()/2 > 3*res_x/4) then
            self.dx = -math.abs(self.dx);
            self:set_rotation(5*math.pi/4)
        end
    elseif(self.type == 3) then
        self:rotate(diff_dt*.1);
        self.dx = (self.target_x - self:get_x())/10;
        self.dy = (self.target_y - self:get_y())/10;
    elseif(self.type == 4) then
        self:rotate(diff_dt*.01);
        distance_x = self.target_x - self:get_x();
        distance_y = self.target_y - self:get_y();
        self.dx = (distance_x)/100;
        self.dy = (distance_y)/100;
        if(math.abs(distance_x) < 10 and math.abs(distance_y) < 10) then
            self.target_x = res_x/2 + love.math.random(-50, 50);
            self.target_y = self:get_y() + love.math.random(30, 50);
        end
    end
    Enemy.super.tick(self, diff_dt)
end