Object = require "classic";
require "Rect";
require "Sprite";
require "Animated_Sprite";
require "Player";
require "Enemy";
require "Bullet";
--permanent init values
    standard_dt = 1/60; --60 ticks per seconds
    res_x = 256; res_y = 204; --game resolution
    --love.window.setMode(res_x * 4, res_y * 4, {fullscreen = false});
    love.window.setMode(0, 0, {fullscreen = true});
    two_player = false;

function love.load(arg)
    if(arg ~= nil) then
        if(arg[1] == "2") then
            two_player = true;
        end
    end
    --game init values
    sprites = {};
    bullets = {};
    enemies = {};
    camera = 0;
    lives = 3;
    enemy_percent = 0.01;
    is_gameovered = false;
    hit_enemy = false;
    next_player = 1; --the next player that needs to hit the ball
    music = love.audio.newSource("assets/audio/music.ogg", "stream");
    gameover_music = love.audio.newSource("assets/audio/gameover.ogg", "stream");
    bounce = love.audio.newSource("assets/audio/bounce.wav", "static");
    shoot = love.audio.newSource("assets/audio/shoot.wav", "static");
    hurt = love.audio.newSource("assets/audio/hurt.wav", "static");
    music:setLooping(true);
    music:play();


    screen_width, screen_height = love.graphics.getDimensions(); --dimensions of screen
    scale = screen_height/res_y;
    font = love.graphics.newFont("assets/uni0553.ttf", 96);
    love.graphics.setFont(font);
    font:setFilter("nearest", "nearest");
    load_enemies();

    p1_image = love.graphics.newImage("assets/p1.png");
    p2_image = love.graphics.newImage("assets/p2.png");
    ball_image_right = love.graphics.newImage("assets/signal_right.png");
    ball_image_left = love.graphics.newImage("assets/signal_left.png");
    bullet_image = love.graphics.newImage("assets/bullet.png");
    sky = love.graphics.newImage("assets/sky.png");

    p1_image:setFilter("nearest", "nearest");
    p2_image:setFilter("nearest", "nearest");
    ball_image_right:setFilter("nearest", "nearest");
    ball_image_left:setFilter("nearest", "nearest");
    bullet_image:setFilter("nearest", "nearest");
    sky:setFilter("nearest", "nearest");

    p1 = Player(20, 100, 2, 20, 0, 0, p1_image, 1);
    if(two_player) then
        p2 = Player(236, 100, 2, 20, 0, 0, p2_image, 2);
    else
        p2 = Rect(236, 100, 2, res_y, 0, 0, {.1, .1, .6});
    end
    set_ball();
    ball_lives = {};
    table.insert(ball_lives, Sprite(res_x/2 - 7/2 - 25, res_y - 10, 7, 7, 0, 0, ball_image))
    table.insert(ball_lives, Sprite(res_x/2 - 7/2,  res_y - 10, 7, 7, 0, 0, ball_image))
    table.insert(ball_lives, Sprite(res_x/2 - 7/2 + 25,  res_y - 10, 7, 7, 0, 0, ball_image))


    skybox1 = Sprite(0, 0, 256, 384, 0, 0, sky);
    skybox2 = Sprite(0, -384, 256, 384, 0, 0, sky);

    table.insert(sprites, bg);
    table.insert(sprites, p1);
    table.insert(sprites, p2);
    table.insert(sprites, ball);
end

function love.draw()
    love.graphics.scale(scale, scale);
    camera = -ball:get_y() + res_y/2;

    
    --background    
    skybox1:draw(camera);
    skybox2:draw(camera);

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

    if(not two_player) then
        p2:set_position(p2:get_x(), -camera);
    end
        
    love.graphics.setColor({.5, 1, .5});
    height = string.format("%.0fm", camera + 5);
    font_width = font:getWidth(height) * .15;
    font_height = font:getHeight(height) * .15;
    love.graphics.print(height, res_x/2- font_width/2, res_y - 30, 0, .15, .15);

    for i,v in ipairs(ball_lives) do
        if(i <= lives) then
            v:draw(0);
        end
    end

    if(is_gameovered) then
        text = "Game Over";
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height*3, 0, .15, .15);
        if(hit_enemy) then
            text = string.format("Signal intercepted!");
        else
            text = string.format("Player %s dropped the signal!", next_player);
        end
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height*2, 0, .15, .15);
        text = "Press White to restart.";
        font_width = font:getWidth(text) * .15;
        font_height = font:getHeight(text) * .15;
        love.graphics.print(text, res_x/2- font_width/2, res_y - 30 - font_height, 0, .15, .15);
    end
end

function love.update(dt)
    dt_diff = dt/standard_dt;

    if(not is_gameovered) then
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
    --lives
    if(lives <= 0) then
        gameover()
    end
    --managing objects  
    manage_enemies(dt_diff);
    manage_entities(dt_diff);
    manage_skybox(dt_diff);

    --speeding up ball
    ball:set_dx(ball:get_dx()*1.0005);
    ball:set_dy(ball:get_dy()*1.0005);
    if(p1:check_collision(ball)) then
        ball:set_dx(-ball:get_dx());
        ball:set_position(p1:get_x() + p1:get_width() + 1, ball:get_y());
        ball:set_image(ball_image_right);
        next_player = 2;
        bounce:play();
    elseif(p2:check_collision(ball)) then
        ball:set_dx(-ball:get_dx());
        ball:set_position(p2:get_x() - ball:get_width() - 1, ball:get_y());
        ball:set_image(ball_image_left);
        next_player = 1;
        bounce:play();
    end
end

function reset_ball()    
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
    ball:set_position(res_x/2, ball:get_y());
    ball:set_dx(ballspeed);
    ball:set_dy(-0.2);
    ball:set_image(ball_image);
end

function set_ball()
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
    ball = Sprite(res_x/2, 100, 7, 7, ballspeed, -0.2, ball_image);
end


function manage_entities(dt_diff)
    --managing bullets
    for i,v in ipairs(bullets) do
        if(v:get_x() > res_x or v:get_x() + v:get_width() < 0) then
            v:die();
            table.remove(bullets, i);
        end
    end
    if(ball:get_x() > res_x or ball:get_x() + ball:get_width() < 0) then
        lives = lives - 1
        hurt:play();
        reset_ball();
    end
end



function manage_enemies(dt_diff)
    --spawning enemies
    rand = love.math.random();
    if(rand < enemy_percent) then
        position = res_x/2 - 50 + love.math.random(100);
        type = math.floor(love.math.random(4));
        new_enemy = Enemy(position, -camera, 10, 10, 0, 0, type);
        table.insert(enemies, new_enemy);
    end

    --enemy collisions
    for i,v in ipairs(enemies) do
        if(ball:check_collision(v)) then
            lives = lives - 1;
            hurt:play();
            table.remove(enemies, i);
            hit_enemy = true;
        end
        for k,w in ipairs(bullets) do
            if(v:check_collision(w)) then
                table.remove(enemies, i);
            end
        end
    end
end

function manage_skybox(dt_diff)
    --moving skybox
    if(skybox1:get_y() - skybox1:get_height() > -camera) then
        skybox1:move(0, -skybox1:get_height());
    end
    if(skybox2:get_y() > -camera) then
        skybox2:move(0, -skybox2:get_height());
    end
    
end

function love.keypressed(key)
    if(is_gameovered) then
        if(key == 'e' or (key == 'u' and two_player)) then
            gameover_music:stop();
            love.load();
        end
    elseif(key == 'f') then
        p1:shoot();
    elseif(key == 'h' and two_player) then
        p2:shoot();
    end
    if(key == '/') then
        love.event.quit() 
    end
end

function gameover()
    ball:die();
    is_gameovered = true;
    music:stop();
    gameover_music:play();
end