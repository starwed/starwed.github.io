// Generated by CoffeeScript 1.6.3
(function() {
  var BlockGrid, CheckSupport, Clamp, Crafty, Di, Direction, FindFriends, XOffset, YOffset, bail, checkUnmaker, clickControl, fillBlocks, getBlock, jumpSound, newUnmaker, randomType, randomUnmakerType, setBlock, setup, sliceSprites, spriteList, typeExtant, typeList, xcell, ycell;

  Crafty = window.Crafty;

  Di = window.Di = {};

  Clamp = function(x, a, b) {
    return Math.min(Math.max(x, a), b);
  };

  Direction = function(x, y) {
    if (x < y) {
      return 1;
    }
    if (x > y) {
      return -1;
    }
    return 0;
  };

  window.Direction = Direction;

  spriteList = [];

  XOffset = 200;

  YOffset = 0;

  typeList = ["white", "blue", "yellow", "green", "red"];

  typeExtant = function(type) {
    if (Crafty("" + type + "bubble").length > 0) {
      return true;
    } else {
      return false;
    }
  };

  randomUnmakerType = function() {
    var type;
    type = randomType();
    console.log(typeExtant(type));
    if (typeExtant(type)) {
      return type;
    } else {
      return randomUnmakerType();
    }
  };

  randomType = function() {
    return typeList[Math.floor(Math.random() * 5)];
  };

  ycell = 28;

  xcell = 32;

  BlockGrid = [];

  getBlock = function(r, c) {
    return BlockGrid[100 * r + c];
  };

  setBlock = function(r, c, value) {
    return BlockGrid[100 * r + c] = value;
  };

  Crafty.c("Snap", {
    init: function() {
      return this.friends = [];
    },
    snap: function() {
      var snapCol, snapRow;
      snapRow = Math.round(this.y / ycell);
      this.y = snapRow * ycell;
      if ((snapRow % 2) === 0) {
        snapCol = Math.round(this.x / xcell);
        this.x = snapCol * xcell;
      } else {
        snapCol = Math.round(this.x / xcell + .5);
        this.x = snapCol * xcell - xcell / 2;
      }
      this.row = snapRow;
      this.col = snapCol;
      setBlock(snapRow, snapCol, this);
      this.addComponent("Friends");
      FindFriends();
      return this;
    },
    preplace: function(r, c) {
      var snapCol, snapRow;
      snapRow = r;
      this.y = snapRow * ycell;
      if ((snapRow % 2) === 0) {
        snapCol = c;
        this.x = snapCol * xcell;
      } else {
        snapCol = c;
        this.x = snapCol * xcell - xcell / 2;
      }
      this.row = snapRow;
      this.col = snapCol;
      setBlock(snapRow, snapCol, this);
      return this;
    },
    checkAdjacent: function() {
      var b, _i, _len, _ref;
      this.friends.length = 0;
      b = getBlock(this.row, this.col - 1);
      this.checkBlock(b);
      b = getBlock(this.row, this.col + 1);
      this.checkBlock(b);
      b = getBlock(this.row - 1, this.col);
      this.checkBlock(b);
      b = getBlock(this.row + 1, this.col);
      this.checkBlock(b);
      if (this.row % 2 === 0) {
        b = getBlock(this.row - 1, this.col + 1);
        this.checkBlock(b);
        b = getBlock(this.row + 1, this.col + 1);
        this.checkBlock(b);
      } else {
        b = getBlock(this.row - 1, this.col - 1);
        this.checkBlock(b);
        b = getBlock(this.row + 1, this.col - 1);
        this.checkBlock(b);
      }
      if (this.friends.length > 1) {
        _ref = this.friends;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          b = _ref[_i];
          b.destroy();
        }
        return this.destroy();
      }
    },
    checkBlock: function(b) {
      if (typeof b === "undefined") {
        return;
      }
      if ((b != null ? b.type : void 0) === this.type) {
        console.log("Friend! " + this.type);
        return b.addComponent("Friends");
      }
    },
    remove: function() {
      return setBlock(this.row, this.col, void 0);
    }
  });

  FindFriends = function(type) {
    var Friends, startNum;
    Friends = Crafty("Friends");
    startNum = Friends.length;
    if (startNum === 0) {
      return;
    }
    Friends.each(function() {
      return this.checkAdjacent();
    });
    Friends = Crafty("Friends");
    if (Friends.length > startNum) {
      return FindFriends(type);
    } else {
      if (Friends.length > 2) {
        Friends.each(function() {
          return this.disintegrate();
        });
        Crafty.audio.play("trill", 1, 0.1);
        return CheckSupport();
      } else {
        Friends.each(function() {
          return this.removeComponent("Friends");
        });
        return Crafty.audio.play("place", 1, 0.2);
      }
    }
  };

  CheckSupport = function() {
    var blocks;
    return blocks = Crafty("Block");
  };

  Crafty.c("Block", {
    init: function() {
      var m, poly;
      this.requires("2D, Canvas, Sprite, Collision, Platform, Snap");
      this.w = 32;
      this.h = 32;
      m = 8;
      poly = new Crafty.circle(16, 16, 8);
      return this.collision(poly);
    },
    blockType: function(type) {
      this.type = type;
      switch (type) {
        case "white":
          this.addComponent("whitebubble");
          break;
        case "yellow":
          this.addComponent("yellowbubble");
          break;
        case "blue":
          this.addComponent("bluebubble");
          break;
        case "green":
          this.addComponent("greenbubble");
          break;
        case "red":
          this.addComponent("redbubble");
      }
      this.h = this.w = 32;
      return this;
    },
    disintegrate: function() {
      this.removeComponent("Block");
      this.addComponent("AnimatedEffect");
      this.setTween({
        alpha: 0
      });
      return this.runAnimation(15);
    }
  });

  Crafty.c("Unmaker", {
    init: function() {
      this.requires("2D, WebGL, Ballistic, Collision, KeyboardMan, Snap, Solid, Bounce").attr({
        h: 32,
        w: 32
      }).launch(0, -5).accelerate(0, .2);
      this.restitution = .7;
      this.origin(16, 16);
      this.bind("Jump", this._jump);
      this.bind("BackgroundClick", this.leap);
      return this.bind("Move", this._checkCollisions);
    },
    _setOrientation: function() {
      return this.rotation = 360 / 6.28 * Math.atan2(this._vx, -this._vy);
    },
    _checkCollisions: function(move) {
      var b, hits;
      if ((hits = this.hit("Block"))) {
        this.destroy();
        b = Crafty.e("Block").blockType(this.type);
        b.x = move._x;
        b.y = move._y;
        return b.snap();
      }
      /*if (hits = this.hit("Barrier"))
      
          this.x = move._x
          this.y = move._y
          this._vx = -0.5 * this._vx
          this._vy = -0.5 * this._vy
      */

    },
    /*_checkGround: (move)->
        if (hits = this.hit("Platform") )
            if this._vy > 0 
                this._vy = 0
                this._ay = 0
                target = hits[0].obj
                this.y = target.y - this.h
                @grounded = true
                @active = false
    */

    leap: function(data) {
      var dx, dy, norm, o;
      Crafty.trigger("JumpPower");
      jumpSound();
      o = {
        x: this._x + this._w / 2,
        y: this._y + this._h / 2
      };
      dx = data.x - o.x;
      dy = data.y - o.y;
      norm = Math.sqrt(dx * dx + dy * dy);
      dx = dx / norm;
      dy = dy / norm;
      this.launch(dx * 9, dy * 9);
      this.grounded = false;
      return this;
    },
    umtype: function(type) {
      this.type = type;
      console.log("Type " + type);
      switch (type) {
        case "white":
          this.addComponent("cloud");
          break;
        case "yellow":
          this.addComponent("sun");
          break;
        case "blue":
          this.addComponent("drop");
          break;
        case "green":
          this.addComponent("leaf");
          break;
        case "red":
          this.addComponent("flower");
      }
      this.h = this.w = 32;
      console.log(this.program);
      return this;
    },
    _jump: function() {
      Crafty.trigger("JumpPower");
      jumpSound();
      this.grounded = false;
      this.launch(this._vx, -7);
      return this._ay = 0.2;
    }
  });

  bail = false;

  newUnmaker = function(ox, oy) {
    var clear, u;
    if (ox == null) {
      ox = 0;
    }
    if (oy == null) {
      oy = 0;
    }
    if (bail === true) {
      return;
    }
    if (Crafty("Block").length === 0) {
      clear = true;
      return;
    }
    console.log('maker');
    u = Crafty.e("Unmaker").attr({
      x: 156 + ox,
      y: 300 + oy
    }).umtype(randomUnmakerType());
    if (u.hit("Block")) {
      u.destroy();
      Crafty.unbind("EnterFrame", checkUnmaker);
    }
  };

  checkUnmaker = function() {
    if (Crafty("Unmaker").length === 0) {
      return newUnmaker();
    }
  };

  fillBlocks = function() {
    var c, r, _i, _j;
    for (r = _i = 1; _i <= 3; r = ++_i) {
      for (c = _j = 3; _j <= 9; c = ++_j) {
        Crafty.e("Block").attr({
          x: r * xcell,
          y: c * ycell
        }).blockType(randomType()).preplace(r, c);
      }
    }
    console.log(typeExtant("red"));
    return console.log("red bubbles " + Crafty("redbubble").length);
  };

  setup = function() {
    var score, scoreCard;
    Crafty.background('url("assets/cloudy_sky.png")');
    console.log('start');
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 32,
      y: 420,
      h: 32,
      w: 320
    }).color("maroon");
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 32,
      y: -16,
      h: 32,
      w: 320
    }).color("maroon");
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 32,
      y: 0,
      h: 420,
      w: 32
    }).color("maroon");
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 320,
      y: 0,
      h: 420,
      w: 32
    }).color("maroon");
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 64,
      y: 200,
      h: 16,
      w: 32
    }).color("maroon");
    Crafty.e("2D, DOM, Color, Solid").attr({
      x: 320 - 32,
      y: 200,
      h: 16,
      w: 32
    }).color("maroon");
    scoreCard = Crafty.e("2D, DOM, Text").attr({
      x: 500,
      y: 100
    }).textFont({
      size: "30px"
    });
    score = 50;
    scoreCard.text(score);
    Crafty.bind("JumpPower", function() {
      score--;
      return scoreCard.text(score);
    });
    fillBlocks();
    newUnmaker();
    return Crafty.bind("EnterFrame", checkUnmaker);
  };

  clickControl = function(mouseData) {
    var data;
    data = {
      x: mouseData.clientX - Crafty.viewport.x,
      y: mouseData.clientY - Crafty.viewport.x
    };
    return Crafty.trigger("BackgroundClick", data);
  };

  sliceSprites = function() {
    /*Crafty.sprite(48, "guard.png", {
        guard1: [0,0],
        guard2: [1,0]
        guardx: [2,0]} )
    */

    Crafty.sprite(32, 32, "assets/white-bubble.gif", {
      whitebubble: [0, 0]
    });
    Crafty.sprite(32, 32, "assets/blue-bubble.gif", {
      bluebubble: [0, 0]
    });
    Crafty.sprite(32, 32, "assets/yellow-bubble.gif", {
      yellowbubble: [0, 0]
    });
    Crafty.sprite(32, 32, "assets/green-bubble.gif", {
      greenbubble: [0, 0]
    });
    Crafty.sprite(32, 32, "assets/red-bubble.gif", {
      redbubble: [0, 0]
    });
    Crafty.sprite(16, 16, "assets/mistercloud.png", {
      cloud: [0, 0]
    });
    Crafty.sprite(16, 16, "assets/misterleaf.png", {
      leaf: [0, 0]
    });
    Crafty.sprite(16, 16, "assets/misterflower.png", {
      flower: [0, 0]
    });
    Crafty.sprite(16, 16, "assets/mistersun.png", {
      sun: [0, 0]
    });
    return Crafty.sprite(16, 16, "assets/misterdrop.png", {
      drop: [0, 0]
    });
  };

  jumpSound = function() {
    return Crafty.audio.play("jump" + Math.ceil(Math.random() * 4), 1, 0.3);
  };

  window.onload = function() {
    var HEIGHT, WIDTH;
    WIDTH = 1200;
    HEIGHT = 800;
    Crafty.extraZoom = 1;
    Crafty.init(WIDTH, HEIGHT);
    Crafty.pixelart(true);
    Crafty.DrawManager.debugDirty = false;
    Crafty.timer.steptype("semifixed");
    window.addEventListener("click", clickControl);
    Crafty.scene("main", setup);
    Crafty.load(["assets/white-bubble.gif", "assets/misterleaf.png", "assets/blue-bubble.gif", "assets/green-bubble.gif", "assets/yellow-bubble.gif", "assets/misterdrop.png", "assets/mistersun.png", "assets/mistercloud.png", "assets/red-bubble.gif", "assets/misterflower.png", "assets/cloudy_sky.png"], function() {
      return Crafty.scene("main");
    });
    Crafty.audio.add("jump1", "assets/Jump17.wav");
    Crafty.audio.add("jump2", "assets/Jump17-2.wav");
    Crafty.audio.add("jump3", "assets/Jump17-3.wav");
    Crafty.audio.add("jump4", "assets/Jump17-4.wav");
    Crafty.audio.add("place", "assets/place.wav");
    Crafty.audio.add("trill", "assets/trill.wav");
    return sliceSprites();
  };

}).call(this);
