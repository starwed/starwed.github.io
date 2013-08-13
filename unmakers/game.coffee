Crafty = window.Crafty;


Crafty.c("NewSupportable", {
	init: ()->
		this.bind("EnterFrame", @checkSupport)


	checkSupport: ()->
		Crafty.map.search({})


})