
    function jump_ease(){
        return this.time()*this.time()*(2- this.time()*this.time())
    }

 window.onload = function() {
    Crafty.init(600, 400);
    Crafty.bind("BackgroundClick", function(){Crafty.trigger("KeyDown")})
    Crafty.timer.steptype("variable");
    Crafty.pixelart(false);
    Crafty.timer.FPS(50);
    Crafty.scene("play", startgame);
    Crafty.load(
    {
        "sprites":{
            "runner.png": {
                tile:200, 
                tileh:200, 
                map:{
                    runstart: [0,0],
                }
            },
            "sprite_sheet.png": {
                tile: 25,
                tileh: 25, 
                map:{
                    spike: [0, 0],
                    coin: [1, 0]
                }
            }
        },
        "images":["images/Trees1.PNG", "images/Trees2.PNG", "images/Trees3.PNG", "images/Trees4.PNG"]
    }, function(){Crafty.scene("play")});
 }


 function makePlayer(){
     var jm = Crafty.e("Player, 2D, Foreground, runstart, Fourway, SpriteAnimation")
        //.color("blue")
        .attr({x:200, y:200, h:50, w:50})
        .origin(25, 25)
        .bind("KeyDown", function(){
            if (this.y > 199){
                this.tween({y: 50, rotation:180}, 1000/VELOCITY, jump_ease);
                this._flipX = true;
            } else if (this.y < 51) {
                this.tween({y: 200, rotation:0}, 1000/VELOCITY, jump_ease);
                this._flipX = false;
            }
        }).bind("EnterFrame", function(){
            this.animationSpeed = VELOCITY/3;
            if (this.hit("Goomba")){
                //window.alert('Dead!  Score: ' + coin_count);
                deathNote();
                this.destroy();
            }
        }).reel("running", 500, [ 
            [0, 0], [1, 0], [2, 0],
            [0, 1], [1, 1], [2, 1],
            [0, 2], [1, 2] 
          ])
        .animate("running", -1)
        .collision(new Crafty.polygon([10, 0, 35, 0, 25, 50, 20, 50]));
        

    Crafty.sprite(200, 200, "runner.png", {
        runstart: [0,0],
        runmid: [0, 1]
    });
    return jm;
 }

 function startgame(){
    coin_count = 0;
    VELOCITY = 3;

    
    
    Crafty.createLayer("Background", "WebGL", {z: 10, xResponse: .2});
    Crafty.createLayer("Midground", "WebGL", {z: 15, xResponse: .4});
    Crafty.createLayer("Foreground", "WebGL", {z: 20, xResponse: .8});
    Crafty.createLayer("UI", "DOM", {
        xResponse: 0, yResponse:0, scaleResponse:0, z: 50
    });
    Crafty.createLayer("ActionLayer", "WebGL", {z: 25, xResponse: 1});

    // Sun layer
    Crafty.e("2D, Background, Image")
        .image("images/Trees1.PNG")
        .attr({x:0, y:0, h:400, w:1800});
    Crafty.e("2D, Midground, Image")
        .image("images/Trees2.PNG")
        .attr({x:0, y:0, h:400, w:1800});
    Crafty.e("2D, Midground, Image")
        .image("images/Trees2.PNG")
        .attr({x:1800, y:0, h:400, w:1800});
        
    Crafty.e("2D, Foreground, Image")
        .image("images/Trees3.PNG")
        .attr({x:0, y:0, h:400, w:1800});
    Crafty.e("2D, Foreground, Image")
        .image("images/Trees3.PNG")
        .attr({x:1800, y:0, h:400, w:1800});
    
    Crafty.e("2D, ActionLayer, Image")
        .image("images/Trees4.PNG")
        .attr({x:0, y:0, h:400, w:1800});
    Crafty.e("2D, ActionLayer, Image")
        .image("images/Trees4.PNG")
        .attr({x:1800, y:0, h:400, w:1800});
       
    //Crafty.viewport.pan(1800, 0, 6000);

    var player = Crafty.e("2D, ActionLayer, Color, Fourway")
        .attr({x: 200, y: 120, w: 50, h: 50})
        .color("red")
        .fourway(200);
    // var ground = Crafty.e("2D, ActionLayer, Color")
    //     .attr({x:0, y:170, w:2*1800, h:50}).color("brown");
        
    Crafty.viewport.follow(player);
    Crafty.e("2D, UI, Text")
        .textColor("white")
        .textFont({size: '20px', family:'Arial'})
        .attr({x: 100, y: 300, w: 200})
        .bind("EnterFrame", function(){
            this.text("Distance: " + Math.floor(Math.abs(Crafty.viewport.x)));
        })
        
    
};



