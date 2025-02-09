/*MACE: this is version 2 to add limb gangrene (I7026)*/
%let post_index=5;

* within enrollment period;
%macro mace_pre (var);
	%connDBPassThrough(dbname=heoji3, libname1=imp);
	execute (drop table if exists heoji3.mace_05_&var. PURGE) by imp; 
	execute	(create table heoji3.mace_05_&var. as
			select z.enrolid, count(distinct z.svcdate) as &var., min(z.svcdate) as &var._dt
			from (select distinct a.enrolid, b.svcdate
				from mace_04_cohort35 as a inner join (select * from mace_02_&var. where year(to_date(svcdate)) between 2005 and 2019) as b 
				on a.enrolid=b.enrolid and datediff(b.svcdate,a.index_dt) >= 1 and b.svcdate between a.index_dt and a.enroll_end) as z
			group by z.enrolid
		) by imp;
	quit;
%mend mace_pre;
%mace_pre (mi);
%mace_pre (stroke);
%mace_pre (revasc);
%mace_pre (gang);

* within enrollment period and 5 years (post index period);
%macro mace_pre_post (var);
	%connDBPassThrough(dbname=heoji3, libname1=imp);
	execute (drop table if exists heoji3.mace_05_&var._post PURGE) by imp; 
	execute	(create table heoji3.mace_05_&var._post as
			select z.enrolid, count(distinct z.svcdate) as &var._post, min(z.svcdate) as &var._dt_post
			from (select distinct a.enrolid, b.svcdate
				from mace_04_cohort35 as a inner join (select * from mace_02_&var. where year(to_date(svcdate)) between 2005 and 2019) as b 
				on a.enrolid=b.enrolid and datediff(b.svcdate,a.index_dt) between 1 and (365.25*&post_index.) and b.svcdate between a.index_dt and a.enroll_end) as z
			group by z.enrolid
		) by imp;
	quit;
%mend mace_pre_post;
%mace_pre_post (mi);
%mace_pre_post (stroke);
%mace_pre_post (revasc);
%mace_pre_post (gang);

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_05_setup_pre PURGE) by imp; 
execute	(create table heoji3.mace_05_setup_pre as
		select distinct a.*
			, b.mi, b.mi_dt, c.stroke, c.stroke_dt, d.revasc, d.revasc_dt, e.gang, e.gang_dt
		from mace_04_cohort35 as a 
			left join mace_05_mi as b on a.enrolid=b.enrolid
			left join mace_05_stroke as c on a.enrolid=c.enrolid
			left join mace_05_revasc as d on a.enrolid=d.enrolid
			left join mace_05_gang as e on a.enrolid=e.enrolid
	) by imp;
quit;

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_05_setup PURGE) by imp; 
execute	(create table heoji3.mace_05_setup as
		select distinct a.*
			, b1.mi_post, b1.mi_dt_post, c1.stroke_post, c1.stroke_dt_post, d1.revasc_post, d1.revasc_dt_post, e1.gang_post, e1.gang_dt_post
		from mace_05_setup_pre as a 
			left join mace_05_mi_post as b1 on a.enrolid=b1.enrolid
			left join mace_05_stroke_post as c1 on a.enrolid=c1.enrolid
			left join mace_05_revasc_post as d1 on a.enrolid=d1.enrolid
			left join mace_05_gang_post as e1 on a.enrolid=e1.enrolid
	) by imp;
quit;
%countid2(mace_05_setup); /*651624	651624*/
%output2(mace_05_setup);

* save files in SAS;
%connDBPassThrough(dbname=heoji3, libname1=imp);
	create table derived._05_setup as select * from connection to imp
	(select * from mace_05_setup);
quit;

%macro rev;
	data _05_setup2;
		set derived._05_setup (rename=(diag=diag2));
		
		format diag $10.;
		diag=diag2;
		drop diag2;
		
		%do t=1 %to 11;
			%let dt = %scan(index_dt*enroll_start*enroll_end*mi_dt*stroke_dt*revasc_dt*gang_dt*mi_dt_post*stroke_dt_post*revasc_dt_post*gang_dt_post, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
		
		if mi>0 then mi_grp=1; else mi_grp=0;
		if stroke>0 then stroke_grp=1; else stroke_grp=0;
		if revasc>0 then revasc_grp=1; else revasc_grp=0;
		if gang>0 then gang_grp=1; else gang_grp=0;
		if mi>0 or stroke>0 or revasc>0 or revasc>0 then do; overall_grp=1; overall=sum(mi,stroke,revasc,gang); end;
		else overall_grp=0;

		if mi_post>0 then mi_grp_post=1; else mi_grp_post=0;
		if stroke_post>0 then stroke_grp_post=1; else stroke_grp_post=0;
		if revasc_post>0 then revasc_grp_post=1; else revasc_grp_post=0;
		if gang_post>0 then gang_grp_post=1; else gang_grp_post=0;
		if mi_post>0 or stroke_post>0 or revasc_post>0 or gang_post>0 then do; overall_grp_post=1; overall_post=sum(mi_post,stroke_post,revasc_post,gang_post); end;		
		else overall_grp_post=0;
	run;
	
	data derived._05_mace;
		set _05_setup2;
		
		%do e=1 %to 10;
			%let mace_var = %scan(overall*mi*stroke*revasc*gang*overall_post*mi_post*stroke_post*revasc_post*gang_post, &e., *);		
			if &mace_var.=. then &mace_var.=0;
		%end;
		
		py=(min(enroll_end,'31DEC2019'd)-index_dt+1)/365.25;
		ln_py=log(py);
		
		py_post=(min(enroll_end,'31DEC2019'd)-index_dt+1)/365.25;
		if py_post ge &post_index. then py_post=&post_index.;
		ln_py_post=log(py_post);
	run;
%mend rev;
%rev;

* check;
proc sql;
	select distinct min(enroll_end) as min_dt format date9., max(enroll_end) as max_dt format date9. 
	from derived._05_mace;
quit;
%freq(derived._05_mace, py_post);
%freq(derived._05_mace, mi_grp_post);
%freq(derived._05_mace, mi stroke revasc gang overall);
%freq(derived._05_mace, mi_post stroke_post revasc_post gang_post overall_post);



* limit up to post index period;
%macro tb_post (sub, whrcl);
	data _05_tb_post;
		set derived._05_mace (drop= overall mi stroke revasc gang mi_dt stroke_dt revasc_dt gang_dt overall_grp mi_grp stroke_grp revasc_grp gang_grp py ln_py);	
		%do r=1 %to 16;
			%let varn = %scan(overall*mi*stroke*revasc*gang*mi_dt*stroke_dt*revasc_dt*gang_dt*overall_grp*mi_grp*stroke_grp*revasc_grp*gang_grp*py*ln_py, &r., *);
			rename &varn._post=&varn.;
		%end;
	run;

	data _05_tb_setup; set _05_tb_post; where &whrcl.; run;
	proc sql noprint;
		select distinct count(distinct enrolid) into: denom from _05_tb_setup;
		create table _05_desc as
		select distinct 1 as seq, 'overall_pts' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup union
		select distinct 2 as seq, 'overall' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where overall_grp=1 union
		select distinct 3 as seq, 'mi' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where mi_grp=1 union
		select distinct 4 as seq, 'stroke' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where stroke_grp=1 union
		select distinct 5 as seq, 'revasc' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where revasc_grp=1 union
		select distinct 6 as seq, 'gang' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where gang_grp=1;
	quit;

	%do e=1 %to 5;
		%let mace_var = %scan(overall*mi*stroke*revasc*gang, &e., *);
		%let seq = %scan(2*3*4*5*6, &e., *);	
		proc means data=_05_tb_setup (where= (&mace_var. ge 1)) n mean stddev median min q1 q3 max noprint;
			var &mace_var.;
			output out=_05_stat mean()= STD()= median()= Min()= Q1()= Q3()= Max()= /autoname;
		run;
		proc sql; 
			create table _05_stat_tb&e. as  
			select &seq. as seq, "&mace_var." as grp
				, &mace_var._mean as mean
				, &mace_var._stddev as sd
				, &mace_var._median as median
				, &mace_var._min as min
				, &mace_var._q1 as q1
				, &mace_var._q3 as q3
				, &mace_var._max as max  
			from _05_stat;
		quit;
		
		proc genmod data=_05_tb_setup;
			model &mace_var._grp = / offset=ln_py dist=poisson link=log;
			estimate "&mace_var." intercept 1 / exp;
		/* 	ods select none; */
			ods output ParameterEstimates=_05_rate;
		run;
		proc sql;	
			create table _05_rate_cl&e. as
			select distinct &seq. as seq, "&mace_var." as grp, exp(estimate)*100 as rate, exp(LowerWaldCL)*100 as lower95, exp(UpperWaldCL)*100 as upper95
			from _05_rate
			where parameter='Intercept' ;
		quit;
/* 		%print(_05_rate_cl); */
		
		proc sql;
			create table _05_py&e. as 
			select distinct &seq. as seq, "&mace_var." as grp, sum(py) as sum_py
			from _05_tb_setup;
		quit;	
	%end;
	data _05_stat_tb; set _05_stat_tb1 - _05_stat_tb5; run;
/* 	%print(_05_stat_tb); */

	data _05_rate_cl; set _05_rate_cl1 - _05_rate_cl5; run;
/* 	%print(_05_rate_cl);	 */

	data _05_py; set _05_py1 - _05_py5; run;
/* 	%print(_05_py); */
	
	proc sql noprint;		
		create table _05_tb_comb&sub. as
		select distinct a.seq, a.grp, a.pts, a.perc
			, b.mean, b.sd, b.median, b.min, b.q1, b.q3, b.max
			, d.sum_py/100 as total_py
			, c.rate, c.lower95, c.upper95
		from _05_desc as a
			left join _05_stat_tb as b on a.seq=b.seq and a.grp=b.grp
			left join _05_rate_cl as c on a.seq=c.seq and a.grp=c.grp
			left join _05_py as d on a.seq=d.seq and a.grp=d.grp;
	quit;	
%mend tb_post;
%tb_post (sub=1, whrcl= enrolid is not null);
%tb_post (sub=2, whrcl= htn eq 1 or infl eq 1);
%tb_post (sub=3, whrcl= htn eq 1 and infl eq 1);
data _05_tb_comb_fn; set _05_tb_comb1 - _05_tb_comb3; run;
%print(_05_tb_comb_fn);	
	




* end of enrollment regardless post-index period - sensitivity analysis?;
%macro tb (sub, whrcl);
	data _05_tb_setup; set derived._05_mace; where &whrcl.; run;
	proc sql noprint;
		select distinct count(distinct enrolid) into: denom from _05_tb_setup;
		create table _05_desc as
		select distinct 1 as seq, 'overall_pts' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup union
		select distinct 2 as seq, 'overall' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where overall_grp=1 union
		select distinct 3 as seq, 'mi' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where mi_grp=1 union
		select distinct 4 as seq, 'stroke' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where stroke_grp=1 union
		select distinct 5 as seq, 'revasc' as grp, count(distinct enrolid) as pts, count(distinct enrolid)/&denom. as perc from _05_tb_setup where revasc_grp=1;
	quit;

	%do e=1 %to 4;
		%let mace_var = %scan(overall*mi*stroke*revasc, &e., *);
		%let seq = %scan(2*3*4*5, &e., *);	
		proc means data=_05_tb_setup (where= (&mace_var. ge 1)) n mean stddev median min q1 q3 max noprint;
			var &mace_var.;
			output out=_05_stat mean()= STD()= median()= Min()= Q1()= Q3()= Max()= /autoname;
		run;
		proc sql; 
			create table _05_stat_tb&e. as  
			select &seq. as seq, "&mace_var." as grp
				, &mace_var._mean as mean
				, &mace_var._stddev as sd
				, &mace_var._median as median
				, &mace_var._min as min
				, &mace_var._q1 as q1
				, &mace_var._q3 as q3
				, &mace_var._max as max  
			from _05_stat;
		quit;
		
		proc genmod data=_05_tb_setup;
			model &mace_var._grp = / offset=ln_py dist=poisson link=log;
			estimate "&mace_var." intercept 1 / exp;
		/* 	ods select none; */
			ods output ParameterEstimates=_05_rate;
		run;
		proc sql;	
			create table _05_rate_cl&e. as
			select distinct &seq. as seq, "&mace_var." as grp, exp(estimate)*100 as rate, exp(LowerWaldCL)*100 as lower95, exp(UpperWaldCL)*100 as upper95
			from _05_rate
			where parameter='Intercept' ;
		quit;
/* 		%print(_05_rate_cl); */
		
		proc sql;
			create table _05_py&e. as 
			select distinct &seq. as seq, "&mace_var." as grp, sum(py) as sum_py
			from _05_tb_setup;
		quit;	
	%end;
	data _05_stat_tb; set _05_stat_tb1 - _05_stat_tb4; run;
/* 	%print(_05_stat_tb); */

	data _05_rate_cl; set _05_rate_cl1 - _05_rate_cl4; run;
/* 	%print(_05_rate_cl);	 */

	data _05_py; set _05_py1 - _05_py4; run;
/* 	%print(_05_py); */
	
	proc sql noprint;
		create table _05_tb_comb&sub. as
		select distinct a.seq, a.grp, a.pts, a.perc
			, b.mean, b.sd, b.median, b.min, b.q1, b.q3, b.max
			, d.sum_py/100 as total_py
			, c.rate, c.lower95, c.upper95
		from _05_desc as a
			left join _05_stat_tb as b on a.seq=b.seq and a.grp=b.grp
			left join _05_rate_cl as c on a.seq=c.seq and a.grp=c.grp
			left join _05_py as d on a.seq=d.seq and a.grp=d.grp;
	quit;	
%mend tb;
%tb (sub=1, whrcl= enrolid is not null);
%tb (sub=2, whrcl= htn eq 1 or infl eq 1);
%tb (sub=3, whrcl= htn eq 1 and infl eq 1);
data _05_tb_comb_fn; set _05_tb_comb1 - _05_tb_comb3; run;
%print(_05_tb_comb_fn);	
