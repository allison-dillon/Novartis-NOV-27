/*Number of Events model HCRU - (cohort 1 & 2) - one year*/

/*can do for one year */
/*inpatient*/
/*Unadjusted*/

/* data derived._09_outpoverall1one_year1; */
/* 	set derived._09_outpoverall1one_year; */
/* 	outp_reh_cvd=reh_cvd; */
/* 	drop reh_cvd; */
/* run; */
/* 	 */
		
%macro main;
	%do i=1 %to 2;
	%let vars=n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_other*cardio*gp;
PROC SQL;
	CREATE TABLE _08_hcru_&i. AS 
	SELECT c.patid, c.index_date_overall, a.n_hosp, a.hosp_ascvd, a.hosp_mi, a.hosp_stroke, a.hosp_pad, a.hosp_angina, a.hosp_revasc, a.hosp_other, a.icu, a.reh_cvd
					,b.n_outp, b.outp_ascvd, b.outp_mi, b.outp_stroke, b.outp_pad, b.outp_angina, b.outp_revasc, b.outp_other, b.cardio, b.gp, b.outp_reh_cvd
					, case when (&i.=2 and  c.lpa<65) OR (&i.=1 and  c.lpa<30)then 1 
					  when (&i.=2 and c.lpa>=65 and c.lpa<105) OR (&i.=1 and c.lpa>=30 and c.lpa<50) then 2
					  when (&i.=2 and  c.lpa>=105 and c.lpa<150) OR (&i.=1 and c.lpa>=50 and c.lpa<70) then 3
					  when (&i.=2 and  c.lpa>=150 and c.lpa<190) OR (&i.=1 and  c.lpa>=70 and c.lpa<90) then 4
					  when (&i.=2 and  c.lpa>=190 and c.lpa<255) OR (&i.=1 and  c.lpa>=90 and c.lpa<120) then 5
					  when (&i.=2 and  c.lpa>=255) OR (&i.=1 and  c.lpa>=120) then 6 end as lpa_grp
					,case when (&i.=2 and c.lpa<65) OR (&i.=1 and c.lpa<30)  then 1 
					  when (&i.=2 and  c.lpa>=150) or (&i.=1 and  c.lpa>=70) then 2	end as lpa_grp1	
				,case when (&i.=2 and c.lpa<65) OR (&i.=1 and c.lpa<30)  then 1 
					  when (&i.=2 and  c.lpa>=190) or (&i.=1 and  c.lpa>=90) then 2	end as lpa_grp2 
				,c.age, c.age_grp,c.gdr_cd,c.region,c.bus,c.index_yr	
				%let vars1=mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*other;
				%do q=1 %to 8;
				%let var=%scan(&vars1., &q., *);
				,datepart(c.index_date_&var.) as index_date_&var. format mmddyy10.
				,case when datepart(c.index_date_&var.)=a.index_date_overall then '1' else '.' end as index_&var.			
				%end;			
				%do t=1 %to 18;
				%let var=%scan(&vars., &t., *);
				,case when &var.>0 then '1' else '0' end as &var._grp
				%end;
				,case when compress(c.statins)='1' then '1' else '0' end as statins
				, c.diabete
	FROM derived._07_hospoverall&i.one_year a right join derived._05_demo&i.b_overall c on a.patid=c.patid
											  left join derived._09_outpoverall1one_year1 b on c.patid=b.patid
	where c.index_date_overall is not null;
QUIT;
%end;
%mend;
%main;

data _08_hcru_1a;
	set _08_hcru_1;
	if outp_ascvd>1 or outp_mi>1 or outp_stroke>1 or outp_pad >1 or outp_angina>1 or outp_other>1 or cardio>1 or gp>1 or n_outp>1 then n_outp_grp1='1';
	else n_outp_grp1=n_outp_grp;
	where lpa_grp in (1,4) and gdr_cd='M';

run;

/* proc sql; */
/* 	select lpa_grp, n_outp_grp, count(patid) */
/* 	from _08_hcru_1a */
/* 	group by lpa_grp, n_outp_grp; */
/* quit; */

/*do for each comparison group and each outcome*/
/*unadjusted model - stratified by age and adjusted by gender, statin use diabetes and index event */

ODS OUTPUT DIFFS=_08_1n_outp2;
PROC GENMOD data=_08_hcru_1a DESC;
	by gdr_cd;
	CLASS lpa_grp (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc/PARAM=GLM;
	MODEL n_outp_grp1 = lpa_grp age statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=binomial link=logit CL ;
	LSMEANS lpa_grp/ CL DIFF EXP;
RUN;


	data test;
	format _lpa_grp_new $50.;
	set _08_1n_outp2;
	where _lpa_grp=1;
	keep gdr_cd  cohort cohort_new lpa_grp lpa_grp_new _lpa_grp var ExpEstimate Lowerexp UpperExp;

	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';

	run;

ODS OUTPUT DIFFS=_08_1n_ascvd2;
PROC GENMOD data=_08_hcru_1 DESC;
	by gdr_cd;
	CLASS lpa_grp (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc/PARAM=GLM;
	MODEL outp_ascvd_grp = lpa_grp age statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=binomial link=logit CL ;
	LSMEANS lpa_grp/ CL DIFF EXP;
RUN;


	data test1;
	format _lpa_grp_new $50.;
	set _08_1n_ascvd2;
	where _lpa_grp=1;
	keep gdr_cd  cohort cohort_new lpa_grp lpa_grp_new _lpa_grp var ExpEstimate Lowerexp UpperExp;

	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';

	run;


/*only for one year*/
/*do for each comparison group and each outcome*/
%macro main;
	%let groups=lpa_grp*lpa_grp1*lpa_grp2;
	%do q=1 %to 3;
		%do i=1 %to 2;
			%let vars=n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_other*cardio*gp;
			%do z=1 %to 18;
				%let var=%scan(&vars., &z., *);

%let lpa=%scan(&groups.,&q., *);	
ODS OUTPUT DIFFS=_08_&i.&var.1;
PROC GENMOD data=_08_hcru_&i. DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var._grp = &lpa.
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

data _08_&i.&var.1;
	set _08_&i.&var.1;
	format cohort $15. cohort_new var $30.;
	cohort='One Year';
	var="&var.";
	%if &i.=1 %then cohort_new='Patients with Lp(a) in mg/dL';
	%else %if &i.=2 %then cohort_new='Patients with Lp(a) in nmol/L';;
run;
	
proc sort data=	_08_hcru_&i.;
by gdr_cd;
run;
/*do for each comparison group and each outcome*/
/*Adjusted model - stratified by age and adjusted by gender, statin use diabetes and index event */
ODS OUTPUT DIFFS=_08_&i.&var.2;
PROC GENMOD data=_08_hcru_&i. DESC;
	by gdr_cd;
	CLASS &lpa. (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc/PARAM=GLM;
	MODEL &var._grp = &lpa. age statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


data _08_&i.&var.2;
	set _08_&i.&var.2;
	format cohort $15. cohort_new var $30.;
	 cohort='One Year';
	var="&var.";
	%if &i.=1 %then cohort_new='Patients with Lp(a) in mg/dL';
	%else %if &i.=2 %then cohort_new='Patients with Lp(a) in nmol/L';;
run;

	%end;
	%end;

	data _08_model1&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
		%let var=%scan(&vars., &z., *);
	_08_&i.&var.1
	%end;
	%end; ;
	format lpa_grp_new $50.;
	keep cohort cohort_new var &lpa. lpa_grp_new _&lpa. ExpEstimate Lowerexp UpperExp;	
	where _&lpa.=1;
	%if &q.=1 %then %do;
	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥70 mg/dL or ≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 mg/dL or ≥190 nmol/L';;
	run;
	
	data _08_model2&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
			%let var=%scan(&vars., &z., *);
	_08_&i.&var.2
	%end;
	%end; ;
	keep gdr_cd  cohort cohort_new lpa_grp lpa_grp_new _lpa_grp var ExpEstimate Lowerexp UpperExp;
	format lpa_grp_new $50.;
	where _&lpa.=1;
	%if &q.=1 %then %do;
	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥70 mg/dL or ≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 mg/dL or ≥190 nmol/L';;
	run;
	%end;
%mend;
%main;

data _08_model1_final;
	set _08_model11 _08_model12 _08_model13;
	keep cohort cohort_new var lpa_grp_new ExpEstimate Lowerexp UpperExp;	
run;

proc print data=_08_model1_final;
run;

data _08_model2_final;
set _08_model21 _08_model22 _08_model23;
keep gdr_cd cohort cohort_new var lpa_grp_new ExpEstimate Lowerexp UpperExp;	
run;


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_occurence_unadjusted.csv";
proc print data=_08_model1_final;
run;
ods csv close;


ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_occurence_adjusted.csv";
proc print data=_08_model2_final;
run;
ods csv close;


/*number of events analysis*/;

%macro main;
%let groups=lpa_grp*lpa_grp1*lpa_grp2;
	%do q=1 %to 3;
		%do i=1 %to 2;
			%let vars=n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_other*cardio*gp;
			%do z=1 %to 18;
				%let var=%scan(&vars., &z., *);
				
%let lpa=%scan(&groups.,&q., *);				
ODS OUTPUT LSMEANS=_08_M&i.&var.1;
ODS OUTPUT DIFFS=_08_D&i.&var.1;
PROC GENMOD data=_08_hcru_&i. DESC;
	CLASS &lpa. (REF="1") /PARAM=GLM;
	MODEL &var. = &lpa.
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

PROC SQL;
	CREATE TABLE _08_&i.&var.1 AS 
	SELECT 'One Year' as  cohort, "&var." as var format $30. length=30, a.&lpa.
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
		, case when &i.=1 then 'Patients with Lp(a) in mg/dL' else 'Patients with Lp(a) in nmol/L' end as cohort_new
	FROM _08_M&i.&var.1 a LEFT JOIN _08_D&i.&var.1 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;

proc sort data=_08_hcru_&i.;
by gdr_cd;
run;

/*adjusted for covariates*/
ODS OUTPUT LSMEANS=_08_M&i.&var.2;
ODS OUTPUT DIFFS=_08_D&i.&var.2;
PROC GENMOD data=_08_hcru_&i. DESC;
	by gdr_cd;
	CLASS &lpa. (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc /PARAM=GLM;
	MODEL &var. = &lpa. age statins diabete  index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;


PROC SQL;
	CREATE TABLE _08_&i.&var.2 AS 
	SELECT 'One Year' as  cohort, "&var." as var format $30. length=30 , a.&lpa., a.gdr_cd
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
		, case when &i.=1 then 'Patients with Lp(a) in mg/dL' else 'Patients with Lp(a) in nmol/L' end as cohort_new
	FROM _08_M&i.&var.2 a LEFT JOIN _08_D&i.&var.2 b 
		ON a.&lpa.=b.&lpa. and a.gdr_cd=b.gdr_cd and b._&lpa.=1;
QUIT;
	

%end;
%end;
data _08_model1&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
		%let var=%scan(&vars., &z., *);
	_08_&i.&var.1
	%end;
	%end; ;
	format lpa_grp_new $15. var $30.; 
	%if &q.=1 %then %do;
	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥70 mg/dL or ≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 mg/dL or ≥190 nmol/L';;
	if &i.=1 then cohort_new='Patients with Lp(a) in mg/dL';
	else if &i.=2 then cohort_new='Patients with Lp(a) in nmol/L';
	keep cohort cohort_new var lpa_grp lpa_grp_new est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp ;	
	run;
	
	data _08_model2&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
		%let var=%scan(&vars., &z., *);
	_08_&i.&var.2
	%end;
	%end; ;
	format lpa_grp_new $50.;
	%if &q.=1 %then %do;
	if lpa_grp=1  then lpa_grp_new='<30 mg/dL or <65 nmol/L';
	else if lpa_grp=2 then lpa_grp_new='30-<50 mg/dL or 65-<105 nmol/L';
	else if lpa_grp=3 then lpa_grp_new='50-<70 mg/dL or 105-<150 nmol/L';
	else if lpa_grp=4 then lpa_grp_new='70-<90 mg/dL or 150-<190 nmol/L';
	else if lpa_grp=5 then lpa_grp_new='90-<120 mg or 190-<255 nmol/L';
	else if lpa_grp=6 then lpa_grp_new='≥120 mg/dL or ≥255 nmol/L';
	%end;
	%else %if &q.=2 %then if lpa_grp1=2 then lpa_grp_new='≥70 mg/dL or ≥150 nmol/L';
	%else %if &q.=3 %then if lpa_grp2=2 then lpa_grp_new='≥190 mg/dL or ≥190 nmol/L';;
	if &i.=1 then cohort_new='Patients with Lp(a) in mg/dL';
	else if &i.=2 then cohort_new='Patients with Lp(a) in nmol/L';
	keep gdr_cd cohort cohort_new lpa_grp lpa_grp_new var est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;
	run;
%end;
%mend;
%main;


data _08_model1_final;
	set _08_model11 _08_model12 _08_model13
		;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_num_events_unadjusted.csv";
proc print data=_08_model1_final;
run;
ods csv close;

data _08_model2_final;
set _08_model21 _08_model22 _08_model23
		;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_num_events_adjusted.csv";
proc print data=_08_model2_final;
run;
ods csv close;