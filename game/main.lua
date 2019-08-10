Object = require "classic";
require "Rect";
require "Sprite";
require "Player";
require "Enemy";
require "Bullet";
--permanent init values
    standard_dt = 1/60; --60 ticks per seconds
    res_x = 256; res_y = 192; --game resolution
    love.window.setMode(res_x * 4, res_y * 4, {fullscreen = false});

function love.load()
    --game init values
    sprites = {};
    bullets = {};
    enemies = {};
    camera = 0;
    bgcolor = {.75, .92, .93, 1};
    enemy_percent = 0.01;
    gameover = false;
    hit_enemy = false;
    next_player = 1; --the next player that needs to hit the ball


    screen_width, screen_height = love.graphics.getDimensions(); --dimensions of screen
    scale = screen_width/res_x;
    font = love.graphics.newFont("assets/uni0553.ttf", 96);
    love.graphics.setFont(font);
    font:setFilter("nearest", "nearest");
    load_enemies();

    p1_image = love.graphics.newImage("assets/p1.png");
    p2_image = love.graphics.newImage("assets/p2.png");
    ball_image_right = love.graphics.newImage("assets/signal_right.png");
    ball_image_left = love.graphics.newImage("assets/signal_left.png");
    bullet_image = love.graphics.newImage("assets/bullet.png");
    p1_image:setFilter("nearest", "nearest");
    p2_image:setFilter("nearest", "nearest");
    ball_image_right:setFilter("nearest", "nearest");
    ball_image_left:setFilter("nearest", "nearest");
    bullet_image:setFilter("nearest", "nearest");

    p = love.math.random(2);
    if(p == 1) then
        ballspeed = .7;
        next_player = 2;
        ball_image = ball_image_right;
    else
        ballspeed = -.7;
        next_player = 1;
        ball_image = ball_image_left;
    end
    p1 = Player(20, 100, 2, 20, 0, 0, p1_image, 1);
    p2 = Player(236, 100, 2, 20, 0, 0, p2_image, 2);
    ball = Sprite(res_x/2, 100, 7, 7, ballspeed, -0.2, ball_image);

    table.insert(sprites, bg);
    table.insert(sprites, p1);
    table.insert(sprites, p2);
    table.insert(sprites, ball);
end

function love.draw()
    love.graphics.scale(scale, scale);
    camera = -ball:get_y() + res_y/2;

    
    --background    
    love.graphics.setColor(bgcolor);
    love.graphics.rectangle("fill", 0, 0, res_x, res_y);
    indent = false
    love.graphics.setColor(0.5, 0.5, 0.5, 1);
    for i=0, res_y, 4 do
        indent = not indent
        love.graphics.rectangle("fill", 0, (i + camera)%(res_y + 4) - 4, indent and 2 or 4, 4);
        love.graphics.rectangle("fill", indent and res_x - 2 or res_x - 4, (i + camera)%(res_y + 4) - 4, indent and 2 or 4, 4);
    end
    
    for i,v in ipairs(enemies) do
        if(v:get_y() + v:get_height() + camera > 0 and v:get_y() + camera < res_y) then
            v:draw(camera);
        end
    end

    for i,v in ipairs(bullets) do
        if(v:get_y() + v:get_height() + camera > 0 and v:get_y() + camera < res_y) then
            v:draw(camera);
        end
    end

    for i,v in ipairs(sprites) do
        if(v:get_y() + v:get_height() + camera > 0 and v:get_y() + camera < res_y) then
            v:draw(camera);
        end
    end
        
    love.graphics.setColor({0, 0, 0});
    height = string.format("%.0fm", camera + 5);
    font_width = font:getWidth(height) * .15;
    font_height = font:getHeight(height) * .15;
    love.graphics.print(height, res_x/2- font_width/2, res_y - 30, 0, .15, .15);

    if(gameover) then
        text = "Game Over";
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height*3, 0, .15, .15);
        if(hit_enemy) then
            text = string.format("An enemy intercepted the message!");
        else
            text = string.format("Player %s dropped the signal!", next_player);
        end
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height*2, 0, .15, .15);
        text = "Press Red to restart.";
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height, 0, .15, .15);
    end
end

function love.update(dt)
    dt_diff = dt/standard_dt;

    if(not gameover) then
        for i,v in ipairs(sprites) do
            v:tick(dt_diff);
        end

        for i,v in ipairs(enemies) do
            v:tick(dt_diff);
        end

        for i,v in ipairs(bullets) do
            v:tick(dt_diff);
        end

        logic(dt_diff);
    else --not gameovered

    end
end

function logic(dt_diff)
    --managing objects  
    manage_enemies(dt_diff);
    manage_entities(dt_diff);

    --changing sky color
    color_change = 1 - (0.0001*dt_diff);
    bgcolor = {bgcolor[1]*color_change, bgcolor[2]*color_change, bgcolor[3]*color_change};

    --speeding up ball
    ball:set_dx(ball:get_dx()*1.001);
    ball:set_dy(ball:get_dy()*1.001);
    if(p1:check_collision(ball)) then
        ball:set_dx(-ball:get_dx());
        ball:set_position(p1:get_x() + p1:get_width() + 1, ball:get_y());
        ball:set_image(ball_image_right);
        next_player = 2;
    elseif(p2:check_collision(ball)) then
        ball:set_dx(-ball:get_dx());
        ball:set_position(p2:get_x() - ball:get_width() - 1, ball:get_y());
        ball:set_image(ball_image_left);
        next_player = 1;
    end
end

function manage_entities(dt_diff)
    --managing bullets
    for i,v in ipairs(bullets) do
        if(v:get_x() > res_x or v:get_x() + v:get_width() < 0) then
            v:die();
            table.remove(bullets, i);
            print("Bullet died.");
        end
    end
    if(ball:get_x() > res_x or ball:get_x() + ball:get_width() < 0) then
        ball:die();
        gameover = true;
    end
end



function manage_enemies(dt_diff)
    --spawning enemies
    rand = love.math.random();
    if(rand < enemy_percent) then
        position = res_x/2 - 50 + love.math.random(100);
        type = math.floor(love.math.random(2));
        new_enemy = Enemy(position, -camera, 10, 10, 0, 0, type);
        table.insert(enemies, new_enemy);
    end

    --enemy collisions
    for i,v in ipairs(enemies) do
        if(ball:check_collision(v)) then
            ball:die();
            gameover = true;
        end
        for k,w in ipairs(bullets) do
            if(v:check_collision(w)) then
                table.remove(enemies, i);
            end
        end
    end
end

function love.keypressed(key)
    if(gameover and (key == 'f' or key == 'h')) then
        love.load();
    elseif(key == 'f') then
        p1:shoot();
    elseif(key == 'h') then
        p2:shoot();
    end
end