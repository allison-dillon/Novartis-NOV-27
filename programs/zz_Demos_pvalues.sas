
%macro output(table, year, whr);

proc sql;
	create table cohort2_overall as 
	select a.*
		,case when compress(a.index_unsta_angina)='1' or compress(a.index_sta_angina)='1' or compress(a.index_revasc)='1' or compress(a.index_tia)='1' then '1' end as index_noncvd
	from    derived._05_demo2b_&table.  a
	where a.index_date_&table. is not null and &whr.
/* 	and (rslt_grp65 is not null or rslt_grp150 is not null) */
	;
quit;

ods select none;
proc univariate data =  cohort2_overall;
var cprot;
output out=outdata_65 PCTLPTS =0 to 100 by 20 PCTLPRE = P;
where rslt_grp65='<65';
run;

proc sql;
	select P0, P20, P40, P60, P80, P100 into: P0, :P20, :P40, :P60, :P80, :P100 from outdata_65;
quit;

proc univariate data =  cohort2_overall;
var cprot;
output out=outdata_150 PCTLPTS =0 to 100 by 20 PCTLPRE = P;
where rslt_grp150='>=150';
run;


proc sql;
	select P0, P20, P40, P60, P80, P100 into: P01, :P201, :P401, :P601, :P801, :P1001 from outdata_150;
quit;
ods select all;

/*demos for overall population*/
PROC SQL;
	CREATE TABLE cohort2_overall_1 as
	select 
		case when rslt_grp65 is not null and  &P0.<=cprot<&P20. then lpa
			  when rslt_grp150 is not null and  &P01.<=cprot<&P201.  then lpa end as lpa_min_p20
		,case when rslt_grp65 is not null and  &P20.<=cprot<&P40. then lpa
			  when rslt_grp150 is not null and  &P201.<=cprot<&P401. then lpa end as lpa_p20_p40
		,case when rslt_grp65 is not null and  &P40.<=cprot<&P60. then lpa 
			  when rslt_grp150 is not null and  &P401.<=cprot<&P601. then lpa end as lpa_p40_p60
		,case when rslt_grp65 is not null and  &P60.<=cprot<&P80. then lpa 
			  when rslt_grp150 is not null and  &P601.<=cprot<&P801. then lpa end as lpa_p60_p80
		,case when rslt_grp65 is not null and  &P80.<=cprot<=&P100. then lpa 
			  when rslt_grp150 is not null and  &P801.<=cprot<=&P1001. then lpa end as lpa_p80_p100
		%let vars=gdr_cd*bus*index_cvd*index_mi*index_pad*index_stroke*index_anginatia*index_unsta_angina*index_sta_angina*index_tia*index_revasc*index_other*index_noncvd
				*dial1*aphe1*revasc1*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant*no_rx;
		%do i=1 %to %sysfunc(countw(&vars.));
		%let var=%scan(&vars., &i., *);
			,case when &var. is null  or COMPRESS(&var)='.' OR  COMPRESS(&var)='0' THEN 'ZZ' else &var. end as &var.
		%end;
		,a.*
		
	FROM cohort2_overall a;
quit;

DATA cohort2_overall_2	;
	SET cohort2_overall_1 (in=a) cohort2_overall_1;
	if a then rslt_grp='ove';
	else if rslt_grp65='<65 ' then rslt_grp='LT_65 ';
	else rslt_grp='GE_150';
RUN;

%let source_dset=cohort2_overall_2;
%let output_dset=_02_demos;
%let global_options=HEADER ONECOL NOMISSING PVALS FISH STTEST MEDIANS MWUTEST; /* DEFAULTS = AUTOTYPE MISSING NOHEADER NOONECOL NOPVALS INDEPENDENT PARAMETRIC NOSMD MEANS QUARTILES RANGES */ /*ALLCHARS ALLNUMS */
%let strat_var=rslt_grp;
%let weight_var=;
%let pval_comparators=('LT_65 ' 'GE_150');

%let vars=age*gdr_cd*bus*index_cvd*index_mi*index_pad*index_stroke*index_anginatia*index_unsta_angina*index_sta_angina*index_tia*index_revasc*index_other*index_noncvd
				*dial1*aphe1*revasc1
				*af*cardiac_amy*hypertension*ckd3*ckd45*hf*valvular
				*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep	
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Loop_Diuretic*MRA*Anticoagulant*no_rx
				*lpa*ldlc*hdlc*tc*cprot*tg;
%table1_init;
%do i=1 %to %sysfunc(countw(&vars.));
%let var=%scan(&vars., &i., *);
%if &var. in (gdr_cd bus index_cvd index_mi index_pad index_stroke index_anginatia index_unsta_angina index_sta_angina index_tia index_revasc index_other index_noncvd
				 dial1 aphe1 revasc1
				 af cardiac_amy hypertension ckd3 ckd45 hf valvular
				 alzheimer anemia cancer copd cognitive dementia depression diabete mix_dyslipid hypercholest liver obesity rheumathoid sleep	
				 statin_tot PCSK9i Eze Fibrates Niacin_tot Mipomersen Tocilizumab Hormone Fibrinolytic Betablocker ACE Antiplatelet Loop_Diuretic MRA Anticoagulant no_rx)
%then %do;  %table1_row(&var., C, &var.); %end;
%else %if &var. in (age ldlc hdlc tc cprot tg) 
%then %do; %table1_row(&var., N, &var.); %end;
%else %if &var. in (lpa) 
%then %do; %table1_row(&var., N MEDIANS MWUTEST, &var.); %end;
%end;

DATA _02_demos1;
	SET _02_demos;
	IF p1_test='NA' THEN p1_val=' ';
RUN;

PROC PRINT DATA=_02_demos1;
WHERE trim(value) NOT LIKE  'Z%';
VAR var value ove_1 LT_65_1 GE_150_1	p1_test	p1_val;
RUN;

%mend;

%output(overall, one_year, whr=one_year=1);
%output(mi, one_year, whr=one_year=1);
%output(pad, one_year, whr=one_year=1);
%output(stroke, one_year, whr=one_year=1);

%output(overall, overall, whr=1);
%output(mi, overall, whr=1);
%output(pad, overall, whr=1);
%output(stroke, overall, whr=1);
/*  */