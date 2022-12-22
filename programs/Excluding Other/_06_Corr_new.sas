/*Spearman or Pearson coefficient to assest the correlation between LDL-C and Lp(a) levels*/
/*Sub groups of interest will be exploratory*/

/*most recent ldlc in study period*/
/*  */
/* %select */
/* 	select top 100 * */
/* 	from dingyig.ldlc_04_lab  */
/* %select; */

options mprint;
*most recent lab value;

	%create(ldlc_06)
			select a.patid, b.rslt_nbr as recent_ldlc, b.fst_dt as r_ldlc_date
			,row_number() over (partition by a.patid order by b.fst_dt desc) as rn 
		from dingyig._04_cohort_setup a inner join dingyig.ldlc_04_lab b
		on a.patid=b.patid and b.grp='ldlc'
		where year(to_date(b.fst_dt)) >= 2007 and year(to_date(b.fst_dt)) <= 2019 and b.rslt_nbr > 0 and b.rslt_nbr < 9999
			
	%create(ldlc_06);
	
	%create(ldlc_06_1)
		select *
		from dingyig.ldlc_06 
		where rn=1
	%create(ldlc_06_1);
	
* save files in SAS;
/* %connDBPassThrough(dbname=dingyig, libname1=imp); */
/* 	create table derived.ldlc_06 as select * from connection to imp */
/* 	(select * from ldlc_06_1); */
/* quit; */

PROC SQL;
	CREATE TABLE cohort1 as 
	SELECT a.*, b.recent_ldlc, b.r_ldlc_date
	FROM derived._05_demo1b_overall a left join heor.ldlc_06_1 b
		on a.patid=b.patid
	;
quit;

/*correlation again with most recent ldlc*/

%macro corr(seq, subgroup, whr);
	%let ad_groups=overall;
	%do ad=1 %to 1;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
	proc sql;
	create table cohort1_&ad_group. as 
	select *
	from cohort1
	where index_date_&ad_group. is not null;
	quit;
	
	
	data _07_all; 
	set cohort1_&ad_group.;
	where &whr. ; 
	run;
	
	proc corr data= _07_all plots(maxpoints=none)= matrix(nvar= all);
		var recent_ldlc lpa;
		ods output PearsonCorr=_07_pearson SimpleStats=_07_stat_all;
	run;
		
	data _07_sub; 
	set cohort1_&ad_group.;
	where &whr. and not missing(recent_ldlc); 
	run;
	
	proc corr data= _07_sub plots(maxpoints=none)= matrix(nvar= all);
		var recent_ldlc lpa;
		ods output PearsonCorr=_07_pearson SimpleStats=_07_stat;
	run;
	
	proc sql;
		create table _07_corr&seq. as 
		select distinct &seq. as seq, c.nobs as N_all, a.*, b.lpa, b.PLPA
		from (select "&whr.                           " as cat, Variable, NObs, Mean, StdDev from _07_stat_all) as c
			left join 
			(select "&whr.                           " as cat, Variable, NObs, Mean, StdDev from _07_stat) as a
			on a.variable=c.variable
			left join (select * from _07_pearson where Variable='recent_ldlc') as b
		on a.Variable=b.Variable
		order by seq, a.variable desc;
	quit;
	
	data _07_cohort1&ad_group.&seq;
	length cat1 cat2 $45.;
		set _07_corr&seq.;
		if &ad.=1. then cat1="Overall";
		else if &ad.=2 then cat1="Myocardial Infarcation";
		else if &ad.=3 then cat1="Peripheral artery disease (PAD)";
		else if &ad.=4 then cat1="Ischemic Stroke";
		else if &ad.=5 then cat1="Transient Ischemic Attack (TIA)";
		else if &ad.=6 then cat1="Unstable Angina";
		else if &ad.=7 then cat1="Stable Angina";
		else if &ad.=8 then cat1="Post-revascularization";
		else if &ad=9 then cat1="Percutaneous coronary intervention (PCI)";
		else if &ad=10  then cat1="Coronary artery bypass grafting (CABG)";
		else if &ad=11 then cat1="Angioplasty and/or stent placement";
		else if &ad=12 then cat1="Endarterectomy";
		else if &ad=13 then cat1="Thrombectomy";
		else if &ad.=14 then cat1="Other";
		cat2="&subgroup.";
	run;
	%end;
	
%mend corr;

%corr(1, overall,  whr=overall='1');
%corr(2, <30 mg/dL ,  whr= rslt_grp30='<30 ');
%corr(3, <50 mg/dL,whr= rslt_grp50='<50 ');
%corr(4, 30-<50 mg/dL, whr= rslt_grp='1. >=30 - <50');
%corr(5, 50-<70 mg/dL, whr= rslt_grp='2. >=50 - <70');
%corr(6, 70-<90 mg/dL, whr= rslt_grp='3. >=70 - <90');
%corr(7, 90-<120 mg/dL, whr= rslt_grp='4. >=90 - <120');
%corr(8, ≥70 mg/dL, whr= rslt_grp70='>=70 ');
%corr(9, ≥90 mg/dL, whr= rslt_grp90='>=90 ' );
%corr(10, ≥120 mg/dL,  whr= rslt_grp120='>=120');
%corr(11, ≥150 mg/dL, whr= rslt_grp150='>=150' );


data _07_corr1;
	set _07_cohort1overall1-_07_cohort1overall11;
/* 		_07_cohort1mi1-_07_cohort1mi11 */
/* 		_07_cohort1pad1-_07_cohort1pad11 */
/* 		_07_cohort1stroke1-_07_cohort1stroke11 */
/* 		_07_cohort1unsta_angina1-_07_cohort1unsta_angina11 */
/* 		_07_cohort1sta_angina1-_07_cohort1sta_angina11 */
/* 		_07_cohort1tia1-_07_cohort1tia11 */
/* 		_07_cohort1other1-_07_cohort1other11 */
/* 		_07_cohort1revasc1-_07_cohort1revasc11 */
/* 		_07_cohort1throm1-_07_cohort1throm11 */
/* 		_07_cohort1cabg1-_07_cohort1cabg11 */
/* 		_07_cohort1endar1-_07_cohort1endar11 */
/* 		_07_cohort1pci1 -_07_cohort1pci11 */
/* 		_07_cohort1angio_stent1-_07_cohort1angio_stent11; */
run;

proc print data=_07_corr1;
run;


/*  */
/* data _07_corr_total; set _07_corr1 - _07_corr11; run; */
/* proc print data=_07_corr_total; */
/* run; */


proc sgplot data= 	cohort1;
	scatter x=lpa y=recent_ldlc;
	xaxis label='Lp(a) (mg/dL)';
	yaxis label='LDL-C (mg/dL)';
	reg x=lpa y=recent_ldlc;
run;



/*COHORT 2*/

PROC SQL;
	CREATE TABLE cohort2 as 
	SELECT a.*, b.recent_ldlc, b.r_ldlc_date
	FROM derived._05_demo2b_overall a left join heor.ldlc_06_1 b
		on a.patid=b.patid;
quit;


/*correlation again with most recent ldlc*/

%macro corr(seq, subgroup, whr);
	%let ad_groups=overall;
	%do ad=1 %to 1;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
	proc sql;
	create table cohort2_&ad_group. as 
	select *
	from cohort2
	where index_date_&ad_group. is not null;
	quit;
	
	
	data _07_all; 
	set cohort2_&ad_group.;
	where &whr. ; 
	run;
	
	proc corr data= _07_all plots(maxpoints=none)= matrix(nvar= all);
		var recent_ldlc lpa;
		ods output PearsonCorr=_07_pearson SimpleStats=_07_stat_all;
	run;
		
	data _07_sub; 
	set cohort2_&ad_group.;
	where &whr. and not missing(recent_ldlc); 
	run;
	
	proc corr data= _07_sub plots(maxpoints=none)= matrix(nvar= all);
		var recent_ldlc lpa;
		ods output PearsonCorr=_07_pearson SimpleStats=_07_stat;
	run;
	
	proc sql;
		create table _07_corr&seq. as 
		select distinct &seq. as seq, c.nobs as N_all, a.*, b.lpa, b.PLPA
		from (select "&whr.                           " as cat, Variable, NObs, Mean, StdDev from _07_stat_all) as c
			left join 
			(select "&whr.                           " as cat, Variable, NObs, Mean, StdDev from _07_stat) as a
			on a.variable=c.variable
			left join (select * from _07_pearson where Variable='recent_ldlc') as b
		on a.Variable=b.Variable
		order by seq, a.variable desc;
	quit;
	
	data _07_cohort2&ad_group.&seq;
	length cat1 cat2 $45.;
		set _07_corr&seq.;
		if &ad.=1. then cat1="Overall";
		else if &ad.=2 then cat1="Myocardial Infarcation";
		else if &ad.=3 then cat1="Peripheral artery disease (PAD)";
		else if &ad.=4 then cat1="Ischemic Stroke";
		else if &ad.=5 then cat1="Transient Ischemic Attack (TIA)";
		else if &ad.=6 then cat1="Unstable Angina";
		else if &ad.=7 then cat1="Stable Angina";
		else if &ad.=8 then cat1="Post-revascularization";
		else if &ad=9 then cat1="Percutaneous coronary intervention (PCI)";
		else if &ad=10  then cat1="Coronary artery bypass grafting (CABG)";
		else if &ad=11 then cat1="Angioplasty and/or stent placement";
		else if &ad=12 then cat1="Endarterectomy";
		else if &ad=13 then cat1="Thrombectomy";
		else if &ad.=14 then cat1="Other";
		cat2="&subgroup.";
	run;
	%end;
	
%mend corr;


%corr(1, overall,  whr=overall='1');
%corr(2, <65 nmol/L ,  whr= rslt_grp65='<65 ');
%corr(3, <105 nmol/L,whr= rslt_grp105='<105 ');
%corr(4, 65-<105 nmol/L, whr= rslt_grp='1. >=65 - <105');
%corr(5, 105-<150 nmol/L, whr= rslt_grp='2. >=105 - <150');
%corr(6, 150-<190 nmol/L, whr= rslt_grp='3. >=150 - <190');
%corr(7, 190-<255 nmol/L, whr= rslt_grp='4. >=190 - <255');
%corr(8, ≥150 nmol/L, whr= rslt_grp150='>=150 ');
%corr(9, ≥190 nmol/L, whr= rslt_grp190='>=190 ' );
%corr(10, ≥255 nmol/L,  whr= rslt_grp255='>=255');
%corr(11, ≥320 nmol/L, whr= rslt_grp320='>=320' );

data _07_corr2;
	set _07_cohort2overall1-_07_cohort2overall11; 
/* 		_07_cohort2mi1-_07_cohort2mi11 */
/* 		_07_cohort2pad1-_07_cohort2pad11 */
/* 		_07_cohort2stroke1-_07_cohort2stroke11 */
/* 		_07_cohort2unsta_angina1-_07_cohort2unsta_angina11 */
/* 		_07_cohort2sta_angina1-_07_cohort2sta_angina11 */
/* 		_07_cohort2tia1-_07_cohort2tia11 */
/* 		_07_cohort2other1-_07_cohort2other11 */
/* 		_07_cohort2revasc1-_07_cohort2revasc11 */
/* 		_07_cohort2throm1-_07_cohort2throm11 */
/* 		_07_cohort2cabg1-_07_cohort2cabg11 */
/* 		_07_cohort2endar1-_07_cohort2endar11 */
/* 		_07_cohort2pci1 -_07_cohort2pci11 */
/* 		_07_cohort2angio_stent1-_07_cohort2angio_stent11; */
run;

proc print data=_07_corr2;
run;


proc sgplot data= 	cohort2;
	scatter x=lpa y=recent_ldlc;
	xaxis label='Lp(a) (mg/dL)';
	yaxis label='LDL-C (mg/dL)';
	reg x=lpa y=recent_ldlc;
run;


