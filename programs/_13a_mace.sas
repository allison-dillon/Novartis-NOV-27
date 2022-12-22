%let mi=%str('410','100','1000','1001','1002','101','1010','1011','1012','102','1020','1021','1022','103','1030','1031','1032','104','1040',
'1041','1042','105','1050','1051','1052','106','1060','1061','1062','107','1070','1071','1072','108','1080','1081','1082','109','1090','1091'
,'1092','412','42979','I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A','I21A1',
'I21A9','I22','I220','I221','I222','I228','I229','I230','I231','I232','I233','I234','I235','I236','I237','I238','I252');
/*only has ICD10 codes for hemorrhagic stroke*/
%let stroke=%str('43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011','I63012',
'I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111','I63112',
'I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321','I63211','I63212',
'I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311','I63312',
'I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334','I63341',
'I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413','I63419','I6342','I63421','I63422',
'I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349','I635',
'I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531','I63532',
'I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359','I636','I638','I6381','I6389','I639','I600','I6000',
'I6001','I6002','I601','I6010','I6011','I6012','I602','I603','I6030','I6031','I6032','I604','I605','I6050','I6051','I6052','I606','I607',
'I608','I609','I610','I611','I612','I613','I614','I615','I616','I618','I619','I620','I621','I629','I6200','I6201','I6202','I6203');

%let gang=%str('I7026');

/*gets hospitalizations for mace procs in follow up period - mi, stroke, revasc and gang*/
%macro mace;

%create(_13a_mace_proc)
		%do i=1 %to 3;
			%let dx =%scan(mi*stroke*gang, &i., *);
			select distinct a.patid, a.fst_dt as dt,  "&dx." as grp
			from dingyig._07_hosp_er_diag_prim as a
			where year(to_date(a.fst_dt)) >= 2008
				and year(to_date(a.fst_dt)) <= 2020 
				and (substr(a.diag,1,3) in (&&&dx.) 
					or substr(a.diag,1,4) in (&&&dx.) 
					or substr(a.diag,1,5) in (&&&dx.) 
					or substr(a.diag,1,6) in (&&&dx.)) 
		UNION ALL
		%end;
		SELECT distinct a.patid, b.dt, b.grp
		from dingyig._07_hosp_er_diag_prim as a inner join (select * from dingyig._13_MACE_proc where pos in (&inp_pos.,&er_pos.) and grp in ('revasc') and num=1) as b
			on a.patid=b.patid and b.dt between a.fst_dt and a.lst_dt
		WHERE year(to_date(b.dt)) >= 2008
				and b.dt <= '2020-06-30 23:59:59.99'
%create(_13a_mace_proc);
%mend;
%mace;
	
%macro mace(year, years);
	%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%let vars=mi*stroke*gang*revasc;
		%do i=1 %to 4;
		%let var=%scan(&vars., &i., *);
%create(_13a_&z.&var.&year.)
	select a.patid, a.index_date_overall, min(b.dt) as &var._dt, count(distinct b.dt) as &var.
	from dingyig._01_cohort_6&ct. a inner join dingyig._13a_mace_proc b
			on a.patid=b.patid and a.index_date_overall < b.dt and b.dt<=&years.
	where  year(to_date(b.dt)) >= 2008 and year(to_date(b.dt)) <= 2020
			and b.grp="&var."
	group by a.patid, a.index_date_overall
%create(_13a_&z.&var.&year.);
	%end;
	%end;
%mend;
%mace(one_year, index_date_overall + INTERVAL 365 DAYS);
%mace(two_years,  index_date_overall + INTERVAL 730 DAYS);
%mace(all, a.eligend);	

%macro mace(year);
	%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%create(_13a_mace&z.&year.)
		SELECT a.patid, a.index_date_overall, a.eligeff, a.eligend, b.mi, b.mi_dt, c.stroke, c.stroke_dt, d.gang, d.gang_dt, e.revasc, e.revasc_dt
		FROM dingyig._01_cohort_6&ct. a
				LEFT JOIN dingyig._13a_&z.mi&year. b on a.patid=b.patid
				LEFT JOIN dingyig._13a_&z.stroke&year. c on a.patid=c.patid
				LEFT JOIN dingyig._13a_&z.gang&year. d on a.patid=d.patid
				LEFT JOIN dingyig._13a_&z.revasc&year. e on a.patid=e.patid
	%create(_13a_mace&z.&year.);
	%end;
%mend;
%mace(one_year);
%mace(two_years);
%mace(all);


%macro bringsas(year, years);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table _13a_mace_&ad.&z.&year. as
	select *
	 from heor._13a_mace&z.&year. ;
			 
quit;
	%end;
	%end;

%mend;

%bringsas(one_year, index_date_&ad. + INTERVAL 365 DAYS);
%bringsas(two_years,  index_date_&ad. + INTERVAL 730 DAYS);
%bringsas(all, eligend);

%macro char_correct(year);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);		
	data _13a_mace1_&ad.&z.&year.;
		set _13a_mace_&ad.&z.&year.;
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
%char_correct(two_years);
%char_correct(all);


/*hospitalizations need all,  1 and 2 years*/
options mprint;	
%macro hosp(time_1, time, num, year);
/*cohort 1*/
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _13a_mace2_&ad.&z.&year. as 
		select distinct a.*
				%do i=1 %to 4;
				%let grp =%scan(mi*stroke*revasc*gang, &i., *);
							,sum(case when a.index_date_&ad. <  &grp._dt le (&time.) then &grp. end) as &grp.
							,min(case when a.index_date_&ad. <  &grp._dt le (&time.)  then &grp._dt end) as &grp._dt format mmddyy10.
				%end;
		from derived._07_primary_&z.&ad. a left join _13a_mace1_&ad.&z.&year. b 
		on a.patid=b.patid 
		where a.index_date_overall is not null
		group by a.patid, a.index_date_overall
		;	
	quit;
	


data _13a_mace3_&ad.&z.&year.; 
	set _13a_mace2_&ad.&z.&year.;
	
		if mi>0 then mi_grp=1; else mi_grp=0;
		if stroke>0 then stroke_grp=1; else stroke_grp=0;
		if revasc>0 then revasc_grp=1; else revasc_grp=0;
		if gang>0 then gang_grp=1; else gang_grp=0;
		if mi>0 or stroke>0 or revasc>0 or revasc>0 then do; overall_grp=1; overall1=sum(mi,stroke,revasc,gang); end;
		if overall1>=1 then overall1_grp=1;
		else overall1_grp=0;

	run;

	
data derived._13a_mace_&ad.&z.&year;
	set _13a_mace3_&ad.&z.&year.;
	* person-year;
	py=(min(eligend, &time_1.)-index_date_overall+1)/365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	
run;

		%end;
	%end;
%mend ;
%hosp(index_date_&ad.+365.25, a.index_date_&ad.+365.25, 1, one_year);
%hosp(index_date_&ad.+(365.25*2), a.index_date_&ad.+(365.25*2), 2, two_years);	
%hosp(eligend, a.eligend, 11, all);


%macro time (year, years);
%macro rate_tb(num, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=2 %to 2;
	%let groups=overall*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100;
		%do zz=1 %to 5;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _13a_tb_setup as 
		select a.*
			,case when b.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when b.recent_ldlc >=70 then '1' end as rslt_ge_70
			,case when b.recent_ldlc <100 then '1' end as rslt_lt_100
			,case when b.recent_ldlc >=100 then '1' end as rslt_ge_100
			,'1' as overall 
		from derived._13a_mace_overall&z.&year. a left join derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years. ;
		quit;
	
	data _13a_tb_setup1;
		set _13a_tb_setup;
		%if &z.=1 %then where &whrcl1. and &ad.='1'; 
		%else where &whrcl2. and &ad.='1';;
	run;
	
	proc sql noprint;
		select distinct count(distinct patid) into: denom from _13a_tb_setup1;
		create table _13a_desc as
		select distinct 1 as seq, 'overall_pts' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 union
		select distinct 2 as seq, 'overall1' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 where overall1_grp=1 union
		select distinct 3 as seq, 'mi' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 where mi_grp=1 union
		select distinct 4 as seq, 'stroke' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 where stroke_grp=1 union
		select distinct 5 as seq, 'revasc' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 where revasc_grp=1 union
		select distinct 6 as seq, 'gang' as grp, count(distinct patid) as pts, count(distinct patid)/&denom. as perc from _13a_tb_setup1 where gang_grp=1;
	quit;

	%do e=1 %to 5;
		%let mace_var = %scan(overall1*mi*stroke*revasc*gang, &e., *);
		%let seq = %scan(2*3*4*5*6, &e., *);	
		proc means data=_13a_tb_setup1 (where= (&mace_var. ge 1)) n mean stddev median min q1 q3 max noprint;
			var &mace_var.;
			output out=_13a_stat mean()= STD()= median()= Min()= Q1()= Q3()= Max()= /autoname;
		run;
		proc sql; 
			create table _13a_stat_tb&e. as  
			select &seq. as seq, "&mace_var." as grp
				, &mace_var._mean as mean
				, &mace_var._stddev as sd
				, &mace_var._median as median
				, &mace_var._min as min
				, &mace_var._q1 as q1
				, &mace_var._q3 as q3
				, &mace_var._max as max  
			from _13a_stat;
		quit;
		
		proc genmod data=_13a_tb_setup1;
			model &mace_var._grp = / offset=ln_py dist=poisson link=log;
			estimate "&mace_var." intercept 1 / exp;
		/* 	ods select none; */
			ods output ParameterEstimates=_13a_rate;
		run;
		proc sql;	
			create table _13a_rate_cl&e. as
			select distinct &seq. as seq, "&mace_var." as grp, exp(estimate)*100 as rate, exp(LowerWaldCL)*100 as lower95, exp(UpperWaldCL)*100 as upper95
			from _13a_rate
			where parameter='Intercept' ;
		quit;
/* 		%print(_05_rate_cl); */
		
		proc sql;
			create table _13a_py&e. as 
			select distinct &seq. as seq, "&mace_var." as grp, sum(py) as sum_py
			from _13a_tb_setup1
			;
		quit;	
	%end;
	data _13a_stat_tb; set _13a_stat_tb1 - _13a_stat_tb5; run;
/* 	%print(_13a_stat_tb); */

	data _13a_rate_cl; set _13a_rate_cl1 - _13a_rate_cl5; run;
/* 	%print(_13a_rate_cl);	 */

	data _13a_py; set _13a_py1 - _13a_py5; run;
	
	proc sql noprint;		
		create table _13a_mace_&ad.&z.&year. as
		select distinct a.seq, a.grp, a.pts, a.perc
			, b.mean, b.sd, b.median, b.min, b.q1, b.q3, b.max
			, d.sum_py/100 as total_py
			, c.rate, c.lower95, c.upper95
		from _13a_desc as a
			left join _13a_stat_tb as b on a.seq=b.seq and a.grp=b.grp
			left join _13a_rate_cl as c on a.seq=c.seq and a.grp=c.grp
			left join _13a_py as d on a.seq=d.seq and a.grp=d.grp;
	quit;
	
		data  _13a_&z.&ad._&num.; 
		length cohort_new group1 group2 $100.;
			set  _13a_mace_&ad.&z.&year.; 
					
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
	

data derived._13a_&year.;
		retain cohort_new group1 lpa_level1 seq concat pts PERC MEAN SD MEDIAN MIN Q1 Q3 MAX ;
		length lpa_level1 $50. cohort_new $50. concat $200.;
		
	set	_13a_1overall_1 - _13a_1overall_11
		_13a_1rslt_lt_70_1 - _13a_1rslt_lt_70_11
		_13a_1rslt_ge_70_1 - _13a_1rslt_ge_70_11
		_13a_1rslt_lt_100_1 - _13a_1rslt_lt_100_11
		_13a_1rslt_ge_100_1 - _13a_1rslt_ge_100_11
		_13a_2overall_1 - _13a_2overall_11
		_13a_2rslt_lt_70_1 - _13a_2rslt_lt_70_11
		_13a_2rslt_ge_70_1 - _13a_2rslt_ge_70_11
		_13a_2rslt_lt_100_1 - _13a_2rslt_lt_100_11
		_13a_2rslt_ge_100_1 - _13a_2rslt_ge_100_11;
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
proc print data=derived._13a_one_year;
run;
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_mace_two_years.csv";
proc print data=derived._13a_two_years;
run;
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_14_mace_all.csv";
proc print data=derived._13a_all;
run;
ods csv close;