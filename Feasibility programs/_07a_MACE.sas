
/*can do for one year and two years*/
/*do for each comparison group and each outcome*/
%macro main;
%let groups=lpa_grp*lpa_grp1*lpa_grp2;
%do q=1 %to 3;
	%let years=one_year*two_years;
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%let vars=overall1*stroke*revasc*mi;
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
	
/*do for each comparison group and each outcome*/
/*Adjusted model - stratified by age and adjusted by gender, statin use diabetes and index event */
%let lpa=%scan(&groups., &q., *);
ODS OUTPUT DIFFS=_07_&year.&var.2;
PROC GENMOD data=derived._07_mace_&year. DESC;
	CLASS &lpa. (REF="1") statins diabete /PARAM=GLM;
	MODEL &var._grp = &lpa. age statins diabete 
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


data _07_&year.&var.2;
	set _07_&year.&var.2;
	format time $15.;
	%if &i.=1 %then time='One Year ';
	%else %if &i.=2 %then time='Two Years';;
	var="&var.";
run;

	%end;
	%end;
	
	data _07_model2&q.;
	set 
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
	_07_&year.&var.2
	%end;
	%end; ;
	format lpa_grp_new $15.;
	where _&lpa.=1;
	%if &q.=1 %then %do;
	if lpa_grp=2 then lpa_grp_new='65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 nmol/L';;
	keep  Time lpa_grp_new var ExpEstimate Lowerexp UpperExp;
	run;
%end;
%mend;
%main;

/*overall follow up time*/
data _07_mace_all_1;
	set derived._07_mace_all;
	futime=eligend-index_date_overall+1;
	ln_futime=log(futime);
	event_time=coalesce(overall1_dt-index_date_overall,futime);
run;


%macro main;

%let groups=lpa_grp*lpa_grp1*lpa_grp2;
%do q=1 %to 3;
%let vars=overall1*stroke*revasc*mi;
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);


/*overall model adjusted for covariates*/
%let lpa=%scan(&groups., &q., *);
ODS OUTPUT DIFFS=_07_all&var.2;
PROC GENMOD data=_07_mace_all_1 DESC;
	CLASS &lpa. (REF="1") statins diabete /PARAM=GLM;
	MODEL &var._grp =  &lpa. age statins diabete 
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

data _07_all&var.2;
	set _07_all&var.2;
	format time $15.;
	time='Overall';
	var="&var.";
run;


%end;

	
	data _07_all2&q.;
	set 
	%do z=1 %to 4;
		%let var=%scan(&vars., &z., *);
	_07_all&var.2
	%end; ;
	format lpa_grp_new $15.;
	where _&lpa.=1;
	%if &q.=1 %then %do;
	if lpa_grp=2 then lpa_grp_new='65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 nmol/L';;
	keep Time var lpa_grp_new ExpEstimate Lowerexp UpperExp;
	run;
%end;
%mend;
%main;


data _07_model2_final;
	set _07_model21 _07_model22 _07_model23
		_07_all21 _07_all22 _07_all23;
	keep Time var lpa_grp_new ExpEstimate Lowerexp UpperExp;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_occurenceoveralladjusted.csv";
proc print data=_07_model2_final;
run;
ods csv close;

/*number of events analysis*/;
/*overall follow up time*/
data _07_mace_all_1;
	set derived._07_mace_all;
	futime=(eligend-index_date_overall+1)/365.25;
	ln_futime=log(futime);
	event_time=coalesce(overall1_dt-index_date_overall,futime);
run;

%macro main;
%let groups=lpa_grp*lpa_grp1*lpa_grp2;
%do q=1 %to 3;
	%let years=one_year*two_years;
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%let vars=overall1*stroke*revasc*mi;
		%do z=1 %to 4;
		%let var=%scan(&vars., &z., *);
		
/*adjusted for covariates*/
%let lpa=%scan(&groups., &q., *);
ODS OUTPUT LSMEANS=_07_M&year.&var.2;
ODS OUTPUT DIFFS=_07_D&year.&var.2;
PROC GENMOD data=derived._07_mace_&year. DESC;
	CLASS &lpa. (REF="1") statins diabete  /PARAM=GLM;
	MODEL &var. = &lpa. age statins diabete  
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


PROC SQL;
	CREATE TABLE _07_&year.&var.2 AS 
	SELECT case when &i.=1 then 'One Year' else 'Two Years' end as time, "&var." as var, a.&lpa.
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_M&year.&var.2 a LEFT JOIN _07_D&year.&var.2 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;
	

%end;
%end;

	data _07_model2&q.;
	set 
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
	_07_&year.&var.2
	%end;
	%end; ;
	format lpa_grp_new $15.;
	%if &q.=1 %then %do;
	if lpa_grp=2 then lpa_grp_new='65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 nmol/L';;
	keep Time lpa_grp_new var est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;
	run;
%end;
%mend;
%main;

%macro main;
%let groups=lpa_grp*lpa_grp1*lpa_grp2;
%do q=1 %to 3;
%let vars=overall1*stroke*revasc*mi;
	%do z=1 %to 4;
	%let var=%scan(&vars., &z., *);

/*overall - with follow up time adjusted for covariates*/
%let lpa=%scan(&groups., &q., *);
ODS OUTPUT LSMEANS=_07_Mall&var.2;
ODS OUTPUT DIFFS=_07_Dall&var.2;
PROC GENMOD data=_07_mace_all_1 DESC;
	CLASS &lpa. (REF="1")  statins diabete  /PARAM=GLM;
	MODEL &var. = &lpa. age  statins diabete 
	/ OFFSET=ln_futime dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;
 

PROC SQL;
	CREATE TABLE _07_all&var.2 AS 
	SELECT 'Overall' as time, "&var." as var, a.&lpa.
		, exp(a.estimate) as est_mean
		, exp(a.lower) as lowermean
		, exp(a.upper) as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_Mall&var.2 a LEFT JOIN _07_Dall&var.2 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;

%end;

	data _07_all2&q.;
	set 
	%do z=1 %to 4;
		%let var=%scan(&vars., &z., *);
	_07_all&var.2
	%end; ;
	format lpa_grp_new $15.;
	%if &q.=1 %then %do;
	if lpa_grp=2 then lpa_grp_new='65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 nmol/L';;
	keep Time var lpa_grp_new ExpEstimate Lowerexp UpperExp;
	run;
%end;
%mend;
%main;

data _07_model2_final;
	set _07_model21 _07_model22 _07_model23
		_07_all21 _07_all22 _07_all23;
		gdr_cd='Overall';
		retain gdr_cd ExpEstimate Lowerexp UpperExp Time var lpa_grp_new ;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_numberoveralladjusted.csv";
proc print data=_07_model2_final;
run;
ods csv close;

