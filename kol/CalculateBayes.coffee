

#   BUG!!!  for some reason when rateset isn't ordered, a bug in Apply might occur
#	That'll never happen if you use the [N..M] format, though
#	You can fiddle with rateset if you know the approximate ranges and want to speed things up





self.console = {log:(msg)-> msg}
RATESET = []
max_rates=[]
certainty = 0;
Confidences = []

self.onmessage = (event) ->
	msg = event.data
	switch msg.type
		when 'RUN'
			Run( msg.dataset, msg.range)
		when 'STOP'	# Don't use, make Firefox sad -- investigate and file bug?
			Stop(msg)
		else
			return
	
		
Stop = (msg) ->
	self.close()
	

Run  = (dataset, range='FULL') ->
	
	#Produce range of indices to iterate over
	switch range
		when 'FULL' then RATESET = [1..100]
		when 'SPARSE' 
			RATESET = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10
				15, 20, 25, 30, 35, 40, 45, 50, 55, 
				60, 65, 70, 75, 80, 85, 90, 95, 100]
		when 'FULL-NEG'
			RATESET = [-100..100]
		when 'SUPER LOW'
			RATESET = [	0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,
						1,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,
						2,2.1,2.2,2.3,2.4,2.5, 2.6, 2.7, 2.8, 2.9, 3 ]				
		else
			RATESET = JSON.parse(range)

	ArrayOfProbs = CreateArray(dataset[0].counts.length-2)

	#Calculations

	## Iterate over each element of the data set, also posting 'progress' 
	for point, n in dataset
		Progress( Math.floor( (n+1)/(dataset.length+3)*100)  )
		FindLnProbArray(ArrayOfProbs, point.counts,  point.boost, point.flat_boost)
	
	## Final calculation, find the normalised probability from the ln array
	Progress Math.floor( (dataset.length+2) / (dataset.length+2) * 100 )
	ExpArray(ArrayOfProbs)
	
	## Now we're done calculating, post 100% and return results
	Progress(100)
	msg = {'type':'RESULT', 'results':Confidences}
	postMessage(msg)

	#Cleanup!  Hopefully free some memory, if it matters.
	ArrayOfProbs = []
	Confidences = []
	dataset = []
	max_rates=[]


	return



ExpArray = (ArrayOfProbs) ->
	max=-Infinity
	GetMax = (a, i, r) -> 
		if a[i]>max
			max= a[i] 
			max_rates = r

	Apply(ArrayOfProbs, GetMax)
	
	sum=0
	GetExp = (a, i) -> 
		 a[i] = Math.pow(Math.E, a[i]-max)
		 sum+= a[i] if !isNaN(a[i])
	Apply(ArrayOfProbs, GetExp)

	Norm = (a, i) -> a[i] = a[i]/sum
	Apply(ArrayOfProbs, Norm)

	certainty = Get(ArrayOfProbs, max_rates)
	
	Round = (x) ->  Math.floor(x*10000)/100

	GetTopResults = (a, i, r) ->
		if(a[i]*10 > certainty or a[i]>0.01)
			Confidences.push( {rates: r, belief: Round( a[i]) } )			

	Apply(ArrayOfProbs, GetTopResults)
	return



FindLnProbArray = (ArrayOfProbs, counts, boost=0, flat_boost=0) ->
	FLP = (a, i, rates) -> a[i] += FindLnProb(counts, boost, rates, flat_boost)
	Apply(ArrayOfProbs, FLP)
	return ArrayOfProbs


CombinationSum = (r, n) -> 
	#Log("r: #{r}, n #{n}")
	return 0 if n>r.length
	
	if(n==0)
		result=1
		for rate in r
			result*= (1-rate) 
		return result
	
	result=0
	for chosen_rate, i in r
		s = r.slice(0)
		s.splice(i, 1)
		result+= chosen_rate * CombinationSum(s, n-1)
	#Log("result: #{result}")
	return result/n


# rates and counts are arrays of length m
FindLnProb = (counts, boost, rates=0, flat_boost=0) ->
	ob_rates = new Array()
	mandate=0	# how many drops are mandatory at this set of theoretical rates
	for rate, i in rates
		ob_rates[i] = rate/100 * (1 + boost/100) + flat_boost/100
		if ob_rates[i] > 1
			ob_rates[i]=1
			mandate++
		if ob_rates[i]<0
			ob_rates[i]=0
	LnChance=0
	for count, c in counts
		#Mandate tracks number of required drops;  if requirement not met, return NaN
		if mandate > c			
			return NaN if count != 0 
		else 
			if count is 0
				result = 1
			else
				result = CombinationSum(ob_rates, c)
			#Log("---- r #{rates} ob_r #{ob_rates} c #{c} ----- ")
			
			#Log("- RESULT! #{result} - ")
			#if result is 0 
			#	LnChance +=0
			#else
			LnChance += count* Math.log(result)
	#Log("LNCHANCE #{LnChance}, #{rates}")
	return LnChance
		


# Apply an action to every combination of rates
# The condition inside the for loop prevents degeneracy, like looping over both [1, 5] and [5, 1]
# equivalent to a 'natural' way of listing them	
Apply = (a, action, rates=[]) ->
	for i in RATESET
		if(rates.length > 0)
			if(rates[rates.length-1]< i)
				return
		s = rates.slice(0)
		s.push(i)
		if a[i].length>1
			Apply( a[i], action, s)
		else
			action(a, i, s );

# Creates a multi-dimensional array to hold the probability of each combination of different rates;
# Will have m indices, defined by
# Called recursively at each step.
CreateArray = (m) ->
	root=new Array();
	for i in RATESET
		if m>0
			root[i] = CreateArray(m-1);
		else
			root[i]=0;
	return root;	


###
Get and Set both use a kind of 'recursive for loop' construct to do their job.
Maybe there's a more idiomatic way of doing this?

The reason it requires the loop is because we don't know the dimension of the data structure.
###

#Find the value of a[ index1][index2][index3];
Get = (a, indices) ->
	for index in indices
		a = a[index];
	return a


#Set the value of a[ index1][index2][index3];
Set = (a, indices, value) -> 
	for index, n in indices
		if n < indices.length-1
			a=a[index]
		else
			a[index] = value


Progress = (percent, message="") ->
	msg = {'type':'PROGRESS', 'percent':percent}
	postMessage(msg)

Log = (text) ->
	msg = {'type':'LOG', 'text':text}
	postMessage(msg)
