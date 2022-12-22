* Annualized rate;
option mprint;
%macro time(year, years);

* Annualized Hospitalization Rates table;
%macro rate_tb (seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	/* Create HCRU table */
	%do z=1 %to 2;
	%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
	
	proc sql;
		create table _15_sub0&z. as 
		select a.* , b.recent_ldlc, b.rslt_lt_55, b.rslt_ge_55, b.rslt_lt_70, b.rslt_ge_70, b.rslt_lt_100, b.rslt_ge_100, '1' as Overall
		from  derived._07_primary_&z.overall a inner join derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years.;
		quit;
		
		data _15_sub&z.;
		set _15_sub0&z.;
		%if &z.=1 %then where &whrcl1. and &ad. is not null; 
		%else where &whrcl2. and &ad. is not null; 
		;
		run;
					
		
		proc sql;
			create table _15_hosp&z. as select * from derived._07_hospoverall&z.&year. where patid in (select distinct patid from _15_sub&z.);
			create table _15_er&z. as select * from derived._08_eroverall&z.&year. where patid in (select distinct patid from _15_sub&z.) ;
			create table _15_outp&z. as select * from derived._09_outpoverall&z.&year. where patid in (select distinct patid from _15_sub&z.) ;
		quit;
		
		
	* Inpatient;
		%do q=1 %to 10;
			%let vars=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*reh_cvd, &q., *);
			proc sql;
				create table _15_desc as
				select distinct &q. as seq, 'hosp' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					, sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/sum(py) as rate_ori
				from _15_hosp&z.
				where &vars.>0;
			quit;
		
			ods output ParameterEstimates=_15_est_allpts;
			proc genmod data=_15_hosp&z. (where= (&vars.>0));
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _15_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _15_est_allpts
				where parameter='Intercept' ;
			quit;
			data _15_hosp_rate&q.; merge _15_desc _15_rate_cl; by seq; run;
		%end;


	* ER;
		%do q=1 %to 8;
			%let vars=%scan(n_er*er_ascvd*er_mi*er_stroke*er_pad*er_angina*er_revasc*er_other, &q., *);
			proc sql;
				create table _15_desc as
				select distinct &q. as seq, 'er' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					, sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/sum(py) as rate_ori
				from _15_er&z.
				where &vars.>0;
			quit;
		
			ods output ParameterEstimates=_15_est_allpts;
			proc genmod data=_15_er&z. (where= (&vars.>0));
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _15_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _15_est_allpts
				where parameter='Intercept' ;
			quit;
			data _15_er_rate&q.; merge _15_desc _15_rate_cl; by seq; run;
		%end;
		
	* outpatient;
		%do q=1 %to 11;
			%let vars=%scan(n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_revasc*outp_other*cardio*gp*reh_cvd, &q., *);
			proc sql;
				create table _15_desc as
				select distinct &q. as seq, 'outp' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					, sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/sum(py) as rate_ori
				from _15_outp&z.
				where &vars.>0 ;
			quit;
		
			ods output ParameterEstimates=_15_est_allpts;
			proc genmod data=_15_outp&z. (where= (&vars.>0));
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _15_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _15_est_allpts
				where parameter='Intercept' ;
			quit;
			data _15_outp_rate&q.; merge _15_desc _15_rate_cl; by seq; run;
		%end;
		
		* set descriptive tables;
		data _15_&ad.&z.hcru_rate&seq.; 
			set _15_hosp_rate1 - _15_hosp_rate10 _15_er_rate1 - _15_er_rate8 _15_outp_rate1 - _15_outp_rate11;
			length group1 group2 $100.;
			if pts=0 then delete; 
				%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
				if &zz.=1 then group1='Overall';
/* 				if &zz.=1 then group1="< 55 mg/dL"; */
/* 				else if &zz.=2 then group1='≥ 55 mg/dL'; */
/* 				else if &zz.=3 then group1='< 70 mg/dL'; */
/* 				else if &zz.=4 then group1= '≥ 70 mg/dL'; */
/* 				else if &zz.=5 then group1='< 100 mg/dL'; */
/* 				else if &zz.=6 then group1='≥ 100 mg/dL'; */
		run;
		
	* Top 20 causes;
		proc sql;
			create table _15_diag_r as 
			select distinct a.patid, a.fst_dt, case when b.icd9 is not null then b.icd9 else a.diag end as diag
			from derived._09_outp_cause as a left join derived.icd_map as b
			on a.diag=b.icd10
			where a.patid in (select distinct patid from _15_sub&z.);
		
			create table _15_icd2 as 
			select distinct a.*, b.icd_flag, b.long_desc
			from (select distinct diag, count(distinct patid) as n_pts, count(diag) as n_icd /*based on the number of outpatient visits*/
					from _15_diag_r
					group by diag) as a
				left join (select distinct code, long_desc, '10' as icd_flag from derived.icd10_list union 
							select distinct code, long_desc, '9' as icd_flag from derived.icd9_list) as b
			on a.diag=b.code
			order by a.n_icd desc;
		quit;	
		data _15_icd3; set _15_icd2 (obs=20); run; /*select top 20 cause outpatient visits*/
		
		proc sql;
			create table _15_top_cause as 
			select distinct a.patid, count(distinct a.fst_dt) as n_topcause, a.diag, b.long_desc
			from _15_diag_r as a inner join _15_icd3 as b
			on a.diag=b.diag
			group by a.patid, a.diag;
		quit;
		
		proc sort data=_15_top_cause out=_15_unique_diag0 (keep=diag) nodupkey; by diag; run;
		data _15_unique_diag; set _15_unique_diag0; num=_n_; run;
		
		%do q=1 %to 20;
			proc sql;
				create table _15_top_cause_sub as
				select distinct a.*, b.py, b.ln_py
				from _15_top_cause as a inner join _15_outp&z. as b
				on a.patid=b.patid
				where diag in (select distinct diag from _15_unique_diag where num=&q.);
			
				create table _15_desc as
				select distinct &q. as seq, 'topcause' as cat1, long_desc
					, count(distinct patid) as pts
					, sum(py) as py, sum(n_topcause) as n_encounter, sum(n_topcause)/sum(py) as rate_ori
				from _15_top_cause_sub;
			quit;
		
			ods output ParameterEstimates=_15_est_allpts;
			proc genmod data=_15_top_cause_sub;
				model n_topcause= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _15_rate_cl as
				select &q. as seq, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _15_est_allpts
				where parameter='Intercept' ;
			quit;
			data _15_cause&q.; merge _15_desc _15_rate_cl; by seq; run;
		%end;
		data _15_cause_pre; set _15_cause1 - _15_cause20; drop seq; run;
		proc sort data=_15_cause_pre; by descending n_encounter; run;
		
		data _15_&ad.&z.cause_rate&seq.; 
		length group1 group2 $100.;
			set _15_cause_pre; 
			num=_n_; 
					
				%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
				if &zz.=1 then group1='Overall';
/* 				if &zz.=1 then group1="< 55 mg/dL"; */
/* 				else if &zz.=2 then group1='≥ 55 mg/dL'; */
/* 				else if &zz.=3 then group1='< 70 mg/dL'; */
/* 				else if &zz.=4 then group1= '≥ 70 mg/dL'; */
/* 				else if &zz.=5 then group1='< 100 mg/dL'; */
/* 				else if &zz.=6 then group1='≥ 100 mg/dL'; */
			run;	
	%end;
	%end;

%mend rate_tb;
	
%rate_tb(1, overall, overall,  whrcl1= '1', whrcl2='1');
%rate_tb(2, <30 mg/dL , <65 nmol/L , whrcl1=rslt_grp30='<30 ',  whrcl2= rslt_grp65='<65 ');
%rate_tb(3, <50 mg/dL, <105 nmol/L, whrcl1= rslt_grp50='<50 ', whrcl2= rslt_grp105='<105 ');
%rate_tb(4, 30-<50 mg/dL, 65-<105 nmol/L,  whrcl1= rslt_grp='1. >=30 - <50', whrcl2= rslt_grp='1. >=65 - <105');
%rate_tb(5,  50-<70 mg/dL, 105-<150 nmol/L, whrcl1= rslt_grp='2. >=50 - <70', whrcl2= rslt_grp='2. >=105 - <150');
%rate_tb(6, 70-<90 mg/dL, 150-<190 nmol/L, whrcl1= rslt_grp='3. >=70 - <90', whrcl2= rslt_grp='3. >=150 - <190');
%rate_tb(7, 90-<120 mg/dL, 190-<255 nmol/L, whrcl1= rslt_grp='4. >=90 - <120', whrcl2= rslt_grp='4. >=190 - <255');
%rate_tb(8, ≥70 mg/dL, ≥150 nmol/L, whrcl1= rslt_grp70='>=70 ', whrcl2= rslt_grp150='>=150 ');
%rate_tb(9, ≥90 mg/dL, ≥190 nmol/L, whrcl1= rslt_grp90='>=90 ', whrcl2= rslt_grp190='>=190 ' );
%rate_tb(10, ≥120 mg/dL, ≥255 nmol/L, whrcl1= rslt_grp120='>=120',  whrcl2= rslt_grp255='>=255');
%rate_tb(11, ≥150 mg/dL, ≥320 nmol/L, whrcl1= rslt_grp150='>=150', whrcl2= rslt_grp320='>=320' );
		

%macro output;		
	%do z=1 %to 2;
		data _15_hcru_rate&z.&year.; 
		set 
		_15_overall&z.hcru_rate1 - _15_overall&z.hcru_rate11;
/* 		_15_rslt_lt_55&z.hcru_rate1 - _15_rslt_lt_55&z.hcru_rate11 */
/* 		_15_rslt_ge_55&z.hcru_rate1 - _15_rslt_ge_55&z.hcru_rate11 */
/* 		_15_rslt_lt_70&z.hcru_rate1 - _15_rslt_lt_70&z.hcru_rate11 */
/* 		_15_rslt_ge_70&z.hcru_rate1 - _15_rslt_ge_70&z.hcru_rate11 */
/* 		_15_rslt_lt_100&z.hcru_rate1 - _15_rslt_lt_100&z.hcru_rate11 */
/* 		_15_rslt_ge_100&z.hcru_rate1 - _15_rslt_ge_100&z.hcru_rate11; */
		cohort=&z.;
	
		cohort=&z.;
		run;

		data _15_cause_rate&z.&year.; 
		set _15_overall&z.cause_rate1 - _15_overall&z.cause_rate11;
		
/* 		_15_rslt_lt_55&z.cause_rate1 - _15_rslt_lt_55&z.cause_rate11 */
/* 		_15_rslt_ge_55&z.cause_rate1 - _15_rslt_ge_55&z.cause_rate11 */
/* 		_15_rslt_lt_70&z.cause_rate1 - _15_rslt_lt_70&z.cause_rate11 */
/* 		_15_rslt_ge_70&z.cause_rate1 - _15_rslt_ge_70&z.cause_rate11 */
/* 		_15_rslt_lt_100&z.cause_rate1 - _15_rslt_lt_100&z.cause_rate11 */
/* 		_15_rslt_ge_100&z.cause_rate1 - _15_rslt_ge_100&z.cause_rate11; */
		cohort=&z.;
	run;
	%end;
	
	data derived._15_hcru_rate&year.;
		retain cohort_new group1 lpa_level1 seq cat1 cat2 concat NUM _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		set _15_hcru_rate1&year. _15_hcru_rate2&year.;
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
		if cohort=1 then cohort_new='Patients with Lp(a) in mg/dL';
		else if cohort=2 then cohort_new='Patients with Lp(a) in nmol/L';
		drop group2;
		concat=cats(cohort_new,group1,lpa_level1, put(seq, 5.), cat1, cat2);
	run;
	
	data derived._15_cause_rate&year.;
	retain cohort_new group1 lpa_level1 seq cat1 cat2 concat NUM _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
	length lpa_level1 $50. cohort_new $50. concat $200.;
		set _15_cause_rate1&year. _15_cause_rate2&year.;
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
		if cohort=1 then cohort_new='Patients with Lp(a) in mg/dL';
		else if cohort=2 then cohort_new='Patients with Lp(a) in nmol/L';
		drop group2;
		concat=cats(cohort_new,group1,lpa_level1, put(seq, 5.), cat1, cat2);
	run;
%mend;
%output;

%mend;

%time(one_year, years=one_year=1);
%time(two_years, years=two_years=1);
%time(all, years=patid is not null);


/*one year*/
ods csv file="/home/dingyig/proj/NOV-27/Output/_15_hcru_rate_one_year.csv";
proc print data=derived._15_hcru_rateone_year;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cause_rate_one_year.csv";
proc print data=derived._15_cause_rateone_year;
run;
ods csv close;

/*two year*/

ods csv file="/home/dingyig/proj/NOV-27/Output/_15_hcru_rate_two_year.csv";
proc print data=derived._15_hcru_ratetwo_years noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cause_rate_two_year.csv";
proc print data=derived._15_cause_ratetwo_years noobs;
run;
ods csv close;

/*all follow up */

ods csv file="/home/dingyig/proj/NOV-27/Output/_15_hcru_rate_all.csv";
proc print data=derived._15_hcru_rateall noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_15_cause_rate_all.csv";
proc print data=derived._15_cause_rateall noobs;
run;
ods csv close;
