// Generated by CoffeeScript 1.4.0
(function() {
  var checkLists, createList, data, dropList, fishes, makeListElement, playerData, playerLookup, playerURL, sample_data, setAutoComplete, startUp, wishListURL;

  playerURL = "https://afh.firebaseio.com/dread/wishlists/1345/wants";

  wishListURL = "https://afh.firebaseio.com/dread/wishlists/";

  playerData = null;

  data = null;

  playerLookup = null;

  dropList = {
    ghost_outfit: {
      name: "Ghost Outfit",
      max: 3
    },
    sash: {
      name: "Mayor Ghost's Sash",
      max: 1
    },
    gavel: {
      name: "Mayor Ghost's Gavel",
      max: 1
    },
    scissors: {
      name: "Mayor Ghost's Scissors",
      max: 1
    },
    zombie_outfit: {
      name: "Zombie HOA Outfit",
      max: 3
    },
    eyes: {
      name: "HOA zombie eyes",
      max: 1
    }
  };

  makeListElement = function(drop, dropID, has) {
    var dropdown, i, li, _i, _ref;
    li = $("<li id='" + dropID + "'></li>").append("<b>" + drop.name + "</b>&nbsp;&nbsp; ");
    dropdown = $("<select>  </select>");
    for (i = _i = 0, _ref = drop.max; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (i === parseFloat(has)) {
        dropdown.append("<option selected='selected'>" + i + "</option>");
      } else {
        dropdown.append("<option>" + i + "</option>");
      }
    }
    li.append(dropdown);
    return li;
  };

  fishes = null;

  startUp = function() {
    fishes = new Firebase(wishListURL);
    return fishes.once('value', setAutoComplete);
  };

  setAutoComplete = function(snapshot) {
    var available_names, player;
    data = snapshot.val();
    playerLookup = {};
    available_names = [];
    for (player in data) {
      console.log("player: " + player);
      console.log(data[player].player);
      available_names.push(data[player].player);
      playerLookup[data[player].player] = player;
    }
    $("#tags").autocomplete({
      source: available_names
    });
    return $("#tags").autocomplete({
      close: checkLists
    });
  };

  checkLists = function() {
    var name, pid;
    name = $("#tags").val();
    pid = playerLookup[name];
    if (pid != null) {
      playerData = data[pid].wants;
      createList(playerData);
      return playerURL = wishListURL + ("/" + pid + "/wants");
    }
  };

  createList = function(snapshot) {
    var all, drop, has, item, li, priority, _i, _len, _results;
    $("#sortable").empty();
    $("#sortable2").empty();
    for (drop in playerData) {
      console.log("fishes: " + drop);
    }
    all = [];
    for (drop in dropList) {
      if ((playerData[drop] != null)) {
        has = playerData[drop].has;
        priority = playerData[drop].priority;
      } else {
        has = 0;
        priority = Infinity;
      }
      console.log(dropList[drop]);
      li = makeListElement(dropList[drop], drop, has);
      all.push({
        el: li,
        priority: priority
      });
    }
    all.sort(function(a, b) {
      return a.priority - b.priority;
    });
    _results = [];
    for (_i = 0, _len = all.length; _i < _len; _i++) {
      item = all[_i];
      if (item.priority < 0) {
        _results.push($("#sortable2").append(item.el));
      } else {
        _results.push($("#sortable").append(item.el));
      }
    }
    return _results;
  };

  window.Run = startUp;

  sample_data = {
    dread: {
      wishlists: [
        {
          player: "starwed",
          wants: {
            ghost_outfit: {
              has: 2,
              priority: 8
            },
            sash: {
              has: 0,
              priority: 3
            }
          }
        }
      ]
    }
  };

  /* sortable design
  	CreateList: creates an array of element ids from a list  <-- this is all I need!
  
  	CreateWishlist:
  		gets a list of wanted items
  			for each, specify number and priority
  		get a list of not wanted items
  			for each, specify number and priority (negative)
  
  		That's it!
  */


  window.saveList = function() {
    var err, has, id, newWishList, playerWishes, priority, spurned_items, wanted_items, _i, _j, _len, _len1;
    wanted_items = $("#sortable").sortable("toArray");
    priority = 1;
    newWishList = {};
    for (_i = 0, _len = wanted_items.length; _i < _len; _i++) {
      id = wanted_items[_i];
      has = $("#" + id).find("select").val();
      newWishList[id] = {
        has: has,
        priority: priority
      };
      priority++;
    }
    spurned_items = $("#sortable2").sortable("toArray");
    priority = -100;
    for (_j = 0, _len1 = spurned_items.length; _j < _len1; _j++) {
      id = spurned_items[_j];
      has = $("#" + id).find("select").val();
      newWishList[id] = {
        has: has,
        priority: priority
      };
      priority++;
    }
    err = function(e) {
      if (e != null) {
        return console.log('Data could not be saved.' + error);
      } else {
        return console.log("data saved");
      }
    };
    playerWishes = new Firebase(playerURL);
    return playerWishes.set(newWishList, err);
  };

}).call(this);
