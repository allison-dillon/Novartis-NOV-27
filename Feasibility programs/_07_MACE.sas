/*MACE model*/

/* proc print data= derived._05_demo2b_overall(obs=10); */
/* run; */

/*add in demographics*/
%macro main(years, year);

PROC SQL;
	CREATE TABLE derived._07_mace_&year. AS 
	SELECT a.patid, a.index_date_overall, a.eligeff, a.eligend, c.lpa
			
				,case when c.lpa<65 then 1 
					  when c.lpa>=65 and c.lpa<105 then 2
					  when c.lpa>=105 and c.lpa<150 then 3
					  when c.lpa>=150 and c.lpa<190 then 4
					  when c.lpa>=190 and c.lpa<255 then 5
					  when c.lpa>=255 then 6	end as lpa_grp			
				/*need to run with subgroups for >=150 and >=190*/
					,case when c.lpa<65 then 1 
					  when c.lpa>=150 then 2	end as lpa_grp1	
					 ,case when c.lpa<65 then 1 
					  when c.lpa>=190 then 2	end as lpa_grp2
				, coalesce(a.mi,0) as mi
				, a.mi_dt, a.mi_grp
				, coalesce(a.stroke,0) as stroke
				, a.stroke_dt, a.stroke_grp
				, coalesce(a.gang,0) as gang, a.gang_dt ,a.gang_grp
				, coalesce(a.revasc,0) as revasc, a.revasc_dt, a.revasc_grp
				,coalesce(a.overall1,0) as overall1
				, a.overall1_grp
				,min(mi_dt,stroke_dt,revasc_dt,gang_dt) as overall1_dt format mmddyy10.
				,b.recent_ldlc as LDLC, c.age, c.age_grp,c.gdr_cd,c.region,c.bus,c.index_yr	
				%let vars=mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*other;
				%do i=1 %to 8;
				%let var=%scan(&vars., &i., *);
				,datepart(c.index_date_&var.) as index_date_&var. format mmddyy10.
				,case when datepart(c.index_date_&var.)=a.index_date_overall then '1' else '.' end as index_&var.			
				%end;
			
				,case when compress(c.statins)='1' then '1' else '0' end as statins
				, c.diabete
	FROM derived._13a_mace_overall2&year. a inner join derived.ldlc_06 b on a.patid=b.patid
		inner join derived._05_demo2b_overall c on a.patid=c.patid
	where a.index_date_overall is not null and &years. 
	order by gdr_cd;
	quit;
	
%mend;
%main(one_year is not null, one_year);
%main(two_years is not null, two_years);
%main(1, all);

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

%let lpa=%scan(&groups.,&q., *);	
ODS OUTPUT DIFFS=_07_&year.&var.1;
PROC GENMOD data=derived._07_mace_&year. DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var._grp = &lpa.
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

data _07_&year.&var.1;
	set _07_&year.&var.1;
	format time $15.;
	%if &i.=1 %then time='One Year ';
	%else %if &i.=2 %then time='Two Years';;
	var="&var.";
run;
	
	
/*do for each comparison group and each outcome*/
/*Adjusted model - stratified by age and adjusted by gender, statin use diabetes and index event */
ODS OUTPUT DIFFS=_07_&year.&var.2;
PROC GENMOD data=derived._07_mace_&year. DESC;
	by gdr_cd;
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
	
	data _07_model1&q.;
	set 
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
	_07_&year.&var.1
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
	keep Time var &lpa. lpa_grp_new _&lpa. ExpEstimate Lowerexp UpperExp;	
	run;
	
	
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
	keep gdr_cd keep Time lpa_grp lpa_grp_new _lpa_grp var ExpEstimate Lowerexp UpperExp;
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

proc sort data=_07_mace_all_1;
by gdr_cd;
run;

%macro main;
%let groups=lpa_grp*lpa_grp1*lpa_grp2;
%do q=1 %to 3;
%let vars=overall1*stroke*revasc*mi;
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
%let lpa=%scan(&groups.,&q., *);
ODS OUTPUT DIFFS=_07_all&var.1;
PROC GENMOD data=_07_mace_all_1 DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var._grp = &lpa.
	/OFFSET=ln_futime dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


data _07_all&var.1;
	set _07_all&var.1;
	format time $15.;
	time='Overall';
	var="&var.";
run;



/*overall model adjusted for covariates*/
ODS OUTPUT DIFFS=_07_all&var.2;
PROC GENMOD data=_07_mace_all_1 DESC;
	by gdr_cd;
	CLASS &lpa. (REF="1") statins diabete /PARAM=GLM;
	MODEL &var._grp = &lpa. age statins diabete
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


data _07_all1&q.;
	set 
	%do z=1 %to 4;
		%let var=%scan(&vars., &z., *);
	_07_all&var.1
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
	keep gdr_cd keep Time var lpa_grp_new ExpEstimate Lowerexp UpperExp;
	run;
	%end;
%mend;
%main;

data _07_model1_final;
	set _07_model11 _07_model12 _07_model13
		_07_all11 _07_all12 _07_all13;
	keep ExpEstimate	LowerExp	UpperExp	time	var	lpa_grp_new;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_occurenceunadjusted.csv";
proc print data=_07_model1_final;
run;
ods csv close;

data _07_model2_final;
set 
_07_model21 _07_model22 _07_model23
		_07_all21 _07_all22 _07_all23;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_occurenceadjusted.csv";
proc print data=_07_model2_final;
run;
ods csv close;

/*number of events analysis*/;
/*overall follow up time in years*/
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
%let lpa=%scan(&groups., &q., *);		
ODS OUTPUT LSMEANS=_07_M&year.&var.1;
ODS OUTPUT DIFFS=_07_D&year.&var.1;
PROC GENMOD data=derived._07_mace_&year. DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var. = &lpa.
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

PROC SQL;
	CREATE TABLE _07_&year.&var.1 AS 
	SELECT case when &i.=1 then 'One Year' else 'Two Years' end as time, "&var." as var, a.&lpa.
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_M&year.&var.1 a LEFT JOIN _07_D&year.&var.1 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;

/*adjusted for covariates*/
ODS OUTPUT LSMEANS=_07_M&year.&var.2;
ODS OUTPUT DIFFS=_07_D&year.&var.2;
PROC GENMOD data=derived._07_mace_&year. DESC;
	by gdr_cd;
	CLASS &lpa. (REF="1") statins diabete /PARAM=GLM;
	MODEL &var. = &lpa. age statins diabete  
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


PROC SQL;
	CREATE TABLE _07_&year.&var.2 AS 
	SELECT case when &i.=1 then 'One Year' else 'Two Years' end as time, "&var." as var, a.&lpa., a.gdr_cd
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_M&year.&var.2 a LEFT JOIN _07_D&year.&var.2 b 
		ON a.&lpa.=b.&lpa. and a.gdr_cd=b.gdr_cd and b._&lpa.=1;
QUIT;
	

%end;
%end;
data _07_model1&q.;
	set 
	%do i=1 %to 2;
	%let year=%scan(&years., &i., *);
		%do z=1 %to 4;
			%let var=%scan(&vars., &z., *);
	_07_&year.&var.1
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
	keep Time var lpa_grp lpa_grp_new est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp ;	
	run;
	
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
	keep gdr_cd keep Time lpa_grp lpa_grp_new var est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;
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
/*overall - with follow up time*/
%let lpa=%scan(&groups., &q., *);
ODS OUTPUT LSMEANS=_07_Mall&var.1;
ODS OUTPUT DIFFS=_07_Dall&var.1;
PROC GENMOD data=_07_mace_all_1 DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var. = &lpa.
	/ OFFSET=ln_futime dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

PROC SQL;
	CREATE TABLE _07_all&var.1 AS 
	SELECT  'Overall' as time, "&var." as var, a.&lpa.
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_Mall&var.1 a LEFT JOIN _07_Dall&var.1 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;
	


/*overall - with follow up time adjusted for covariates*/
ODS OUTPUT LSMEANS=_07_Mall&var.2;
ODS OUTPUT DIFFS=_07_Dall&var.2;
PROC GENMOD data=_07_mace_all_1 DESC;
	by gdr_cd;
	CLASS &lpa. (REF="1")  statins diabete /PARAM=GLM;
	MODEL &var. = &lpa. age  statins diabete 
	/ OFFSET=ln_futime dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


PROC SQL;
	CREATE TABLE _07_all&var.2 AS 
	SELECT 'Overall' as time, "&var." as var, a.&lpa., a.gdr_cd
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
	FROM _07_Mall&var.2 a LEFT JOIN _07_Dall&var.2 b 
		ON a.&lpa.=b.&lpa. and a.gdr_cd=b.gdr_cd and b._&lpa.=1;
QUIT;

%end;

data _07_all1&q.;
	set 
	%do z=1 %to 4;
		%let var=%scan(&vars., &z., *);
	_07_all&var.1
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
	keep Time var lpa_grp_new est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;	
	run;
	
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
	keep gdr_cd keep Time var lpa_grp_new est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;
	run;
	%end;
%mend;
%main;

data _07_model1_final;
	set _07_model11 _07_model12 _07_model13
		_07_all11 _07_all12 _07_all13;
	keep ExpEstimate	LowerExp	UpperExp	time	var	lpa_grp_new;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_numberunadjusted.csv";
proc print data=_07_model1_final;
run;
ods csv close;

data _07_model2_final;
set _07_model21 _07_model22 _07_model23
		_07_all21 _07_all22 _07_all23;
		keep gdr_cd ExpEstimate	LowerExp	UpperExp	time	var	lpa_grp_new;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_07_numberadjusted.csv";
proc print data=_07_model2_final;
run;
