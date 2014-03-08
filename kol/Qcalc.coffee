

N_max = 20
STANDARD_REJECTION = 3/4


round = (x)-> Math.round(x * 100000)/1000

window.analyze = analyze = ()->
	models = init()

	for data in streams
		processStream(data, models)
	normalize(models)
	output(models)
	
output = (models)->
	out = "N\t\t normal Q\t\t no rej"
	report = []
	for mod in models
		if mod.confidence >= .001
			report.push(mod)
	
	report.sort( (a, b)-> b.confidence - a.confidence)
	report_out = ""
	for mod in report
		report_out += mod.report() + "\n"
	console.log(report_out)
	window.document.getElementById("output").value = report_out

window.runit = ()->
	data = document.getElementById("data").value
	streams = JSON.parse(data)
	analyze()


init = ()->
	models = []
	smv = document.getElementById("submodels").value 
	submodels = JSON.parse(smv)
	for n in [0..N_max]
		for name, rejection of submodels
			models.push( new Model(n, rejection, "+#{n} copies, #{name}"))
	return models


normalize = (models)->
	tot = 0;

	#shift by a constant so things don't disappear into the ether aka limited float precision
	max = -Infinity
	for mod in models
		max = Math.max(mod.log_prob, max)
	for mod in models
		tot += mod.confidence = Math.exp(mod.log_prob - max)
	
	for mod in models
		mod.confidence /= tot


processStream = (data, models) ->
	stream = data.stream
	monsters = data.monsters

	for mod in models
		mod.setZone(monsters)
	queue = new Q()

	#Process data, ignoring the first 5 points so that we know the queue for sure!
	for m, i in stream
		if (i>=5)
			mod.processDataPoint(m, queue) for mod in models
		queue.add(m)			


class Q
	constructor: ()->
		@queue = []
	reset: ()->
		@queue = []
	add: (id)->
		@queue.push(id)
		@queue.shift() if @queue.length > 5
	check: (id)->
		for monster in @queue
			if id is monster
				return true
		return false


class Model
	constructor: (N, j_special, description)->
		@N = N
		@rej = []
		@j_special = j_special
		@log_prob = 0
		@description = description

	report: ()-> "#{@con()}% #{@description}"

	con: ()-> Math.round(@confidence * 100000)/1000


	setZone: (monsters)->
		@monsters = monsters
		@rates = []
		e = 0
		for copies in monsters
			e+=copies
		for copies, i in monsters
			if i is 0
				@rates[i] = (copies+@N)/(e+@N)
			else
				@rates[i] = (copies)/(e+@N)

	processDataPoint: (i, queue)->
		@log_prob += Math.log( @p(i, queue) )

	p: (i, queue)->
		r = @rates[i]
		j = @getJ(i, queue)
		rej = @getRej(queue)
		return r * (1 - j)/ (1-rej)

	getJ: (i, queue)->
		if queue.check(i)
			if i is 0 then return @j_special else return STANDARD_REJECTION
		else
			return 0

	getRej: (queue)->
		rej = 0
		for r, m in @rates
			rej+= r * @getJ(m, queue)
		return rej
