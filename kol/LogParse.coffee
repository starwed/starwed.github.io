google.load("visualization", "1", {packages:["corechart"]})
google.load('visualization', '1', {packages: ['table']})



PointValue = {
	kills: 1,
	bossKills: 1,
	keys: 10,
	banishElement: 1,
	banishType: 1,
	losses: 0,
}

###
Blacklist of multis who don't get loot
	Maestro of Mariachi (#1873125)
	Sauciest Saucier (#1873222)
	Tzar of Turtles (#1873176)
littlelolligagged:	
	mommyneedssleep (#2051971)

###
Blacklist = [1873125, 1873222, 1873176, 2051971]

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
			bossKills: 0
		}



logit = (text) ->
	if (typeof console == "object")
		console.log(text)

bossMatch = /(.+) defeated (The Great Wolf of the Air|the Zombie Homeowners' Association|The Unkillable Skeleton|Falls-From-Sky|Mayor Ghost|Count Drunkula)\s+\((\d+) turn/
loseSearch = /(.+) was defeated .*\((\d+) turn/
search = /(.+) defeated (\S+)\s+(\S+) .*\((\d+) turn/

elSearch = /(.+) made the (.+) less (\S+)/

keySearch = /(.+) unlocked (.+)\s+\(/

banishSearch = /(.+) drove some (.+) out of the (.+)/

playerSearch = /(.+\(#\d+\))/

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


quickReport= {
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

monsterAlias = {
	zombies:"zombie", ghosts:"ghost", skeletons:"skeleton", vampires:"vampire", bugbears:"bugbear", werewolves: "werewolf"
}

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


	
	monsters = quickReport.banishedMonsters;
	mk = quickReport.monstersKilled
	html += "<b>Doors unlocked:</b> <br/>&nbsp;&nbsp;&nbsp;" + quickReport.unlockedDoors.join(", ")
	html += "<table style='font-size: 8px' id='zones'><tr><td>"
	elementsLine(quickReport.forestElements, "Forest");	
	banishedLine("bugbears")
	banishedLine("werewolves")
	if mk["the great wolf of the air"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Great Wolf slain</b>"
	if mk["falls-from-sky"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Falls-From-Sky slain</b>"

	html += "</td><td>"
	elementsLine(quickReport.villageElements, "Village");
	banishedLine("ghosts")
	banishedLine("zombies")
	if mk["mayor ghost"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Mayor Ghost slain</b>"
	if mk["the zombie homeowners' association"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>ZHO slain</b>"


	html += "</td><td>"
	elementsLine(quickReport.castleElements, "Castle");
	banishedLine("skeletons")
	banishedLine("vampires")
	if mk["count drunkula"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Count slain</b>"
	if mk["the unkillable skeleton"]
		html+="<br/>&nbsp;&nbsp;&nbsp;<b>Skelly slain</b>"


	html += "</td><tr></table>"
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
		accounts[pName].kills+= parseFloat(number)
		return

	parsed = playerSearch.exec(line)
	if (parsed?[1])
		pName = findAccount(parsed[1]);	

		

ChartResult = (accounts, total) -> 

	data = new google.visualization.DataTable()



	data.addColumn('string', 'name')
	data.addColumn('string', 'kills')
	data.addColumn('string', 'bosses')
	data.addColumn('string', 'keys [x10]')
	data.addColumn('string', 'el')
	data.addColumn('string', 'type')
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
				t['banishElement'].toString()
				t['banishType'].toString()
				parseFloat(Points[a])
			])

	for account, tally of accounts
		AddRow(tally, account)
		row++
	

	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(data, {showRowNumber:false, sortColumn:0} )



	pointsOut = ""
	#Points['Total']=0	
	#AddRow(total, 'Total')
	row=0
	cumArray = []
	for account, score of cumPoints		
		cumData.addRows 1
		cumData.setValue(row, 0, account.toString() )
		cumData.setValue( row, 1, parseFloat(score) )
		cumArray.push(account)
		row++

	cumArray.sort( (a,b)-> cumPoints[b]-cumPoints[a]) 
	for account in cumArray
		pointsOut+="#{account}\t#{cumPoints[account]}\n"
	table = new google.visualization.Table(document.getElementById('point_div'))
	table.draw(cumData, {showRowNumber:false, sortColumn:1, sortAscending:false} )
	document.getElementById('points-out').value = pointsOut
	#Create an ordered list by points


	row = 0
	RunPlayers.sort( (a, b)-> thisRunPoints[b] - thisRunPoints[a])
	wishlink = "http://alliancefromhell.com/viewtopic.php?f=13&t=5752"
	lootHtml = "<table id='lootTable'>"
	for name in RunPlayers

		account = name
		score = thisRunPoints[account]
		lootHtml+= "<tr><td><b>#{name}</b> </td><td>#{score}</td></tr>"

		
			
		row++
		break if row>10

	lootHtml+= "</table><br/><a target='_blank' href='#{wishlink}'>Wishlists</a>"
	distroArea = document.getElementById('distro')
	distroArea.insertAdjacentHTML("beforeend", lootHtml);





	return




	### Everything below here was HSH specific
	row=0
	minO=1
	minS=1
	#for account, score of thisRunPoints
	hasOutfit = (p) -> 
		if outfit[p]==true 
			return true 
		else 
			return false


	hasStaff = (p) -> 
		if staff[p]==true 
			return true 
		else 
			return false



	sortEquip = (p) -> 
		sortpoint=1
		if hasStaff(p)==true 
			if hasOutfit(p)==true
				return 0
			else 
				return 5
		else
			if hasOutfit(p)==true
				return 1
			else
				return 3

	RunPlayers.sort( (a,b)-> sortEquip(b) - sortEquip(a) )
	#RunPlayers.sort()

	

	