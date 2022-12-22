/*cohort 1*/
%macro bringsas;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);

data derived.ldlc_05_index_dx_&ad.;
	set heor.ldlc_05_index_dx_&ad.;
	drop 
run;
%end;

%mend;
%bringsas

%macro demos;

%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);	
options mprint;
* modify variables;
%macro rev_demo;
	data ldlc_05_index_dx_&ad.;
		set derived.ldlc_05_index_dx_&ad.;
		%let vars=ascvd*index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm*index_other
						;
	
			%do j=1 %to %sysfunc(countw(&vars., *));
			%let char = %scan(&vars., &j., *);
		
			format &char._pre $3.;
			&char._pre=&char.;
			drop &char.;
			rename &char._pre=&char.;
		%end;

	run;
	

%mend rev_demo;
%rev_demo;

* Demo table cohort 1;
/* index_throm	index_cabg	index_endar	index_pci	index_angio_stent	index_other */
PROC SQL;
	CREATE TABLE _05_demo1b_&ad. AS 
	SELECT a.*, b.rslt_grp30, b.rslt_grp50, b.rslt_grp, b.rslt_grp70, b.rslt_grp90, b.rslt_grp120, b.rslt_grp150, b.rslt_nbr as lpa 
	, '1' as overall
	FROM  ldlc_05_index_dx_&ad. a inner join derived._02_primary_1 b
		on a.patid=b.patid
	;
QUIT;

%end;
%mend;
%demos;

options mprint;
%macro output(seq, subgroup, whr);
	%let ad_groups=overall*mi*pad*stroke*tia*unsta_angina*sta_angina*revasc*pci*cabg*angio_stent*endar*throm*other;
	%do ad=1 %to 14;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
proc sql;
	create table cohort1_&ad_group. as 
	select *
	from _05_demo1b_&ad_group.
	where index_date_&ad_group. is not null
	;
quit;


%table1(cohort= cohort1_&ad_group.
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= 
				index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm*index_other
			
			, hide_headspace= dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
	
			, hide_missing= age*age_grp*gdr_cd*region*bus*index_yr*index_mi*index_pad*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				
				
	
		, combine_cols=
		, pvalues=
		, strat_whr0= &whr.;

	
	);
		
	data _02_cohort1&ad_group.&seq;
	length cat1 cat2 $45.;
		set _05_sub_tb;
		if &ad.=1. then cat1="Overall";
		else if &ad.=2 then cat1="Myocardial Infarcation";
		else if &ad.=3 then cat1="Peripheral artery disease (PAD)";
		else if &ad.=4 then cat1="Ischemic Stroke";
		else if &ad.=5 then cat1="Transient Ischemic Attack (TIA)";
		else if &ad.=6 then cat1="Unstable Angina";
		else if &ad.=7 then cat1="Stable Angina";
		else if &ad.=8 then cat1="Post-revascularization";
		else if &ad=9 then cat1="Percutaneous coronary intervention (PCI)";
		else if &ad=10  then cat1="Coronary artery bypass grafting (CABG)";
		else if &ad=11 then cat1="Angioplasty and/or stent placement";
		else if &ad=12 then cat1="Endarterectomy";
		else if &ad=13 then cat1="Thrombectomy";
		else if &ad.=14 then cat1="Other";
		cat2="&subgroup.";
	run;
	%end;
	

	
%mend output;

%output(1, overall,  whr= 1);
%output(2, <30 mg/dL ,  whr= rslt_grp30='<30 ');
%output(3, <50 mg/dL,whr= rslt_grp50='<50 ');
%output(4, 30-<50 mg/dL, whr= rslt_grp='1. >=30 - <50');
%output(5, 50-<70 mg/dL, whr= rslt_grp='2. >=50 - <70');
%output(6, 70-<90 mg/dL, whr= rslt_grp='3. >=70 - <90');
%output(7, 90-<120 mg/dL, whr= rslt_grp='4. >=90 - <120');
%output(8, ≥70 mg/dL, whr= rslt_grp70='>=70 ');
%output(9, ≥90 mg/dL, whr= rslt_grp90='>=90 ' );
%output(10, ≥120 mg/dL,  whr= rslt_grp120='>=120');
%output(11, ≥150 mg/dL, whr= rslt_grp150='>=150' );

data _05_demos;
	set _02_cohort1overall1-_02_cohort1overall11
		_02_cohort1mi1-_02_cohort1mi11
		_02_cohort1pad1-_02_cohort1pad11
		_02_cohort1stroke1-_02_cohort1stroke11
		_02_cohort1unsta_angina1-_02_cohort1unsta_angina11
		_02_cohort1sta_angina1-_02_cohort1sta_angina11
		_02_cohort1tia1-_02_cohort1tia11
		_02_cohort1other1-_02_cohort1other11
		_02_cohort1revasc1-_02_cohort1revasc11
		_02_cohort1throm1-_02_cohort1throm11
		_02_cohort1cabg1-_02_cohort1cabg11
		_02_cohort1endar1-_02_cohort1endar11
		_02_cohort1pci1 -_02_cohort1pci11
		_02_cohort1angio_stent1-_02_cohort1angio_stent11;
run;

ods csv file="/home/dingyig/proj/ASCVD_1/cohort1_index.csv";
proc print data=	_05_demos noobs;
run;	
ods csv close;


/*cohort 2*/
%macro bringsas;
%let groups=overall;
		%do i=1 %to 1;
		%let ad = %scan(&groups., &i., *);

data derived.ldlc_05_index_dx_&ad.2;
	set heor.ldlc_05_index_dx_&ad.2;
	
run;
%end;

%mend;
%bringsas;

%macro demos;

%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);	
options mprint;
* modify variables;
%macro rev_demo;
	data ldlc_05_index_dx_&ad.2;
		set derived.ldlc_05_index_dx_&ad.2;
		%let vars=ascvd*index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm*index_other
						;
	
			%do j=1 %to %sysfunc(countw(&vars., *));
			%let char = %scan(&vars., &j., *);
		
			format &char._pre $3.;
			&char._pre=&char.;
			drop &char.;
			rename &char._pre=&char.;
		%end;

	run;
	

%mend rev_demo;
%rev_demo;

* Demo table cohort 1;
/* index_throm	index_cabg	index_endar	index_pci	index_angio_stent	index_other */
PROC SQL;
	CREATE TABLE _05_demo2b_&ad.2 AS 
	SELECT a.*, b.RSLT_NBR as Lpa, 	b.rslt_grp65, b.rslt_grp105, b.rslt_grp, b.rslt_grp150, b.rslt_grp190, b.rslt_grp255, b.rslt_grp320
	, '1' as overall
	FROM  ldlc_05_index_dx_&ad.2 a inner join derived._02_primary_2 b
		on a.patid=b.patid
	;
QUIT;

%end;
%mend;
%demos;


options mprint;
%macro output(seq, subgroup, whr);
	%let ad_groups=overall*mi*pad*stroke*tia*unsta_angina*sta_angina*revasc*pci*cabg*angio_stent*endar*throm*other;
	%do ad=1 %to 14;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
proc sql;
	create table cohort2_&ad_group. as 
	select *
	from   _05_demo2b_&ad_group.2
	where index_date_&ad_group. is not null
	;
quit;


%table1(cohort= cohort2_&ad_group.
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= 
				index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm*index_other
			
			, hide_headspace= dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
	
			, hide_missing= age*age_grp*gdr_cd*region*bus*index_yr*index_mi*index_pad*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				
				
	
		, combine_cols=
		, pvalues=
		, strat_whr0= &whr.;

	
	);
		
	data _02_cohort2&ad_group.&seq;
	length cat1 cat2 $45.;
		set _05_sub_tb;
		if &ad.=1. then cat1="Overall";
		else if &ad.=2 then cat1="Myocardial Infarction";
		else if &ad.=3 then cat1="Peripheral artery disease (PAD)";
		else if &ad.=4 then cat1="Ischemic Stroke";
		else if &ad.=5 then cat1="Transient Ischemic Attack (TIA)";
		else if &ad.=6 then cat1="Unstable Angina";
		else if &ad.=7 then cat1="Stable Angina";
		else if &ad.=8 then cat1="Post-revascularization";
		else if &ad=9 then cat1="Percutaneous coronary intervention (PCI)";
		else if &ad=10  then cat1="Coronary artery bypass grafting (CABG)";
		else if &ad=11 then cat1="Angioplasty and/or stent placement";
		else if &ad=12 then cat1="Endarterectomy";
		else if &ad=13 then cat1="Thrombectomy";
		else if &ad.=14 then cat1="Other";
		cat2="&subgroup.";
	run;
	%end;
	

	
%mend output;

%output(1, overall,  whr= '1');
%output(2, <65 nmol/L ,  whr= rslt_grp65='<65 ');
%output(3, <105 nmol/L,whr= rslt_grp105='<105 ');
%output(4, 65-<105 nmol/L, whr= rslt_grp='1. >=65 - <105');
%output(5, 105-<150 nmol/L, whr= rslt_grp='2. >=105 - <150');
%output(6, 150-<190 nmol/L, whr= rslt_grp='3. >=150 - <190');
%output(7, 190-<255 nmol/L, whr= rslt_grp='4. >=190 - <255');
%output(8, ≥150 nmol/L, whr= rslt_grp150='>=150 ');
%output(9, ≥190 nmol/L, whr= rslt_grp190='>=190 ' );
%output(10, ≥255 nmol/L,  whr= rslt_grp255='>=255');
%output(11, ≥320 nmol/L, whr= rslt_grp320='>=320' );


data _05_demos_2;
	set _02_cohort2overall1-_02_cohort2overall11
		_02_cohort2mi1-_02_cohort2mi11
		_02_cohort2pad1-_02_cohort2pad11
		_02_cohort2stroke1-_02_cohort2stroke11
		_02_cohort2unsta_angina1-_02_cohort2unsta_angina11
		_02_cohort2sta_angina1-_02_cohort2sta_angina11
		_02_cohort2tia1-_02_cohort2tia11
		_02_cohort2other1-_02_cohort2other11
		_02_cohort2revasc1-_02_cohort2revasc11
		_02_cohort2throm1-_02_cohort2throm11
		_02_cohort2cabg1-_02_cohort2cabg11
		_02_cohort2endar1-_02_cohort2endar11
		_02_cohort2pci1 -_02_cohort2pci11
		_02_cohort2angio_stent1-_02_cohort2angio_stent11;
run;
ods csv file="/home/dingyig/proj/ASCVD_1/cohort2_index.csv";
proc print data=	_05_demos_2 noobs;
run;	
ods csv close;

