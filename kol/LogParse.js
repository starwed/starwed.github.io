// Generated by CoffeeScript 1.4.0
(function() {
  var AllPlayers, Blacklist, ChartResult, ElementList, MonsterList, NewTally, PointValue, Points, Process, RunPlayers, accounts, banishSearch, bossMatch, calcCum, checkBlacklist, cumPoints, distroSearch, elSearch, getAccountName, importantItems, instanceSummary, keySearch, logit, lootCount, looters, loseSearch, miscNC, monsterAlias, onceChecklist, outfit, playerSearch, quickReport, search, sheetSearch, staff, styleElement, thisRunPoints, worthyTasks;

  google.load("visualization", "1", {
    packages: ["corechart"]
  });

  google.load('visualization', '1', {
    packages: ['table']
  });

  PointValue = {
    kills: 1,
    bossKills: 1,
    keys: 1,
    banishElement: 1,
    banishType: 1,
    losses: 0,
    tasks: 5
  };

  /*
  Blacklist of multis who don't get loot
  (clan multis)	
  	Maestro of Mariachi (#1873125)
  	Sauciest Saucier (#1873222)
  	Tzar of Turtles (#1873176)
  (littlelolligagged)
  	mommyneedssleep (#2051971)
  */


  Blacklist = [1873125, 1873222, 1873176, 2051971];

  checkBlacklist = function(account) {
    var num, _i, _len;
    for (_i = 0, _len = Blacklist.length; _i < _len; _i++) {
      num = Blacklist[_i];
      if (account.indexOf(num) > -1) {
        logit("Blacklisted " + account + "!");
        return true;
      }
    }
    return false;
  };

  NewTally = function() {
    return {
      kills: 0,
      keys: 0,
      banishElement: 0,
      banishType: 0,
      losses: 0,
      bossKills: 0,
      tasks: 0
    };
  };

  logit = function(text) {
    if (typeof console === "object") {
      return console.log(text);
    }
  };

  bossMatch = /(.+) defeated (The Great Wolf of the Air|the Zombie Homeowners' Association|The Unkillable Skeleton|Falls-From-Sky|Mayor Ghost|Count Drunkula)\s+\((\d+) turn/;

  loseSearch = /(.+) was defeated .*\((\d+) turn/;

  search = /(.+) defeated (\S+)\s+(\S+) .*\((\d+) turn/;

  elSearch = /(.+) made the (.+) less (\S+)/;

  keySearch = /(.+) unlocked (.+)\s+\(/;

  banishSearch = /(.+) drove some (.+) out of the (.+)/;

  distroSearch = /(.+) distributed/;

  playerSearch = /(.+\(#\d+?\))/;

  ElementList = ['stench', 'cold', 'hot', 'sleaze', 'spooky'];

  MonsterList = ['skeleton', 'werewolf', 'zombie', 'ghost', 'vampire', 'bugbear'];

  importantItems = {
    banana: /(.+) got a wax banana/,
    amber: /(.+) acquired a chunk of moon-amber/,
    musicbox: /(.+) made the forest less spooky/,
    roast: /(.+) got some roast beast/,
    agaric: /(.+) got some stinking agaric/,
    kiwi: /(.+) got a blood kiwi/
  };

  worthyTasks = {
    polish: /(.+) polished some moon-amber/,
    flour: /(.+) made some bone flour/,
    impression: /(.+) made an impression of a complicated lock/
  };

  looters = {
    pencils: /(.+) collected a ghost pencil /,
    newspapers: /(.+) recycled some newspapers/,
    locker: /(.+) rifled through a footlocker/,
    garbage: /(.+) found and sold a rare baseball card/,
    graves: /(.+) robbed some graves/,
    dresser: /(.+) raided a dresser/,
    ashes: /(.+) sifted through some ashes/,
    shack: /(.+) looted the tinker's shack/,
    till: /(.+) looted the blacksmith's till/
  };

  lootCount = {
    pencils: 0,
    newspapers: 0,
    locker: 0,
    garbage: 0,
    graves: 0,
    dresser: 0,
    ashes: 0,
    shack: 0,
    till: 0
  };

  onceChecklist = {
    banana: false,
    amber: false,
    musicbox: false,
    roast: false,
    agaric: false,
    kiwi: false
  };

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
    },
    monstersKilled: {
      zombie: 0,
      ghost: 0,
      skeleton: 0,
      vampire: 0,
      bugbear: 0,
      werewolf: 0
    }
  };

  monsterAlias = {
    zombies: "zombie",
    ghosts: "ghost",
    skeletons: "skeleton",
    vampires: "vampire",
    bugbears: "bugbear",
    werewolves: "werewolf"
  };

  instanceSummary = function() {
    var banishedLine, checks, counts, elementsLine, html, item, mk, monsters, number, state, style;
    html = "";
    banishedLine = function(name) {
      html += "<br/>&nbsp;&nbsp;&nbsp;" + ("<i>" + name + ":</i> ") + quickReport.monstersKilled[monsterAlias[name]] + " kills";
      if (monsters[name] === 1) {
        html += ", banished once";
      }
      if (monsters[name] === 2) {
        return html += ", banished twice";
      }
    };
    elementsLine = function(el, area) {
      html += ("<br/> <b>" + area + "  (kisses: ") + (el.length + 1) + ")</b> ";
      if (el.length === 5) {
        return html += "<br/>&nbsp;&nbsp;&nbsp; <b><i>all</i></b> elements removed";
      } else if (el.length === 0) {
        return html += "<br/>&nbsp;&nbsp;&nbsp;<i>No</i> elements removed";
      } else {
        return html += "<br/>&nbsp;&nbsp;&nbsp;" + el.join(", ") + " elements removed";
      }
    };
    monsters = quickReport.banishedMonsters;
    mk = quickReport.monstersKilled;
    html += "<table style='font-size: 8px' id='zones'><tr><td>";
    elementsLine(quickReport.forestElements, "Forest");
    banishedLine("bugbears");
    banishedLine("werewolves");
    if (mk["the great wolf of the air"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>Great Wolf slain</b>";
    }
    if (mk["falls-from-sky"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>Falls-From-Sky slain</b>";
    }
    html += "</td><td>";
    elementsLine(quickReport.villageElements, "Village");
    banishedLine("ghosts");
    banishedLine("zombies");
    if (mk["mayor ghost"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>Mayor Ghost slain</b>";
    }
    if (mk["the zombie homeowners' association"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>ZHO slain</b>";
    }
    html += "</td><td>";
    elementsLine(quickReport.castleElements, "Castle");
    banishedLine("skeletons");
    banishedLine("vampires");
    if (mk["count drunkula"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>Count slain</b>";
    }
    if (mk["the unkillable skeleton"]) {
      html += "<br/>&nbsp;&nbsp;&nbsp;<b>Skelly slain</b>";
    }
    html += "</td><tr></table>";
    html += "<br/><b>Doors unlocked:</b> <br/>&nbsp;&nbsp;&nbsp;" + quickReport.unlockedDoors.join(", ");
    html += "<br/> <b>1/dungeon tasks accomplished:</b> <br/>&nbsp;&nbsp;&nbsp;";
    checks = [];
    for (item in onceChecklist) {
      state = onceChecklist[item];
      style = state === true ? "color: green; font-weight: bold" : "color: grey";
      checks.push("<span style='" + style + "'>" + item + "</span>");
    }
    html += checks.join(", ");
    html += "<br/> <b>10/dungeon loot left:</b> <br/>&nbsp;&nbsp;&nbsp;";
    counts = [];
    for (item in lootCount) {
      number = lootCount[item];
      style = number === 10 ? "color: grey; text-decoration: line-through" : "color: black";
      counts.push("<span style='" + style + "'>" + item + ": " + (10 - number) + "</span>");
    }
    html += counts.join(", ");
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
    var account, action, line, tally, text, textArray, times, total, _i, _len;
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
      if (checkBlacklist(account)) {
        continue;
      }
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
    calcCum();
    ChartResult(accounts);
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
    return account.trim();
  };

  staff = new Object();

  outfit = new Object();

  calcCum = function() {
    var account, key, line, oldScores, parsed, prior, score, searchOldScore, _i, _len, _results;
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
    _results = [];
    for (account in Points) {
      score = Points[account];
      if (checkBlacklist(account)) {
        continue;
      }
      if (cumPoints[account]) {
        cumPoints[account] = cumPoints[account] * 1.0 + 1.0 * score;
      } else {
        cumPoints[account] = score;
      }
      _results.push(thisRunPoints[account] = cumPoints[account]);
    }
    return _results;
  };

  Process = function(line) {
    var area, bossKill, door, element, elementKill, findAccount, item, itemSearch, lootSearch, lootedThing, monster, number, pName, parsed, task, taskSearch, typeKill;
    findAccount = function(name) {
      var acc;
      acc = getAccountName(name);
      if (!(accounts != null ? accounts[acc] : void 0)) {
        accounts[acc] = NewTally();
      }
      return acc;
    };
    for (item in importantItems) {
      itemSearch = importantItems[item];
      parsed = itemSearch.exec(line);
      if ((parsed != null ? parsed[1] : void 0)) {
        pName = findAccount(parsed[1]);
        onceChecklist[item] = true;
      }
    }
    parsed = keySearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0)) {
      pName = findAccount(parsed[1]);
      door = parsed[2];
      quickReport.unlockedDoors.push(door);
      accounts[pName].keys++;
      return;
    }
    parsed = elSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0)) {
      pName = findAccount(parsed[1]);
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
      pName = findAccount(parsed[1]);
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
      pName = findAccount(parsed[1]);
      number = parsed[2];
      accounts[pName].losses += parseFloat(number);
      return;
    }
    parsed = bossMatch.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0)) {
      pName = findAccount(parsed[1]);
      bossKill = parsed != null ? parsed[2].trim().toLowerCase() : void 0;
      if (!quickReport.monstersKilled[bossKill]) {
        quickReport.monstersKilled[bossKill] = 0;
      }
      quickReport.monstersKilled[bossKill]++;
      accounts[pName].bossKills += 1;
      return;
    }
    parsed = search.exec(line);
    if ((parsed != null ? parsed[1] : void 0) && (parsed != null ? parsed[2] : void 0) && (parsed != null ? parsed[3] : void 0) && (parsed != null ? parsed[4] : void 0)) {
      pName = findAccount(parsed[1]);
      elementKill = parsed[2];
      typeKill = parsed[3];
      number = parsed[4];
      quickReport.monstersKilled[typeKill] += parseFloat(number);
      accounts[pName].kills += parseFloat(number);
      return;
    }
    for (task in worthyTasks) {
      taskSearch = worthyTasks[task];
      parsed = taskSearch.exec(line);
      if ((parsed != null ? parsed[1] : void 0)) {
        pName = findAccount(parsed[1]);
        accounts[pName].tasks++;
        return;
      }
    }
    for (lootedThing in looters) {
      lootSearch = looters[lootedThing];
      parsed = lootSearch.exec(line);
      if ((parsed != null ? parsed[1] : void 0)) {
        pName = findAccount(parsed[1]);
        lootCount[lootedThing]++;
        return;
      }
    }
    parsed = distroSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0)) {
      return;
    }
    parsed = playerSearch.exec(line);
    if ((parsed != null ? parsed[1] : void 0)) {
      return pName = findAccount(parsed[1]);
    }
  };

  ChartResult = function(accounts, total) {
    var AddRow, SetRow, account, cumArray, cumData, data, distroArea, lootHtml, name, pointsOut, row, runData, score, table, tally, wishlink, _i, _j, _len, _len1;
    data = new google.visualization.DataTable();
    data.addColumn('string', 'name');
    data.addColumn('string', 'kills');
    data.addColumn('string', 'bosses');
    data.addColumn('string', 'keys');
    data.addColumn('string', 'banish');
    data.addColumn('string', 'tasks(5)');
    data.addColumn('number', 'points');
    runData = new google.visualization.DataTable();
    runData.addColumn('string', 'name');
    runData.addColumn('number', 'points');
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
      return SetRow([a.toString(), t['kills'].toString(), t['bossKills'].toString(), t['keys'].toString(), (t.banishElement + t.banishType).toString(), t.tasks.toString(), parseFloat(Points[a])]);
    };
    for (account in accounts) {
      tally = accounts[account];
      AddRow(tally, account);
      row++;
    }
    table = new google.visualization.Table(document.getElementById('table_div'));
    table.draw(data, {
      showRowNumber: false,
      sortColumn: 0
    });
    pointsOut = "";
    row = 0;
    cumArray = [];
    for (account in cumPoints) {
      score = cumPoints[account];
      cumData.addRows(1);
      cumData.setValue(row, 0, account.toString());
      cumData.setValue(row, 1, parseFloat(score));
      cumArray.push(account);
      row++;
    }
    cumArray.sort(function(a, b) {
      return cumPoints[b] - cumPoints[a];
    });
    for (_i = 0, _len = cumArray.length; _i < _len; _i++) {
      account = cumArray[_i];
      pointsOut += "" + account + "\t" + cumPoints[account] + "\n";
    }
    table = new google.visualization.Table(document.getElementById('point_div'));
    table.draw(cumData, {
      showRowNumber: false,
      sortColumn: 1,
      sortAscending: false
    });
    document.getElementById('points-out').value = pointsOut;
    row = 0;
    RunPlayers.sort(function(a, b) {
      return thisRunPoints[b] - thisRunPoints[a];
    });
    wishlink = "http://alliancefromhell.com/viewtopic.php?f=13&t=5752";
    lootHtml = "<table id='lootTable'>";
    for (_j = 0, _len1 = RunPlayers.length; _j < _len1; _j++) {
      name = RunPlayers[_j];
      account = name;
      score = thisRunPoints[account];
      lootHtml += "<tr><td><b>" + name + "</b> </td><td>" + score + "</td></tr>";
      row++;
      if (row > 10) {
        break;
      }
    }
    lootHtml += "</table><br/><a target='_blank' href='" + wishlink + "'>Wishlists</a>";
    distroArea = document.getElementById('distro');
    distroArea.insertAdjacentHTML("beforeend", lootHtml);
  };

}).call(this);
