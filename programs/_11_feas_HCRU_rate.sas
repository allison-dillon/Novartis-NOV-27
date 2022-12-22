* Annualized rate;

options mprint;	
%macro py(time, num, year, years);
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 12;
		
		%let ad = %scan(&groups., &zz., *);
/*overall py for all patients*/
DATA _11_rate_&z.&ad.&year.;
	set derived._07_primary_&z.&ad. ;
	py=(eligend-index_date_&ad.+1)/ 365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	where &years. and index_date_&ad. is not null;
run;

%end;
%end;
%mend;
%py(a.index_date_&ad.+365.25, 1, one_year, years=one_year=1);
%py(a.index_date_&ad.+(365.25*2), 2, two_years, years=two_years=1);	
%py(a.eligend, 11, all, years=patid is not null);

%macro time (year, period, years);

%macro rate_tb (seq, lpa_level1, lpa_level2, whrcl1, whrcl2);



	%do z=1 %to 2;
	%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 12;
		%let ad = %scan(&groups., &zz., *);
	
		data _11_sub0&z.; 
		set derived._07_primary_&z.&ad.; 
		where index_date_&ad. is not null and &years.;
		run;
		
		data _11_sub&z.;
		set _11_sub0&z.;
		%if &z.=1 %then where &whrcl1. ; 
		%else where &whrcl2.;
		;
		run;
					
		
		proc sql;
			create table _11_hosp&z. as select * from derived._07_hosp&ad.&z.&year. where patid in (select distinct patid from _11_sub&z.);
			create table _11_er&z. as select * from derived._08_er&ad.&z.&year. where patid in (select distinct patid from _11_sub&z.) ;
			create table _11_outp&z. as select * from derived._09_outp&ad.&z.&year. where patid in (select distinct patid from _11_sub&z.) ;
		quit;
				
	/*inpatient person-year denominator*/
	
	PROC SQL;
		SELECT sum(py) INTO: py
		FROM  _11_rate_&z.&ad.&year. 
		WHERE patid in (select distinct patid from _11_sub&z.)
		;
	QUIT;
	
	
	
	PROC SQL;
		SELECT sum(coalesce(a.py,b.py)) INTO: inp_py
		FROM  _11_hosp&z. a RIGHT JOIN _11_rate_&z.&ad.&year. b
		on a.patid=b.patid
		WHERE b.patid in (select distinct patid from _11_sub&z.);
	QUIT;
	/*er person-year denominator*/
	PROC SQL;
		SELECT sum(coalesce(a.py,b.py)) INTO: er_py
		FROM  _11_er&z. a RIGHT JOIN _11_rate_&z.&ad.&year. b
		on a.patid=b.patid
		WHERE b.patid in (select distinct patid from _11_sub&z.);
	QUIT;
	PROC SQL;
		SELECT sum(coalesce(a.py,b.py)) INTO: op_py
		FROM  _11_outp&z. a RIGHT JOIN _11_rate_&z.&ad.&year. b
		on a.patid=b.patid
		WHERE b.patid in (select distinct patid from _11_sub&z.);
	QUIT;
		
	* Inpatient;
		%do q=1 %to 10;
			%let vars=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*reh_cvd, &q., *);
			
			proc sql;
				create table _11_desc as
				select distinct &q. as seq, 'hosp' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					,&py. as overall_py, sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/sum(&inp_py.) as rate_ori
				from _11_hosp&z.
				where &vars.>0;
			quit;
			
			ods output ParameterEstimates=_11_est_allpts;
			proc genmod data=_11_hosp&z.;
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _11_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _11_est_allpts
				where parameter='Intercept' ;
			quit;
			data _11_hosp_rate&q.; merge _11_desc _11_rate_cl; by seq; run;
		%end;


	* ER;
		%do q=1 %to 8;
			%let vars=%scan(n_er*er_ascvd*er_mi*er_stroke*er_pad*er_angina*er_revasc*er_other, &q., *);
			proc sql;
				create table _11_desc as
				select distinct &q. as seq, 'er' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					,&py. as overall_py,  sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/&er_py. as rate_ori
				from _11_er&z.
				where &vars.>0;
			quit;
		
			ods output ParameterEstimates=_11_est_allpts;
			proc genmod data=_11_er&z. ;
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _11_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _11_est_allpts
				where parameter='Intercept' ;
			quit;
			data _11_er_rate&q.; merge _11_desc _11_rate_cl; by seq; run;
		%end;
		
	* outpatient;
		%do q=1 %to 11;
			%let vars=%scan(n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_revasc*outp_other*cardio*gp*reh_cvd, &q., *);
			proc sql;
				create table _11_desc as
				select distinct &q. as seq, 'outp' as cat1, "&vars.                    " as cat2
					, count(distinct patid) as pts
					,&py. as overall_py, sum(py) as py, sum(&vars.) as n_encounter, sum(&vars.)/&op_py. as rate_ori
				from _11_outp&z.
				where &vars.>0 ;
			quit;
	
			ods output ParameterEstimates=_11_est_allpts;
			proc genmod data=_11_outp&z.;
				model &vars.= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _11_rate_cl as
				select &q. as seq, "&vars.                    " as cat2, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _11_est_allpts
				where parameter='Intercept' ;
			quit;
			data _11_outp_rate&q.; merge _11_desc _11_rate_cl; by seq; run;
		%end;
		
		* set descriptive tables;
		data _11_hcru_rate&z.&ad.&seq.; 
			set _11_hosp_rate1 - _11_hosp_rate10 _11_er_rate1 - _11_er_rate8 _11_outp_rate1 - _11_outp_rate11;
			length cohort_new group1 group2 $100.;
			if pts=0 then delete; 
				%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
					
				if &zz.=1. then group1="Main ASCVD";
				else if &zz.=2 then group1="Myocardial Infarction";
				else if &zz.=3 then group1="Peripheral artery disease (PAD)";
				else if &zz.=4 then group1="Ischemic Stroke";
				else if &zz.=5 then group1="Unstable Angina";
				else if &zz.=6 then group1="Stable Angina";
				else if &zz.=7 then group1="Transient ischemic attack (TIA)";
				else if &zz.=8 then group1="Other";
				else if &zz.=9 then group1="Post-revascularization";
				else if &zz.=10 then group1="MI, Ischemic stroke, PAD";
				else if &zz.=11 then group1="Unstable Angina, Stable Angina, Transient ischemic attack (TIA)";
				if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
				else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
		run;
		
	* Top 20 causes;
		proc sql;
			create table _11_diag_r as 
			select distinct a.patid, a.fst_dt, case when b.icd9 is not null then b.icd9 else a.diag end as diag
			from derived._09_outp_cause as a left join derived.icd_map as b
			on a.diag=b.icd10
				inner join _11_sub&z. c on a.patid=c.patid and datepart(a.fst_dt)>=index_date_&ad. and datepart(a.fst_dt)<=&period.;
		
			create table _11_icd2 as 
			select distinct a.*, b.icd_flag, b.long_desc
			from (select distinct diag, count(distinct patid) as n_pts, count(diag) as n_icd /*based on the number of outpatient visits*/
					from _11_diag_r
					group by diag) as a
				left join (select distinct code, long_desc, '10' as icd_flag from derived.icd10_list union 
							select distinct code, long_desc, '9' as icd_flag from derived.icd9_list) as b
			on a.diag=b.code
			order by a.n_icd desc;
		quit;	
		data _11_icd3; set _11_icd2 (obs=20); run; /*select top 20 cause outpatient visits*/
		
		proc sql;
			create table _11_top_cause as 
			select distinct a.patid, count(distinct a.fst_dt) as n_topcause, a.diag, b.long_desc
			from _11_diag_r as a inner join _11_icd3 as b
			on a.diag=b.diag
			group by a.patid, a.diag;
		quit;
		
		proc sort data=_11_top_cause out=_11_unique_diag0 (keep=diag) nodupkey; by diag; run;
		data _11_unique_diag; set _11_unique_diag0; num=_n_; run;
		
		%do q=1 %to 20;			
			proc sql;
			/*only patients in our cohort*/
				create table _11_top_cause_sub as
				select distinct b.patid, coalesce(a.n_topcause,0) as n_topcause, a.diag, a.long_desc, b.py, b.ln_py, c.num
				from _11_top_cause as a right join _11_outp&z. as b
				on a.patid=b.patid left join  _11_unique_diag c on a.diag=c.diag
				where c.num=&q.;
			
			/*all patients - for rates*/
				create table _11_top_cause_sub1 as 
				select distinct b.patid, coalesce(a.n_topcause,0) as n_topcause, a.diag, a.long_desc, b.py, b.ln_py
				from _11_top_cause_sub as a right join _11_outp&z. as b on a.patid=b.patid
				;				
				create table _11_desc as
				select distinct &q. as seq, 'topcause' as cat1, long_desc
					, count(distinct patid) as pts
					,&py. as overall_py, sum(py) as py, sum(n_topcause) as n_encounter, sum(n_topcause)/&op_py. as rate_ori
				from _11_top_cause_sub
			 ;
			quit;
			
		
			ods output ParameterEstimates=_11_est_allpts;
			proc genmod data=_11_top_cause_sub1;
				model n_topcause= / offset=ln_py dist=poisson link=log;
			run;
			proc sql;	
				create table _11_rate_cl as
				select &q. as seq, exp(estimate) as rate, exp(LowerWaldCL) as lower95, exp(UpperWaldCL) as upper95
				from _11_est_allpts
				where parameter='Intercept' ;
			quit;
			data _11_cause&q.; merge _11_desc _11_rate_cl; by seq; run;
		%end;
		
		data _11_cause_pre; set _11_cause1 - _11_cause20; drop seq; run;
		proc sort data=_11_cause_pre; by descending n_encounter; run;
		
		data _11_cause_rate&z.&ad.&seq.; 
		length cohort_new group1 group2 $100.;
			set _11_cause_pre; 
			num=_n_; 
					
				%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
					
				if &zz.=1. then group1="Main ASCVD";
				else if &zz.=2 then group1="Myocardial Infarction";
				else if &zz.=3 then group1="Peripheral artery disease (PAD)";
				else if &zz.=4 then group1="Ischemic Stroke";
				else if &zz.=5 then group1="Unstable Angina";
				else if &zz.=6 then group1="Stable Angina";
				else if &zz.=7 then group1="Transient ischemic attack (TIA)";
				else if &zz.=8 then group1="Other";
				else if &zz.=9 then group1="Post-revascularization";
				else if &zz.=10 then group1="MI, Ischemic stroke, PAD";
				else if &zz.=11 then group1="Unstable Angina, Stable Angina, Transient ischemic attack (TIA)";
				if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
				else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
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
		

data derived._11_hcru_rate&year.;
		retain cohort_new group1 lpa_level1 seq cat1 cat2 concat NUM _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		
	set _11_hcru_rate1overall1-_11_hcru_rate1overall11
		_11_hcru_rate1cvd1-_11_hcru_rate1cvd11
		_11_hcru_rate1noncvd1-_11_hcru_rate1noncvd11
		_11_hcru_rate1mi1-_11_hcru_rate1mi11
		_11_hcru_rate1pad1-_11_hcru_rate1pad11
		_11_hcru_rate1stroke1-_11_hcru_rate1stroke11
		_11_hcru_rate1unsta_angina1-_11_hcru_rate1unsta_angina11
		_11_hcru_rate1sta_angina1-_11_hcru_rate1sta_angina11
		_11_hcru_rate1tia1-_11_hcru_rate1tia11
		_11_hcru_rate1other1-_11_hcru_rate1other11
		_11_hcru_rate1revasc1-_11_hcru_rate1revasc11
		_11_hcru_rate1anginatia1-_11_hcru_rate1anginatia11
	
		_11_hcru_rate2overall1-_11_hcru_rate2overall11
		_11_hcru_rate2cvd1-_11_hcru_rate2cvd11
		_11_hcru_rate2noncvd1-_11_hcru_rate2noncvd11
		_11_hcru_rate2mi1-_11_hcru_rate2mi11
		_11_hcru_rate2pad1-_11_hcru_rate2pad11
		_11_hcru_rate2stroke1-_11_hcru_rate2stroke11
		_11_hcru_rate2unsta_angina1-_11_hcru_rate2unsta_angina11
		_11_hcru_rate2sta_angina1-_11_hcru_rate2sta_angina11
		_11_hcru_rate2tia1-_11_hcru_rate2tia11
		_11_hcru_rate2other1-_11_hcru_rate2other11
		_11_hcru_rate2revasc1-_11_hcru_rate2revasc11
		_11_hcru_rate2anginatia1-_11_hcru_rate2anginatia11;
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
		concat=cats(cohort_new,group1,lpa_level1, put(seq, 5.), cat1, cat2);
	run;
	
	data derived._11_cause_rate&year.;
	retain cohort_new group1 lpa_level1 NUM cat1 cat2 concat _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
	length lpa_level1 $50. cohort_new $50. concat $200.;
				
	set _11_cause_rate1overall1-_11_cause_rate1overall11
		_11_cause_rate1cvd1-_11_cause_rate1cvd11
		_11_cause_rate1noncvd1-_11_cause_rate1noncvd11
		_11_cause_rate1mi1-_11_cause_rate1mi11
		_11_cause_rate1pad1-_11_cause_rate1pad11
		_11_cause_rate1stroke1-_11_cause_rate1stroke11
		_11_cause_rate1unsta_angina1-_11_cause_rate1unsta_angina11
		_11_cause_rate1sta_angina1-_11_cause_rate1sta_angina11
		_11_cause_rate1tia1-_11_cause_rate1tia11
		_11_cause_rate1other1-_11_cause_rate1other11
		_11_cause_rate1revasc1-_11_cause_rate1revasc11
		_11_cause_rate1anginatia1-_11_cause_rate1anginatia11

		_11_cause_rate2overall1-_11_cause_rate2overall11
		_11_cause_rate2cvd1-_11_cause_rate2cvd11
		_11_cause_rate2noncvd1-_11_cause_rate2noncvd11
		_11_cause_rate2mi1-_11_cause_rate2mi11
		_11_cause_rate2pad1-_11_cause_rate2pad11
		_11_cause_rate2stroke1-_11_cause_rate2stroke11
		_11_cause_rate2unsta_angina1-_11_cause_rate2unsta_angina11
		_11_cause_rate2sta_angina1-_11_cause_rate2sta_angina11
		_11_cause_rate2tia1-_11_cause_rate2tia11
		_11_cause_rate2other1-_11_cause_rate2other11
		_11_cause_rate2revasc1-_11_cause_rate2revasc11
		_11_cause_rate2anginatia1-_11_cause_rate2anginatia11
		;
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
		concat=cats(cohort_new,group1,lpa_level1, put(NUM, 5.), cat1, cat2);
	run;
		
		
%mend time;

/* %time(one_year, c.index_date_&ad.+365, years=one_year=1); */
%time(two_years,  c.index_date_&ad.+(365*2), years=two_years=1);
%time(all, c.eligend, years=patid is not null);




/*one year*/
ods csv file="/home/dingyig/proj/NOV-27/Output/_11_hcru_rate_one_year.csv";
proc print data=derived._11_hcru_rateone_year ;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_11_cause_rate_one_year.csv";
proc print data=derived._11_cause_rateone_year;
run;
ods csv close;

/*two year*/

ods csv file="/home/dingyig/proj/NOV-27/Output/_11_hcru_rate_two_year.csv";
proc print data=derived._11_hcru_ratetwo_years noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_11_cause_rate_two_year.csv";
proc print data=derived._11_cause_ratetwo_years noobs;
run;
ods csv close;

/*all follow up */

ods csv file="/home/dingyig/proj/NOV-27/Output/_11_hcru_rate_all.csv";
proc print data=derived._11_hcru_rateall noobs;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_11_cause_rate_all.csv";
proc print data=derived._11_cause_rateall noobs;
run;
ods csv close;


