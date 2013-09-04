
logit = (text) ->
	if (typeof console == "object")
		console.log(text)

parseCells = (d)->
	Table = []
	add = (r, c, val)->
		if not Table[r]?
			Table[r] = []
		Table[r][c-1] = val
	cells = d.feed.entry;
	for entry in cells
		cell = entry.gs$cell;
		add(cell.row, cell.col, cell.$t)
	return Table;




createRowData = (tableData)->
	accounts = {}
	for row in tableData
		
		continue if not row?[0]?
		name = row[0].trim().toLowerCase().replace(/\s/g, "_")
		accounts[name] = {}
		for i in [1..25]
			item = spreadsheet_key[i]
			text = row[i]
			text = "" if not text?
			text = text.trim().toLowerCase()
			## Find priority
			if text.indexOf("low")>=0
				pnumber = Infinity
			else if text.indexOf("p") >=0  
				pmatch = /p[\s-]*(\d+)/
				pnumber = pmatch.exec(text)
				if pnumber?[1]?
					pnumber=pnumber[1]
				else
				 	pnumber = 1
			else if text.indexOf("n") >=0
				pnumber = -100
			else
				if dropList[item].max is 3
					pnumber = 10000000
				else if dropList[item].max is 5
					pnumber = 100000
				else
					pnumber = 1000000


			#Find number
			havematch = /have\s*(\d+)/
			match = havematch.exec(text)
			if match?[1]?
				has = match[1]
			else
				numbermatch = /(\d+)/
				match = numbermatch.exec(text)
				if pnumber>=0 and pnumber<100000 #100k and up used to indicate default priority
					has = 0
				else if match?[1]?
					has = match[1]
				else
					has = 0

			if has >= dropList[item].max
				pnumber = -100

			accounts[name][item]={has:has, priority:pnumber, text:text}

	return accounts
				
			




createTable = (tableData, columns, distroList, lootList)->
	$table = $("<table/>")
	
	$thr = $("<tr/>")
	lastcat = null
	for i in columns	
		item = spreadsheet_key[i]
		if item is "name" 
			$thr.append("<th>Name</th>")
		else
			drop = dropList[item]
			$thr.append("<th class='#{drop.cat}'>#{drop.shortname}</th>")
	$thr.append("<th class='loot'>Distro</th>")
	$table.append($thr)
	row_list = []
	accounts = createRowData(tableData)

	for name, wishes of accounts
		distroPriority = distroList.indexOf(name)
		continue if distroPriority<0
		$tr = $("<tr/>")

		for i in columns
			if i is 0 
				cl = "name"
				text = name
			else 
				distroPriority = distroList.indexOf(name)
				item = spreadsheet_key[i]
				try
					data = wishes[item]
					text = data.has
				catch e
					logit("item: #{item}, account: #{name}")
				if data.priority <0
					if data.has >= dropList[item].max
						cl = "has"
					else
						cl = "unwanted"
						text = "-"
				else if data.priority < 10000
					cl = "priority"
					text+= " [P#{data.priority}]"
				else 	
					cl = "wanted"
				text = data.text #Return to original text
			$tr.append("<td class='#{cl}'>#{text}</td>")

		row_list.push({el:$tr, priority:distroPriority, wishes:wishes, name:name})


		
	row_list.sort( (a, b)-> a.priority-b.priority)
	for row in row_list
		
		gets = null
		currentPriority = Infinity
		for item, data of row.wishes
			if lootList[item]? and lootList[item] > 0
				if data.priority<=currentPriority and data.priority>=0
					currentPriority = data.priority
					gets = item
		if not gets?
			gets = "--" 
		else
			lootList[gets]--
		row.el.append("<td>#{gets}</td>")
		row.gets = gets
		

		$table.append(row.el)



	$("body").append($table)
	return row_list


	
window.MakeDistroTable = (bossKills, distroList, Loot, callback)->
	lootList = processLoot(Loot)
	
	window.getWishes(distroList, bossKills, lootList, callback)



processLoot = (Loot) ->
	loot_list = {}
	loot_lines = Loot.split("\n")
	for line in loot_lines
		for key, drop of dropList
			if line.indexOf(drop.name)>=0 or drop.match?.exec(line)
				if loot_list[key]?
					loot_list[key]++
				else
					loot_list[key] = 1


	return loot_list


window.getWishes = (distroList, bossKills, lootList, callback)->
	
	columns = [0]
	#bossKills = {forest:"bugbear", village:"ghost", castle:"vampire"}
	if bossKills.forest is "bugbear"
		columns.push(1, 2, 3,4)
	else
		columns.push(5,6,7,8)
	if bossKills.village is "ghost"
		columns.push(9,10,11,12)
	else
		columns.push(13, 14, 15, 16)
	if bossKills.castle is "skeleton"
		columns.push(17, 18, 19, 20)
	else
		columns.push(21, 22, 23, 24)
	columns.push(25)

	doitall = (d)->
		table = parseCells(d)
		rowList = createTable(table, columns, distroList, lootList)
		getList = {}
		for row in rowList
			getList[row.name] = row.gets
		callback(getList)

	key = "0AkCuuVp5c_x-dFBRdHFQMnQyTGZINWVZaDkySWdnWHc"
	url = "https://spreadsheets.google.com/feeds/cells/#{key}/od6/public/values?alt=json-in-script&callback=?";
	$.getJSON(url,{},  doitall);
	return



#$( ()->window.getWishes())


spreadsheet_key = [
	"name"
	"bugbear_outfit", "pyj", "qys", "hys",
	"wolf_outfit", "lice", "rocket", "trousers",
	"ghost_outfit", "scissors", "sash", "gavel",
	"zombie_outfit", "book", "eyes", "pad",
	"skeleton_outfit", "sword", "leg", "shield",
	"vampire_outfit",  "glass", "bell", "ring"
	"capacitor"]



dropList = {
	capacitor: {
		name: "skull capacitor"
		shortname: "Capacitor"
		max: 5
		image:  "http://images.kingdomofloathing.com/itemimages/dv_skullcap.gif"
		cat: "special"
	}

	
	wolf_outfit: {
		name: "Wolf Outfit"
		shortname: "[Wolf]"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat3.gif"
		cat: "wolf"
		match: /Great Wolf's (headband|right|left)/
	}

	lice: {
		name: "Great Wolf's lice"
		shortname: "Lice"
		max: 1
		image:"http://images.kingdomofloathing.com/itemimages/ww_lice.gif"
		cat: "wolf"

	}

	rocket: {
		name: "Great Wolf's rocket launcher"
		shortname: "Rocket"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/ww_bazooka.gif"
		cat: "wolf"

	}

	trousers: {
		name: "Great Wolf's beastly trousers"
		shortname: "Trousers"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/ww_pants.gif"
		cat: "wolf"

	}



	bugbear_outfit: {
		name: "Bugbear Outfit"
		shortname: "[Bugbear]"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat2.gif"
		cat: "bugbear"
		match: /(Drapes-|Warms-|Covers-)You/
	}

	pyj: {
		name: "Protects-Your-Junk"
		shortname: "PYJ"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_speedo.gif"
		cat: "bugbear"
	}



	qys: {
		name: "Quiets-Your-Steps"
		shortname: "QYS"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_shoes.gif"
		cat: "bugbear"
	}

	hys: {
		name: "Helps-You-Sleep"
		shortname: "HYS"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/bb_mask.gif"
		cat: "bugbear"
	}



	ghost_outfit: {
		name:"Ghost Outfit"
		shortname: "[Ghost]"
		max:3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat5.gif"
		cat: "ghost"
		match: /Mayor Ghost's (cloak|khakis|toupee)/


	}

	scissors: {
		name: "Mayor Ghost's scissors"
		shortname: "Scissors"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/mg_scissors.gif"
		cat: "ghost"
	}
	sash: {
		name: "Mayor Ghost's sash"
		shortname: "Sash"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_sash.gif"
		cat: "ghost"
	}
	gavel: {
		name: "Mayor Ghost's gavel"
		shortname: "Gavel"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/mg_gavel.gif"
		cat: "ghost"
	}
	

	zombie_outfit: {
		name: "Zombie Outfit"
		shortname: "[Zombie]"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat4.gif"
		cat: "zombie"
		match: /zombie (mariachi|accordion)/
	}
	book: {
		name: "HOA regulation book"
		shortname: "Book"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/book4.gif"
		cat: "zombie"
	}
	eyes: {
		name: "HOA zombie eyes"
		shortname: "Eyes"
		max:1
		image: "http://images.kingdomofloathing.com/itemimages/zh_eyes.gif"
		cat: "zombie"
	}

	pad: {
		name: "HOA citation pad"
		shortname: "Pad"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/zh_pad.gif"
		cat: "zombie"
	}


	skeleton_outfit:{
		name: "Skeleton Outfit"
		shortname: "[Skeleton]"
		max: 3
		image: "http://images.kingdomofloathing.com/otherimages/sigils/dvotat6.gif"
		cat: "skeleton"
		match: /Unkillable Skeleton's (skullcap|shinguards|breastplate)/
	}

	shield: {
		name: "Unkillable Skeleton's shield"
		shortname: "Shield"
		max: 1
		image:	"http://images.kingdomofloathing.com/itemimages/sk_shield.gif"
		cat: "skeleton"
	}

	sword: {
		name: "Unkillable Skeleton's sawsword"
		shortname: "Sword"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/sk_sword.gif"
		cat: "skeleton"
	}

	leg: {
		name:"Unkillable Skeleton's restless leg"
		shortname: "Leg"
		max: 1
		image:"http://images.kingdomofloathing.com/itemimages/sk_leg.gif"
		cat: "skeleton"
	}


	vampire_outfit: {
		name: "Vampire Outfit"
		shortname: "[Vampire]"
		max: 3
		image:"http://images.kingdomofloathing.com/otherimages/sigils/dvotat7.gif"
		cat: "vampire"
		match: /unkula's (drinking|silky|cape)/
	}

	ring: {
		name: "Drunkula's ring of haze"
		shortname: "Ring"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_ring.gif"
		cat: "vampire"
	}

	glass: {
		name: "Drunkula's wineglass"
		shortname: "Wineglass"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_wineglass.gif"
		cat: "vampire"
	}

	bell: {
		name: "Drunkula's bell"
		shortname: "Bell"
		max: 1
		image: "http://images.kingdomofloathing.com/itemimages/dr_bell.gif"
		cat: "vampire"
	}
}

