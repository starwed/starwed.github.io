
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



clanWants = {
	
}

percentagesComplete = {}
clanSize = 0


createRowData = (tableData)->
	accounts = {}
	clanSize = 0
	for row in tableData
		
		continue if not row?[0]?
		name = row[0].trim().toLowerCase().replace(/\s/g, "_")
		accounts[name] = {}
		clanSize++
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
			else if /\bno?\b/.exec(text) isnt null  # Matches "n" or "no" if they're not just part of a word
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
				else if pnumber < 0
					has = dropList[item].max
				else 
					has = 0



			if has >= dropList[item].max
				pnumber = -100
			else
				if not clanWants[item]?
					clanWants[item] = 0
				clanWants[item] += (dropList[item].max - has)

			accounts[name][item]={has:has, priority:pnumber, text:text}


	# Measure clan completion
	catsComplete = {}
	for item, wants of clanWants
		logit("#{item}:#{wants}")
		max = dropList[item].max
		percentagesComplete[item] = 1 - wants / (max * clanSize)
		cat = dropList[item].cat
		if not catsComplete[cat]?
			catsComplete[cat] = {size: 0, wanted:0, hmsize:0, hmwanted:0, outfitsize:0, outfitwanted:0}
		if max is 1
			catsComplete[cat].hmsize += clanSize
			catsComplete[cat].hmwanted += wants
		else if max is 3
			catsComplete[cat].outfitsize += clanSize * 3
			catsComplete[cat].outfitwanted += wants

		catsComplete[cat].size += max*clanSize
		catsComplete[cat].wanted += wants
	logit(percentagesComplete)
	for cat, info of catsComplete
		completion = 1 - info.wanted/info.size
		completion = Math.floor( completion*1000)/10
		
		if info.hmsize>0
			hmcompletion = 1 - info.hmwanted/info.hmsize
			hmcompletion = Math.floor( hmcompletion*1000)/10
			#console.log("HM #{cat} is at #{completion}% completion")
		if info.outfitsize > 0
			outfitcompletion = 1 - info.outfitwanted/info.outfitsize
			outfitcompletion = Math.floor( outfitcompletion*1000)/10
			logit("#{cat}\t #{outfitcompletion}\t#{hmcompletion}\t#{completion}")
		else
			logit("Capacitor is at #{completion}% completion")

	return accounts
				
			

displayGet = (gets)->
		if gets.length>0
			return gets.toString()
		else
			return "--"

createTable = (tableData, columns, distroList, lootList)->
	$table = $("<table/>")
	$table.addClass("table").addClass("table-striped")
	
	$thr = $("<tr/>")
	lastcat = null
	for i in columns	
		item = spreadsheet_key[i]
		if item is "name" 
			$thr.append("<th>Name</th>")
		else
			drop = dropList[item]
			if lootList[item]>1
				num = " (x" + lootList[item] + ")"
			else
				num = ''
			$thr.append("<th class='#{drop.cat}'>#{drop.shortname}#{num}</th>")
	$thr.append("<th class='loot'>Distro</th>")
	$table.append($thr)
	row_list = []
	accounts = createRowData(tableData)


	# step through and interpret the data; create a table and figure out priorities
	for name, wishes of accounts
		distroPriority = distroList.indexOf(name)
		continue if distroPriority<0
		$tr = $("<tr/>")

		for i in columns
			if i is 0 
				cl = "name"
				text = name
				item = "name"
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
			$tr.append("<td id='#{name}-#{item}' class='#{cl}'>#{text}</td>")

		row_list.push({el:$tr, priority:distroPriority, wishes:wishes, name:name, gets:[]})


	$("#loot-table-holder").append($table)
	row_list.sort( (a, b)-> a.priority-b.priority)

	countLootLeft = (list)->
		n = 0
		for item, number of list
			n+=number
		return n
	l = countLootLeft(lootList)

	# Loop while we have loot left
	leftover = []
	
	while(l>0)
		assignLoot(row_list, lootList, $table)
		# Break if no loot was distributed this time, because we're done!
		if (countLootLeft(lootList)==l)
			for item, number of lootList
				leftover.push("#{item} (#{number})") if number >0
			break;
		else
			l = countLootLeft(lootList)

	

	# after all loot has been assigne
	for row in row_list
		row.el.append("<td>#{displayGet(row.gets)}</td>")
		$table.append(row.el)



	
	return [row_list, leftover]


assignLoot= (row_list, lootList, $table)->
	for row in row_list
		
		gets = null
		currentPriority = Infinity
		for item, data of row.wishes
			if lootList[item]? and lootList[item] > 0
				if data.priority<=currentPriority and data.priority>=0 and row.gets.indexOf(item)<0
					currentPriority = data.priority
					gets = item
		if gets?
			lootList[gets]--
			$("##{row.name}-#{gets}", row.el).addClass("default-distro")
			logit("#{row.name}-#{gets}")
			row.gets.push(gets)
			
		
		
		



	
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

	for item, i in spreadsheet_key
		if lootList[item]?
			columns.push(i)


	doitall = (d)->
		tableData = parseCells(d)
		[rowList, leftover] = createTable(tableData, columns, distroList, lootList)
		getList = {}
		for row in rowList
			getList[row.name] = row.gets
		loot_left = leftover.join(", ")
		
		
		callback(getList, loot_left)

	key = "0AvrVWFdz4jg1dGp3RnVtUGZkak12dnFyVjBXYjlkdHc"
		  
	url = "https://spreadsheets.google.com/feeds/cells/#{key}/od6/public/values?alt=json-in-script&callback=?";
	$.getJSON(url,{},  doitall);
	return



#$( ()->window.getWishes())

# these match the columns of the psreadsheet to the correct items
spreadsheet_key = [
	"name"
	"bugbear_outfit", "pyj", "qys", "hys",
	"wolf_outfit", "lice", "rocket", "trousers",
	"ghost_outfit", "scissors", "sash", "gavel",
	"zombie_outfit", "book", "eyes", "pad",
	"skeleton_outfit", "sword", "leg", "shield",
	"vampire_outfit",  "glass", "bell", "ring"
	"capacitor"]


# Properties of the boss drops to be distributed
window.dropList = dropList = {
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

