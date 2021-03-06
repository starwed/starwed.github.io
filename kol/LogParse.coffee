google.load("visualization", "1", {packages:["corechart"]})
google.load('visualization', '1', {packages: ['table']})



window.toggleDistro = (target, name)->
	logit("Distro toggle #{name}")
	target.style.textDecoration = "line-through"

PointValue = {
	kills: 1,
	bossKills: 1,
	keys: 1,
	banishElement: 10,
	banishType: 10,
	losses: 0,
	tasks: 5
}

###
Blacklist of multis who don't get loot
(clan multis)	
	Maestro of Mariachi (#1873125)
	Sauciest Saucier (#1873222)
	Tzar of Turtles (#1873176)
	Potentate of Pasta (#1873602)
	Duke of Disco (#1873203)
	Scourge of Seals (#1873601)
(littlelolligagged)
	mommyneedssleep (#2051971)
	Rises From Earth (#2423706)
###

Blacklist = [1873125, 1873222, 1873176, 2051971, 1873602, 1873203, 1873601, 2423706]


Wishlist = {




}





checkBlacklist = (account)->
	for num in Blacklist
		if account.indexOf(num) > -1
			logit("Blacklisted #{account}!")
			return true

	return false

NewTally = () -> {
			kills: 0, 
			keys: 0,
			banishElement: 0,
			banishType: 0,
			losses: 0,
			bossKills: 0,
			tasks: 0
		}



logit = (text) ->
	if (typeof console == "object")
		console.log(text)


kissMatch = /(\d+) kisses earned in this dungeon so far./

bossMatch = /(.+) defeated (The Great Wolf of the Air|the Zombie Homeowners' Association|The Unkillable Skeleton|Falls-From-Sky|Mayor Ghost|Count Drunkula)\s+\((\d+) turn/
loseSearch = /(.+) was defeated .*\((\d+) turn/
search = /(.+) defeated (\S+)\s+(\S+) .*\((\d+) turn/

elSearch = /(.+) made the (.+) less (\S+)/

keySearch = /(.+) unlocked (.+)\s+\(/

banishSearch = /(.+) drove some (.+) out of the (.+)/

distroSearch = /(.+) distributed/

playerSearch = /(.+\(#\d+?\))/

ElementList = ['stench', 'cold', 'hot', 'sleaze', 'spooky' ]

MonsterList = ['skeleton', 'werewolf', 'zombie', 'ghost', 'vampire', 'bugbear']


importantItems = {
	banana:		/(.+) got a wax banana/
	amber:		/(.+) acquired a chunk of moon-amber/
	musicbox:	/(.+) made the forest less spooky/
	roast:    	/(.+) got some roast beast/
	agaric:  	/(.+) got some stinking agaric/ 
	kiwi:		/(.+) got a blood kiwi/
}


worthyTasks = {
	polish: /(.+) polished some moon-amber/
	replica: /(.+) made a complicated key/
	flour: /(.+) made some bone flour/
	impression: /(.+) made an impression of a complicated lock/
}

looters ={
	pencils: /(.+) collected a ghost pencil /

	newspapers: /(.+) recycled some newspapers/
	locker: /(.+) rifled through a footlocker/
	garbage: /(.+) found and sold a rare baseball card/
	graves: /(.+) robbed some graves/
	dresser: /(.+) raided a dresser/
	ashes: /(.+) sifted through some ashes/
	shack: /(.+) looted the tinker's shack/
	till: /(.+) looted the blacksmith's till/
}

lootCount ={
	pencils:0 

	newspapers: 0
	locker: 0
	garbage: 0
	graves: 0
	dresser: 0
	ashes: 0
	shack: 0
	till: 0
}

onceChecklist = {
	banana: false
	amber: false
	musicbox: false
	roast: false
	agaric: false
	kiwi: false

}


quickReport= {
	totalLosses: 0
	totalKills: 0
	villageElements: []
	forestElements: []
	castleElements: []
	unlockedDoors: []
	banishedMonsters:{
		zombies:0,
		ghosts:0,
		skeletons:0
		vampires:0
		bugbears:0
		werewolves:0


	}
	monstersKilled:{
		zombie:0,
		ghost:0,
		skeleton:0
		vampire:0
		bugbear:0
		werewolf:0


	}

}


bossKills = {
	forest: null,
	village: null,
	castle: null


}
monsterAlias = {
	zombies:"zombie", ghosts:"ghost", skeletons:"skeleton", vampires:"vampire", bugbears:"bugbear", werewolves: "werewolf"
}

#scope cumArray
cumArray = null
savedGetList = null
savedLeftovers = null

instanceSummary = ()->
	html = ""

	banishedLine = (name)->
		html += "<br/>&nbsp;&nbsp;&nbsp;" + "<i>#{name}:</i> " + quickReport.monstersKilled[monsterAlias[name]] + " kills"
		if monsters[name] is 1
			html+=  ", banished once"
		if monsters[name] is 2
			html+= ", banished twice"

	elementsLine = (el, area)->
		html+= "<br/> <b>#{area}  (kisses: " + (el.length+1) + ")</b> " 
		if (el.length is 5)
			html+= "<br/>&nbsp;&nbsp;&nbsp; <b><i>all</i></b> elements removed" 
		else if el.length is 0
			html+= "<br/>&nbsp;&nbsp;&nbsp;<i>No</i> elements removed" 
		else
			html+=  "<br/>&nbsp;&nbsp;&nbsp;" + el.join(", ") + " elements removed" 

	html+= "#{quickReport.totalKisses} total kisses, #{quickReport.totalKills} kills, #{quickReport.totalLosses} losses, #{parseFloat(quickReport.totalKisses) + quickReport.totalLosses} earned"
	
	monsters = quickReport.banishedMonsters;
	mk = quickReport.monstersKilled
	

	



	html += "<table style='font-size: 8px' id='zones'><tr><td>"
	elementsLine(quickReport.forestElements, "Forest");	
	banishedLine("bugbears")
	banishedLine("werewolves")
	if mk["the great wolf of the air"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Great Wolf slain</b>"
		bossKills.forest = "wolf"
	if mk["falls-from-sky"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Falls-From-Sky slain</b>"
		bossKills.forest = "bugbear"

	html += "</td><td>"
	elementsLine(quickReport.villageElements, "Village");
	banishedLine("ghosts")
	banishedLine("zombies")
	if mk["mayor ghost"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Mayor Ghost slain</b>"
		bossKills.village = "ghost"
	if mk["the zombie homeowners' association"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>ZHO slain</b>"
		bossKills.village = "zombie"


	html += "</td><td>"
	elementsLine(quickReport.castleElements, "Castle");
	banishedLine("skeletons")
	banishedLine("vampires")
	if mk["count drunkula"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Count slain</b>"
		bossKills.castle = "vampire"
	if mk["the unkillable skeleton"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Skelly slain</b>"
		bossKills.castle = "skeleton"


	html += "</td><tr></table>"


	html += "<br/><b>Doors unlocked:</b> <br/>&nbsp;&nbsp;&nbsp;" + quickReport.unlockedDoors.join(", ")
	
	html += "<br/> <b>1/dungeon tasks accomplished:</b> <br/>&nbsp;&nbsp;&nbsp;"
	checks = []
	for item, state of onceChecklist
		style = if state is true then "color: green; font-weight: bold" else "color: grey"
		checks.push("<span style='#{style}'>#{item}</span>")
	html += checks.join(", ")

	html += "<br/> <b>10/dungeon loot left:</b> <br/>&nbsp;&nbsp;&nbsp;"
	counts = []
	for item, number of lootCount
		style = if number is 10 then "color: grey; text-decoration: line-through" else "color: black"
		counts.push("<span style='#{style}'>#{item}: #{10-number}</span>")
	html+=counts.join(", ")
	document.getElementById("sum").insertAdjacentHTML("beforeend", html);


styleElement = (el)->
	el = el.trim()
	switch el
		when "stench", "stink", "stinky"
			color = "green"
		when "sleaze", "sleazy"
			color = "purple"
		when "hot"
			color = "red"
		when "cold"
			color = "blue"
		when "spooky"
			color = "grey"
	return "<b style='color:#{color}'>" + el + "</b>"


sheetSearch = /(.+) got the carriageman (.+) sheet/

miscNC = {
	#woods	
	baseball: "rare baseball card"
	footlocker: "rifled through a footlocker"
	newspapers: "recycled some newspapers"
	coals: 		"got intimate with some hot coals"
	tarragon: "dread tarragon"
	seedpod: "cool seed pod"
	lock: "made an impression"
	auditor: "auditor's badge "
	amber: "acquired a chunk of moon"
	heart: "listened to the forest's heart"

	#castle
	ashes: "sifted through some ashes"
	dresser: "raided a dresser"
	secrets: "read some ancient secrets"
	spores: "rolled around in some mushrooms"
	agaric: "got some stinking agaric"
	frolic: "frolicked in a freezer"
	wax: "got a wax banana"
	beast: "got some roast beast"

	#village (vilage)
	till: "looted the blacksmith's till"
	robbed: "robbed some graves"
	hung: "was hung by a clanmate"
	execute: "hung a clanmate "
	fuse: "got some old fuse"
	cabinets: "raided some naughty cabinets"
	pencil: "collected a ghost pencil"
	shelves: "looted the tinker's shack "
}

# Folk with the complete set
AllPlayers = new Array()
RunPlayers = new Array()


cumPoints = new Object()
thisRunPoints = new Object()


accounts = new Object()




Points = new Object()

Loot = ""
window.Run = () ->
	#pointOverride = document.getElementById('points').value
	#if(pointOverride.length>1)
	#		PointValue=eval(pointOverride)

	RunPlayers= new Array()
	AllPlayers = new Array()


	accounts = new Object()
	Points = new Object()
	text =document.getElementById('in').value
	text = text.replace("(unknown action: v_cold)", " made the village less cold")

	Loot = document.getElementById('dropped_loot').value

	textArray = text.split('\n')
	for line in textArray
		Process(line)
	#logit(accounts)
	instanceSummary()




	
	

	total = NewTally()

	# Calculate points
	for account, tally of accounts
		continue if checkBlacklist(account)
		for action, times of tally
			#logit("#{action} #{times}")
			total[action]+=1.0*times
			if not Points?[account]?
				Points[account]=0
				RunPlayers.push(account)
			Points[account]+=PointValue[action] * times
	
	# Now cumulative points
	calcCum()

	# Print to screen
	ChartResult(accounts)
	
	return


getAccountName = (account)->
	if(Points[account])
		return account
	

	numsearch=/\(.+\)/
	matcher = numsearch.exec(account)
	if(matcher)
		number = matcher[0]
		for name, score of Points
			if name.search(number) > -1
				return name 
	else
		accountNorm = account.trim().replace(/\s/g, "_").toLowerCase()
		for name, score of Points
			name2 = name.split("(")[0]
			norm = name2.trim().replace(/\s/g, "_").toLowerCase()
			if norm is accountNorm
				return name

	
	return account.trim()
		

staff = new Object()
outfit = new Object()


calcCum = () ->
	cumPoints = new Object()
	staff = new Object()
	outfit = new Object()
	thisRunPoints = new Object()
	prior = document.getElementById('prior').value
	searchOldScore=/(.+)\t\s*(\d+)/
	oldScores = prior.split('\n')
	logit('Old scores')
	

	
	for line in oldScores
		parsed = line.split(/\t|\s\s+/)
		if parsed?[0] and parsed?[1]
			key=getAccountName(parsed[0])
			cumPoints[key] = parsed[1]
			AllPlayers.push(key)

	for account, score of Points
		continue if checkBlacklist(account)
		if(cumPoints[account])
			cumPoints[account] = cumPoints[account] * 1.0 + 1.0*score
		else
			cumPoints[account] = score
		thisRunPoints[account] = cumPoints[account]





Process = (line) ->
	findAccount = (name)->
		acc = getAccountName(name)
		if not accounts?[acc]
			accounts[acc] = NewTally()
		return acc

	parsed = kissMatch.exec(line)
	if parsed?[1]
		quickReport.totalKisses = parsed[1]
		return


	for item, itemSearch of importantItems
		parsed = itemSearch.exec(line)
		if (parsed?[1])
			pName = findAccount(parsed[1]);	
			onceChecklist[item] = true

	parsed = keySearch.exec(line)
	if (parsed?[1] and parsed?[2])
		
		pName = findAccount(parsed[1]);
	
		door = parsed[2];
		quickReport.unlockedDoors.push(door)
		accounts[pName].keys++
		return

	parsed = elSearch.exec(line)
	if (parsed?[1] and parsed?[2] and parsed?[3])
		pName = findAccount(parsed[1]);
		area = parsed[2];
		if area is "vilage"	#Stupid bugs
			area = "village"
		element = parsed[3];
		quickReport[area+"Elements"].push(styleElement(element))
		accounts[pName].banishElement++;
		return

	parsed = banishSearch.exec(line)
	if (parsed?[1] and parsed?[2] and parsed?[3])
		pName = findAccount(parsed[1]);
		area = parsed[3];
		if area is "vilage"	#Stupid bugs
			area = "village"
		monster = parsed[2];
		quickReport.banishedMonsters[monster]++
		accounts[pName].banishType++;
		return


	parsed = loseSearch.exec(line)
	if parsed?[1] and parsed?[2]
		pName = findAccount(parsed[1]);
		number = parsed[2]
		accounts[pName].losses += parseFloat(number)
		quickReport.totalLosses+= parseFloat(number)
		return

	
	parsed = bossMatch.exec(line)
	if (parsed?[1] and parsed?[2] and parsed?[3])
		pName = findAccount(parsed[1]);			
		bossKill = parsed?[2].trim().toLowerCase()
		if not quickReport.monstersKilled[bossKill]
			quickReport.monstersKilled[bossKill] = 0;
		quickReport.monstersKilled[bossKill]++
		accounts[pName].bossKills+= 1
		return

	parsed = search.exec(line)
	if( parsed?[1] and parsed?[2] and parsed?[3] and parsed?[4])
		pName = findAccount(parsed[1]);	
		elementKill = parsed[2]
		typeKill = parsed[3]
		number = parsed[4]
		quickReport.monstersKilled[typeKill]+= parseFloat(number)	
		quickReport.totalKills += parseFloat(number)	
		accounts[pName].kills+= parseFloat(number)
		return

	

	for task, taskSearch of worthyTasks
		parsed = taskSearch.exec(line)
		if (parsed?[1])
			pName = findAccount(parsed[1]);	
			accounts[pName].tasks++
			return

	for lootedThing, lootSearch of looters
		parsed = lootSearch.exec(line)
		if (parsed?[1])
			pName = findAccount(parsed[1]);	
			lootCount[lootedThing]++
			return

	parsed = distroSearch.exec(line)
	if (parsed?[1])
		return

	parsed = playerSearch.exec(line)
	if (parsed?[1])
		pName = findAccount(parsed[1]);	

		

ChartResult = (accounts, total) -> 

	data = new google.visualization.DataTable()



	data.addColumn('string', 'name')
	data.addColumn('string', 'kills')
	data.addColumn('string', 'bosses')
	data.addColumn('string', 'keys')
	data.addColumn('string', 'banish')
	data.addColumn('string', 'tasks(5)')
	data.addColumn('number', 'points')

	runData = new google.visualization.DataTable()

	runData.addColumn('string', 'name')
	runData.addColumn('number', 'points')

	cumData = new google.visualization.DataTable()

	cumData.addColumn('string', 'name')
	cumData.addColumn('number', 'points')


	row = 0

	SetRow = (r) ->
		for d,i in r
			#logit("#{d}, #{i}")
			data.setValue(row, i, d)

	AddRow = (t,a) ->
		data.addRows 1
		SetRow( [
				a.toString() 
				t['kills'].toString()
				t['bossKills'].toString()
				t['keys'].toString()
				(t.banishElement + t.banishType).toString()
				t.tasks.toString()
				parseFloat(Points[a])
			])

	for account, tally of accounts
		AddRow(tally, account)
		row++
	

	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(data, {showRowNumber:false, sortColumn:0} )




	row=0
	cumArray = []
	for account, score of cumPoints		
		cumData.addRows 1
		cumData.setValue(row, 0, account.toString() )
		cumData.setValue( row, 1, parseFloat(score) )
		cumArray.push(account)
		row++

	cumArray.sort( (a,b)-> cumPoints[b]-cumPoints[a]) 

	base_match = /(.+)\(/
	distroList = []
	
	MakePointsOut(cumArray)
		
	table = new google.visualization.Table(document.getElementById('point_div'))
	table.draw(cumData, {showRowNumber:false, sortColumn:1, sortAscending:false} )
	
	#Create an ordered list by points


	row = 0
	RunPlayers.sort( (a, b)-> thisRunPoints[b] - thisRunPoints[a])
	#wishlink = "http://alliancefromhell.com/viewtopic.php?f=13&t=5752"
	
	wishlink = "https://docs.google.com/spreadsheet/ccc?key=0AvrVWFdz4jg1dGp3RnVtUGZkak12dnFyVjBXYjlkdHc#gid=0"
	lootHtml = "<table class='table table-striped' id='lootTable'>"
	for name in RunPlayers

		account = name
		score = thisRunPoints[account]
		
		base_name = base_match.exec(account)
		if base_name?[1]?
			base_name = base_name[1].trim().toLowerCase().replace(/\s/g, "_")
			distroList.push(base_name)
		else
			base_name = "0"

		lootHtml+= """<tr><td onclick='toggleDistro(this, "#{name}")'><b>#{name}</b></td><td>#{score}</td><td class='loot-suggestion' id='loot-#{base_name}'></td></tr>"""
		
			
		row++
		break if row>30

	lootHtml+= "</table><br/><a target='_blank' href='#{wishlink}'>Wishlists</a><br/><small>Parsed wishlist will load at the bottom of the page</small>"
	distroArea = document.getElementById('distro')
	distroArea.insertAdjacentHTML("beforeend", lootHtml);
	$("#distro-blurb").text("(Loading wish list spreadsheet...)")
	window.MakeDistroTable(bossKills, distroList, Loot, (list, leftover)->MakeLootTable(RunPlayers, list, leftover))

	return



getBaseName = (account)->
	base_match = /(.+)\(/
	base_name = base_match.exec(account)
	if base_name[1]?
		return base_name[1].trim().toLowerCase().replace(/\s/g, "_")
	else
		return null


MakeLootTable = (RunPlayers, getList, leftover)->
	wishlink = "http://alliancefromhell.com/viewtopic.php?f=13&t=5752"
	
	lootHtml = "<table id='lootTable'>"
	
	row = 0
	for name in RunPlayers

		account = name
		base_name = getBaseName(account)

		
		if base_name? and getList[base_name]?
			gets = getList[base_name].join(", ")
		else
			gets = "???"
		$("#loot-#{base_name}").text(gets)		
			
		row++
		break if row>20
	$("#distro-blurb").text("(Items are suggestions only)")
	savedGetList = getList
	
	
	if leftover.length>0
		savedLeftovers = leftover
		$(document.getElementById("smash-list")).text(leftover)
		document.getElementById("smash-div").hidden = false

	if document.getElementById("zero").checked is true
		zeroOut(true)

	

window.zeroOut = (state)->
	if state is true and savedGetList?
		MakePointsOut(cumArray, savedGetList, savedLeftovers)
	else
		MakePointsOut(cumArray)






MakePointsOut = (cumArray, getList, leftover)->
	pointsOut = ""
	base_match = /(.+)\(/
	preamble = ""

	for account in cumArray
		newpoints = points = cumPoints[account]

		if getList?
			base_name = getBaseName(account)
			gets = getList[base_name]
			if gets?.length>0
				newpoints = Math.max(points - 1000, 0)
				drops = [];
				#drop = dropList[gets].name
				for item in gets
					drop = dropList[item].name
				
					if item is "capacitor"
						drop = "[b]#{drop}[/b]"
					drops.push(drop)

				if drops.length>1
					drops = "(#{drops.join(', ')})"
				else
					drops = drops[0]
				preamble += "\n #{account} gets #{drops} for #{points-newpoints} points"

		pointsOut+="#{account}\t#{newpoints}\n"
	if leftover?.length>0
		preamble += "\n\n [b]The following loot had no home:[/b] #{leftover}"

	pointsOut = "#{preamble}\n\n[code]\n#{pointsOut}[/code]"
	document.getElementById('points-out').value = pointsOut


	