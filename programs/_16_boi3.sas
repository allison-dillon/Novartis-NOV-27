

%macro prepdemos(year);
* modify variables;
%do z=1 %to 2;
/* 	%let groups=rslt_lt_55*rslt_ge_55*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100; */
/* 	%let groups=overall; */
/* 		%do zz=1 %to 1; */
/* 		%let ad = %scan(&groups., &zz., *);		 */
	data derived._16_hcru_overall&z.&year.;
		set derived._12_hcru_overall&z.&year.;
		%let vars=statins*pcsk9i*ezetimibe*fibrates*niacin*mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet*niacin_statin*loop_diuretic*mra
		*anticoagulant*statins_index*pcsk9i_index*ezetimibe_index*fibrates_index*niacin_index*mipomersen_index*tocilizumab_index*hormone_index
		*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index*niacin_statin_index*loop_diuretic_index*mra_index*anticoagulant_index
		*angio_stent*cabg*endar*pci*throm*aphe*dial*angio*stent*pci_angio_stent_sameday*pci_and_angio_stent
						;
	
			%do j=1 %to %sysfunc(countw(&vars., *));
			%let char = %scan(&vars., &j., *);
		
			format &char._pre $3.;
			&char._pre=&char.;
			drop &char.;
			rename &char._pre=&char.;
		%end;

		%do t=1 %to 3;
			%let dt = %scan(index_date_overall*eligeff*eligend, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
		
		%do t=1 %to 7;
			%let lab = %scan(ldlc_cnt*hdlc_cnt*tc_cnt*tg_cnt*lpa_mg_cnt*lpa_mol_cnt*cprot_cnt, &t., *);
			if &lab. <=0 then &lab.=.;
		%end;
		

		%do t=1 %to 7;
			%let lab = %scan(ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot, &t., *);
			if &lab. ne . then &lab._pts='1';
			format &lab.2 8. &lab._dt2 date9.;
			&lab.2=&lab.;
			&lab._dt2=datepart(&lab._dt);
			drop &lab. &lab._dt;
			rename &lab.2=&lab. &lab._dt2=&lab._dt;
		%end;
		drop grp cat test_desc;
			if sys_bp ge 140 then sys_bp_grp='uc'; else if 0 le sys_bp lt 140 then sys_bp_grp='c';
		if dia_bp ge 90 then dia_bp_grp='uc'; else if 0 le dia_bp lt 90 then dia_bp_grp='c';
		
		if pci='1' or angio_stent='1' then pci_or_angio_stent='1';
				
		pci_or_angio_stent_cnt=sum(pci_cnt,angio_stent_cnt);
		
		if Ezetimibe_Statin='1' or Statins='1' or Niacin_Statin='1' then statin_tot='1';
		if Niacin_Statin='1' or Niacin='1' then Niacin_tot='1';
		if Ezetimibe_Statin='1' or Ezetimibe='1' then Eze='1';
		
		if Ezetimibe_Statin_index='1' or Statins_index='1' or Niacin_Statin_index='1' then statin_tot_index='1';
		if Niacin_Statin_index='1' or Niacin_index='1' then Niacin_tot_index='1';
		if Ezetimibe_Statin_index='1' or Ezetimibe_index='1' then Eze_index='1';
			
		if diabete='1' then hba1c_dia=hba1c;
		if diabete='1' and hba1c_dia ne . then hba1c_dia_pts='1';
		
	run;
	%end;
%mend;

%prepdemos(one_year);
%prepdemos(two_years);
%prepdemos(all);


%macro demos(year);
* modify variables;
%do z=1 %to 1;

PROC SQL;
	CREATE TABLE derived._16_hcru1_overall&z.&year. AS 
	SELECT a.*, b.rslt_grp30, b.rslt_grp50, b.rslt_grp, b.rslt_grp70, b.rslt_grp90, b.rslt_grp120, b.rslt_grp150, b.rslt_nbr as lpa 
	, '1' as overall
	FROM  derived._16_hcru_overall&z.&year. a inner join derived._02_primary_1 b
		on a.patid=b.patid
	;
QUIT;

	%end;
%mend;

%demos(one_year);
%demos(two_years);
%demos(all);

%macro demos(year);

%do z=2 %to 2;

*Demo table cohort 2;
PROC SQL;
	CREATE TABLE derived._16_hcru1_overall&z.&year. AS 
	SELECT  a.*, b.RSLT_NBR as Lpa, b.rslt_grp65, b.rslt_grp105, b.rslt_grp, b.rslt_grp150, b.rslt_grp190, b.rslt_grp255, b.rslt_grp320
	, '1' as overall
	FROM derived._16_hcru_overall&z.&year. a inner join derived._02_primary_2 b
		on a.patid=b.patid
	;
QUIT;

	%end;
%mend; 

%demos(one_year);
%demos(two_years);
%demos(all);


%macro year(year, years=one_year=1);

%macro output(seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=1 %to 2;
/* 	%let ad_groups=rslt_lt_55*rslt_ge_55*rslt_lt_70*rslt_ge_70*rslt_lt_100*rslt_ge_100; */
	%let ad_groups=overall;
		%do zz=1 %to 1;
			%let ad = %scan(&ad_groups., &zz., *);
			
proc sql;
	create table cohort&z._&ad.&year. as 
	select b.*, c.recent_ldlc, c.rslt_lt_55, c.rslt_ge_55, c.rslt_lt_70, c.rslt_ge_70, c.rslt_lt_100, c.rslt_ge_100, '1' as overall
	from derived._07_primary_&z.overall a inner join derived._16_hcru1_overall&z.&year. b
		on a.patid=b.patid inner join derived.ldlc_06 c
		on a.patid=c.patid
		where a.index_date_overall is not null and &years.;
quit;


data cohort&z._&ad.&year._1;
	set cohort&z._&ad.&year. ;
	%if &z.=1 %then where &whrcl1. and &ad. is not null; 
	%else where &whrcl2. and &ad. is not null; 
	;
run;

proc univariate data = cohort&z._&ad.&year._1;
var cprot;
output out=outdata PCTLPTS =0 to 100 by 20 PCTLPRE = P;
run;

proc sql;
	select P0, P20, P40, P60, P80, P100 into: P0, :P20, :P40, :P60, :P80, :P100 from outdata;
quit;

PROC SQL;
	CREATE TABLE cohort&z._&ad.&year._2 as
	select a.*
		,case when &P0.<=cprot<&P20. then lpa end as lpa_min_p20
		,case when &P20.<=cprot<&P40. then lpa end as lpa_p20_p40
		,case when &P40.<=cprot<&P60. then lpa end as lpa_p40_p60
		,case when &P60.<=cprot<&P80. then lpa end as lpa_p60_p80
		,case when &P80.<=cprot<=&P100. then lpa end as lpa_p80_p100
	FROM cohort&z._&ad.&year._1 a
;

%table1(cohort= cohort&z._&ad.&year._2
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= /*procedure*/
				dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				/*medications at index*/
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet*niacin_statin*loop_diuretic*mra
				*anticoagulant
				/*medications post index*/
				*statin_tot_index*pcsk9i_index*Eze_index*fibrates_index*Niacin_tot_index*mipomersen_index*tocilizumab_index*hormone_index
				*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index*niacin_statin_index*loop_diuretic_index*mra_index*anticoagulant_index
				/*lab values*/	
				*ldlc*hdlc*tc*tg*cprot
				*ldlc_cnt*hdlc_cnt*tc_cnt*tg_cnt*cprot_cnt
				/*lab values by c-reactive protein*/
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
		, hide_headspace=dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm*statins*pcsk9i*ezetimibe*fibrates
				*niacin*mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet*niacin_statin*loop_diuretic*mra
				*anticoagulant*statins_index*pcsk9i_index*ezetimibe_index*fibrates_index*niacin_index*mipomersen_index*tocilizumab_index*hormone_index
				*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index*niacin_statin_index*loop_diuretic_index*mra_index*anticoagulant_index
				*ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
		
		, hide_missing=dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm*statins*pcsk9i*ezetimibe*fibrates
				*niacin*mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet*niacin_statin*loop_diuretic*mra
				*anticoagulant*statins_index*pcsk9i_index*ezetimibe_index*fibrates_index*niacin_index*mipomersen_index*tocilizumab_index*hormone_index
				*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index*niacin_statin_index*loop_diuretic_index*mra_index*anticoagulant_index
				*ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
		
		, combine_cols=
		, pvalues=
		, strat_whr0= patid is not null;

	
	);
		
	data _16_&ad.&z.cohort&seq;
	length cohort_new group1 group2 $100.;
		set _05_sub_tb;
			%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;
			
				if &zz.=1 then group1='Overall';
/* 				if &zz.=1 then group1="< 55 mg/dL"; */
/* 				else if &zz.=2 then group1='≥ 55 mg/dL'; */
/* 				else if &zz.=3 then group1='< 70 mg/dL'; */
/* 				else if &zz.=4 then group1= '≥ 70 mg/dL'; */
/* 				else if &zz.=5 then group1='< 100 mg/dL'; */
/* 				else if &zz.=6 then group1='≥ 100 mg/dL'; */
		if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
		else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
	run;
	%end;
	%end;

	
%mend output;

%output(1, overall, overall,  whrcl1= '1', whrcl2='1');
%output(2, <30 mg/dL , <65 nmol/L , whrcl1=rslt_grp30='<30 ',  whrcl2= rslt_grp65='<65 ');
%output(3, <50 mg/dL, <105 nmol/L, whrcl1= rslt_grp50='<50 ', whrcl2= rslt_grp105='<105 ');
%output(4, 30-<50 mg/dL, 65-<105 nmol/L,  whrcl1= rslt_grp='1. >=30 - <50', whrcl2= rslt_grp='1. >=65 - <105');
%output(5,  50-<70 mg/dL, 105-<150 nmol/L, whrcl1= rslt_grp='2. >=50 - <70', whrcl2= rslt_grp='2. >=105 - <150');
%output(6, 70-<90 mg/dL, 150-<190 nmol/L, whrcl1= rslt_grp='3. >=70 - <90', whrcl2= rslt_grp='3. >=150 - <190');
%output(7, 90-<120 mg/dL, 190-<255 nmol/L, whrcl1= rslt_grp='4. >=90 - <120', whrcl2= rslt_grp='4. >=190 - <255');
%output(8, ≥70 mg/dL, ≥150 nmol/L, whrcl1= rslt_grp70='>=70 ', whrcl2= rslt_grp150='>=150 ');
%output(9, ≥90 mg/dL, ≥190 nmol/L, whrcl1= rslt_grp90='>=90 ', whrcl2= rslt_grp190='>=190 ' );
%output(10, ≥120 mg/dL, ≥255 nmol/L, whrcl1= rslt_grp120='>=120',  whrcl2= rslt_grp255='>=255');
%output(11, ≥150 mg/dL, ≥320 nmol/L, whrcl1= rslt_grp150='>=150', whrcl2= rslt_grp320='>=320' );

data _16_hcru_&year.;

	set  _16_overall1cohort1 - _16_overall1cohort11
		_16_overall2cohort1 - _16_overall2cohort11;
	
/* 		_16_rslt_lt_551cohort1 - _16_rslt_lt_551cohort11 */
/* 		_16_rslt_ge_551cohort1 - _16_rslt_ge_551cohort11 */
/* 		_16_rslt_lt_701cohort1 - _16_rslt_lt_701cohort11 */
/* 		_16_rslt_ge_701cohort1 - _16_rslt_ge_701cohort11 */
/* 		_16_rslt_lt_1001cohort1 - _16_rslt_lt_1001cohort11 */
/* 		_16_rslt_ge_1001cohort1 - _16_rslt_ge_1001cohort11 */
/*  */
/* 		 _16_rslt_lt_552cohort1 - _16_rslt_lt_552cohort11 */
/* 		_16_rslt_ge_552cohort1 - _16_rslt_ge_552cohort11 */
/* 		_16_rslt_lt_702cohort1 - _16_rslt_lt_702cohort11 */
/* 		_16_rslt_ge_702cohort1 - _16_rslt_ge_702cohort11 */
/* 		_16_rslt_lt_1002cohort1 - _16_rslt_lt_1002cohort11 */
/* 		_16_rslt_ge_1002cohort1 - _16_rslt_ge_1002cohort11; */
		if group2 in ('<30 mg/dL' , '<65 nmol/L') then group2='<30 mg/dL or <65 nmol/L';
		else if group2 in ('<50 mg/dL', '<105 nmol/L') then group2='<50 mg/dL or <105 nmol/L';
		else if group2 in ('30-<50 mg/dL', '65-<105 nmol/L') then group2='30-<50 mg/dL or 65-<105 nmol/L';
		else if group2 in ('50-<70 mg/dL', '105-<150 nmol/L') then group2='50-<70 mg/dL or 105-<150 nmol/L';
		else if group2 in ('70-<90 mg/dL', '150-<190 nmol/L') then group2='70-<90 mg/dL or 150-<190 nmol/L';
		else if group2 in ('90-<120 mg/dL', '190-<255 nmol/L') then group2='90-<120 mg/dL or 190-<255 nmol/L';
		else if group2 in ('≥70 mg/dL', '≥150 nmol/L') then group2='≥70 mg/dL or ≥150 nmol/L';
		else if group2 in ('≥90 mg/dL', '≥190 nmol/L') then group2='≥90 mg/dL or ≥190 nmol/L';
		else if group2 in ('≥120 mg/dL', '≥255 nmol/L') then group2='≥120 mg/dL or ≥255 nmol/L';
		else if group2 in ('≥150 mg/dL', '≥320 nmol/L') then group2='≥150 mg/dL or ≥320 nmol/L';
		else if group2='overall' then group2='Overall';
		
	run;


%mend;

%year(one_year, years=one_year=1);
%year(two_years, years=two_years=1);
%year(all, years=b.patid is not null);

ods csv file="/home/dingyig/proj/NOV-27/Output/_16_hcru_one_year.csv";
proc print data=	_16_hcru_one_year ;
run;	
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_16_hcru_two_years.csv";
proc print data=	_16_hcru_two_years noobs;
run;	
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_16_hcru_all.csv";
proc print data=	_16_hcru_all noobs;
run;	
ods csv close;


/*count number of procedures and labs in post index period*/	
options mprint;
%macro year(year, table, years=one_year=1);

%macro count(seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=1 %to 2;
	%let ad_groups=overall;
		%do zz=1 %to 1;
			%let ad = %scan(&ad_groups., &zz., *);
	
	proc sql;
	create table cohort&z._&ad.&year. as 
	select b.* , c.recent_ldlc, c.rslt_lt_55, c.rslt_ge_55, c.rslt_lt_70, c.rslt_ge_70, c.rslt_lt_100, c.rslt_ge_100
	from derived._07_primary_&z.overall a inner join derived._16_hcru1_overall&z.&year. b
		on a.patid=b.patid inner join derived.ldlc_06 c
		on a.patid=c.patid
		where a.index_date_overall is not null and &years.;
quit;

data cohort&z._&ad.&year._1;
	set cohort&z._&ad.&year. ;
	%if &z.=1 %then where &whrcl1. and &ad. is not null; 
	%else where &whrcl2. and &ad. is not null; 
	;
run;
	/*procedures*/
	%do q=1 %to 12;
				proc sql noprint; select count(distinct patid) into: pts_hosp from cohort&z._&ad.&year._1; quit;
				%let vars=%scan(angio_stent_cnt*cabg_cnt*endar_cnt*pci_cnt*throm_cnt*aphe_cnt*dial_cnt*angio_cnt*stent_cnt*pciangiostentsamedaycnt*pci_or_angio_stent_cnt*pciandangiostentcnt, &q., *);
				proc means data=cohort&z._&ad.&year._1 (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_16_proc_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _16_proc_&ad.out&q. as  
					select &q. as seq, 'proc' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_hosp. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _16_proc_out;
				quit;	
			%end;
	
	
	
	data _16_&ad.&z.procs&seq.; 
			length cohort_new group1 group2 cat2 $100.;
			set _16_proc_&ad.out1-_16_proc_&ad.out12;			
				if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
				else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
				if &z.=1 then group2="&lpa_level1."; else group2="&lpa_level2."; 
					
				if &zz.=1 then group1='Overall';	
/* 				if &zz.=1 then group1="< 55 mg/dL"; */
/* 				else if &zz.=2 then group1='≥ 55 mg/dL'; */
/* 				else if &zz.=3 then group1='< 70 mg/dL'; */
/* 				else if &zz.=4 then group1= '≥ 70 mg/dL'; */
/* 				else if &zz.=5 then group1='< 100 mg/dL'; */
/* 				else if &zz.=6 then group1='≥ 100 mg/dL'; */
				else if cat2='pci_or_angio_stent_cnt' then cat2='pci_or_angio_stent';
				else if cat2='pciangiostentsamedaycnt' then cat2='pci_angio_stent_sameday';
				else if cat2='pciandangiostentcnt' then cat2='pci_and_angio_stent';		
				seq=1;
		run;

	%end;	
	%end;
	
		

%mend;
%count(1, overall, overall,  whrcl1= '1', whrcl2='1');
%count(2, <30 mg/dL , <65 nmol/L , whrcl1=rslt_grp30='<30 ',  whrcl2= rslt_grp65='<65 ');
%count(3, <50 mg/dL, <105 nmol/L, whrcl1= rslt_grp50='<50 ', whrcl2= rslt_grp105='<105 ');
%count(4, 30-<50 mg/dL, 65-<105 nmol/L,  whrcl1= rslt_grp='1. >=30 - <50', whrcl2= rslt_grp='1. >=65 - <105');
%count(5,  50-<70 mg/dL, 105-<150 nmol/L, whrcl1= rslt_grp='2. >=50 - <70', whrcl2= rslt_grp='2. >=105 - <150');
%count(6, 70-<90 mg/dL, 150-<190 nmol/L, whrcl1= rslt_grp='3. >=70 - <90', whrcl2= rslt_grp='3. >=150 - <190');
%count(7, 90-<120 mg/dL, 190-<255 nmol/L, whrcl1= rslt_grp='4. >=90 - <120', whrcl2= rslt_grp='4. >=190 - <255');
%count(8, ≥70 mg/dL, ≥150 nmol/L, whrcl1= rslt_grp70='>=70 ', whrcl2= rslt_grp150='>=150 ');
%count(9, ≥90 mg/dL, ≥190 nmol/L, whrcl1= rslt_grp90='>=90 ', whrcl2= rslt_grp190='>=190 ' );
%count(10, ≥120 mg/dL, ≥255 nmol/L, whrcl1= rslt_grp120='>=120',  whrcl2= rslt_grp255='>=255');
%count(11, ≥150 mg/dL, ≥320 nmol/L, whrcl1= rslt_grp150='>=150', whrcl2= rslt_grp320='>=320' );

data _16_procs&year.; 
		set _16_overall1procs1 - _16_overall1procs11
		_16_overall2procs1 - _16_overall2procs11;
		
/* 		_16_rslt_lt_551procs1 - _16_rslt_lt_551procs11 */
/* 		_16_rslt_ge_551procs1 - _16_rslt_ge_551procs11 */
/* 		_16_rslt_lt_701procs1 - _16_rslt_lt_701procs11 */
/* 		_16_rslt_ge_701procs1 - _16_rslt_ge_701procs11 */
/* 		_16_rslt_lt_1001procs1 - _16_rslt_lt_1001procs11 */
/* 		_16_rslt_ge_1001procs1 - _16_rslt_ge_1001procs11 */
/* 		 */
/* 		_16_rslt_lt_552procs1 - _16_rslt_lt_552procs11 */
/* 		_16_rslt_ge_552procs1 - _16_rslt_ge_552procs11 */
/* 		_16_rslt_lt_702procs1 - _16_rslt_lt_702procs11 */
/* 		_16_rslt_ge_702procs1 - _16_rslt_ge_702procs11 */
/* 		_16_rslt_lt_1002procs1 - _16_rslt_lt_1002procs11 */
/* 		_16_rslt_ge_1002procs1 - _16_rslt_ge_1002procs11				; */
		if group2 in ('<30 mg/dL' , '<65 nmol/L') then group2='<30 mg/dL or <65 nmol/L';
		else if group2 in ('<50 mg/dL', '<105 nmol/L') then group2='<50 mg/dL or <105 nmol/L';
		else if group2 in ('30-<50 mg/dL', '65-<105 nmol/L') then group2='30-<50 mg/dL or 65-<105 nmol/L';
		else if group2 in ('50-<70 mg/dL', '105-<150 nmol/L') then group2='50-<70 mg/dL or 105-<150 nmol/L';
		else if group2 in ('70-<90 mg/dL', '150-<190 nmol/L') then group2='70-<90 mg/dL or 150-<190 nmol/L';
		else if group2 in ('90-<120 mg/dL', '190-<255 nmol/L') then group2='90-<120 mg/dL or 190-<255 nmol/L';
		else if group2 in ('≥70 mg/dL', '≥150 nmol/L') then group2='≥70 mg/dL or ≥150 nmol/L';
		else if group2 in ('≥90 mg/dL', '≥190 nmol/L') then group2='≥90 mg/dL or ≥190 nmol/L';
		else if group2 in ('≥120 mg/dL', '≥255 nmol/L') then group2='≥120 mg/dL or ≥255 nmol/L';
		else if group2 in ('≥150 mg/dL', '≥320 nmol/L') then group2='≥150 mg/dL or ≥320 nmol/L';
		else if group2='overall' then group2='Overall';
	run;	


%mend;


%year(one_year, years=one_year=1);
%year(two_years, years=two_years=1);
%year(all,  years=b.patid is not null);

/*all follow up*/
ods csv file="/home/dingyig/proj/NOV-27/Output/_16_procs_all.csv";
proc print data=	_16_procsall noobs;
run;	
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_16_procs_one_year.csv";
proc print data=	_16_procsone_year noobs;
run;	
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_16_procs_two_year.csv";
proc print data=	_16_procstwo_years noobs;
run;	
ods csv close;

