playerURL = ""
wishListURL = "https://afh.firebaseio.com/dread/wishlists/"
playerData = null
data = null
playerLookup = null


#Spreadsheet stuff




spreadsheet_key = [
	"name"
	"bugbear_outfit", "pyj", "qys", "hys",
	"wolf_outfit", "lice", "rocket", "trousers",
	"ghost_outfit", "scissors", "sash", "gavel",
	"zombie_outfit", "book", "eyes", "pad",
	"skeleton_outfit", "sword", "leg", "shield",
	"vampire_outfit", "ring", "glass", "bell",
	"capacitor"]



dropList = {
	capacitor: {
		name: "Skull capacitor"
		max: 5
		image:  "http://images.kingdomofloathing.com/itemimages/dv_skullcap.gif"
		cat: "special"
	}

	
	wolf_outfit: {
		name: "Wolf Outfit"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat3.gif"
		cat: "wolf"
	}

	lice: {
		name: "Great Wolf's lice"
		max: 1
		image:"http://images.kingdomofloathing.com/itemimages/ww_lice.gif"
		cat: "wolf"

	}

	rocket: {
		name: "Great Wolf's rocket launcher"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/ww_bazooka.gif"
		cat: "wolf"

	}

	trousers: {
		name: "Great Wolf's beastly trousers"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/ww_pants.gif"
		cat: "wolf"

	}



	bugbear_outfit: {
		name: "Bugbear Outfit"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat2.gif"
		cat: "bugbear"
	}

	pyj: {
		name: "Protects-Your-Junk"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_speedo.gif"
		cat: "bugbear"
	}



	qys: {
		name: "Quiets-Your-Steps"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_shoes.gif"
		cat: "bugbear"
	}

	hys: {
		name: "Helps-You-Sleep"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_mask.gif"
		cat: "bugbear"
	}



	ghost_outfit: {
		name:"Ghost Outfit"
		max:3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat5.gif"
		cat: "ghost"


	}

	scissors: {
		name: "Mayor Ghost's scissors"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/mg_scissors.gif"
		cat: "ghost"
	}
	sash: {
		name: "Mayor Ghost's sash"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_sash.gif"
		cat: "ghost"
	}
	gavel: {
		name: "Mayor Ghost's gavel"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_gavel.gif"
		cat: "ghost"
	}
	

	zombie_outfit: {
		name: "Zombie Outfit"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat4.gif"
		cat: "zombie"
	}
	book: {
		name: "HOA regulation book"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/book4.gif"
		cat: "zombie"
	}
	eyes: {
		name: "HOA zombie eyes"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/zh_eyes.gif"
		cat: "zombie"
	}

	pad: {
		name: "HOA citation pad"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/zh_pad.gif"
		cat: "zombie"
	}


	skeleton_outfit:{
		name: "Skeleton Outfit"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat6.gif"
		cat: "skeleton"
	}

	shield: {
		name: "Unkillable Skeleton's shield"
		max: 1
		image:	"http://images.kingdomofloathing.com/itemimages/sk_shield.gif"
		cat: "skeleton"
	}

	sword: {
		name: "Unkillable Skeleton's sawsword"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/sk_sword.gif"
		cat: "skeleton"
	}

	leg: {
		name:"Unkillable Skeleton's restless leg"
		max: 1
		image:"http://images.kingdomofloathing.com/itemimages/sk_leg.gif"
		cat: "skeleton"
	}


	vampire_outfit: {
		name: "Vampire Outfit"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat7.gif"
		cat: "vampire"
	}

	ring: {
		name: "Drunkula's ring of haze"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_ring.gif"
		cat: "vampire"
	}

	glass: {
		name: "Drunkula's wineglass"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_wineglass.gif"
		cat: "vampire"
	}

	bell: {
		name: "Drunkula's bell"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_bell.gif"
		cat: "vampire"
	}
}

makeListElement = (drop, dropID, has)->
	
	li = $("<li id='#{dropID}'></li>")
		.append("<span class='name #{drop.cat}'> <img height='24' width='24' src='#{drop.image}'/> &nbsp;" + drop.name + "</span>")
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



parseCells = (d)->
	Table = []
	add = (r, c, val)->
		if not Table[r]?
			Table[r] = []
		Table[r][c] = val
	cells = d.feed.entry;
	for entry in cells
		cell = entry.gs$cell;
		#console.log(cell.$t)
		add(cell.row, cell.col, cell.$t)
	test = []
	for row in Table
		if row?
			console.log(row)
	return Table;


	
startUp = ()->
	key = "0AkCuuVp5c_x-dFBRdHFQMnQyTGZINWVZaDkySWdnWHc"
	url = "https://spreadsheets.google.com/feeds/cells/#{key}/od6/public/values?alt=json-in-script&callback=?";
	$.getJSON(url,{},  parseCells);
	return
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


window.showNewPlayer = ()-> document.getElementById("new").hidden = false
window.hideNewPlayer = ()-> 
	document.getElementById("new").hidden = true
	document.getElementById("new-name").value = ""
	document.getElementById("new-pid").value = ""