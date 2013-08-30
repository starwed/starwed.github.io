playerURL = "https://afh.firebaseio.com/dread/wishlists/1345/wants"
wishListURL = "https://afh.firebaseio.com/dread/wishlists/"
playerData = null
data = null
playerLookup = null

dropList = {
	ghost_outfit: {
		name:"Ghost Outfit"
		max:3
	}
	sash: {
		name: "Mayor Ghost's Sash"
		max:1
	}
	gavel: {
		name: "Mayor Ghost's Gavel"
		max:1

	}
	scissors: {
		name: "Mayor Ghost's Scissors"
		max: 1

	}

	zombie_outfit: {
		name: "Zombie HOA Outfit"
		max: 3
	}

	eyes: {
		name: "HOA zombie eyes"
		max:1
	}




}

makeListElement = (drop, dropID, has)->
	
	li = $("<li id='#{dropID}'></li>")
		.append("<b>" + drop.name + "</b>&nbsp;&nbsp; ")
	dropdown = $("""<select>  </select>""")
	for i in [0..drop.max]
		if i == has
			dropdown.append("<option selected='selected'>#{i}</option>")
		else
			dropdown.append("<option>#{i}</option>")
	li.append(dropdown)
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
	$("#sortable").empty()
	$("#sortable2").empty()

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
		console.log(dropList[drop])
		li = makeListElement(dropList[drop], drop, has)
		all.push( {el:li, priority:priority})

	all.sort(  (a, b)-> a.priority-b.priority)
	

	for item in all
		if item.priority<0
			$("#sortable2").append(item.el)
		else
			$("#sortable").append(item.el)


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



### sortable design
	CreateList: creates an array of element ids from a list  <-- this is all I need!

	CreateWishlist:
		gets a list of wanted items
			for each, specify number and priority
		get a list of not wanted items
			for each, specify number and priority (negative)

		That's it!





###

window.saveList = ()->
	wanted_items = $("#sortable").sortable("toArray")
	priority = 1;
	newWishList = {}
	for id in wanted_items
		has = $("##{id}").find("select").val()
		newWishList[id] = {has:has, priority: priority}
		priority++


	spurned_items = $("#sortable2").sortable("toArray")
	priority = -100;
	for id in spurned_items
		has = $("##{id}").find("select").val()
		newWishList[id] = {has:has, priority: priority}
		priority++
		
		
	err = (e)->
		if e?
			console.log('Data could not be saved.' + error);
		else
			console.log("data saved")

	playerWishes = new Firebase(playerURL);

	playerWishes.set(newWishList, err)