Enemy = Sprite:extend();
function load_enemies()    
    enemy_types = {"assets/enemy.png", "assets/enemy_2.png"};
    enemy_images = {};
    for i,v in ipairs(enemy_types) do
        new_enemy = love.graphics.newImage(v);
        new_enemy:setFilter("nearest", "nearest");
        table.insert(enemy_images, new_enemy);
    end
end


function Enemy:new(x, y, width, height, dx, dy, type)
    Enemy.super.new(self, x, y, width, height, dx, dy, enemy_images[type])
    if(self:get_x() + self:get_width()/2 > res_x/2) then
        self.dx = -1;
        self:set_rotation(3*math.pi/2)
    else
        self.dx = 1;
        self:set_rotation(math.pi/2);
    end
end

function Enemy:tick(diff_dt)
    if(self:get_x() + self:get_width()/2 < res_x/4) then
        self.dx = 1;
        self:set_rotation(math.pi/2);
    elseif(self:get_x() + self:get_width()/2 > 3*res_x/4) then
        self.dx = -1;
        self:set_rotation(3*math.pi/2);
    end
    
    Enemy.super.tick(self, diff_dt)
end