

/*gets all hospitalizations for mace in follow up period - mi, stroke, revasc and gang*/
%macro mace;

%create(_13_mace_proc)
		select patid, fst_dt, lst_dt, max(mi) as mi, max(stroke) as stroke, max(gang) as gang, max(revasc) as revasc
		from (
		select distinct patid, fst_dt, lst_dt
			%do i=1 %to 3;
				%let dx =%scan(mi*stroke*gang, &i., *); /*chd and cerebrovascular are optional*/
				, case when (substr(diag,1,3) in (&&&dx.) 
						or substr(diag,1,4) in (&&&dx.) 
						or substr(diag,1,5) in (&&&dx.) 
						or substr(diag,1,6) in (&&&dx.)) 
					then 1 else 0
				end as &dx.
			%end;
			, 0 as revasc
			from dingyig._07_hosp_er_diag_prim
			union
			select distinct a.patid, a.fst_dt, a.lst_dt
				,0 as mi, 0 as stroke, 0 as gang
					, case when b.patid is not null and b.grp = "revasc" then 1 else 0 end as revasc /*choose all procedure code because cant identify primary procedure*/
				/*revascularization*/	
			from dingyig._07_hosp_er_diag_prim as a left join (select * from dingyig.optum2_01_proc where pos in (&inp_pos.,&er_pos.) and grp in ('revasc')) as b
			on a.patid=b.patid and b.dt between a.fst_dt and a.lst_dt
	
		) a
		group by patid, fst_dt, lst_dt
		
	
%create(_13_mace_proc);
%mend;
%mace;

%macro mace(year, years);
/*counts labs during post index period*/
	%let cohorts=a*b;
	%do z=1 %to 1;
	%let ct = %scan(&cohorts., &z., *);
	%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do i=1 %to 1;
			%let ad = %scan(&groups., &i., *);
		%create(_13_mace1_&ad.&z.&year.)
			select a.patid, a.index_date_&ad., a.eligeff, a.eligend, b.fst_dt, b.lst_dt, b.mi, b.revasc, b.gang, b.stroke
				from dingyig._01_cohort_6&ct. as a inner join dingyig._13_mace_proc b
				on a.patid=b.patid and a.index_date_&ad. < b.fst_dt and b.fst_dt<=&years.
				where  year(to_date(b.fst_dt)) >= 2008 and year(to_date(b.fst_dt)) <= 2020
		%create(_13_mace1_&ad.&z.&year.);
	%end;
	%end;

%mend mace;
%mace(one_year, index_date_&ad. + INTERVAL 365 DAYS);
%mace(two_years,  index_date_&ad. + INTERVAL 730 DAYS);
%mace(all, a.eligend);	


%macro bringsas(year, years);
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table _13_mace_&ad.&z.&year. as
	select *
	 from heor._13_mace1_&ad.&z.&year. ;
			 
quit;
	%end;
	%end;

%mend;

%bringsas(one_year, index_date_&ad. + INTERVAL 365 DAYS);
%bringsas(two_years,  index_date_&ad. + INTERVAL 730 DAYS);
%bringsas(all, eligend);

%macro char_correct(year);
%do z=1 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);		
	data _13_mace1_&ad.&z.&year.;
		set _13_mace_&ad.&z.&year.;
		%do t=1 %to 3;
			%let dt = %scan(index_date_&ad.*fst_dt*lst_dt, &t., *);
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
%char_correct(two_years);
%char_correct(all);


/*hospitalizations need all,  1 and 2 years*/
options mprint;	
%macro hosp(time, num, year);
/*cohort 1*/
%do z=1 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _13_mace2_&ad.&z.&year. as 
		select distinct a.*, b.*
		from derived._07_primary_&z.&ad.  as a 
			left join (select distinct patid
						%do i=1 %to 4;
							%let grp =%scan(mi*stroke*revasc*gang, &i., *);
							, sum(&grp.) as &grp.
						%end;
						from _13_mace1_&ad.&z.&year.
						where index_date_&ad. lt fst_dt le (&time.)
						group by patid
						) as b
		on a.patid=b.patid 
		where a.index_date_overall is not null
		;	
	quit;
	


data _13_mace3_&ad.&z.&year.; 
	set _13_mace2_&ad.&z.&year.;
	
		if mi>0 then mi_grp=1; else mi_grp=0;
		if stroke>0 then stroke_grp=1; else stroke_grp=0;
		if revasc>0 then revasc_grp=1; else revasc_grp=0;
		if gang>0 then gang_grp=1; else gang_grp=0;
		if mi>0 or stroke>0 or revasc>0 or revasc>0 then do; overall_grp=1; overall1=sum(mi,stroke,revasc,gang); end;
		if overall1>=1 then overall1_grp=1;
		else overall1_grp=0;

	run;

	
data derived._13_mace_&ad.&z.&year;
	set _13_mace3_&ad.&z.&year.;
	* person-year;
	py=(min(eligend, &time.)-index_date_overall+1)/365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	
run;


		%end;
	%end;
%mend ;
%hosp(index_date_&ad.+365.25, 1, one_year);
%hosp(index_date_&ad.+(365.25*2), 2, two_years);	
%hosp(eligend, 11, all);


%macro time (year, years);
%macro rate_tb(num, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=1 %to 2;
	%let groups=overall*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100;
		%do zz=1 %to 5;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _13_tb_setup as 
		select a.*,
			case when b.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when b.recent_ldlc >=70 then '1' end as rslt_ge_70
			,case when b.recent_ldlc <100 then '1' end as rslt_lt_100
			,case when b.recent_ldlc >=100 then '1' end as rslt_ge_100
			'1' as overall 
		from derived._13_mace_overall&z.&year. a inner join derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years.;
		quit;
	
	data _13_tb_setup1;
		set _13_tb_setup;
		%if &z.=1 %then where &whrcl1.; 
		%else where &whrcl2.;;
	run;
	
	proc sql noprint;
		select distinct count(distinct patid) into: denom from _13_tb_setup1;
		create table _13_desc as
		select distinct 1 as seq, 'overall_pts' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 union
		select distinct 2 as seq, 'overall1' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 where overall1_grp=1 union
		select distinct 3 as seq, 'mi' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 where mi_grp=1 union
		select distinct 4 as seq, 'stroke' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 where stroke_grp=1 union
		select distinct 5 as seq, 'revasc' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 where revasc_grp=1 union
		select distinct 6 as seq, 'gang' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13_tb_setup1 where gang_grp=1;
	quit;

	%do e=1 %to 5;
		%let mace_var = %scan(overall1*mi*stroke*revasc*gang, &e., *);
		%let seq = %scan(2*3*4*5*6, &e., *);	
		proc means data=_13_tb_setup1 (where= (&mace_var. ge 1)) n mean stddev median min q1 q3 max noprint;
			var &mace_var.;
			output out=_13_stat mean()= STD()= median()= Min()= Q1()= Q3()= Max()= /autoname;
		run;
		proc sql; 
			create table _13_stat_tb&e. as  
			select &seq. as seq, "&mace_var." as grp
				, &mace_var._mean as mean
				, &mace_var._stddev as sd
				, &mace_var._median as median
				, &mace_var._min as min
				, &mace_var._q1 as q1
				, &mace_var._q3 as q3
				, &mace_var._max as max  
			from _13_stat;
		quit;
		
		proc genmod data=_13_tb_setup1;
			model &mace_var._grp = / offset=ln_py dist=poisson link=log;
			estimate "&mace_var." intercept 1 / exp;
		/* 	ods select none; */
			ods output ParameterEstimates=_13_rate;
		run;
		proc sql;	
			create table _13_rate_cl&e. as
			select distinct &seq. as seq, "&mace_var." as grp, exp(estimate)*100 as rate, exp(LowerWaldCL)*100 as lower95, exp(UpperWaldCL)*100 as upper95
			from _13_rate
			where parameter='Intercept' ;
		quit;
/* 		%print(_05_rate_cl); */
		
		proc sql;
			create table _13_py&e. as 
			select distinct &seq. as seq, "&mace_var." as grp, sum(py) as sum_py
			from _13_tb_setup1
			;
		quit;	
	%end;
	data _13_stat_tb; set _13_stat_tb1 - _13_stat_tb5; run;
/* 	%print(_13_stat_tb); */

	data _13_rate_cl; set _13_rate_cl1 - _13_rate_cl5; run;
/* 	%print(_13_rate_cl);	 */

	data _13_py; set _13_py1 - _13_py5; run;
	
	proc sql noprint;		
		create table _13_mace_&ad.&z.&year. as
		select distinct a.seq, a.grp, a.pts, a.perc
			, b.mean, b.sd, b.median, b.min, b.q1, b.q3, b.max
			, d.sum_py/100 as total_py
			, c.rate, c.lower95, c.upper95
		from _13_desc as a
			left join _13_stat_tb as b on a.seq=b.seq and a.grp=b.grp
			left join _13_rate_cl as c on a.seq=c.seq and a.grp=c.grp
			left join _13_py as d on a.seq=d.seq and a.grp=d.grp;
	quit;
	
		data  _13_&z.&ad._&num.; 
		length cohort_new group1 group2 $100.;
			set  _13_mace_&ad.&z.&year.; 
					
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
	

data derived._13_&year.;
		retain cohort_new group1 lpa_level1 seq cat1 cat2 concat NUM _FREQ_ PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		
	set	_13_1overall_1 - _13_1overall_11
		_13_1rslt_lt_70_1 - _13_1rslt_lt_70_11
		_13_1rslt_ge_70_1 - _13_1rslt_ge_70_11
		_13_1rslt_lt_100_1 - _13_1rslt_lt_100_11
		_13_1rslt_ge_100_1 - _13_1rslt_ge_100_11
		_13_2overall_1 - _13_2overall_11
		_13_2rslt_lt_70_1 - _13_2rslt_lt_70_11
		_13_2rslt_ge_70_1 - _13_2rslt_ge_70_11
		_13_2rslt_lt_100_1 - _13_2rslt_lt_100_11
		_13_2rslt_ge_100_1 - _13_2rslt_ge_100_11;
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
%mend time;

%time(one_year, years=one_year=1);		
%time(two_years, years=two_years=1);
%time(all, years=a.patid is not null);


ods csv file="/home/dingyig/proj/NOV-27/Output/_14_mace_one_year.csv";
proc print data=derived._13_one_year;
run;
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_mace_two_years.csv";
proc print data=derived._13_two_years;
run;
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_mace_all.csv";
proc print data=derived._13_all;
run;
ods csv close;
