/* Project 1*/
proc sort data=sashelp.shoes out=sorted_shoes;
by descending Product Sales;
run;

proc format;
	value salesrange low-<100000="Lower"
					100000-200000="Middle"
					200000<-high="High";
run;

data salesrangeshoes;
set sorted_shoes;
format Sales salesrange.;
run;

/*Project 2*/
proc freq data=salesrangeshoes nlevels;
table Sales;
where Sales between 100000 and 200000;
run;

proc means data=salesrangeshoes;
var Sales;
where Sales between 100000 and 200000;
run;

/*Project 3*/
data work.lowchol work.highchol work.misschol;
 set sashelp.heart;
 if Cholesterol=. then output work.misschol;
 else if Cholesterol lt 200 then output work.lowchol;
 else if Cholesterol ge 200 then output work.highchol;
run;


