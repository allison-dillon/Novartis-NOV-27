option mprint;
%macro time(year, years);

%macro stat_hcru (seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	/* Create HCRU table */
	%do z=1 %to 2;
	%let groups=overall*rslt_lt_55*rslt_ge_55*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100;
		%do zz=1 %to 7;
		%let ad = %scan(&groups., &zz., *);
	
		/*adds in most recent ldlc - only patients with continuous enrollment in that time period*/	
		proc sql;
			create table _14_sub0&z. as 
			select a.*, b.recent_ldlc, b.rslt_lt_55, b.rslt_ge_55, b.rslt_lt_70, b.rslt_ge_70, b.rslt_lt_100, b.rslt_ge_100, '1' as overall 
			from derived._07_primary_&z.overall a inner join  derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years.;
		quit;
		
		data _14_sub&z.;
		set _14_sub0&z.;
		%if &z.=1 %then where &whrcl1. and &ad. is not null; 
		%else where &whrcl2. and &ad. is not null; 
		;
		run;
			
		proc sql;
			create table _14_hosp&z. as select * from derived._07_hospoverall&z.&year. where patid in (select distinct patid from _14_sub&z.);
			create table _14_er&z. as select * from derived._08_eroverall&z.&year. where patid in (select distinct patid from _14_sub&z.) ;
			create table _14_outp&z. as select * from derived._09_outpoverall&z.&year. where patid in (select distinct patid from _14_sub&z.) ;
		quit;
	
		
		* Overall number of patients;
		proc sql;
			create table _14_overall_pts as
			select 0 as seq, 'overall     ' as cat1, 'overall         ' as cat2, count(distinct patid) as _FREQ_, 1 as perc
			from _14_sub&z.;
		quit;
		
		* Number of Hospitalizations;
			%do q=1 %to 10;
				proc sql noprint; select count(distinct patid) into: pts_hosp from _14_hosp&z.; quit;
				%let vars=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*reh_cvd, &q., *);
				proc means data=_14_hosp&z. (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_14_stat_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _14_stat_out&q. as  
					select &q. as seq, 'hosp' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_hosp. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _14_stat_out;
				quit;	
			%end;
		
		* Length of Stay in Hospitalizations;
			%do q=1 %to 12;
				%let vars=%scan(los*hosp_ascvd_los*hosp_mi_los*hosp_stroke_los*hosp_pad_los*hosp_angina_los*hosp_revasc_los*hosp_other_los
								*icu_los*icu_stay_los*reh_cvd_los*reh_cvd_stay_los, &q., *);
				proc sql noprint; select count(distinct patid) into: pts_hosp from _14_hosp&z.; quit;
				proc means data=_14_hosp&z. (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_14_stat_los_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _14_stat_los_out&q. as  
					select &q. as seq, 'los' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_hosp. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _14_stat_los_out;
				quit;	
			%end;
			
		* Length of Stay per Hospitalizations;
			%do q=1 %to 12;
				%let vars=%scan(los*hosp_ascvd_los*hosp_mi_los*hosp_stroke_los*hosp_pad_los*hosp_angina_los*hosp_revasc_los*hosp_other_los
								*icu_los*icu_stay_los*reh_cvd_los*reh_cvd_stay_los, &q., *);
				%let denom=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*icu*reh_cvd*reh_cvd, &q., *);
				proc sql noprint; select count(distinct patid) into: pts_hosp from _14_hosp&z.; quit;
				data _14_hosp_losperhosp; set _14_hosp&z.; &vars._ph= &vars./&denom.; where &vars. ge 1; run;
				proc means data=_14_hosp_losperhosp (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars._ph;
					output out=_14_stat_losperhosp mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _14_stat_losperhosp&q. as  
					select &q. as seq, 'los_per_hosp' as cat1, "&vars._ph" as cat2, _FREQ_, _FREQ_/&pts_hosp. as perc
						, &vars._ph_mean as mean
						, &vars._ph_stddev as sd
						, &vars._ph_median as median
						, &vars._ph_min as min
						, &vars._ph_q1 as q1
						, &vars._ph_q3 as q3
						, &vars._ph_max as max  
					from _14_stat_losperhosp;
				quit;	
			%end;
			
		* Number of ER visits;
			%do q=1 %to 8;
				%let vars=%scan(n_er*er_ascvd*er_mi*er_stroke*er_pad*er_angina*er_revasc*er_other, &q., *);
				proc sql noprint; select count(distinct patid) into: pts_er from _14_er&z.; quit;
				proc means data=_14_er&z. (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_14_stat_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _14_stat_er&q. as  
					select &q. as seq, 'er' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_er. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _14_stat_out;
				quit;	
			%end;
			
		* Number of outpatient visits;
			%do q=1 %to 11;
				%let vars=%scan(n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_revasc*outp_other*cardio*gp*reh_cvd, &q., *);
				proc sql noprint; select count(distinct patid) into: pts_outp from _14_outp&z.; quit;
				proc means data=_14_outp&z. (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_14_stat_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _14_stat_outp&q. as  
					select &q. as seq, 'outp' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_outp. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _14_stat_out;
				quit;	
			%end;
		
		*** set all descriptive table;
			data _14_&ad.&z.desc&seq.; 
				length group1 group2 $100.;
				set _14_overall_pts
					_14_stat_out1 - _14_stat_out10
					_14_stat_los_out1 - _14_stat_los_out12
					_14_stat_losperhosp1 - _14_stat_losperhosp12
					_14_stat_er1 - _14_stat_er8 
					_14_stat_outp1 - _14_stat_outp11;
				n=_n_;
				
				if &z.=1 then group2="&lpa_level1."; else group2="&lpa_level2."; 
		
				if &zz.=1 then group1='Overall';
				else if &zz.=2 then group1="< 55 mg/dL";
				else if &zz.=3 then group1='≥ 55 mg/dL';
				else if &zz.=4 then group1='< 70 mg/dL';
				else if &zz.=5 then group1= '≥ 70 mg/dL';
				else if &zz.=6 then group1='< 100 mg/dL';
				else if &zz.=7 then group1='≥ 100 mg/dL';
			run;
			

		* Top 20 causes by subgroups;
			proc sql;
				create table _14_diag_r as 
				select distinct a.patid, a.fst_dt, case when b.icd9 is not null then b.icd9 else a.diag end as diag /*make all code to icd10*/
				from derived._09_outp_cause as a left join derived.icd_map as b
				on a.diag=b.icd10
				where a.patid in (select distinct patid from _14_sub&z.);
			
				create table _14_icd2 as 
				select distinct a.*, b.icd_flag, b.long_desc
				from (select distinct diag, count(distinct patid) as n_pts, count(diag) as n_icd /*based on the number of outpatient visits*/
						from _14_diag_r
						group by diag) as a
					left join (select distinct code, long_desc, '10' as icd_flag from derived.icd10_list union 
								select distinct code, long_desc, '9' as icd_flag from derived.icd9_list) as b
				on a.diag=b.code
				order by a.n_icd desc;
			quit;	
			data _14_icd3; set _14_icd2 (obs=20); run; /*select top 20 cause outpatient visits*/
			
			proc sql;
				create table _14_top_cause as 
				select distinct a.patid, count(distinct a.fst_dt) as n_topcause, a.diag, b.long_desc
				from _14_diag_r as a inner join _14_icd3 as b
				on a.diag=b.diag inner join _14_outp&z. as c
				on a.patid=c.patid
				group by a.patid, a.diag;
			quit;
			
			proc means data=_14_top_cause n sum mean stddev median min q1 q3 max;
				var n_topcause;
				class diag;
				output out=_14_stat_topcause sum()= mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
			run;
			
			proc sort data=_14_top_cause out=_14_desc (keep= diag long_desc) nodupkey; by diag long_desc;
			data _14_merge_desc; merge _14_stat_topcause _14_desc; by diag; format cat2 $200.; cat2=trim(long_desc)||" (n= "||trim(left(n_topcause_sum))||")"; run;
			
			* set top 20 cause outpatients visit table;
			proc sql; 
				create table _14_stat_topcause_final_pre as  
				select distinct 'topcause' as cat1, cat2, _FREQ_, _FREQ_/&pts_outp. as perc
					, n_topcause_mean as mean
					, n_topcause_stddev as sd
					, n_topcause_median as median
					, n_topcause_min as min
					, n_topcause_q1 as q1
					, n_topcause_q3 as q3
					, n_topcause_max as max  
				from _14_merge_desc
				where _TYPE_ ne 0
				order by n_topcause_sum desc;
			quit;
			
			data _14_&ad.&z.top&seq.; 
			LENGTH group2  group1 $100.;
				set _14_stat_topcause_final_pre; 
				num=_n_; 
				if &z.=1 then group2="&lpa_level1."; else group2="&lpa_level2."; 
				
				if &zz.=1 then group1='Overall';
				else if &zz.=2 then group1="< 55 mg/dL";
				else if &zz.=3 then group1='≥ 55 mg/dL';
				else if &zz.=4 then group1='< 70 mg/dL';
				else if &zz.=5 then group1= '≥ 70 mg/dL';
				else if &zz.=6 then group1='< 100 mg/dL';
				else if &zz.=7 then group1='≥ 100 mg/dL';
		
			run;			
		%end;
	%end;


%mend stat_hcru;
	
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

%macro output;		
	%do z=1 %to 2;
		data _14_hcru_&z.&year.; 
		set 
		_14_overall&z.desc1 -_14_overall&z.desc11
		_14_rslt_lt_55&z.desc1 - _14_rslt_lt_55&z.desc11
		_14_rslt_ge_55&z.desc1 - _14_rslt_ge_55&z.desc11
		_14_rslt_lt_70&z.desc1 - _14_rslt_lt_70&z.desc11
		_14_rslt_ge_70&z.desc1 - _14_rslt_ge_70&z.desc11
		_14_rslt_lt_100&z.desc1 - _14_rslt_lt_100&z.desc11
		_14_rslt_ge_100&z.desc1 - _14_rslt_ge_100&z.desc11;
		cohort=&z.;
		run;

		data _14_cause_&z.&year.; 
		set _14_overall&z.top1 - _14_overall&z.top11
		_14_rslt_lt_55&z.top1 - _14_rslt_lt_55&z.top11
		_14_rslt_ge_55&z.top1 - _14_rslt_ge_55&z.top11
		_14_rslt_lt_70&z.top1 - _14_rslt_lt_70&z.top11
		_14_rslt_ge_70&z.top1 - _14_rslt_ge_70&z.top11
		_14_rslt_lt_100&z.top1 - _14_rslt_lt_100&z.top11
		_14_rslt_ge_100&z.top1 - _14_rslt_ge_100&z.top11;
		cohort=&z.;
	run;
	%end;
	
	data _14_hcru_&year.;
		retain cohort_new group1 lpa_level1 seq cat1 cat2 concat NUM _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		set _14_hcru_1&year. _14_hcru_2&year.;
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
	

	data _14_cause_&year.;
	retain cohort_new group1 lpa_level1 NUM cat1 concat cat2 _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
	length lpa_level1 $50. cohort_new $50. concat $200.;
		set _14_cause_1&year. _14_cause_2&year.;
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
%time(all, years=a.patid is not null);



/*one year*/
ods csv file="/home/dingyig/proj/NOV-27/Output/_14_hcru_one_year.csv";
proc print data=_14_hcru_one_year;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_14_cause_one_year.csv";
proc print data=_14_cause_one_year;
run;
ods csv close;

/*two year*/

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_hcru_two_year.csv";
proc print data=_14_hcru_two_years noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_14_cause_two_year.csv";
proc print data=_14_cause_two_years noobs;
run;
ods csv close;

/*all follow up */

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_hcru_all.csv";
proc print data=_14_hcru_all noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_14_cause_all.csv";
proc print data=_14_cause_all noobs;
run;
ods csv close;
