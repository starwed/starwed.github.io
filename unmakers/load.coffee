Crafty = window.Crafty
Di = window.Di = {};


Clamp = (x, a, b)->
    return Math.min(Math.max(x,a),b)

Direction = (x, y)->
    return 1 if x < y 
    return -1 if x > y 
    return 0

window.Direction = Direction;


spriteList =  []


XOffset = 200;
YOffset = 0;





typeList = ["white", "blue", "yellow", "green", "red"]

randomType = ()-> typeList[ Math.floor(Math.random()*5)]


ycell = 28
xcell = 32


BlockGrid = []

getBlock = (r, c) -> BlockGrid[100*r + c]


setBlock = (r, c, value) -> BlockGrid[100*r + c] = value

Crafty.c("Snap", {
    init: ()-> 
        this.friends = []


    snap: ()->
        snapRow = Math.round(this.y/ycell)
        this.y = snapRow * ycell
         
        if (snapRow%2) is 0
            snapCol = Math.round(this.x/xcell)
            this.x = snapCol * xcell
        else
            snapCol= Math.round(this.x/xcell+.5)
            this.x = snapCol * xcell - xcell/2

        this.row = snapRow
        this.col = snapCol
        setBlock(snapRow, snapCol, this)

        this.addComponent("Friends")
        FindFriends()

        return this


    preplace: (r, c)->
        console.log(r, c)
        snapRow = r
        this.y = snapRow * ycell
        if (snapRow%2) is 0
            snapCol = c
            this.x = snapCol * xcell
        else
            snapCol= c
            this.x = snapCol * xcell - xcell/2

        this.row = snapRow
        this.col = snapCol
        setBlock(snapRow, snapCol, this)



        return this

    checkAdjacent: ()->
        console.log("Checking adjacent")
        this.friends.length = 0

        b = getBlock(this.row, this.col-1)
        this.checkBlock(b)

        b = getBlock(this.row, this.col+1)
        this.checkBlock(b)


        b = getBlock(this.row-1, this.col)
        this.checkBlock(b)

        b = getBlock(this.row+1, this.col)
        this.checkBlock(b)

        if this.row % 2 is 0
            b = getBlock(this.row-1, this.col+1)
            this.checkBlock(b)

            b = getBlock(this.row+1, this.col+1)
            this.checkBlock(b)
        else
            b = getBlock(this.row-1, this.col-1)
            this.checkBlock(b)

            b = getBlock(this.row+1, this.col-1)
            this.checkBlock(b)


        if this.friends.length>1
            for b in this.friends
                b.destroy()
            this.destroy()



    checkBlock: (b)->
        console.log('ding')
        return if typeof b is "undefined"
        if b?.type is this.type
            console.log("Friend! #{this.type}")
            b.addComponent("Friends")


    remove: ()->
        setBlock(this.row, this.col, undefined)

})


FindFriends = (type)->
    Friends = Crafty("Friends")
    startNum = Friends.length
    return if startNum is 0
    Friends.each( ()->this.checkAdjacent() );
    Friends = Crafty("Friends")
    if Friends.length > startNum
        FindFriends(type)
    else
        if (Friends.length>2)
            Friends.each( ()-> this.disintegrate() )
            Crafty.audio.play("trill", 1, 0.1)
        else
            Friends.each( ()-> this.removeComponent("Friends"))
            Crafty.audio.play("place", 1, 0.2)






Crafty.c("Block", {
    init: ()->
        this.requires("2D, Canvas, Sprite, Collision, Solid, Platform, Snap")
        this.w = 32;
        this.h = 32;
        m = 8
        #poly = new Crafty.polygon([m, m], [this._w-m, m], [this._w-m, this._h-m], [m, this._h-m]);
        poly = new Crafty.circle(16, 16, 8)
        this.collision(poly)
        #this.matchHitBox()
        #this.css("border", "2px dotted purple")

    blockType: (type)->
        this.type = type
        switch type
            when "white" 
                @addComponent("whitebubble")
            when "yellow"
                @addComponent("yellowbubble")
            when "blue"
                @addComponent("bluebubble")
            when "green"
                @addComponent("greenbubble")
            when "red"
                @addComponent("redbubble")
        this.h=this.w=32
        #this.color(type)
        return this

    disintegrate: ()->
        this.removeComponent("Block")
        this.addComponent("AnimatedEffect")
        this.setTween({alpha: 0})
        this.runAnimation(15)


})


Crafty.c("Unmaker", {
    init: ()->
        @requires("2D, Canvas, Sprite, Ballistic, Collision, KeyboardMan, Slider, Snap")
            .attr({h:32, w:32})
            #.color("purple")
            #.css("border", "1px solid grey")
            #.css("border-radius", "8px")
            .launch(0, -5)
            .accelerate(0, .2)

        this.origin(16, 16)
        this.bind("Jump", @_jump)

        this.bind("BackgroundClick", @leap)

        this.bind("Move", @_checkCollisions)
            
        this.bind("Moved", @_checkGround)

        #this.bind("Moved", @_setOrientation)

        #Crafty.viewport.follow(this)

    _setOrientation: ()->
        this.rotation = 360/6.28*Math.atan2(this._vx, -this._vy)


    _checkCollisions: (move)->
        if (hits = this.hit("Block"))
            this.destroy()
            
            b = Crafty.e("Block").blockType(this.type)

            b.x = move._x;
            b.y = move._y;
            b.snap()
            
            ##Crafty.one("KeyDown", ()->Crafty.one("EnterFrame") )

    _checkGround: (move)->
        if (hits = this.hit("Platform") )
            if this._vy > 0 
                this._vy = 0
                this._ay = 0
                target = hits[0].obj
                this.y = target.y - this.h
                @grounded = true
                @active = false

    leap: (data)->
        jumpSound()
        o = {x: this._x + this._w/2, y: this._y + this._h/2}
        dx = data.x - o.x
        dy = data.y-o.y
        norm = Math.sqrt(dx*dx + dy*dy)
        dx = dx/norm
        dy = dy/norm
        this.launch( dx*7, dy*7)
        @grounded = false

        return this


    umtype: (type)->
        this.type = type
        switch type
            when "white" 
                @addComponent("cloud")
            when "yellow"
                @addComponent("sun")
            when "blue"
                @addComponent("drop")
            when "green"
                @addComponent("leaf")
            when "red"
                @addComponent("flower")
        this.h=this.w=32
        return this


    _jump: ()->
        jumpSound()
        @grounded = false
        this.launch(@_vx, -7)
        this._ay = 0.2


})


bail = false

newUnmaker = ()->
    if bail is true then return
    console.log('maker')
    u = Crafty.e("Unmaker")
        .attr({x:64, y: 300})
        .umtype(randomType())

    if (u.hit("Block"))
        u.destroy()
        Crafty.unbind("EnterFrame", checkUnmaker)
        return

checkUnmaker = ()->
    if Crafty("Unmaker").length is 0
        newUnmaker()


fillBlocks = ()->
    for r in [1..3]
        for c in [3..9]
            Crafty.e("Block")
                .attr({x:r*xcell, y: c*ycell})
                .blockType(randomType())
                .preplace(r, c)




setup = ()->
    Crafty.background('url("assets/cloudy_sky.png")')
    console.log('start')
    Crafty.e("2D, DOM, Color, Floor, Solid, Platform, Collision")
        .attr({x: 32, y:420, h:64, w: 640})
        .color("maroon")
        .css("border", "2px solid grey")

    newUnmaker()
    fillBlocks();
 

    Crafty.bind("EnterFrame", checkUnmaker)

    Crafty.bind("BackgroundClick", (data)->console.log("clicked #{data.x}, #{data.y}") )
 

clickControl = (mouseData)->
    data = {x: mouseData.clientX - Crafty.viewport.x, y:mouseData.clientY - Crafty.viewport.x}
    Crafty.trigger("BackgroundClick", data)
 





sliceSprites = ()->
    ###Crafty.sprite(48, "guard.png", {
        guard1: [0,0],
        guard2: [1,0]
        guardx: [2,0]} )###
    Crafty.sprite(32, 32, "assets/white-bubble.gif", {
        whitebubble: [0,0]
    })

    Crafty.sprite(32, 32, "assets/blue-bubble.gif", {
        bluebubble: [0,0]
    })

    Crafty.sprite(32, 32, "assets/yellow-bubble.gif", {
        yellowbubble: [0,0]
    })

    Crafty.sprite(32, 32, "assets/green-bubble.gif", {
        greenbubble: [0,0]
    })

    Crafty.sprite(32, 32, "assets/red-bubble.gif", {
        redbubble: [0,0]
    })

   
    Crafty.sprite(16, 16, "assets/mistercloud.png", {
        cloud: [0,0]
    })

    Crafty.sprite(16, 16, "assets/misterleaf.png", {
        leaf: [0,0]
    })

    Crafty.sprite(16, 16, "assets/misterflower.png", {
        flower: [0,0]
    })

    Crafty.sprite(16, 16, "assets/mistersun.png", {
        sun: [0,0]
    })

    Crafty.sprite(16, 16, "assets/misterdrop.png", {
        drop: [0, 0]

    })




jumpSound = ()->
    Crafty.audio.play("jump" + Math.ceil(Math.random()*4), 1, 0.3)

window.onload = ()->
    WIDTH = 1200   
    HEIGHT = 800
    # Initialize Crafty
    Crafty.extraZoom = 1;
    Crafty.init(WIDTH, HEIGHT)
    Crafty.DrawManager.debugDirty = false
    #Crafty.timer.setMode("time")

    window.addEventListener("click", clickControl)
    #Crafty.viewport.clampToEntities = false

    

    
    Crafty.scene("main", setup)
    Crafty.load( 
        ["assets/white-bubble.gif", "assets/misterleaf.png", "assets/blue-bubble.gif", "assets/green-bubble.gif", 
        "assets/yellow-bubble.gif", "assets/misterdrop.png", "assets/mistersun.png", "assets/mistercloud.png", 
        "assets/red-bubble.gif", "assets/misterflower.png", "assets/cloudy_sky.png"], ()->Crafty.scene("main") )
    Crafty.audio.add("jump1", "assets/Jump17.wav")
    Crafty.audio.add("jump2", "assets/Jump17-2.wav")
    Crafty.audio.add("jump3", "assets/Jump17-3.wav")
    Crafty.audio.add("jump4", "assets/Jump17-4.wav")
    Crafty.audio.add("place", "assets/place.wav")
    Crafty.audio.add("trill", "assets/trill.wav")
    sliceSprites()
    


