/*first MACE: this is version 2 to add limb gangrene (I7026)*/

* 3-yr baseline + 5-yr follow-up;
%macro time_mace_35 (sub, whrcl);
	data _07_sub;
		set derived._05_mace;
		if htn eq 1 or infl eq 1 then sub1=1;
		if htn eq 1 and infl eq 1 then sub2=1;
	run;
gang
	proc sql;
		create table _07_time as
		select distinct enrolid, diag, sub1, sub2, index_dt, mi_dt_post as mace_dt format date9., 'mi' as mace from _07_sub where mi_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, stroke_dt_post as mace_dt format date9., 'stroke' as mace from _07_sub where stroke_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, revasc_dt_post as mace_dt format date9., 'revasc' as mace from _07_sub where revasc_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, gang_dt_post as mace_dt format date9., 'gang' as mace from _07_sub where gang_dt_post ne .;
	
		create table _07_first_mace as
		select distinct *, mace_dt-index_dt as time_mace
		from _07_time
		group by enrolid
		having min(mace_dt)=mace_dt;
	
		create table _07_overall as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace;
		create table _07_mi_stroke as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="mi" or mace="stroke";
		create table _07_mi as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="mi";		
		create table _07_stroke as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="stroke";	
		create table _07_revasc as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="revasc";		
		create table _07_gang as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="gang";			
	quit;	
	%do e=1 %to 6;
		%let mace_var = %scan(overall*mi_stroke*mi*stroke*revasc*gang, &e., *);
		data _07_setup_stat; set _07_&mace_var.; where &whrcl.; run;
		proc means data= _07_setup_stat n mean stddev median min q1 q3 max;
			var time_mace;
			output out=_07_stat_pre&e. mean()= STD()= median()=  Min()= Q1()= Q3()= Max()= /autoname;
		run;
		data _07_stat&e.; set _07_stat_pre&e.; format mace $20.; mace="&mace_var."; run;
	%end;	
	data _07_stat_fn&sub.; set _07_stat1 - _07_stat6; sub=&sub.; run;
%mend time_mace_35;
%time_mace_35 (sub=1, whrcl= enrolid is not null);
%time_mace_35 (sub=2, whrcl= sub1 eq 1);
%time_mace_35 (sub=3, whrcl= sub2 eq 1);
data _07_stat_tb; set _07_stat_fn1 - _07_stat_fn3; run;
%print(_07_stat_tb);



* 5-yr baseline + 3-yr follow-up;
%macro time_mace_53 (sub, whrcl);
	data _07_sub;
		set derived._06_mace;
		if htn eq 1 or infl eq 1 then sub1=1;
		if htn eq 1 and infl eq 1 then sub2=1;
	run;

	proc sql;
		create table _07_time as
		select distinct enrolid, diag, sub1, sub2, index_dt, mi_dt_post as mace_dt format date9., 'mi' as mace from _07_sub where mi_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, stroke_dt_post as mace_dt format date9., 'stroke' as mace from _07_sub where stroke_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, revasc_dt_post as mace_dt format date9., 'revasc' as mace from _07_sub where revasc_dt_post ne . union
		select distinct enrolid, diag, sub1, sub2, index_dt, gang_dt_post as mace_dt format date9., 'gang' as mace from _07_sub where gang_dt_post ne .;
	
		create table _07_first_mace as
		select distinct *, mace_dt-index_dt as time_mace
		from _07_time
		group by enrolid
		having min(mace_dt)=mace_dt;
	
		create table _07_overall as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace;
		create table _07_mi_stroke as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="mi" or mace="stroke";
		create table _07_mi as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="mi";		
		create table _07_stroke as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="stroke";	
		create table _07_revasc as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="revasc";		
		create table _07_gang as select distinct enrolid, sub1, sub2, mace_dt, time_mace from _07_first_mace where mace="gang";			
	quit;	
	%do e=1 %to 6;
		%let mace_var = %scan(overall*mi_stroke*mi*stroke*revasc*gang, &e., *);
		data _07_setup_stat; set _07_&mace_var.; where &whrcl.; run;
		proc means data= _07_setup_stat n mean stddev median min q1 q3 max;
			var time_mace;
			output out=_07_stat_pre&e. mean()= STD()= median()=  Min()= Q1()= Q3()= Max()= /autoname;
		run;
		data _07_stat&e.; set _07_stat_pre&e.; format mace $20.; mace="&mace_var."; run;
	%end;	
	data _07_stat_fn&sub.; set _07_stat1 - _07_stat6; sub=&sub.; run;
%mend time_mace_53;
%time_mace_53 (sub=1, whrcl= enrolid is not null);
%time_mace_53 (sub=2, whrcl= sub1 eq 1);
%time_mace_53 (sub=3, whrcl= sub2 eq 1);
data _07_stat_tb; set _07_stat_fn1 - _07_stat_fn3; run;
%print(_07_stat_tb);










