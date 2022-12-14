/* Cleaning Data */
data cleaned_tourism;
	length Country_Name $300 Tourism_Type $20;
	retain Country_Name "Tourism_Type";
	set cr.tourism(drop=_1995-_2013);
	if A ne . then Country_Name=Country;
	if lowcase(Country)="inbound tourism" then Tourism_Type="Inbound tourism";
	else if lowcase(Country)="outbound tourism" then Tourism_Type="Outbound tourism";
	if Country_Name ne Country and Country ne Tourism_Type;
	Series=upcase(Series);
	if Series=".." then Series="";
	Conversion_Type=scan(Country, -1, " ");
	if _2014=".." then _2014=".";
	if Conversion_Type="Mn" then do;
		if _2014 ne "." then Y2014=input(_2014,16.)*1000000;
		else Y2014=.;
		Category=cat(scan(Country,1,"-",'r'),' - US$');
	end;
	else if Conversion_Type="Thousands" then do;
		if _2014 ne "." then Y2014=input(_2014,16.)*1000;
		else Y2014=.;
		Category=scan(Country,1,"-",'r');
	end;
	format Y2014 comma25.;
	drop A Conversion_Type Country _2014;
run;

/* Checking for Distinct Values */
proc freq data=cleaned_tourism;
	table Category Tourism_Type Series;
run;

proc means data=cleaned_tourism mean min max sum maxdec=0;
	var Y2014;
run;

/* Create Final Table */

*create custom format;
proc format;
	value contIDs
		1="North America"
		2="South America"
		3="Europe"
		4="Africa"
		5="Asia"
		6="Oceania"
		7="Antarctica";
run;

*merge clean tourism with country info table;
proc sort data=cr.country_info(rename=(Country=Country_Name))
	out=country_sorted;
	by Country_Name;
run;

data final_tourism;
	merge cleaned_tourism(in=t) country_sorted(in=c);
	by Country_Name;
	if t=1 and c=1 then output final_tourism;
	format Continent contIDs.;
run;

/* Create NoCountryFound Table */
data final_tourism no_country_found(keep=Country_Name);
	merge cleaned_tourism(in=t) country_sorted(in=c);
	by Country_Name;
	if t=1 and c=1 then output final_tourism;
	if t=1 and c=0 and first.Country_Name=1 then output no_country_found;
	format Continent contIDs.;
run;

/* Stats for Questions */
*summary stats by continent;
proc means data=final_tourism mean min max maxdec=0;	
	var Y2014;
	class Continent;
	where Category="Arrivals";
run;

proc sort data=final_tourism;
	by Continent;
	where Category="Tourism expenditure in other countries - US$";
run;

proc means data=final_tourism mean;
	var Y2014;
run;

