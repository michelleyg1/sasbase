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

proc freq data=salesrangeshoes nlevels;
table Sales;
where Sales between 100000 and 200000;
run;

proc means data=salesrangeshoes;
var Sales;
where Sales between 100000 and 200000;
run;

