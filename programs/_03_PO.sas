* primary objective, will use both mg/dL and nmol/L, seraprately;


PROC SQL;
	create table derived._02_cohort1 as 
	SELECT * 
	FROM heor._01_cohort_6a;
quit;

PROC SQL;
	create table derived._02_cohort2 as
	select * 
	from heor._01_cohort_6b;
quit;

proc sql;
	create table derived._02_primary_1 as
	select a.*
		, case when rslt_NBR lt 30 then '<30 ' end as rslt_grp30
		, case when RSLT_NBR lt 50 then '<50 ' end as rslt_grp50
		, case when 30 le RSLT_NBR lt 50 then '1. >=30 - <50'
		 	when 50 le RSLT_NBR lt 70 then '2. >=50 - <70'
			when 70 le RSLT_NBR lt 90 then '3. >=70 - <90'
			when 90 le RSLT_NBR lt 120 then '4. >=90 - <120' end as rslt_grp
		, case when 70 le RSLT_NBR then '>=70 ' end as rslt_grp70
		, case when 90 le RSLT_NBR then '>=90 ' end as rslt_grp90
		, case when 120 le RSLT_NBR then '>=120' end as rslt_grp120
		, case when 150 le RSLT_NBR then '>=150' end as rslt_grp150
		,'1' as overall
	from derived._02_cohort1 a ;
quit;


DATA TEST;
	SET derived._02_primary_1;
	Lpa=RSLT_NBR;
	label Lpa="Lp(a) (in mg/dL)";
	title= "Distribution of Lpa for Main ASCVD Cohort";
	where not missing(index_date_overall );
run;

proc univariate data=test;
   var Lpa;
   histogram;
   title1 "Distribution of Lpa for Main ASCVD Cohort";
run;


%macro output(table, group);
proc sql;
	create table _02_cohort1_&table. as 
	select *
	from derived._02_primary_1
	where index_date_&table. is not null;
quit;

/* proc print data=derived._02_primary_1 (obs=500); */
/* run; */

%table1(cohort= _02_cohort1_&table.
		, output_dset= _02_primary_1a
		, cont_stats= MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= RSLT_NBR*rslt_grp30*rslt_grp50*rslt_grp*rslt_grp70*rslt_grp90*rslt_grp120*rslt_grp150
		, hide_headspace= RSLT_NBR*rslt_grp30*rslt_grp50*rslt_grp*rslt_grp70*rslt_grp90*rslt_grp120*rslt_grp150
		, hide_missing= RSLT_NBR*rslt_grp30*rslt_grp50*rslt_grp*rslt_grp70*rslt_grp90*rslt_grp120*rslt_grp150
		, combine_cols=
		, pvalues=
		, strat_whr0=1;
	);
	
	
	data &table.;
		length cat1 $100.;
		set _02_primary_1a;
		cat1=&group.;
	run;
	
%mend output;


%output(overall, "Main ASCVD");
%output(cvd, "MI, Ischemic stroke, PAD");
%output(anginatia, "Unstable Angina, Stable Angina, Transient ischemic attack (TIA)");
%output(revasc, "Post-revascularization");
%output(other, "Other");
%output(mi, "Myocardial Infarction");
%output(pad, "Peripheral artery disease (PAD)");
%output(stroke, "Ischemic Stroke");
%output(unsta_angina, "Unstable Angina");
%output(sta_angina, "Stable Angina");
%output(tia, "Transient Ischemic Attack (TIA)");

data _02_final_1;
	retain cat1 col0 col1 concat;
	set overall 
		cvd
		anginatia
		revasc
		other
		mi
		pad
		stroke
		unsta_angina
		sta_angina
		tia;
	
		concat=catx(trim(cat1),trim(col0),trim(col1));
run;

proc print data=_02_final_1;
run;

proc sql;
	create table derived._02_primary_2 as
	select a.*
	, case when rslt_NBR lt 65 then '<65' end as rslt_grp65
		, case when RSLT_NBR lt 105 then '<105 ' end as rslt_grp105
		, case when 65 le RSLT_NBR lt 105 then '1. >=65 - <105'
		 	when 105 le RSLT_NBR lt 150 then '2. >=105 - <150'
			when 150 le RSLT_NBR lt 190 then '3. >=150 - <190'
			when 190 le RSLT_NBR lt 255 then '4. >=190 - <255' end as rslt_grp
		, case when 150 le RSLT_NBR then '>=150 ' end as rslt_grp150
		, case when 190 le RSLT_NBR then '>=190 ' end as rslt_grp190
		, case when 255 le RSLT_NBR then '>=255' end as rslt_grp255
		, case when 320 le RSLT_NBR then '>=320' end as rslt_grp320

	from derived._02_cohort2 a	;
quit;

DATA TEST_2;
	SET derived._02_primary_2;
	Lpa=RSLT_NBR;
	label Lpa="Lp(a) (in nmol/L)";
	where not missing(index_date_overall );
run;

proc univariate data=test_2;
title 'Distribution of Lpa for Main ASCVD Cohort';
   var Lpa;
   histogram  / endpoints = 0 to 75 by 5;
run;


%macro output(table, group);
proc sql;
	create table _02_cohort2_&table. as 
	select *
	from derived._02_primary_2
	where index_date_&table. is not null;
quit;

%table1(cohort= _02_cohort2_&table.
		, output_dset= _02_primary_2a
		, cont_stats= MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= RSLT_NBR*rslt_grp65*rslt_grp105*rslt_grp*rslt_grp150*rslt_grp190*rslt_grp255*rslt_grp320
		, hide_headspace= RSLT_NBR*rslt_grp65*rslt_grp105*rslt_grp*rslt_grp150*rslt_grp190*rslt_grp255*rslt_grp320
		, hide_missing= RSLT_NBR*rslt_grp65*rslt_grp105*rslt_grp*rslt_grp150*rslt_grp190*rslt_grp255*rslt_grp320
		, combine_cols=
		, pvalues=
		, strat_whr0=1;
	);
	
	
	data &table.;
		length cat1 $100.;
		set _02_primary_2a;
		cat1=&group.;
	run;
	
%mend output;




%output(overall, "Main ASCVD");
%output(cvd, "MI, Ischemic stroke, PAD");
%output(anginatia, "Unstable Angina, Stable Angina, Transient ischemic attack (TIA)");
%output(revasc, "Post-revascularization");
%output(other, "Other");
%output(mi, "Myocardial Infarction");
%output(pad, "Peripheral artery disease (PAD)");
%output(stroke, "Ischemic Stroke");
%output(unsta_angina, "Unstable Angina");
%output(sta_angina, "Stable Angina");
%output(tia, "Transient Ischemic Attack (TIA)");


data _02_final_2;
retain cat1 col0 col1 concat;
		set overall 
		cvd
		anginatia
		revasc
		other
		mi
		pad
		stroke
		unsta_angina
		sta_angina
		tia;
	concat=cat(trim(cat1),trim(col0),trim(col1));
run;


proc print data=_02_final_2;
run;

/*distribution of diagnoses for other index cohorts*/
%create(_01_other_1)
	select a.*, b.code
	from dingyig._01_cohort_6a a inner join dingyig.optum2_01_ascvd b
		on a.patid=b.patid and a.index_date_other=b.dt and b.grp='other'
%create(_01_other_1);

%select
	select code, count(patid) as pats
	from dingyig._01_other_1
	group by code
%select;


/*distribution of diagnoses for other index cohorts*/
%create(_01_other_2)
	select a.*, b.code
	from dingyig._01_cohort_6b a inner join dingyig.optum2_01_ascvd b
		on a.patid=b.patid and a.index_date_other=b.dt and b.grp='other'
%create(_01_other_2);


%select
	select code, count(patid) as pats
	from dingyig._01_other_2
	group by code
%select;


