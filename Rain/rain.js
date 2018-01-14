function startGame() {
    Crafty.timer.steptype("fixed");
    //Crafty.timer.FPS(30);
    Crafty.init(600, 600);
    Crafty.background("lightblue");
    for (var i=0; i<6; i++) {
        var c = Crafty.e("Cloud");
        c.x = 40 + i * 70;
        c.y = 0;
        c.intensity = 0.3 * (i +1); 
    }
    
    var g = Crafty.e("Ground");
    g.w = 500;
    g.h = 50;
    g.x = 50;
    g.y = 400;
    var p = Crafty.e("Player");
    p.x = 300;
    p.y = g.y - p.h; 

}

Crafty.c("ActionLayer", {
    required: "2D, WebGL"
});

Crafty.defaultShader("Raindrop", new Crafty.WebGLShader(
// Vertex shader
`
attribute vec2 aPosition;
attribute vec3 aOrientation;
attribute vec2 aLayer;
attribute vec4 aColor;
attribute float aRelativeHeight;

varying lowp vec4 vColor;
varying float vHeight;
uniform  vec4 uViewport;

mat4 viewportScale = mat4(2.0 / uViewport.z, 0, 0, 0,    0, -2.0 / uViewport.w, 0,0,    0, 0,1,0,    -1,+1,0,1);
vec4 viewportTranslation = vec4(uViewport.xy, 0, 0);

void main() {
  vec2 pos = aPosition;
  vec2 entityOrigin = aOrientation.xy;
  mat2 entityRotationMatrix = mat2(cos(aOrientation.z), sin(aOrientation.z), -sin(aOrientation.z), cos(aOrientation.z));

  pos = entityRotationMatrix * (pos - entityOrigin) + entityOrigin;
  gl_Position = viewportScale * (viewportTranslation + vec4(pos, 1.0/(1.0+exp(aLayer.x) ), 1) );

  vColor = vec4(aColor.rgb*aColor.a*aLayer.y, aColor.a*aLayer.y);
  vHeight = aRelativeHeight;
}
`,

 // Fragment shader
 `
precision mediump float;
varying lowp vec4 vColor;
varying float vHeight;
void main(void) {
    float myint = vHeight;
	gl_FragColor = vec4(vColor.r, vColor.g, vColor.b * smoothstep(-0.5, 1.0, vHeight), 0.5*smoothstep(0.0, 1.0, myint));
}
`,

    [
        { name: "aPosition",    width: 2 },
        { name: "aOrientation", width: 3 },
        { name: "aLayer",       width: 2 },
        { name: "aColor",       width: 4 },
        { name: "aRelativeHeight", width: 1}
    ],
    function(e, entity) {
        e.program.writeVector("aColor",
            entity._red/255,
            entity._green/255,
            entity._blue/255,
            entity._strength
        );
        e.program.writeVector("aRelativeHeight", 
             0,
             1,
             0,
             1);
    }
));


Crafty.c("Raindrop", {
    init: function() {
        this.requires("ActionLayer, Motion");
        var b = 200;
        var r,g;
        r = g = 20 *  Math.random() + 90;
        r = g = 20;
        this._red = r;
        this._green = g;
        this._blue = b;
        this._strength = 0.5;
        //this.color("blue");
        
        this.__coord = [0, 0, 0, 0];

        this.w = 1;
        //if (Math.random() > 0.9) this.w = 2;
        this.h = 60 + Math.random()*10;
        this.alpha = 0.8;

        if (this._drawLayer) {
            this._establishShader("Raindrop", Crafty.defaultShader("Raindrop"));
        }
    },
    splat: function() {
        Dropfactory.recycle(this);
    },
    events: {
        "EnterFrame": function() {
            if (this.y > 600) {
                this.splat();
            }
        },
        "LayerAttached": function() {
            this._establishShader("Raindrop", Crafty.defaultShader("Raindrop"));
        },
        "Draw": function(e){
            e.program.draw(e, this);
        },
        
    }
});

Crafty.c("Cloud", {
    intensity: 0.1,
    init: function() {
        this.requires("ActionLayer, Color");
        this.color("white");
        this.w = 50;
        this.h = 50;
    },

    events: {
        "EnterFrame": function() {
            if (Math.random() < this.intensity){
                this.spawnRaindrop();
            }
        }
    },
    spawnRaindrop: function() {
        var x = Math.round((Math.random() * this.w) + this.x);
        //var drop = Crafty.e("Raindrop");
        var drop = Dropfactory.get();
        drop.x = x;
        drop.y = this.y + this.h;
        drop.vy = 100 + 10 * (Math.random() - Math.random()) ;
        drop.vy *=5;
        drop.vx = Math.random() - Math.random();
    }
});

Crafty.c("RainDestroyer", {
    init: function() {
        this._destroyerResults = [];
    },
    events: {
        "EnterFrame": function() {
            // Do a direct map search rather than using collision elements
            // TODO: wire into crafty support for simpler quad intersection tests with collision
            this._destroyerResults.length = 0;
            var results = Crafty.map.search(this, this._destroyerResults);
            var drops = 0;
            for(var i in results) {
                if(results[i].__c["Raindrop"]) {
                    results[i].splat();
                    drops++;
                }
            }
            if (drops > 0){
                this.trigger("RainDestroyed", drops);
            }
        }
    }
})

Crafty.c("Ground", {
    init: function() {
        this.requires("ActionLayer, Color, RainDestroyer");
        this.color("brown");
    }
});

Crafty.c("Player", {
    init: function() {
        this.requires("ActionLayer, Color, Motion, Twoway, RainDestroyer, Gravity");
        this.color("red");
        this.gravity("Ground");
        this.twoway(120, 400);
        this.w = this.h = 50;
    },
    events: {
        "RainDestroyed": function(drops) {
            if (this.vy != 0) {
                this.vy +=  5 * drops;
            }
        }
    }
});


DropfactoryReg = {
    get: function(){
        return Crafty.e("Raindrop");
    },
    recycle: function(drop){
        drop.destroy();
    }
}

DropfactoryFreeze = {
    _drops: [],
    _maxSize: 200,
    get: function() {
        if (this._drops.length > 0){
            var drop =  this._drops.pop();
            // Should get auto inserted into map automatically
            drop.unfreeze();
            //console.log('drip');
            return drop;
        }
        
        return Crafty.e("Raindrop");
    },
    recycle: function(drop) {
        // Remove from hashmap
        // Set visibility to no
        // 
        //Crafty.map.remove(drop._entry);
        if (this._drops.length > this._maxSize) {
            drop.destroy();
            return;
        }
        drop.freeze();
        this._drops.push(drop);
    }

}

DropfactoryFakeFreeze = {
    _drops: [],
    _maxSize: 200,
    get: function() {
        if (this._drops.length > 0){
            var drop =  this._drops.pop();
            drop.visible = true;
            return drop;
        }
        
        return Crafty.e("Raindrop");
    },
    recycle: function(drop) {
        if (this._drops.length > this._maxSize) {
            drop.destroy();
            return;
        }
        drop.visible = false;
        drop.x = -500;
        drop.y = -500;
        this._drops.push(drop);
    }
}

Dropfactory = DropfactoryFreeze;