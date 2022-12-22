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


%macro bringsas(year);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table _10_mace_&ad.&z.&year. as
	select a.*
	from heor._13a_mace&z.&year. a;
			 
quit;
	%end;
	%end;

%mend;

%bringsas(one_year);
%bringsas(two_years);
%bringsas(all);

%macro char_correct(year);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);		
	data _10_mace1_&ad.&z.&year.;
		set _10_mace_&ad.&z.&year.;
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
		create table _10_mace2_&ad.&z.&year. as 
		select distinct a.*
				%do i=1 %to 4;
				%let grp =%scan(mi*stroke*revasc*gang, &i., *);
							,sum(case when a.index_date_&ad. <  &grp._dt le (&time.) then &grp. end) as &grp.
							,min(case when a.index_date_&ad. <  &grp._dt le (&time.)  then &grp._dt end) as &grp._dt format mmddyy10.
				%end;
		from derived._07_primary_&z.&ad. a left join _10_mace1_&ad.&z.&year. b 
		on a.patid=b.patid 
		where a.index_date_overall is not null
		group by a.patid, a.index_date_overall
		;	
	quit;
	


data _10_mace3_&ad.&z.&year.; 
	set _10_mace2_&ad.&z.&year.;
	
		if mi>0 then mi_grp=1; else mi_grp=0;
		if stroke>0 then stroke_grp=1; else stroke_grp=0;
		if revasc>0 then revasc_grp=1; else revasc_grp=0;
		if gang>0 then gang_grp=1; else gang_grp=0;
		if mi>0 or stroke>0 or revasc>0 or revasc>0 then do; overall_grp=1; overall1=sum(mi,stroke,revasc,gang); end;
		if overall1>=1 then overall1_grp=1;
		else overall1_grp=0;

	run;

	
data derived._10_mace_&ad.&z.&year;
	set _10_mace3_&ad.&z.&year.;
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

/* 	%let groups=overall*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100; */
/* 		%do zz=1 %to 5; */
/* 		%let ad = %scan(&groups., &zz., *); */
	proc sql;
		create table _10_tb_setup as 
		select a.*
			,'1' as overall 
		from derived._10_mace_overall2&year. a left join derived.ldlc_06 b
			on a.patid=b.patid
		where index_date_overall is not null and &years. 
		and (rslt_grp65 is not null or rslt_grp150 is not null )
		;
		quit;
	
	data _10_tb_setup1;
		set _10_tb_setup;
		if rslt_grp65='<65 ' then rslt_grp='<65 ';
			else rslt_grp='>=150';
	run;
	
		proc sort data=_10_tb_setup1;
		by rslt_grp;
		run;		

	%do e=1 %to 5;
		%let mace_var = %scan(overall1*mi*stroke*revasc*gang, &e., *);
		%let seq = %scan(2*3*4*5*6, &e., *);	

		ods output DIFFS=DIFFS;
		proc genmod data=_10_tb_setup1;
		class rslt_grp;
			model &mace_var._grp = rslt_grp / offset=ln_py dist=poisson link=log;		
/* 			estimate "&mace_var." intercept 1 rslt_grp / exp; */
			lsmeans rslt_grp / exp pdiff cl;
			ods output ParameterEstimates=_10_rate;
		run;
			
		proc sql;	
			create table _11_diff&e. as
			select "&mace_var._grp              " as var,  probz, exp(-estimate) as expestimate, exp(-lower) as explower, exp(-upper) as expupper
			from Diffs ;
		quit;
	%end;
	
	* set final table;
		data _hcru_rate&year.;
			format YEAR $15.;
			set _11_diff1 - _11_diff5;
			YEAR="&year.";
		run;
	
%mend time;

%time(one_year, years=one_year=1);		
%time(two_years, years=two_years=1);
%time(all, years=a.patid is not null);

data _hcru_rateoverall; 
	set _hcru_rateone_year
		_hcru_ratetwo_years
		_hcru_rateall		;
run;

proc print data=_hcru_rateoverall;
run;