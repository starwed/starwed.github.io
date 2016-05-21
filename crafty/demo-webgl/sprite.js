var assetsObj = {
    "sprites": {
        // This spritesheet has 16 images, in a 2 by 8 grid
        // The dimensions are 832x228
        "glitch_walker.png": {
            // This is the width of each image in pixels
            tile: 104,
            // The height of each image
            tileh: 114,
            // We give names to three individual images
            map: {
                walker_start: [0, 0]
                walker_middle: [7, 0]
                walker_end: [7, 1]
            }
        }
    }
};


window.onload = function() {
	Crafty.init(400, 400);
	Crafty.load(assetsObj, go);
}

function go() {
	var walker = Crafty.e('2D, Canvas, walker_start, SpriteAnimation')
		.reel("walking", 1000, [
			[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
			[0, 1], [1, 1], [2, 1], [3, 1], [4, 1], [5, 1], [6, 1], [7, 1]
		])
		.animate("walking", -1);
}