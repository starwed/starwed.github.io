google.load("visualization", "1", {packages:["corechart"]})
google.load('visualization', '1', {packages: ['table']})



PointValue = {
	kills: 1,
	keys: 5,
	banishElement: 1,
	banishType: 1,
	losses: 0,
}

NewTally = () -> {
			kills: 0, 
			keys: 0,
			banishElement: 0,
			banishType: 0,
			losses: 0
		}



logit = (text) ->
	if (typeof console == "object")
		console.log(text)


loseSearch = /(.+) was defeated .*\((\d+) turn/
search = /(.+) defeated (\S+\s+\S+) .*\((\d+) turn/

elSearch = /(.+) made the (.+) less (\S+)/

keySearch = /(.+) unlocked (.+)\s+\(/

banishSearch = /(.+) drove some (.+) out of the (.+)/

ElementList = ['stench', 'cold', 'hot', 'sleaze', 'spooky' ]

MonsterList = ['skeleton', 'werewolf', 'zombie', 'ghost', 'vampire', 'bugbear']



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

}

instanceSummary = ()->
	html = ""
	banishedLine = (name)->
		if monsters[name] is 1
			html+= "<br/>&nbsp;&nbsp;&nbsp;" + "<i>#{name}</i> banished once"
		if monsters[name] is 2
			html+= "<br/>&nbsp;&nbsp;&nbsp;" + "<i>#{name}</i> banished twice"

	elementsLine = (el, area)->
		html+= "<br/> <b>#{area}  (kisses: " + (el.length+1) + ")</b> " 
		if (el.length is 5)
			html+= "<br/>&nbsp;&nbsp;&nbsp; <b><i>all</i></b> elements removed" 
		else if el.length is 0
			html+= "<br/>&nbsp;&nbsp;&nbsp; <i>No</i> elements removed" 
		else
			html+=  "<br/>&nbsp;&nbsp;&nbsp;" + el.join(", ") + " elements removed" 


	
	monsters = quickReport.banishedMonsters;
	html += "<b>Doors unlocked:</b> <br/>&nbsp;&nbsp;&nbsp;" + quickReport.unlockedDoors.join(", ")
	
	elementsLine(quickReport.forestElements, "Forest");	
	banishedLine("bugbears")
	banishedLine("werewolves")

	elementsLine(quickReport.villageElements, "Village");
	banishedLine("ghosts")
	banishedLine("zombies")

	elementsLine(quickReport.castleElements, "Castle");
	banishedLine("skeletons")
	banishedLine("vampires")

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
	for account, tally of accounts
		for action, times of tally
			#logit("#{action} #{times}")
			total[action]+=1.0*times
			if not Points?[account]?
				Points[account]=0
				RunPlayers.push(account)
			Points[account]+=PointValue[action] * times
	
	logit(total)
	calcCum()
	ChartResult(accounts)
	
	return
	# Calculate about how many of each monster is killed, according to the log
	Kills = new Object()
	for monster in MonsterList
		Kills[monster] = 1.0 * total[monster] + KillValue["multi_#{monster}"] * 1.0 * total["multi_#{monster}"]
		logit("#{monster} kills: #{Kills[monster]}")
	

	ChartResult(accounts, total)


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
		return name
	else
		accountNorm = account.trim().replace(/\s/g, "_").toLowerCase()
		for name, score of Points
			name2 = name.split("(")[0]
			norm = name2.trim().replace(/\s/g, "_").toLowerCase()
			if norm is accountNorm
				return name

	
	return account
		

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
		if(cumPoints[account])
			cumPoints[account] = cumPoints[account] * 1.0 + 1.0*score
		else
			cumPoints[account] = score
		thisRunPoints[account] = cumPoints[account]

	logit(cumPoints)

Process = (line) ->
	parsed = keySearch.exec(line)
	if (parsed?[1] and parsed?[2])
		
		pName = parsed[1];
		if not accounts?[pName]
			accounts[pName] = NewTally()	
		door = parsed[2];
		quickReport.unlockedDoors.push(door)
		accounts[pName].keys++
		return

	parsed = elSearch.exec(line)
	if (parsed?[1] and parsed?[2] and parsed?[3])
		pName = parsed[1];
		if not accounts?[pName]
			accounts[pName] = NewTally()	
		area = parsed[2];
		if area is "vilage"	#Stupid bugs
			area = "village"
		element = parsed[3];
		quickReport[area+"Elements"].push(styleElement(element))
		accounts[pName].banishElement++;
		return

	parsed = banishSearch.exec(line)
	if (parsed?[1] and parsed?[2] and parsed?[3])
		pName = parsed[1];
		if not accounts?[pName]
			accounts[pName] = NewTally()	
		area = parsed[3];
		if area is "vilage"	#Stupid bugs
			area = "village"
		monster = parsed[2];
		quickReport.banishedMonsters[monster]++
		accounts[pName].banishType++;
		return


	parsed = loseSearch.exec(line)
	if parsed?[1] and parsed?[2]
		pName = parsed[1]
		if not accounts?[pName]
			accounts[pName] = NewTally()
		number = parsed[2]
		accounts[pName].losses += parseFloat(number)
		return

	parsed = search.exec(line)
	if( parsed?[1] and parsed?[2] and parsed?[3])
		pName = parsed[1]
		if not accounts?[pName]
			accounts[pName] = NewTally()			
		
		killed = parsed[2]
		number = parsed[3]
		accounts[pName].kills+= parseFloat(number)
		return

		

ChartResult = (accounts, total) -> 

	data = new google.visualization.DataTable()



	data.addColumn('string', 'name')
	data.addColumn('string', 'kills')
	data.addColumn('string', 'keys')
	data.addColumn('string', 'element bans')
	data.addColumn('string', 'type bans')
	data.addColumn('string', 'points')

	###runData = new google.visualization.DataTable()

	runData.addColumn('string', 'name')
	runData.addColumn('number', 'points')
	runData.addColumn('string', 'OutfitMin')
	runData.addColumn('string', 'OutfitMax')
	runData.addColumn('string', 'StaffMin')
	runData.addColumn('string', 'StaffMax')###
	
	cumData = new google.visualization.DataTable()

	cumData.addColumn('string', 'name')
	cumData.addColumn('string', 'points')


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
				t['keys'].toString()
				t['banishElement'].toString()
				t['banishType'].toString()
				Points[a].toString()
			])

	for account, tally of accounts
		AddRow(tally, account)
		row++
	

	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(data, {showRowNumber:false} )




	#Points['Total']=0	
	#AddRow(total, 'Total')
	row=0
	for account, score of cumPoints
		cumData.addRows 1
		cumData.setValue(row, 0, account.toString() )
		cumData.setValue( row, 1, score.toString() )
		row++


	#Create an ordered list by points
	#orderedPoints = new Array()
	#for account, score of thisRunPoints
	table2 = new google.visualization.Table(document.getElementById('point_div'))
	table2.draw(cumData, {showRowNumber:false} )


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

	for name in RunPlayers
		account = name
		score = thisRunPoints[account]
		runData.addRows 1
		runData.setValue(row, 0, account.toString() )
		runData.setValue( row, 1, 1.0*score )
		if( hasOutfit(account) )
			runData.setValue( row, 2, "-" )
			runData.setValue( row, 3, "-" )
		else
			runData.setValue( row, 2, minO.toString() )
			runData.setValue( row, 3, (minO+1.0*score-1).toString() )
			minO=minO+1.0*score
			
		if( hasStaff(account))
			runData.setValue( row, 4, "-" )
			runData.setValue( row, 5, "-" )
		else
			runData.setValue( row, 4, minS.toString() )
			runData.setValue( row, 5, (minS+1.0*score-1).toString() )
			minS=minS+1.0*score
			
		row++
	
	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(data, {showRowNumber:false} )

	

	#, sortColumn: 1, sortAscending:false
	table3 = new google.visualization.Table(document.getElementById('c_div'))
	table3.draw(runData, {showRowNumber:false} )

	