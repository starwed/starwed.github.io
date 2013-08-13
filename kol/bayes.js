
//Globals
	var threshold = .001;  // Minimum belief to display/graph
	var log = "";
	var error="";
	var madness="";
	var dataStore;
//Load google chart stuff
	google.load("visualization", "1", {packages:["corechart"]});
	google.load('visualization', '1', {packages: ['table']});



// Parse user input. 
function Parse(){
	var input=document.getElementById('in');
	var rawdata=input.value;
	var re = /[^0-9\.\-]+/;		//Ignore everything except numbers, decimals, and negative signs
	var lines = rawdata.split('\n');
	var data = new Array();
	for (i=0; i<lines.length; i++)	{
		data[i] = lines[i].split(re);
		data[i][0]=parseFloat(data[i][0]);
		data[i][1]=parseFloat(data[i][1]);
		data[i][2]=parseFloat(data[i][2]);
	}
	return(data);
}


//Check that user-entered data makes some sort of sense
function CheckData(data){
	log=data;
	dataStore=data;
	for (i=0; i<data.length; i++){
		if( isNaN(data[i][0])|| data[i][0]<0){
			madness= 'Problem with row ' + (i+1) + ':' + ' nonsensical or missing drop number';
			return false;
		}
		if(isNaN(data[i][1]) || data[i][1]<=0){
			madness= 'Problem with row ' + (i+1) + ':' + ' nonsensical or missing sample size';
			return false;
		}
		if(data[i][0] > data[i][1]){
			madness = 'Problem with row ' + (i+1) + ':' + ' more drops than trials.';
			return false;
		}
		if( isNaN(data[i][2]) ){
			madness = 'Problem with row ' + (i+1) + ':' + ' bonus is missing or malformed.';
			return false;
		} else if(data[i][2]<= -100){
			madness = 'Problem with row ' + (i+1) + ':' + ' bonus prevents drops.';
			return false;
		}
	}
	return true;
}



function Run(){
	log="";
	var Data=Parse();
	if(CheckData(Data)==false){
		alert('Madness! \n\n' + madness);
		return;
	}

	var AoP=new Array();

	for (var i=0; i<Data.length;i++)
		AoP[i]=FindLnProbArray(Data[i][0], Data[i][1], Data[i][2]);
	var result = LnConvolute(AoP); 

	Display(Prepare(result));
	Chart(Prepare(result));
}






function FindLnProb(count, size, boost, rate){
	var ob_rate=(rate/100)*(1+boost/100);
	if(ob_rate>=1)
		if(count<size)
			return NaN;
		else
			return 0;
	var LnChance = count  * Math.log(ob_rate) + (size-count)* Math.log(1-ob_rate); 
	return(LnChance);
}

function FindLnProbArray(count, size, boost){
	var LnProbs  = new Array();
	for ( var rate=1;rate<=100; rate++)	{
		LnProbs[rate]	= FindLnProb(count, size, boost, rate);
	}

	return(LnProbs);
}

//Combine different sets of data, produce regular probability
function LnConvolute(ArrayOfProbs)
{
	var l=ArrayOfProbs.length;
	var NetLnProb=new Array();
	var max;
	for(r=1;r<=100;r++){
		NetLnProb[r]=0;
		for(i=0;i<l;i++)
			NetLnProb[r]=NetLnProb[r]+ArrayOfProbs[i][r];
		if(r==1)
			max=NetLnProb[r];
		else if(NetLnProb[r]	>max)
				max=NetLnProb[r];
	}
	var NetProb = new Array();

	for(r=1;r<=100;r++)
		NetProb[r] = Math.pow(Math.E, NetLnProb[r]-max);
	NetProb=Norm(NetProb);
	return(NetProb);
}


//Normalise a set of relative probabilities
function Norm(a){
	var summer=0;
	for( var r=1; r<=100; r++)
		if( !isNaN(a[r]) )	
			summer+=a[r];
	for( var r=1; r<=100; r++)
		a[r]=a[r]/summer;
	return(a);
}


// Prepare result for display, throwing away small/NaN values and rounding.
function Prepare(result){
	var preparedResult = new Object();
	for (var i=1; i<=100;i++){
		 if(result[i]>threshold)
		 	preparedResult[i]=Round(result[i]);
	}
	return(preparedResult);
}

function Round(x){
	return( Math.floor(x*10000)/100);
}

function Display(result){
	var out=document.getElementById('out');
	var text="";
	for (i in result)
		text+= i +"\t" + result[i]+"\n";
	//text=log;	
	out.value=text;
}

//Use google chart API to produce nice looking tables/charts.
function Chart(result){

  	var data = new google.visualization.DataTable();
  	data.addColumn('string', 'Rate');
  	data.addColumn('number', 'Belief');
  	var row=0;
  	for (i in result)
		if(true){
			data.addRows(1);
			data.setValue(row, 0, i.toString() );
			data.setValue(row++, 1, result[i]);
		}

	var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
	chart.draw(data, {width: 600, height: 240, title: 'Belief',legend:'none',
                  hAxis: {title: 'Rate', titleTextStyle: {color: 'red'}, maxAlternation: 1 },
                  vAxis: {maxValue: 100, minValue:0}
                 });
     

    var table = new google.visualization.Table(document.getElementById('table_div'));
    table.draw(data, {width: '10em', showRowNumber: false});
}


