/*demographics in MACE analysis*/

%macro output(seq, subgroup, whr);
	%do z=2 %to 2;
	%let ad_groups=one_year*two_years*all;
		%do ad=1 %to 3;
			%let year = %scan(&ad_groups., &ad., *);
			%let ad_group=overall;
/*adds in most recent LDL-C 	*/	
proc sql;
		create table cohort&z._&ad_group. as 
		select a.*,
			case when c.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when c.recent_ldlc >=70 then '1' end as rslt_ge_70
			,case when c.recent_ldlc <100 then '1' end as rslt_lt_100
			,case when c.recent_ldlc >=100 then '1' end as rslt_ge_100
			,case when compress(index_unsta_angina)='1' or compress(index_sta_angina)='1' or compress(index_revasc)='1' or compress(index_tia)='1' then '1' end as index_noncvd
			,'1' as all 
		from derived._05_demo&z.b_&ad_group a inner join derived.ldlc_06 c on a.patid=c.patid
		where a.index_date_overall is not null ;
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
	FROM cohort&z._&ad_group. a inner join derived._13_mace_overall&z.&year. b on a.patid=b.patid 
	where &whr. and &year. is not null
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
		, strat_whr0= patid is not null;

	
	);

	data _02_cohort&z.&year.&seq.;
	length cat1 cat2 cat3 $100.;
		set _05_sub_tb;
		if &ad.=1. then cat1="Main ASCVD";
		if &z.=1 then cat2='Patients with Lp(a) in mg/dL';
		else if &z.=2 then cat2='Patients with Lp(a) in nmol/L';
		cat3="&year.";
	run;
	%end;
	%end;

	
%mend output;

%output(1, Overall,  whr= a.patid is not null);


data _02_final;
	set 
/* 		_02_cohort1one_year1 */
		_02_cohort2one_year1
/* 		_02_cohort1two_years1 */
		_02_cohort2two_years1
/* 		_02_cohort1all1 */
		_02_cohort2all1
	;
run;	


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_02_Demos_MACE.csv";
proc print data=	_02_final noobs;
run;	
ods csv close;

/*demos by high/low LDL-c*/
/*demographics in MACE analysis*/

%macro output1(seq, subgroup, whr);
	%do z=2 %to 2;
			%let ad_group=overall;
/*adds in most recent LDL-C 	*/	
proc sql;
		create table cohort&z._&ad_group. as 
		select a.*,
			case when c.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when c.recent_ldlc >=70 then '1' end as rslt_ge_70
			,case when c.recent_ldlc <100 then '1' end as rslt_lt_100
			,case when c.recent_ldlc >=100 then '1' end as rslt_ge_100
			,case when compress(index_unsta_angina)='1' or compress(index_sta_angina)='1' or compress(index_revasc)='1' or compress(index_tia)='1' then '1' end as index_noncvd
			,'1' as all 
		from derived._05_demo&z.b_&ad_group a inner join derived.ldlc_06 c on a.patid=c.patid
		where a.index_date_overall is not null ;
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
		, strat_whr0= patid is not null;

	
	);

	data _02_cohort&z.overall&seq.;
	length cat1 cat2 cat3 $100.;
		set _05_sub_tb;
		cat1="Main ASCVD";
		if &z.=1 then cat2='Patients with Lp(a) in mg/dL';
		else if &z.=2 then cat2='Patients with Lp(a) in nmol/L';
		cat3="&subgroup.";
	run;
	%end;
	
%mend ;

%output1(1, Overall,  whr= patid is not null);
%output1(2, <70mg/dL,  whr= rslt_lt_70='1');
%output1(3, ≥70 mg/dL, whr= rslt_ge_70='1');
%output1(4, <100mg/dL,  whr= rslt_lt_100='1');
%output1(5, ≥100 mg/dL, whr= rslt_ge_100='1');

data _02_final1;
	set 
/* 	_02_cohort1overall1-_02_cohort1overall5 */
		_02_cohort2overall1-_02_cohort2overall5
		
	;
run;	


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_02_Demos_byLDLC.csv";
proc print data=	_02_final1 noobs;
run;	
ods csv close;

/*descriptive stats for Lp(a) by Lp(a) distribution*/

%macro output(seq, grp, whrcl);
proc sql noprint; select count(distinct patid) into: pts_hosp from derived._05_demo2b_overall where index_date_overall is not null; quit;
proc means data=derived._05_demo2b_overall (where=(&whrcl. and index_date_overall is not null)) n mean stddev median min q1 q3 max noprint;
					var lpa;
					output out=_02_out mean()= STD()= median()= Q1()= Q3()= Min()= Max()= /autoname;
				run;
				
				proc sql; 
					create table _02_&seq. as  
					select "&seq." as seq, "&grp." as grp, _FREQ_, _FREQ_/&pts_hosp. as perc
						, lpa_mean as mean
						, lpa_stddev as sd
						, lpa_median as median
						, lpa_min as min
						, lpa_q1 as q1
						, lpa_q3 as q3
						, lpa_max as max  
					from _02_out;
				quit;
				
				
%mend;

%output(1, overall, whrcl=patid is not null);
%output(2, <65 nmol/L , whrcl= rslt_grp65='<65 ');
%output(3, <105 nmol/L, whrcl= rslt_grp105='<105 ');
%output(4, 65-<105 nmol/L,  whrcl= rslt_grp='1. >=65 - <105');
%output(5, 105-<150 nmol/L, whrcl= rslt_grp='2. >=105 - <150');
%output(6, 150-<190 nmol/L, whrcl= rslt_grp='3. >=150 - <190');
%output(7,  190-<255 nmol/L, whrcl= rslt_grp='4. >=190 - <255');
%output(8, ≥150 nmol/L, whrcl= rslt_grp150='>=150 ');
%output(9, ≥190 nmol/L, whrcl= rslt_grp190='>=190 ' );
%output(10, ≥255 nmol/L,  whrcl= rslt_grp255='>=255');
%output(11, ≥320 nmol/L, whrcl= rslt_grp320='>=320' );

data _02_final;
	set _02_1-_02_11;
run;

proc print data=_02_final;
run;
