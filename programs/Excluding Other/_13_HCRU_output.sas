
%macro prepdemos(year);
* modify variables;
%do z=1 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);		
	data derived._13_hcru_&ad.&z.&year.;
		set derived._12_hcru_&ad.&z.&year.;
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
			%let dt = %scan(index_date_&ad.*eligeff*eligend, &t., *);
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
	%end;
%mend;

%prepdemos(one_year);
%prepdemos(two_years);
%prepdemos(all);


%macro demos(year);
* modify variables;
%do z=1 %to 1;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
PROC SQL;
	CREATE TABLE derived._13_hcru1_&ad.&z.&year. AS 
	SELECT distinct a.*, b.rslt_grp30, b.rslt_grp50, b.rslt_grp, b.rslt_grp70, b.rslt_grp90, b.rslt_grp120, b.rslt_grp150, b.rslt_nbr as lpa 
	, '1' as overall
	FROM  derived._13_hcru_&ad.&z.&year. a inner join derived._02_primary_1 b
		on a.patid=b.patid
	;
QUIT;
	%end;
	%end;
%mend;

%demos(one_year);
%demos(two_years);
%demos(all);

%macro demos(year);

%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
*Demo table cohort 2;
PROC SQL;
	CREATE TABLE derived._13_hcru1_&ad.&z.&year. AS 
	SELECT distinct a.*, b.RSLT_NBR as Lpa, b.rslt_grp65, b.rslt_grp105, b.rslt_grp, b.rslt_grp150, b.rslt_grp190, b.rslt_grp255, b.rslt_grp320
	, '1' as overall
	FROM derived._13_hcru_&ad.&z.&year. a inner join derived._02_primary_2 b
		on a.patid=b.patid
	;
QUIT;

	%end;
	%end;
%mend; 

%demos(one_year);
%demos(two_years);
%demos(all);


%macro year(year, years=one_year=1);

%macro output(seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=1 %to 2;
	%let ad_groups=overall;
	%do zz=1 %to 1;
			%let ad = %scan(&ad_groups., &zz., *);
			
proc sql;
	create table cohort&z._&ad.&year. as 
	select b.*
	from derived._07_primary_&z.&ad. a inner join derived._13_hcru1_&ad.&z.&year. b
		on a.patid=b.patid
	where b.index_date_&ad. is not null and &years.
	;
quit;

data cohort&z._&ad.&year._1;
	set cohort&z._&ad.&year. ;
	%if &z.=1 %then where &whrcl1. ; 
	%else where &whrcl2.;
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
		
	data _02_cohort&z.&ad.&seq;
	length cohort_new group1 group2 $100.;
		set _05_sub_tb;
			%if &z.=1 %then group2="&lpa_level1."; %else group2="&lpa_level2."; ;		
				if &zz.=1. then group1="Overall";
				else if &zz.=2 then group1="Patients with the following MI, ischemic stroke, or PAD as index";
				else if &zz.=3 then group1="Patients without any MI, ischemic stroke, or PAD on index";
				else if &zz.=4 then group1="MI";
				else if &zz.=5 then group1="PAD";
				else if &zz.=6 then group1="Ischemic Stroke";
				else if &zz.=7 then group1="Transient Ischemic Attack (TIA)";
				else if &zz.=8 then group1="Unstable Angina";
				else if &zz.=9 then group1="Stable Angina";
				else if &zz.=10 then group1="Post-revascularization";
				else if &zz=11 then group1="Percutaneous coronary intervention (PCI)";
				else if &zz=12 then group1="Coronary artery bypass grafting (CABG)";
				else if &zz=13 then group1="Angioplasty and/or stent placement";
				else if &zz=14 then group1="Endarterectomy";
				else if &zz=15 then group1="Thrombectomy";
				else if &zz.=16 then group1="Other";
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

data _13_hcru_&year.;

	set _02_cohort1overall1-_02_cohort1overall11
/* 		_02_cohort1cvd1-_02_cohort1cvd11 */
/* 		_02_cohort1noncvd1-_02_cohort1noncvd11 */
/* 		_02_cohort1mi1-_02_cohort1mi11 */
/* 		_02_cohort1pad1-_02_cohort1pad11 */
/* 		_02_cohort1stroke1-_02_cohort1stroke11 */
/* 		_02_cohort1unsta_angina1-_02_cohort1unsta_angina11 */
/* 		_02_cohort1sta_angina1-_02_cohort1sta_angina11 */
/* 		_02_cohort1tia1-_02_cohort1tia11 */
/* 		_02_cohort1other1-_02_cohort1other11 */
/* 		_02_cohort1revasc1-_02_cohort1revasc11 */
/* 		_02_cohort1throm1-_02_cohort1throm11 */
/* 		_02_cohort1cabg1-_02_cohort1cabg11 */
/* 		_02_cohort1endar1-_02_cohort1endar11 */
/* 		_02_cohort1pci1 -_02_cohort1pci11 */
/* 		_02_cohort1angio_stent1-_02_cohort1angio_stent11 */

		 _02_cohort2overall1-_02_cohort2overall11;
/* 		_02_cohort2cvd1-_02_cohort2cvd11 */
/* 		_02_cohort2noncvd1-_02_cohort2noncvd11 */
/* 		_02_cohort2mi1-_02_cohort2mi11 */
/* 		_02_cohort2pad1-_02_cohort2pad11 */
/* 		_02_cohort2stroke1-_02_cohort2stroke11 */
/* 		_02_cohort2unsta_angina1-_02_cohort2unsta_angina11 */
/* 		_02_cohort2sta_angina1-_02_cohort2sta_angina11 */
/* 		_02_cohort2tia1-_02_cohort2tia11 */
/* 		_02_cohort2other1-_02_cohort2other11 */
/* 		_02_cohort2revasc1-_02_cohort2revasc11 */
/* 		_02_cohort2throm1-_02_cohort2throm11 */
/* 		_02_cohort2cabg1-_02_cohort2cabg11 */
/* 		_02_cohort2endar1-_02_cohort2endar11 */
/* 		_02_cohort2pci1 -_02_cohort2pci11 */
/* 		_02_cohort2angio_stent1-_02_cohort2angio_stent11; */
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

ods csv file="/home/dingyig/proj/NOV-27/Output/_13_hcru_one_year.csv";
proc print data=	_13_hcru_one_year ;
run;	
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_13_hcru_two_years.csv";
proc print data=	_13_hcru_two_years noobs;
run;	
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_13_hcru_all.csv";
proc print data=	_13_hcru_all noobs;
run;	
ods csv close;


/*count number of procedures and labs in post index period*/	
options mprint;
%macro year(year, table, years);

%macro count(seq, lpa_level1, lpa_level2, whrcl1, whrcl2);
	%do z=1 %to 2;
	%let ad_groups=overall;
	%do zz=1 %to 1;
			%let ad = %scan(&ad_groups., &zz., *);
	
	proc sql;
	create table cohort&z._&ad.&year. as 
	select b.*
	from derived._07_primary_&z.&ad. a inner join derived._13_hcru1_&ad.&z.&year. b
		on a.patid=b.patid
	where b.index_date_&ad. is not null and &years.
	;
quit;

data cohort&z._&ad.&year._1;
	set cohort&z._&ad.&year. ;
	%if &z.=1 %then where &whrcl1. ; 
	%else where &whrcl2.;
	;
run;
	/*procedures*/
	%do q=1 %to 12;
				proc sql noprint; select count(distinct patid) into: pts_hosp from cohort&z._&ad.&year._1; quit;
				%let vars=%scan(angio_stent_cnt*cabg_cnt*endar_cnt*pci_cnt*throm_cnt*aphe_cnt*dial_cnt*angio_cnt*stent_cnt*pciangiostentsamedaycnt*pci_or_angio_stent_cnt*pciandangiostentcnt, &q., *);
				proc means data=cohort&z._&ad.&year._1 (where= (&vars. ge 1)) n mean stddev median min q1 q3 max noprint;
					var &vars.;
					output out=_13_proc_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				proc sql; 
					create table _13_proc_&ad.out&q. as  
					select &q. as seq, 'proc' as cat1, "&vars." as cat2, _FREQ_, _FREQ_/&pts_hosp. as perc
						, &vars._mean as mean
						, &vars._stddev as sd
						, &vars._median as median
						, &vars._min as min
						, &vars._q1 as q1
						, &vars._q3 as q3
						, &vars._max as max  
					from _13_proc_out;
				quit;	
			%end;
	
	
	
	data _13_procs&ad.&z.&table.&seq.; 
			length cohort_new group1 group2 cat2 $100.;
			set _13_proc_&ad.out1-_13_proc_&ad.out12;			
				if &z.=1 then cohort_new='Patients with Lp(a) in mg/dL';
				else if &z.=2 then cohort_new='Patients with Lp(a) in nmol/L';
				if &z.=1 then group2="&lpa_level1."; else group2="&lpa_level2."; 
					
				if &zz.=1 then group1="Overall";
				else if &zz.=2 then group1="Patients with the following MI, ischemic stroke, or PAD as index";
				else if &zz.=3 then group1="Patients without any MI, ischemic stroke, or PAD on index";
				else if &zz.=4 then group1="MI";
				else if &zz.=5 then group1="PAD";
				else if &zz.=6 then group1="Ischemic Stroke";
				else if &zz.=7 then group1="Transient Ischemic Attack (TIA)";
				else if &zz.=8 then group1="Unstable Angina";
				else if &zz.=9 then group1="Stable Angina";
				else if &zz.=10 then group1="Post-revascularization";
				else if &zz=11 then group1="Percutaneous coronary intervention (PCI)";
				else if &zz=12 then group1="Coronary artery bypass grafting (CABG)";
				else if &zz=13 then group1="Angioplasty and/or stent placement";
				else if &zz=14 then group1="Endarterectomy";
				else if &zz=15 then group1="Thrombectomy";
				else if &zz.=16 then group1="Other";
				if cat2='angio_stent_cnt' then cat2='angio_stent';
				else if cat2='cabg_cnt' then cat2='cabg';
				else if cat2='endar_cnt' then cat2='endar';
				else if cat2='pci_cnt' then cat2='pci';
				else if cat2='throm_cnt' then cat2='throm';
				else if cat2='aphe_cnt' then cat2='aphe';
				else if cat2='dial_cnt' then cat2='dial';
				else if cat2='angio_cnt' then cat2='angio';
				else if cat2='stent_cnt' then cat2='stent';
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

data _13_procs&table.; 
		set 	WORK._13_procsoverall1&table.1- WORK._13_procsoverall1&table.11
				WORK._13_procsoverall2&table.1 - WORK._13_procsoverall2&table.11
				
				;
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



%year(one_year, one_year, years=one_year=1);
%year(two_years,two_years, years=two_years=1);
%year(all, all, years=b.patid is not null);


ods csv file="/home/dingyig/proj/NOV-27/Output/_13_procs_one_year.csv";
proc print data=	_13_procsone_year ;
run;	
ods csv close;

ods csv file="/home/dingyig/proj/NOV-27/Output/_13_procs_two_years.csv";
proc print data=	_13_procstwo_years noobs;
run;	
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Output/_13_procs_all.csv";
proc print data=	_13_procsall noobs;
run;	
ods csv close;
