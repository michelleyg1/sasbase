*accessing data;

libname tsa "/home/u61896790/ECRB94/data";
options validvarname=v7;
proc import datafile="/home/u61896790/ECRB94/data/TSAClaims2002_2017.csv"
	dbms=csv 
	out=tsa.claimsimport
	replace;
	guessingrows=max;
run;

*exploring data;
proc print data=tsa.claimsimport (obs=20);
run;

proc contents data=tsa.claimsimport varnum;
run;

proc freq data=tsa.claimsimport;
	tables  Claim_Site 
			Disposition 
			Claim_Type 
			Date_Received 
			Incident_Date / nocum nopercent;
	format Date_Received Incident_Date year4.;
run;

*checking if date recieved was before incident date;

proc print data=tsa.claimsimport;
	where Date_Received lt Incident_Date;
run;

*remove duplicates;
proc sort data=tsa.claimsimport out=tsa.claims_nodups noduprecs;
	by _all_;
run;

*sort by incident date ascending;
proc sort data=tsa.claims_nodups;
	by Incident_Date;
run;

*cleaning data;
data tsa.claimscleaned;
	set tsa.claims_nodups;
*clean claims_site column;
	if Claim_Site in ('-',' ') then Claim_Site="Unknown";
*clean disposition column;
	if Disposition in ('-',' ') then Disposition="Unknown";
	else if Disposition="losed: Contractor Claim" then Disposition="Closed:Contractor Claim";
	else if Disposition="Closed: Canceled" then Disposition="Closed:Canceled";
*clean claim_type column;
	if Claim_Type in ('-',' ') then Claim_Type="Unknown";
	else if Claim_Type="Passenger Property Loss/Personal Injur" then Claim_Type="Passenger Property Loss";
	else if Claim_Type="Passenger Property Loss/Personal Injury" then Claim_Type="Passenger Property Loss";
	else if Claim_Type="Property Damage/Personal Injury" then Claim_Type="Property Damage";
*clean State Name and State Value;
	State=upcase(State);
	StateName=propcase(StateName);
*create needs review column for date discrepancies;
	if (Incident_Date>Date_Received or
		Date_Received=. or
		Incident_Date=. or
		year(Incident_Date)<2002 or
		year(Incident_Date)>2017 or
		year(Date_Received)<2002 or
		year(Date_Received)>2017) then Date_Issues="Needs Review";
*add formats and labels;
	format Incident_Date Date_Received date9. Close_Amount dollar20.2;
	label  Incident_Date="Incident Date"
			Date_Received="Date Received"
			Item_Category="Item Category"
			Close_Amount="Close Amount"
			Claim_Type="Claim Type"
			Claim_Site="Claim Site"
			Claim_Number="Claim Number"
			Airport_Name="Airport Name"
			Airport_Code="Airport Code";
	drop County City;
	run;

*double checking that data is clean;
proc freq data=tsa.claimscleaned order=freq;
	tables  Claim_Site 
			Disposition 
			Claim_Type 
			Date_Issues / nocum nopercent;
run;
/* Exporting to PDF */
ods pdf file="/home/u61896790/ECRB94/output/ClaimsReport.pdf"
style=journal pdftoc=1;
ods noproctitle;
/* answering data questions */
/* 1. How many date issues are there in the overall data?*/
ods proclabel= "Date Issues";
title "Date Issues in Overall Data";
proc freq data=tsa.claimscleaned order=freq;
	tables  Date_Issues /missing nocum nopercent;
run;
title;

/* 4,241 date issues that need to be reviewed */
/* 2. How many claims are there in a year? */
ods graphics on;
ods proclabel= "Claims by Year";
title "Claims by Year";
proc freq data=tsa.claimscleaned;
	tables Incident_Date/ nocum nopercent plots=freqplot;
	format Incident_Date year4.;
	where Date_Issues is null;
run;
title;

/* State Specific Analysis: Hawaii */
ods proclabel= "Hawaii Claims Overview";
title "Hawaii Claim Types, Claim Sites, and Claim Disposition";
proc freq data=tsa.claimscleaned order=freq;
	tables Claim_Type Claim_Site Disposition / nocum nopercent;
	where StateName="Hawaii" and Date_Issues is null;
run;
title;

/*Close Amount Statistics for Hawaii*/
ods proclabel= "Close Amount Statistics for Hawaii";
title "Close Amount Statistics for Hawaii";
proc means data=tsa.claimscleaned mean min max sum maxdec=0;
	var Close_Amount;
	where StateName="Hawaii" and Date_Issues is null;
run;
title;
ods pdf close;

