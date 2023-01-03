
/*MACE rates excluding events in first 90 days after index date*/


%macro mace(year, years);
/*counts labs during post index period*/
	%let cohorts=a*b;
	%do z=1 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%let groups=overall;
		%do i=1 %to 1;
			%let ad = %scan(&groups., &i., *);
		%create(_06a_mace1_&ad.&z.&year.)
			select a.patid, a.index_date_&ad., a.eligeff, a.eligend, b.fst_dt, b.lst_dt, b.mi, b.revasc, b.gang, b.stroke
				from dingyig._01_cohort_6&ct. as a inner join dingyig._13_mace_proc b
				on a.patid=b.patid and a.index_date_&ad. < b.fst_dt and b.fst_dt<=&years.
				where  year(to_date(b.fst_dt)) >= 2008 and year(to_date(b.fst_dt)) <= 2020
				and a.index_date_overall+INTERVAL 90 DAYS < b.fst_dt
		%create(_06a_mace1_&ad.&z.&year.);
	%end;
	%end;

%mend;
%mace(one_year, index_date_&ad. + INTERVAL 365 DAYS);


%macro mace(year, years);
	%let cohorts=a*b;
	%do z=1 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%let vars=mi*stroke*gang*revasc;
		%do i=1 %to 4;
		%let var=%scan(&vars., &i., *);
%create(_06a_&z.&var.&year.)
	select a.patid, a.index_date_overall, min(b.dt) as &var._dt, count(distinct b.dt) as &var.
	from dingyig._01_cohort_6&ct. a inner join dingyig._13a_mace_proc b
			on a.patid=b.patid and a.index_date_overall < b.dt and b.dt<=&years.
	where  year(to_date(b.dt)) >= 2008 and year(to_date(b.dt)) <= 2020
			and a.index_date_overall+INTERVAL 90 DAYS < b.dt
			and b.grp="&var."
	group by a.patid, a.index_date_overall
%create(_06a_&z.&var.&year.);
	%end;
	%end;
%mend;
%mace(one_year, index_date_overall + INTERVAL 365 DAYS);
	

%macro mace(year);
	%let cohorts=a*b;
	%do z=1 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%create(_06a_mace&z.&year.)
		SELECT a.patid, a.index_date_overall, a.eligeff, a.eligend, b.mi, b.mi_dt, c.stroke, c.stroke_dt, d.gang, d.gang_dt, e.revasc, e.revasc_dt
		FROM dingyig._01_cohort_6&ct. a
				LEFT JOIN dingyig._06a_&z.mi&year. b on a.patid=b.patid
				LEFT JOIN dingyig._06a_&z.stroke&year. c on a.patid=c.patid
				LEFT JOIN dingyig._06a_&z.gang&year. d on a.patid=d.patid
				LEFT JOIN dingyig._06a_&z.revasc&year. e on a.patid=e.patid
	%create(_06a_mace&z.&year.);
	%end;
%mend;
%mace(one_year);

%macro bringsas(year, years);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table _06a_mace_&ad.&z.&year. as
	select *
	 from heor._06a_mace&z.&year. ;
			 
quit;
	%end;
	%end;

%mend;

%bringsas(one_year, index_date_&ad. + INTERVAL 365 DAYS);

%macro char_correct(year);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);		
	data _06a_mace1_&ad.&z.&year.;
		set _06a_mace_&ad.&z.&year.;
		%do t=1 %to 5;
			%let dt = %scan(index_date_&ad.*mi_dt*stroke_dt*revasc_dt*gang_dt, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
	run;
	%end;
	%end;
%mend char_correct;
%char_correct(one_year);



/*hospitalizations need all,  1 and 2 years*/
options mprint;	
%macro hosp(time_1, time, num, year);
/*cohort 1*/
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _06a_mace2_&ad.&z.&year. as 
		select distinct a.*
				%do i=1 %to 4;
				%let grp =%scan(mi*stroke*revasc*gang, &i., *);
							,sum(case when a.index_date_&ad. <  &grp._dt le (&time.) then &grp. end) as &grp.
							,min(case when a.index_date_&ad. <  &grp._dt le (&time.)  then &grp._dt end) as &grp._dt format mmddyy10.
				%end;
		from derived._07_primary_&z.&ad. a left join _06a_mace1_&ad.&z.&year. b 
		on a.patid=b.patid 
		where a.index_date_overall is not null
		group by a.patid, a.index_date_overall
		;	
	quit;
	


data _06a_mace3_&ad.&z.&year.; 
	set _06a_mace2_&ad.&z.&year.;
	
		if mi>0 then mi_grp=1; else mi_grp=0;
		if stroke>0 then stroke_grp=1; else stroke_grp=0;
		if revasc>0 then revasc_grp=1; else revasc_grp=0;
		if gang>0 then gang_grp=1; else gang_grp=0;
		if mi>0 or stroke>0 or revasc>0 or revasc>0 then do; overall_grp=1; overall1=sum(mi,stroke,revasc,gang); end;
		if overall1>=1 then overall1_grp=1;
		else overall1_grp=0;

	run;

	
data derived._06a_mace_&ad.&z.&year;
	set _06a_mace3_&ad.&z.&year.;
	* person-year;
	py=(min(eligend, &time_1.)-index_date_overall+1)/365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	
run;

		%end;
	%end;
%mend ;
%hosp(index_date_&ad.+365.25, a.index_date_&ad.+365.25, 1, one_year);


%macro time (year, years);
%macro rate_tb(num, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=2 %to 2;
	%let groups=overall*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100;
		%do zz=1 %to 5;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _06a_tb_setup as 
		select a.*
			,case when b.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when b.recent_ldlc >=70 then '1' end as rslt_ge_70
			,case when b.recent_ldlc <100 then '1' end as rslt_lt_100
			,case when b.recent_ldlc >=100 then '1' end as rslt_ge_100
			,'1' as overall 
		from derived._06a_mace_overall&z.&year. a inner join derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years. ;
		quit;
	
	data _06a_tb_setup1;
		set _06a_tb_setup;
		%if &z.=1 %then where &whrcl1. and &ad.='1'; 
		%else where &whrcl2. and &ad.='1';;
	run;
	
	proc sql noprint;
		select distinct count(distinct patid) into: denom from _06a_tb_setup1;
		create table _06a_desc as
		select distinct 1 as seq, 'overall_pts' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 union
		select distinct 2 as seq, 'overall1' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 where overall1_grp=1 union
		select distinct 3 as seq, 'mi' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 where mi_grp=1 union
		select distinct 4 as seq, 'stroke' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 where stroke_grp=1 union
		select distinct 5 as seq, 'revasc' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 where revasc_grp=1 union
		select distinct 6 as seq, 'gang' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _06a_tb_setup1 where gang_grp=1;
	quit;

	%do e=1 %to 5;
		%let mace_var = %scan(overall1*mi*stroke*revasc*gang, &e., *);
		%let seq = %scan(2*3*4*5*6, &e., *);	
		proc means data=_06a_tb_setup1 (where= (&mace_var. ge 1)) n mean stddev median min q1 q3 max noprint;
			var &mace_var.;
			output out=_06a_stat mean()= STD()= median()= Min()= Q1()= Q3()= Max()= /autoname;
		run;
		proc sql; 
			create table _06a_stat_tb&e. as  
			select &seq. as seq, "&mace_var." as grp
				, &mace_var._mean as mean
				, &mace_var._stddev as sd
				, &mace_var._median as median
				, &mace_var._min as min
				, &mace_var._q1 as q1
				, &mace_var._q3 as q3
				, &mace_var._max as max  
			from _06a_stat;
		quit;
		
		proc genmod data=_06a_tb_setup1;
			model &mace_var._grp = / offset=ln_py dist=poisson link=log;
			estimate "&mace_var." intercept 1 / exp;
		/* 	ods select none; */
			ods output ParameterEstimates=_06a_rate;
		run;
		proc sql;	
			create table _06a_rate_cl&e. as
			select distinct &seq. as seq, "&mace_var." as grp, exp(estimate)*100 as rate, exp(LowerWaldCL)*100 as lower95, exp(UpperWaldCL)*100 as upper95
			from _06a_rate
			where parameter='Intercept' ;
		quit;
/* 		%print(_05_rate_cl); */
		
		proc sql;
			create table _06a_py&e. as 
			select distinct &seq. as seq, "&mace_var." as grp, sum(py) as sum_py
			from _06a_tb_setup1
			;
		quit;	
	%end;
	data _06a_stat_tb; set _06a_stat_tb1 - _06a_stat_tb5; run;
/* 	%print(_06a_stat_tb); */

	data _06a_rate_cl; set _06a_rate_cl1 - _06a_rate_cl5; run;
/* 	%print(_06a_rate_cl);	 */

	data _06a_py; set _06a_py1 - _06a_py5; run;
	
	proc sql noprint;		
		create table _06a_mace_&ad.&z.&year. as
		select distinct a.seq, a.grp, a.pts, a.perc
			, b.mean, b.sd, b.median, b.min, b.q1, b.q3, b.max
			, d.sum_py/100 as total_py
			, c.rate, c.lower95, c.upper95
		from _06a_desc as a
			left join _06a_stat_tb as b on a.seq=b.seq and a.grp=b.grp
			left join _06a_rate_cl as c on a.seq=c.seq and a.grp=c.grp
			left join _06a_py as d on a.seq=d.seq and a.grp=d.grp;
	quit;
	
		data  _06a_&z.&ad._&num.; 
		length cohort_new group1 group2 $100.;
			set  _06a_mace_&ad.&z.&year.; 
					
				%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
				if &zz.=1 then group1='Overall';
				else if &zz.=2 then group1='< 70 mg/dL';
				else if &zz.=3 then group1= '≥ 70 mg/dL';
				else if &zz.=4 then group1='< 100 mg/dL';
				else if &zz.=5 then group1='≥ 100 mg/dL';
				if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
				else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
			run;		
			
	%end;
	%end;

%mend;
	
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
	

data derived._06a_&year.;
		retain cohort_new group1 lpa_level1 seq concat pts PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		
	set	_06a_2overall_1 -_06a_2overall_11
		_06a_2rslt_lt_70_1 -_06a_2rslt_lt_70_11
		_06a_2rslt_ge_70_1 -_06a_2rslt_ge_70_11
		_06a_2rslt_lt_100_1 -_06a_2rslt_lt_100_11
		_06a_2rslt_ge_100_1-_06a_2rslt_ge_100_11;
		
		if group2 in ('<30 mg/dL' , '<65 nmol/L') then lpa_level1='<65 nmol/L';
		else if group2 in ('<50 mg/dL', '<105 nmol/L') then lpa_level1='<105 nmol/L';
		else if group2 in ('30-<50 mg/dL', '65-<105 nmol/L') then lpa_level1='65-<105 nmol/L';
		else if group2 in ('50-<70 mg/dL', '105-<150 nmol/L') then lpa_level1='105-<150 nmol/L';
		else if group2 in ('70-<90 mg/dL', '150-<190 nmol/L') then lpa_level1='150-<190 nmol/L';
		else if group2 in ('90-<120 mg/dL', '190-<255 nmol/L') then lpa_level1='190-<255 nmol/L';
		else if group2 in ('≥70 mg/dL', '≥150 nmol/L') then lpa_level1='≥150 nmol/L';
		else if group2 in ('≥90 mg/dL', '≥190 nmol/L') then lpa_level1='≥190 nmol/L';
		else if group2 in ('≥120 mg/dL', '≥255 nmol/L') then lpa_level1='≥255 nmol/L';
		else if group2 in ('≥150 mg/dL', '≥320 nmol/L') then lpa_level1='≥320 nmol/L';
		else if group2='overall' then lpa_level1='Overall';
		
		drop group2;
		concat=cats(cohort_new,group1,lpa_level1, put(seq, 5.), cat1, cat2);
	run;
%mend time;

%time(one_year, years=one_year=1);		


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_14_mace_one_year.csv";
proc print data=derived._06a_one_year;
run;
ods csv close;
