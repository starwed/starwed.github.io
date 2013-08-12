#Google load stuff
google.load("visualization", "1", {packages:["corechart"]})
google.load('visualization', '1', {packages: ['table']})


#Persistant reference to worker
worker=[]

# Yiab's pixel data (white, black, blue, green)
# For use in testing algo
YiabData =  [	
		{counts: [6, 51, 337, 541], boost: 20},
		{counts: [0, 2, 38, 179], 	boost: 40},
		{counts: [0, 0, 6, 105], 	boost: 50},
		{counts: [1, 48, 332, 606], boost: 20},
		{counts: [0, 0, 35, 160], boost: 40},
		{counts: [0,0,7,115], boost: 50	},
		{counts: [2, 45, 354, 536], boost: 20},
		{counts: [0, 0, 27, 192], boost: 40},
		{counts: [0, 0, 12, 105], boost: 50},
		{counts: [0, 41, 355, 567], boost: 20},
		{counts: [0, 1, 31, 184], boost: 40},
		{counts: [0, 0, 8, 107], boost: 50} ]


window.UpdateParse = ->
	dataset=Parse()
	ChartInput(dataset)
	return

window.Kill = ->
	bar = document.getElementById('progress_bar')
	bar.value=0
	worker.terminate()


window.Run  = (range='FULL') ->
	if worker
		oldworker=worker
		
	#dataset = YiabData
	dataset=Parse()
	startMessage = {type:'RUN', "range":range, "dataset":dataset}
	worker = new Worker('CalculateBayes.js')
	worker.onmessage = (event) ->	
		#console.log("message recieved: #{event.data}")
		switch event.data.type
			when 'PROGRESS' then ProcessProgress(event.data)
			when 'RESULT' 	then ProcessResults(event.data)
			when 'LOG' 		then console.log(event.data.text)

	TableData = new google.visualization.DataTable()
	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(TableData)		
	worker.postMessage(startMessage)
	if(oldworker)
		oldworker.terminate?()
	return

ProcessResults = (data) ->
	ChartResult(data.results)

ProcessProgress = (data) ->
	bar = document.getElementById('progress_bar')
	bar.value=data.percent

# Parse user input. 
Parse = ->
	input = document.getElementById('in');
	rawdata = input.value
	return (eval(rawdata))


ChartInput = (input_data) ->
	console.log('Trying to chart shit')
	console.log(input_data)
	console.log('-----------')
	data = new google.visualization.DataTable()
	cols = 2+ input_data[0].counts.length 

	for c,i in input_data[0].counts
		data.addColumn('number', "#{i}" )
	data.addColumn('number', 'boost')
	data.addColumn('number', 'flat_boost')
	row=0
	for run,n in input_data
		data.addRows 1
		for c, i in run.counts
			data.setValue( n, i, c )
		data.setValue(n, cols-2, run.boost)
		data.setValue(n, cols-1, run.flat_boost)
	
	table = new google.visualization.Table(document.getElementById('input_table_div'))
	table.draw(data, {width: '10em',showRowNumber:false} )


ChartResult = (Confidences) -> 
	console.log(Confidences)
	data = new google.visualization.DataTable()
	data.addColumn('number', 'Belief')
	data.addColumn('string', 'Rates')
	
	row = 0
	for c in Confidences
		data.addRows 1
		data.setValue( row, 0, c.belief  )
		data.setValue( row++, 1, ' (' + c.rates.toString() + ')')
	table = new google.visualization.Table(document.getElementById('table_div'))
	table.draw(data, {showRowNumber:false, sortColumn: 0, sortAscending:false} )
	

