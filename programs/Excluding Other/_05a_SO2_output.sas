

%macro output(seq, subgroup, whr);
	%do z=1 %to 2;
	%let ad_groups=overall;
	%do ad=1 %to 1;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
proc sql;
	create table cohort&z._&ad_group. as 
	select *
	from derived._05_demo&z.b_&ad_group.
	where index_date_&ad_group. is not null
	;
quit;


proc univariate data =  cohort&z._&ad_group.;
var cprot;
output out=outdata PCTLPTS =0 to 100 by 20 PCTLPRE = P;
run;

proc sql;
	select P0, P20, P40, P60, P80, P100 into: P0, :P20, :P40, :P60, :P80, :P100 from outdata;
quit;

PROC SQL;
	CREATE TABLE cohort&z._&ad_group._1 as
	select a.*
		,case when &P0.<=cprot<&P20. then lpa end as lpa_min_p20
		,case when &P20.<=cprot<&P40. then lpa end as lpa_p20_p40
		,case when &P40.<=cprot<&P60. then lpa end as lpa_p40_p60
		,case when &P60.<=cprot<&P80. then lpa end as lpa_p60_p80
		,case when &P80.<=cprot<=&P100. then lpa end as lpa_p80_p100
	FROM cohort&z._&ad_group. a
;
quit;

%table1(cohort= cohort1_&ad_group._1
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= age*age_grp*gdr_cd*region*bus*index_yr				
				/*index diagnosis*/
				*index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm
				/*procedure*/
				*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				/*CV comorbidities*/
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
						
				/*Cholesterol lowering treatment*/		
				*statin_tot*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant
				*statin_tot_index*Eze_index*Fibrates_index*Niacin_tot_index*Mipomersen_index*Tocilizumab_index*Hormone_index*Fibrinolytic_index*Loop_Diuretic*MRA*Anticoagulant
				*Betablocker_index*ACE_index*Antiplatelet_index
				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
			, hide_headspace= dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
	
			, hide_missing= age*age_grp*gdr_cd*region*bus*index_yr*index_mi*index_pad*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				*sameday_index*endar_index*throm_index
		
				/*procedure*/
				*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				*sameday_index*endar_index*throm_index
				/*CV comorbidities*/
				*af*hypertension*valvular*valve_stenosis*mitral_regurgitation*valve_regurgitation*hf
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*ckd1*copd*cognitive*dementia*depression*diabete*liver*mix_dyslipid*reno_hyper*obesity*rheumathoid*sleep
						
				/*Cholesterol lowering treatment*/		
				*statin_tot*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet

				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				
	
		, combine_cols=
		, pvalues=
		, strat_whr0= &whr.;

	
	);
		
	data _02_cohort1&ad_group.&seq;
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
	set _02_cohort1overall1-_02_cohort1overall11;
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
/* 		_02_cohort1angio_stent1-_02_cohort1angio_stent11; */
run;

ods csv file="/home/dingyig/proj/NOV-27/Output/cohort1_demos.csv";
proc print data=	_05_demos noobs;
run;	
ods csv close;



options mprint;
%macro output(seq, subgroup, whr);
	%let ad_groups=overall;
	%do ad=1 %to 1;
			%let ad_group = %scan(&ad_groups., &ad., *);
			
proc sql;
	create table cohort2_&ad_group. as 
	select *
	from  derived._05_demo2b_&ad_group.
	where index_date_&ad_group. is not null
	;
quit;


proc univariate data =  cohort2_&ad_group.;
var cprot;
output out=outdata PCTLPTS =0 to 100 by 20 PCTLPRE = P;
run;

proc sql;
	select P0, P20, P40, P60, P80, P100 into: P0, :P20, :P40, :P60, :P80, :P100 from outdata;
quit;

PROC SQL;
	CREATE TABLE cohort2_&ad_group._1 as
	select a.*
		,case when &P0.<=cprot<&P20. then lpa end as lpa_min_p20
		,case when &P20.<=cprot<&P40. then lpa end as lpa_p20_p40
		,case when &P40.<=cprot<&P60. then lpa end as lpa_p40_p60
		,case when &P60.<=cprot<&P80. then lpa end as lpa_p60_p80
		,case when &P80.<=cprot<=&P100. then lpa end as lpa_p80_p100
	FROM cohort2_&ad_group. a
;
quit;

%table1(cohort= cohort2_&ad_group._1
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= age*age_grp*gdr_cd*region*bus*index_yr				
				/*index diagnosis*/
				*index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm
				/*procedure*/
				*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				/*CV comorbidities*/
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
						
				/*Cholesterol lowering treatment*/		
				*statin_tot*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet
				*statin_tot_index*Eze_index*Fibrates_index*Niacin_tot_index*Mipomersen_index*Tocilizumab_index*Hormone_index*Fibrinolytic_index
				*Betablocker_index*ACE_index*Antiplatelet_index
				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
			, hide_headspace= dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
	
			, hide_missing= age*age_grp*gdr_cd*region*bus*index_yr*index_mi*index_pad*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				*sameday_index*endar_index*throm_index
		
				/*procedure*/
				*dial*aphe*pci*angio_stent*angio*stent*pci_or_angio_stent*pci_and_angio_stent*pci_angio_stent_sameday*endar*throm
				*dial1*aphe*pci1*angio_stent1*angio1*stent1*pci_or_angio_stent1*pci_and_angio_stent1*pci_angio_stent_sameday1*endar1*throm1
				*sameday_index*endar_index*throm_index
				/*CV comorbidities*/
				*af*hypertension*valvular*valve_stenosis*mitral_regurgitation*valve_regurgitation*hf
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*ckd1*copd*cognitive*dementia*depression*diabete*liver*mix_dyslipid*reno_hyper*obesity*rheumathoid*sleep
						
				/*Cholesterol lowering treatment*/		
				*statin_tot*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet

				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				
	
		, combine_cols=
		, pvalues=
		, strat_whr0= &whr.;

	
	);
		
	data _02_cohort2&ad_group.&seq;
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
	set _02_cohort2overall1-_02_cohort2overall11;
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
run;

ods csv file="/home/dingyig/proj/NOV-27/cohort2_demos.csv";
proc print data=	_05_demos_2 noobs;
run;	
ods csv close;
