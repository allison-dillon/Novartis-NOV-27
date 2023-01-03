/*Baseline characteristics by Follow Up Period for MACE populations*/

/* FOR COHORT 2*/
%macro output(seq, subgroup, whr);
	%do z=2 %to 2;
	%let ad_groups=one_year*two_years*all;
		%do ad=1 %to 3;
			%let year = %scan(&ad_groups., &ad., *);
			%let ad_group=overall;
			
	data _10_mace_&ad_group.&z.&year.;
		set derived._10_mace_&ad_group.&z.&year.;
		all=1;
	run;
			
/*matches to MACE population*/	
proc sql;
		create table cohort&z._&ad_group. as 
		select a.*			
		,case when compress(index_unsta_angina)='1' or compress(index_sta_angina)='1' or compress(index_revasc)='1' or compress(index_tia)='1' then '1' end as index_noncvd
		,'1' as all 
		from derived._05_demo&z.b_&ad_group. a inner join _10_mace_&ad_group.&z.&year. b 
		on a.patid=b.patid
		where a.index_date_overall is not null and &year.=1;
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
	where &whr.
;
quit;

%table1(cohort= cohort&z._&ad_group._1
		, output_dset= _05_sub_tb
		, cont_stats= N*MEAN*STDDEV*MEDIAN*MIN*Q1*Q3*MAX
		, autofill=
		, headspace= 1
		, vars= age*age_grp*gdr_cd*region*bus*index_yr				
				/*index diagnosis*/
				*index_cvd*index_mi*index_pad*index_stroke*index_anginatia*index_unsta_angina*index_sta_angina*index_tia*index_revasc*index_other*index_noncvd
				/*procedure*/
				*dial*aphe*revasc
				*dial1*aphe1*revasc1
				/*CV comorbidities*/
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
				
				/*Cholesterol lowering treatment*/		
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant
				*no_rx
				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
			, hide_headspace= age*age_grp*gdr_cd*region*bus*index_yr				
				/*index diagnosis*/
				*index_cvd*index_mi*index_pad*index_stroke*index_anginatia*index_unsta_angina*index_sta_angina*index_tia*index_revasc*index_other*index_noncvd
				/*procedure*/
				*dial*aphe*revasc
				*dial1*aphe1*revasc1
				/*CV comorbidities*/
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
				
				/*Cholesterol lowering treatment*/		
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant
				*no_rx
				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
			, hide_missing= age*age_grp*gdr_cd*region*bus*index_yr				
				/*index diagnosis*/
				*index_cvd*index_mi*index_pad*index_stroke*index_noncvd*index_unsta_angina*index_sta_angina*index_tia*index_revasc*index_other
				/*procedure*/
				*dial*aphe*revasc
				*dial1*aphe1*revasc1
				/*CV comorbidities*/
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				/*other chronic comorbidities*/
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
				
				/*Cholesterol lowering treatment*/		
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant
				*no_rx
				/*lab*/
				*ldlc*hdlc*tc*cprot*tg
				*lpa_min_p20*lpa_p20_p40*lpa_p40_p60*lpa_p60_p80*lpa_p80_p100
				
	
		, combine_cols=
		, pvalues=
		, strat_whr0= &whr. and gdr_cd="M"
		, strat_whr1= &whr. and gdr_cd="F"
		, strat_whr2= &whr. ;
	
	);

	data _02_cohort&z.&year.&seq.;
	length cat1 cat2 cat3 $100.;
		set _05_sub_tb;
		cat1="Main ASCVD";
		cat2="&subgroup.";
		cat3="&year.";
	run;
	%end;
	%end;
	
%mend output;

%output(1, Overall,  whr= '1');
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


data _02_final_2;
	set 
		_02_cohort2one_year1-_02_cohort2one_year11
		_02_cohort2two_years1-_02_cohort2two_years11
		_02_cohort2all1-_02_cohort2all11;
run;


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_11_Demos_byFU2.csv";
proc print data=	_02_final_2 noobs;
run;	
ods csv close;