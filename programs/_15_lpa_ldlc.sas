* save files in SAS;


%macro main;
%do z=1 %to 2;
PROC SQL;
	CREATE TABLE cohort&z. as 
	SELECT a.*, b.recent_ldlc, b.r_ldlc_date
		, case when age_grp='1. <=17' then 1 end as le_17
		,case when age_grp='2. 18-24' then 1 end as _18_24
		,case when age_grp='3. 25-34' then 1 end as _25_34
        , case when age_grp='4. 35-44' then 1 end as _35_44
        , case when age_grp='5. 45-54' then 1 end as _45_54
        , case when age_grp='6. 55-64' then 1 end as _55_64
        , case when age_grp='7. 65-74' then 1 end as _65_74
        , case when age_grp='8. >=75' then 1 end as _75
        , '1' as overall
	FROM derived._05_demo&z.b_overall a left join derived.ldlc_06 b
		on a.patid=b.patid
	;
	quit;
	%end;
%mend;
%main;

%macro stat_hcru (seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
%do z=1 %to 2;
%let ad_groups=le_17*_18_24*_25_34*_35_44*_45_54*_55_64*_65_74*_75;
		%do ad=1 %to 8;
			%let ad_group = %scan(&ad_groups., &ad., *);
		
	proc sql;
	create table cohort&z.&ad_group. as 
	select *
	from cohort&z.
	where &ad_group=1 and index_date_overall is not null;
	quit;
	
	data _15_cohort&z.&ad_group.;
	set cohort&z.&ad_group.;
	%if &z.=1 %then where &whrcl1. ; 
	%else where &whrcl2.;
		;
	run;
	
%table1(cohort= _15_cohort&z.&ad_group.
		, output_dset= _15_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= recent_ldlc
		, hide_headspace= recent_ldlc
		, hide_missing=	recent_ldlc
		, combine_cols= 0
		, pvalues= 0
	
	%if &z.=1 %then strat_whr0= &whrcl1. ; 
	%else strat_whr0=&whrcl2.;
	
	);
		
	data _15_cohort&z.&ad_group._&seq.;
	length cohort_new cat1 lpa_level1 $45.;
		set _15_sub_tb;
		if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
		else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
		if &ad.=1. then cat1="<= 17";
		else if &ad.=2 then cat1="18-24";
		else if &ad.=3 then cat1="25-34";
		else if &ad.=4 then cat1="35-44";
		else if &ad.=5 then cat1="45-54";
		else if &ad.=6 then cat1="55-64";
		else if &ad.=7 then cat1="65-74";
		else if &ad.=8 then cat1="75+";
		%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
		if group2 in ('<30 mg/dL' , '<65 nmol/L') then lpa_level1='<30 mg/dL or <65 nmol/L';
		else if group2 in ('<50 mg/dL', '<105 nmol/L') then lpa_level1='<50 mg/dL or <105 nmol/L';
		else if group2 in ('30-<50 mg/dL', '65-<105 nmol/L') then lpa_level1='30-<50 mg/dL or 65-<105 nmol/L';
		else if group2 in ('50-<70 mg/dL', '105-<150 nmol/L') then lpa_level1='50-<70 mg/dL or 105-<150 nmol/L';
		else if group2 in ('70-<90 mg/dL', '150-<190 nmol/L') then lpa_level1='70-<90 mg/dL or 150-<190 nmol/L';
		else if group2 in ('90-<120 mg/dL', '190-<255 nmol/L') then lpa_level1='90-<120 mg/dL or 190-<255 nmol/L';
		else if group2 in ('≥70 mg/dL', '≥150 nmol/L') then lpa_level1='≥70 mg/dL or ≥150 nmol/L';
		else if group2 in ('≥90 mg/dL', '≥190 nmol/L') then lpa_level1='≥90 mg/dL or ≥190 nmol/L';
		else if group2 in ('≥120 mg/dL', '≥255 nmol/L') then lpa_level1='≥120 mg/dL or ≥255 nmol/L';
		else if group2 in ('≥150 mg/dL', '≥320 nmol/L') then lpa_level1='≥150 mg/dL or ≥320 nmol/L';
		else if group2='overall' then lpa_level1='Overall';
		drop group2;
	run;
	
	%end;
	%end;
%mend;
	
%stat_hcru(1, overall, overall,  whrcl1= '1', whrcl2='1');
%stat_hcru(2, <30 mg/dL , <65 nmol/L , whrcl1=rslt_grp30='<30 ',  whrcl2= rslt_grp65='<65 ');
%stat_hcru(3, <50 mg/dL, <105 nmol/L, whrcl1= rslt_grp50='<50 ', whrcl2= rslt_grp105='<105 ');
%stat_hcru(4, 30-<50 mg/dL, 65-<105 nmol/L,  whrcl1= rslt_grp='1. >=30 - <50', whrcl2= rslt_grp='1. >=65 - <105');
%stat_hcru(5,  50-<70 mg/dL, 105-<150 nmol/L, whrcl1= rslt_grp='2. >=50 - <70', whrcl2= rslt_grp='2. >=105 - <150');
%stat_hcru(6, 70-<90 mg/dL, 150-<190 nmol/L, whrcl1= rslt_grp='3. >=70 - <90', whrcl2= rslt_grp='3. >=150 - <190');
%stat_hcru(7, 90-<120 mg/dL, 190-<255 nmol/L, whrcl1= rslt_grp='4. >=90 - <120', whrcl2= rslt_grp='4. >=190 - <255');
%stat_hcru(8, ≥70 mg/dL, ≥150 nmol/L, whrcl1= rslt_grp70='>=70 ', whrcl2= rslt_grp150='>=150 ');
%stat_hcru(9, ≥90 mg/dL, ≥190 nmol/L, whrcl1= rslt_grp90='>=90 ', whrcl2= rslt_grp190='>=190 ' );
%stat_hcru(10, ≥120 mg/dL, ≥255 nmol/L, whrcl1= rslt_grp120='>=120',  whrcl2= rslt_grp255='>=255');
%stat_hcru(11, ≥150 mg/dL, ≥320 nmol/L, whrcl1= rslt_grp150='>=150', whrcl2= rslt_grp320='>=320' );


%macro main;

%do z=1 %to 2;
data _15_cohort&z.;
	set
	%let ad_groups=le_17*_18_24*_25_34*_35_44*_45_54*_55_64*_65_74*_75;
		%do ad=1 %to 8;
			%let ad_group = %scan(&ad_groups., &ad., *);
	_15_cohort&z.&ad_group._1 - _15_cohort&z.&ad_group._11

	%end;
	;
	run;
	%end;
%mend;
%main;

ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cohort1ldlc.csv";
proc print data=_15_cohort1 noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cohort2ldlc.csv";
proc print data=_15_cohort2 noobs;
run;
ods csv close;

/*lpa distribution by age group*/


%macro main;
%do z=1 %to 2;
PROC SQL;
	CREATE TABLE cohort&z. as 
	SELECT a.*
		, case when age_grp='1. <=17' then 1 end as le_17
		,case when age_grp='2. 18-24' then 1 end as _18_24
		,case when age_grp='3. 25-34' then 1 end as _25_34
        , case when age_grp='4. 35-44' then 1 end as _35_44
        , case when age_grp='5. 45-54' then 1 end as _45_54
        , case when age_grp='6. 55-64' then 1 end as _55_64
        , case when age_grp='7. 65-74' then 1 end as _65_74
        , case when age_grp='8. >=75' then 1 end as _75
        , '1' as overall
	FROM derived._05_demo&z.b_overall a 
	;
	quit;
	%end;
%mend;
%main;

%macro stat_hcru (seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
%do z=1 %to 2;
%let ad_groups=le_17*_18_24*_25_34*_35_44*_45_54*_55_64*_65_74*_75;
		%do ad=1 %to 8;
			%let ad_group = %scan(&ad_groups., &ad., *);
		
	proc sql;
	create table cohort&z.&ad_group. as 
	select *
	from cohort&z.
	where &ad_group=1 and index_date_overall is not null;
	quit;
	
	data _15_cohort&z.&ad_group.;
	set cohort&z.&ad_group.;
/* 	%if &z.=1 %then where &whrcl1. ;  */
/* 	%else where &whrcl2.; */
	run;
	
%table1(cohort= _15_cohort&z.&ad_group.
		, output_dset= _15_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= lpa
		, hide_headspace= lpa
		, hide_missing=	lpa
		, combine_cols= 0
		, pvalues= 0
	
	%if &z.=1 %then strat_whr0= &whrcl1. ; 
	%else strat_whr0=&whrcl2.;
	
	);
		
	data _15_cohort&z.&ad_group._&seq.;
	length cat1 cat2 $45.;
		set _15_sub_tb;
		if &ad.=1. then cat1="<= 17";
		else if &ad.=2 then cat1="18-24";
		else if &ad.=3 then cat1="25-34";
		else if &ad.=4 then cat1="35-44";
		else if &ad.=5 then cat1="45-54";
		else if &ad.=6 then cat1="55-64";
		else if &ad.=7 then cat1="65-74";
		else if &ad.=8 then cat1="75+";
		if &z.=1 then cat2="&lpa_level1."; else cat2="&lpa_level2."; ;
	run;
	
	%end;
	%end;
%mend;
	
%stat_hcru(1, overall, overall,  whrcl1= '1', whrcl2='1');

%macro main;
%do z=1 %to 2;
data _15_cohortlpa&z.;
	set
	%let ad_groups=le_17*_18_24*_25_34*_35_44*_45_54*_55_64*_65_74*_75;
		%do ad=1 %to 8;
			%let ad_group = %scan(&ad_groups., &ad., *);
	_15_cohort&z.&ad_group._1 

	%end;
	;
	run;
	%end;
%mend;
%main;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cohort1lpa.csv";
proc print data=_15_cohortlpa1 noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cohort2lpa.csv";
proc print data=_15_cohortlpa2 noobs;
run;
ods csv close;