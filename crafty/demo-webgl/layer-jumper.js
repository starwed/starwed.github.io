
    function jump_ease(){
        return this.time()*this.time()*(2- this.time()*this.time())
    }

 window.onload = function() {
    Crafty.init(600, 300);
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
        }
    }, function(){Crafty.scene("play")});
 }


 function startgame(){
    coin_count = 0;
    VELOCITY = 3;

    Crafty.createLayer("Foreground", "WebGL", {z: 20});
    Crafty.createLayer("Background", "WebGL", {z: 10, xResponse: 2});
    Crafty.createLayer("UI", "DOM", {
        xResponse: 0, yResponse:0, scaleResponse:0, z: 50
    });

    //Crafty.background('rgb(127,127,127)');
    
    //Ground
    Crafty.e("2D, WebGL, Color")
        .color("brown")
        .attr({x:0, y:250, h:50, w:600});
    



    //Jumpman

    var jm = Crafty.e("Player, 2D, Foreground, runstart, Keyboard, Tween, Collision, SpriteAnimation")
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
    })


    Crafty.c("Height", {
        
    });

    Crafty.c("Thing", {
        init: function(){
            this.requires("2D");
            this.bind("EnterFrame", this._onEnterFrame);
        },
        _onEnterFrame: function(frameData){
            this.x -= VELOCITY * frameData.dt / 20;
            if (this.x<0){
                this.trigger("OffLeft")
                this.destroy();
            }
        },
        setHeight: function(level){
            if (level === "up"){
                this.y = 50;
                this._flipY = true;
            } else {
                this.y = 250 - this.h;
                this._flipY = false;
            }
        }
    });
    


    Crafty.c("Spike", {
        init: function(){
            this.requires("Thing, spike")
            //this.color("red")
            .attr({h:30, w:25, x:600});
            goomba_number++;
        },
        remove: function(){
            goomba_number--;
        }
    });

    Crafty.c("Coin", {
        init: function(){
            this.requires("Thing, coin")
            //this.color("yellow")
            this.attr({h:40, w:40, x:600});
            this.bind("EnterFrame", this._checkHits);
            this.bind("OffLeft", this._offLeft)
        },

        _offLeft: function(){

        },

        _checkHits: function(){
            if (this.hit("Player")){
                coin_count++;
                VELOCITY*=1.05;
                this.destroy();
            }
        }
    });



    Crafty.bind("EnterFrame", spawnGoomba);
    //Crafty.bind("BackgroundClick", function(){jm.trigger("KeyDown")} );
    
};


var VELOCITY = 4;
var goomba_number = 0;
var coin_count = 0;
var last_spawn = 0;
var last_coin_spawn = 0;
function spawnGoomba(frame_info){
    var cf = frame_info.gameTime;
    if ( (cf - last_coin_spawn) * VELOCITY < 50*20) return;
    if ( (cf - last_spawn) * VELOCITY < 50*20) return;
    
    if (Math.random() < .02) {
        if ( (cf - last_coin_spawn) * VELOCITY < 100 * 20) return;
        last_coin_spawn = cf;
        if (Math.random() < 0.5 )
            Crafty.e("Coin").setHeight("down");
        else
            Crafty.e("Coin").setHeight("up");
        return;
    }

    if ( (cf - last_spawn) * VELOCITY < 150 * 20) return;
    //console.log("cf is " + cf + "and last is " + last_spawn );
    var rand = Math.random();

    if (rand < .1){
        last_spawn = cf;
        Crafty.e("Goomba").setHeight("up")
    } else if (rand > 0.9)  {
        last_spawn = cf;
        Crafty.e("Goomba").setHeight("down")
    }

}

Crafty.c("Note", {
    init: function(){
        this.requires("2D, DOM, Text")
        this.textFont({size: "30px", family:'Arial'});
    }
})

function deathNote(){
    Crafty.e("2D, UI, Color")
        .attr({x:25, y:25, w:550, h:250, alpha:0.8, z:100})
        .color("white");

    Crafty.e("Note")
        .text("You died!")
        .attr({x:200, y:100, w: 300})

    Crafty.e("Note")
        .text("Score: " + coin_count)
        .attr({x:200, y:150, w: 300})

    Crafty.e("Delay").delay(
        function(){
            Crafty.e("Note")
                .text("Hit any key to restart")
                .attr({x:200, y:200, w: 300})
                .textFont({size: "20px", family:'Arial'});
                
            Crafty.one("KeyDown", function(){Crafty.scene("play");});

        }, 500, 0);


}