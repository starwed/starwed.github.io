 function run(){

      Crafty.sprite(200, 200, "runner.png", {
        runstart: [0,0],
        runmid: [0, 1]
      })
      Crafty.background("black");

      Crafty.viewport.clampToEntities = false;
      //Crafty.viewport.zoom(0.9, 500, 250, 1)

      Crafty.sprite(500, 255, "castle.jpg", {
        grad: [0,0]
      });

      var delayer = Crafty.e("Delay");
      
      Crafty.c("JumpMan", {

        init: function(){
          this.requires("runmid, SpriteAnimation");
          this.h = this.w = 64
          this.reel("running", 500, [ 
            [0, 0], [1, 0], [2, 0],
            [0, 1], [1, 1], [2, 1],
            [0, 2], [1, 2] 
          ])
          this.origin("center");
        },

        start_run: function(){
          this.animate("running", -1);
        }
      });
      Crafty.c("Schedule", {
        init:function(){
          this.requires("Delay, Tween");
        },
        schedule: function(events){
          for (var i=0; i < events.length; i++){
            var e = events[i];
            this.delay(e.f, e.t, 0);
          }
          return this;
        }

      })

      Crafty.pixelart(true);
     var comp = "DOM";
      Crafty.createLayer("TestLayer", "DOM");
      
      Crafty.c("Spinner", {
         init: function() {
             this.requires("2D, Renderable, Color, AngularMotion, Motion");
             this.vrotation = 50 + Math.random()*20;
             this.vx = Math.random() * 10 + 5;
             //this.alpha = 0.5;
         },
         spin: function(color, size) {
             this.color(color);
             this.h = this.w = size;
             this.origin("center");
             return this;
         }
      });
      
      var r = Crafty.e("Spinner, " + comp)
        .spin("red", 40)
        .attr({x: 30, y:30});
        console.log(r._drawLayer.name)
      var b = Crafty.e("Spinner, TestLayer").spin("blue", 52)
        .attr({x: 30, y:30});
        console.log(b._drawLayer.name)
      var y = Crafty.e("Spinner, " + comp).spin("yellow", 37)
        .attr({x: 30, y:35});
        console.log(y._drawLayer.name)
        
        //Crafty.viewport.pan(0, -200, 10000)
      
      var customNode = document.createElement("div");
      customNode.textContent = "HELLO";
      customNode.style.color = "pink";
      
      var custom = Crafty.e("2D, DOM, TestLayer")
        .DOM(customNode)
        .attr({
            x: 100,
            y: 100,
            w: 100,
            h: 100,
            vy: 10,
            vrotation: -100
        });
      
      return;

    };

    function loadScene(){

    };
    $(window).load(function(){
      // Init Crafty:

      Crafty.init();
      Crafty.stage.fullscreen = true
      //Crafty.webgl.init();

      Crafty.timer.steptype("semifixed");
      var greenlegsSprite = {
          tile: 8,
          tileh: 8,
          map: {
            greenlegs: [0,0],
            greenlegs2: [1,1]
          }
      }
      var loadData = {
        images: ["runner.png", "aurora.png", "starynight.png"],
        sprites: {
          "greenlegs.png":greenlegsSprite
        }
      }

      Crafty.load( loadData, run) 

   
    });