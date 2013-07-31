// Generated by CoffeeScript 1.4.0
(function() {
  var AllPlayers, ChartResult, ElementList, MonsterList, NewTally, PointValue, Points, Process, RunPlayers, accounts, banishSearch, calcCum, cumPoints, elSearch, getAccountName, instanceSummary, keySearch, logit, loseSearch, miscNC, outfit, quickReport, search, sheetSearch, staff, styleElement, thisRunPoints;

  google.load("visualization", "1", {
    packages: ["corechart"]
  });

  google.load('visualization', '1', {
    packages: ['table']
  });

  PointValue = {
    kills: 1,
    keys: 5,
    banishElement: 1,
    banishType: 1,
    losses: 0
  };

  NewTally = function() {
    return {
      kills: 0,
      keys: 0,
      banishElement: 0,
      banishType: 0,
      losses: 0
    };
  };

  logit = function(text) {
    if (typeof console === "object") {
      return console.log(text);
    }
  };

  loseSearch = /(.+) was defeated .*\((\d+) turn/;

  search = /(.+) defeated (\S+\s+\S+) .*\((\d+) turn/;

  elSearch = /(.+) made the (.+) less (\S+)/;

  keySearch = /(.+) unlocked (.+)\s+\(/;

  banishSearch = /(.+) drove some (.+) out of the (.+)/;

  ElementList = ['stench', 'cold', 'hot', 'sleaze', 'spooky'];

  MonsterList = ['skeleton', 'werewolf', 'zombie', 'ghost', 'vampire', 'bugbear'];

  quickReport = {
    villageElements: [],
    forestElements: [],
    castleElements: [],
    unlockedDoors: [],
    banishedMonsters: {
      zombies: 0,
      ghosts: 0,
      skeletons: 0,
      vampires: 0,
      bugbears: 0,
      werewolves: 0
    }
  };

  instanceSummary = function() {
    var banishedLine, elementsLine, html, monsters;
    html = "";
    banishedLine = function(name) {
      if (monsters[name] === 1) {
        html += "<br/>&nbsp;&nbsp;&nbsp;" + ("<i>" + name + "</i> banished once");
      }
      if (monsters[name] === 2) {
        return html += "<br/>&nbsp;&nbsp;&nbsp;" + ("<i>" + name + "</i> banished twice");
      }
    };
    elementsLine = function(el, area) {
      html += ("<br/> <b>" + area + "  (kisses: ") + (el.length + 1) + ")</b> ";
      if (el.length === 5) {
        return html += "<br/>&nbsp;&nbsp;&nbsp; <b><i>all</i></b> elements removed";
      } else if (el.length === 0) {
        return html += "<br/>&nbsp;&nbsp;&nbsp; <i>No</i> elements removed";
      } else {
        return html += "<br/>&nbsp;&nbsp;&nbsp;" + el.join(", ") + " elements removed";
      }
    };
    monsters = quickReport.banishedMonsters;
    html += "<b>Doors unlocked:</b> <br/>&nbsp;&nbsp;&nbsp;" + quickReport.unlockedDoors.join(", ");
    elementsLine(quickReport.forestElements, "Forest");
    banishedLine("bugbears");
    banishedLine("werewolves");
    elementsLine(quickReport.villageElements, "Village");
    banishedLine("ghosts");
    banishedLine("zombies");
    elementsLine(quickReport.castleElements, "Castle");
    banishedLine("skeletons");
    banishedLine("vampires");
    return document.getElementById("sum").insertAdjacentHTML("beforeend", html);
  };

  styleElement = function(el) {
    var color;
    el = el.trim();
    switch (el) {
      case "stench":
      case "stink":
      case "stinky":
        color = "green";
        break;
      case "sleaze":
      case "sleazy":
        color = "purple";
        break;
      case "hot":
        color = "red";
        break;
      case "cold":
        color = "blue";
        break;
      case "spooky":
        color = "grey";
    }
    return ("<b style='color:" + color + "'>") + el + "</b>";
  };

  sheetSearch = /(.+) got the carriageman (.+) sheet/;

  miscNC = {
    baseball: "rare baseball card",
    footlocker: "rifled through a footlocker",
    newspapers: "recycled some newspapers",
    coals: "got intimate with some hot coals",
    tarragon: "dread tarragon",
    seedpod: "cool seed pod",
    lock: "made an impression",
    auditor: "auditor's badge ",
    amber: "acquired a chunk of moon",
    heart: "listened to the forest's heart",
    ashes: "sifted through some ashes",
    dresser: "raided a dresser",
    secrets: "read some ancient secrets",
    spores: "rolled around in some mushrooms",
    agaric: "got some stinking agaric",
    frolic: "frolicked in a freezer",
    wax: "got a wax banana",
    beast: "got some roast beast",
    till: "looted the blacksmith's till",
    robbed: "robbed some graves",
    hung: "was hung by a clanmate",
    execute: "hung a clanmate ",
    fuse: "got some old fuse",
    cabinets: "raided some naughty cabinets",
    pencil: "collected a ghost pencil",
    shelves: "looted the tinker's shack "
  };

  AllPlayers = new Array();

  RunPlayers = new Array();

  cumPoints = new Object();

  thisRunPoints = new Object();

  accounts = new Object();

  Points = new Object();

  window.Run = function() {
    var Kills, account, action, line, monster, tally, text, textArray, times, total, _i, _j, _len, _len1;
    RunPlayers = new Array();
    AllPlayers = new Array();
    accounts = new Object();
    Points = new Object();
    text = document.getElementById('in').value;
    text = text.replace("(unknown action: v_cold)", " made the village less cold");
    textArray = text.split('\n');
    for (_i = 0, _len = textArray.length; _i < _len; _i++) {
      line = textArray[_i];
      Process(line);
    }
    instanceSummary();
    total = NewTally();
    for (account in accounts) {
      tally = accounts[account];
      for (action in tally) {
        times = tally[action];
        total[action] += 1.0 * times;
        if (!((Points != null ? Points[account] : void 0) != null)) {
          Points[account] = 0;
          RunPlayers.push(account);
        }
        Points[account] += PointValue[action] * times;
      }
    }
    logit(total);
    calcCum();
    ChartResult(accounts);
    return;
    Kills = new Object();
    for (_j = 0, _len1 = MonsterList.length; _j < _len1; _j++) {
      monster = MonsterList[_j];
      Kills[monster] = 1.0 * total[monster] + KillValue["multi_" + monster] * 1.0 * total["multi_" + monster];
      logit("" + monster + " kills: " + Kills[monster]);
    }
    return ChartResult(accounts, total);
  };

  getAccountName = function(account) {
    var accountNorm, matcher, name, name2, norm, number, numsearch, score;
    if (Points[account]) {
      return account;
    }
    numsearch = /\(.+\)/;
    matcher = numsearch.exec(account);
    if (matcher) {
      number = matcher[0];
      for (name in Points) {
        score = Points[name];
        if (name.search(number) > -1) {
          return name;
        }
      }
    } else {
      accountNorm = account.trim().replace(/\s/g, "_").toLowerCase();
      for (name in Points) {
        score = Points[name];
        name2 = name.split("(")[0];
        norm = name2.trim().replace(/\s/g, "_").toLowerCase();
        if (norm === accountNorm) {
          return name;
        }
      }
    }
    return account;
  };

  staff = new Object();

  outfit = new Object();

  calcCum = function() {
    var account, key, line, oldScores, parsed, prior, score, searchOldScore, _i, _len;
    cumPoints = new Object();
    staff = new Object();
    outfit = new Object();
    thisRunPoints = new Object();
    prior = document.getElementById('prior').value;
    searchOldScore = /(.+)\t\s*(\d+)/;
    oldScores = prior.split('\n');
    logit('Old scores');
    for (_i = 0, _len = oldScores.length; _i < _len; _i++) {
      line = oldScores[_i];
      parsed = line.split(/\t|\s\s+/);
      if ((parsed != null ? parsed[0] : void 0) && (parsed != null ? parsed[1] : void 0)) {
        key = getAccountName(parsed[0]);
        cumPoints[key] = parsed[1];
        AllPlayers.push(key);
      }
    }
    for (account in Points) {
      score = Points[account];
      if (cumPoints[account]) {
        cumPoints[account] = cumPoints[account] * 1.0 + 1.0 * score;
      } else {
        cumPoints[account] = score;
      }
      thisRunPoints[account] = cumPoints[account];
    }
    return logit(cumPoints);
  };

  Process = function(line) {
    var area, door, element, killed, monster, number, pName, parsed;
    parsed = keySearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0)) {
      pName = parsed[1];
      if (!(accounts != null ? accounts[pName] : void 0)) {
        accounts[pName] = NewTally();
      }
      door = parsed[2];
      quickReport.unlockedDoors.push(door);
      accounts[pName].keys++;
      return;
    }
    parsed = elSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0)) {
      pName = parsed[1];
      if (!(accounts != null ? accounts[pName] : void 0)) {
        accounts[pName] = NewTally();
      }
      area = parsed[2];
      if (area === "vilage") {
        area = "village";
      }
      element = parsed[3];
      quickReport[area + "Elements"].push(styleElement(element));
      accounts[pName].banishElement++;
      return;
    }
    parsed = banishSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0)) {
      pName = parsed[1];
      if (!(accounts != null ? accounts[pName] : void 0)) {
        accounts[pName] = NewTally();
      }
      area = parsed[3];
      if (area === "vilage") {
        area = "village";
      }
      monster = parsed[2];
      quickReport.banishedMonsters[monster]++;
      accounts[pName].banishType++;
      return;
    }
    parsed = loseSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0)) {
      pName = parsed[1];
      if (!(accounts != null ? accounts[pName] : void 0)) {
        accounts[pName] = NewTally();
      }
      number = parsed[2];
      accounts[pName].losses += parseFloat(number);
      return;
    }
    parsed = search.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0)) {
      pName = parsed[1];
      if (!(accounts != null ? accounts[pName] : void 0)) {
        accounts[pName] = NewTally();
      }
      killed = parsed[2];
      number = parsed[3];
      accounts[pName].kills += parseFloat(number);
    }
  };

  ChartResult = function(accounts, total) {
    var AddRow, SetRow, account, cumData, data, row, score, table, table2, tally;
    data = new google.visualization.DataTable();
    data.addColumn('string', 'name');
    data.addColumn('string', 'kills');
    data.addColumn('string', 'keys');
    data.addColumn('string', 'element bans');
    data.addColumn('string', 'type bans');
    data.addColumn('number', 'points');
    /*runData = new google.visualization.DataTable()
    
    	runData.addColumn('string', 'name')
    	runData.addColumn('number', 'points')
    	runData.addColumn('string', 'OutfitMin')
    	runData.addColumn('string', 'OutfitMax')
    	runData.addColumn('string', 'StaffMin')
    	runData.addColumn('string', 'StaffMax')
    */

    cumData = new google.visualization.DataTable();
    cumData.addColumn('string', 'name');
    cumData.addColumn('number', 'points');
    row = 0;
    SetRow = function(r) {
      var d, i, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = r.length; _i < _len; i = ++_i) {
        d = r[i];
        _results.push(data.setValue(row, i, d));
      }
      return _results;
    };
    AddRow = function(t, a) {
      data.addRows(1);
      return SetRow([a.toString(), t['kills'].toString(), t['keys'].toString(), t['banishElement'].toString(), t['banishType'].toString(), parseFloat(Points[a])]);
    };
    for (account in accounts) {
      tally = accounts[account];
      AddRow(tally, account);
      row++;
    }
    table = new google.visualization.Table(document.getElementById('table_div'));
    table.draw(data, {
      showRowNumber: false
    });
    row = 0;
    for (account in cumPoints) {
      score = cumPoints[account];
      cumData.addRows(1);
      cumData.setValue(row, 0, account.toString());
      cumData.setValue(row, 1, parseFloat(score));
      row++;
    }
    table2 = new google.visualization.Table(document.getElementById('point_div'));
    table2.draw(cumData, {
      showRowNumber: false
    });
    /* Everything below here was HSH specific
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
    */

  };

}).call(this);
