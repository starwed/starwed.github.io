playerURL = ""
wishListURL = "https://afh.firebaseio.com/dread/wishlists/"
playerData = null
data = null
playerLookup = null

dropList = {
	ghost_outfit: {
		name:"Ghost Outfit"
		max:3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat5.gif"


	}
	sash: {
		name: "Mayor Ghost's Sash"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_sash.gif"
	}
	gavel: {
		name: "Mayor Ghost's Gavel"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_gavel.gif"
	}
	scissors: {
		name: "Mayor Ghost's Scissors"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/mg_scissors.gif"

	}

	zombie_outfit: {
		name: "Zombie HOA Outfit"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat4.gif"
	}

	eyes: {
		name: "HOA zombie eyes"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/zh_eyes.gif"
	}


	ghost_outfit1: {
		name:"Ghost Outfit"
		max:3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat5.gif"


	}
	sash1: {
		name: "Mayor Ghost's Sash"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_sash.gif"
	}
	gavel1: {
		name: "Mayor Ghost's Gavel"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_gavel.gif"
	}
	scissors11: {
		name: "Mayor Ghost's Scissors"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/mg_scissors.gif"

	}

	zombie_outfit1: {
		name: "Zombie HOA Outfit"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat4.gif"
	}

	eyes1: {
		name: "HOA zombie eyes"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/zh_eyes.gif"
	}


	ghost_outfit22: {
		name:"Ghost Outfit"
		max:3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat5.gif"


	}
	sash2: {
		name: "Mayor Ghost's Sash"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_sash.gif"
	}
	gavel2: {
		name: "Mayor Ghost's Gavel"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_gavel.gif"
	}
	scissors2: {
		name: "Mayor Ghost's Scissors"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/mg_scissors.gif"

	}

	zombie_outfit2: {
		name: "Zombie HOA Outfit"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat4.gif"
	}

	eyes2: {
		name: "HOA zombie eyes"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/zh_eyes.gif"
	}



}

makeListElement = (drop, dropID, has)->
	
	li = $("<li id='#{dropID}'></li>")
		.append("<span class='name'> <img height='24' width='24' src='#{drop.image}'/> &nbsp;" + drop.name + "</span>")
	dropdown = $("""<select>  </select>""")
	max = drop.max
	for i in [0..max]
		if i == parseFloat(has)
			dropdown.append("<option selected='selected'>#{i}</option>")
		else
			dropdown.append("<option>#{i}</option>")
	span = $("<span/>").addClass("selection").append(dropdown)

	li.append(span)
	onChange = ()->
		console.log("changed!!!")

		isComplete = $(this).val() >= max
		markedComplete = this.parentElement.parentElement.parentElement.id is "complete"
		if isComplete and not markedComplete
			console.log("moving to complete")
			$("#complete").append(this.parentElement.parentElement)
		else if (not isComplete) and markedComplete
			$("#wanted").append(this.parentElement.parentElement)
			console.log("moving to wanted")
	dropdown.bind("change", onChange)
	if parseFloat(has) >= parseFloat(drop.max)
		li.addClass("complete")
	return li

fishes = null
startUp = ()->
	fishes = new Firebase(wishListURL);
	fishes.once('value', setAutoComplete)

setAutoComplete = (snapshot)->
	data = snapshot.val()
	playerLookup = {}
	available_names = []
	for player of data
		console.log("player: " + player)
		console.log(data[player].player)
		available_names.push(data[player].player)
		playerLookup[data[player].player] = player

	$("#tags").autocomplete({source:available_names})
	$("#tags").autocomplete({close:checkLists})

checkLists= ()->
	name = $("#tags").val()
	pid = playerLookup[name] 
	if pid?
		playerData = data[pid].wants
		createList(playerData)
		playerURL = wishListURL + "/#{pid}/wants"
	



	




createList = (snapshot)->
	$("#wanted").empty()
	$("#unwanted").empty()
	$("#complete").empty()
	document.getElementById("content").hidden=false
	for drop of playerData
		console.log("fishes: #{drop}")
	all = []
	for drop of dropList
		if (playerData[drop]?)
			has = playerData[drop].has
			priority = playerData[drop].priority
		else
			has = 0
			priority = Infinity
		li = makeListElement(dropList[drop], drop, has)
		all.push( {el:li, priority:priority, complete: (has>=dropList[drop].max)})

	all.sort(  (a, b)-> a.priority-b.priority)
	

	for item in all
		if item.complete
			$("#complete").append(item.el)
		else if item.priority<0
			$("#unwanted").append(item.el)
		else
			$("#wanted").append(item.el)




window.Run = startUp;

sample_data = {
	dread:
		{
			
				wishlists:[{
					player: "starwed"
					wants: {
						ghost_outfit: {has:2, priority:8}
						sash: {has:0, priority: 3}

					}

				}]
			
		}
}



### wanted design
	CreateList: creates an array of element ids from a list  <-- this is all I need!

	CreateWishlist:
		gets a list of wanted items
			for each, specify number and priority
		get a list of not wanted items
			for each, specify number and priority (negative)

		That's it!





###

window.saveList = ()->
	$("#save_feedback").text("")
	wanted_items = $("#wanted").sortable("toArray")
	priority = 1;
	newWishList = {}
	for id in wanted_items
		has = $("##{id}").find("select").val()
		newWishList[id] = {has:has, priority: priority}
		priority++


	spurned_items = $("#unwanted").sortable("toArray")
	priority = -100;
	for id in spurned_items
		has = $("##{id}").find("select").val()
		newWishList[id] = {has:has, priority: priority}
		priority++
		
	complete_items = $("#complete").sortable("toArray")
	priority = 10000
	for id in complete_items
		has = $("##{id}").find("select").val()
		newWishList[id] = {has:has, priority: priority}
		priority++
	err = (e)->
		if e?
			console.log('Data could not be saved.' + error);
			$("#save_feedback").text("ERROR!  Wishlist not saved!")
		else
			console.log("data saved")
			$("#save_feedback").text("Wishlist saved")

	playerWishes = new Firebase(playerURL);

	playerWishes.set(newWishList, err)