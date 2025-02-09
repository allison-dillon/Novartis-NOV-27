
/* ODS OUTPUT DIFFS=_08a_1n_outp2; */
/* PROC GENMOD data=_08_hcru_2 DESC; */
/* 	CLASS lpa_grp (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc/PARAM=GLM; */
/* 	MODEL n_outp_grp = lpa_grp age statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc */
/* 	/ dist=binomial link=logit CL ; */
/* 	LSMEANS lpa_grp/ CL DIFF EXP; */
/* RUN; */



/*can do for one year and two years*/
/*do for each comparison group and each outcome*/
%macro main;
	%let groups=lpa_grp*lpa_grp1*lpa_grp2;
	%do q=1 %to 3;
		%do i=1 %to 2;
			%let vars=n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_other*cardio*gp;
			%do z=1 %to 18;
				%let var=%scan(&vars., &z., *);

%let lpa=%scan(&groups.,&q., *);	
ODS OUTPUT DIFFS=_08a_&i.&var.2;
PROC GENMOD data=_08_hcru_&i. DESC;
	CLASS &lpa. (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc/PARAM=GLM;
	MODEL &var._grp = &lpa. age statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=binomial link=logit CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

data _08a_&i.&var.2;
	set _08a_&i.&var.2;
	format cohort $15. cohort_new var $30.;
	cohort='One Year';
	var="&var.";
	%if &i.=1 %then cohort_new='Patients with Lp(a) in mg/dL';
	%else %if &i.=2 %then cohort_new='Patients with Lp(a) in nmol/L';;
run;
	

	%end;
	%end;
	
	data _08a_model2&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
		%let var=%scan(&vars., &z., *);
	_08a_&i.&var.2
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
	
%end;
%mend;
%main;


data _08a_model2_final;
	set _08a_model21 _08a_model22 _08a_model23
		;

run;
ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_occurence_overall_adj.csv";
proc print data=_08a_model2_final;
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
ODS OUTPUT LSMEANS=_08a_M&i.&var.2;
ODS OUTPUT DIFFS=_08a_D&i.&var.2;
PROC GENMOD data=_08_hcru_&i. DESC;
	CLASS &lpa. (REF="1") statins diabete index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc /PARAM=GLM;
	MODEL &var. = &lpa. age statins diabete  index_mi index_pad index_stroke index_unsta_angina index_sta_angina index_tia index_revasc
	/ dist=poisson link=log CL ;
	LSMEANS &lpa./ CL DIFF EXP;
RUN;

PROC SQL;
	CREATE TABLE _08_&i.&var.2 AS 
	SELECT 'One Year' as  cohort, "&var." as var format $30. length=30, a.&lpa.
		, a.expestimate as est_mean
		, a.lowerexp as lowermean
		, a.upperexp as uppermean
		, b.expestimate, b.lowerexp, b.upperexp
		, case when &i.=1 then 'Patients with Lp(a) in mg/dL' else 'Patients with Lp(a) in nmol/L' end as cohort_new
	FROM _08a_M&i.&var.2 a LEFT JOIN _08a_D&i.&var.2 b 
		ON a.&lpa.=b.&lpa. and b._&lpa.=1;
QUIT;
	
	

%end;
%end;

data _08a_model2&q.;
	set 
	%do i=1 %to 2;
		%do z=1 %to 18;
		%let var=%scan(&vars., &z., *);
	_08_&i.&var.2
	%end;
	%end; ;
	format lpa_grp_new  var $50.;
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
	keep gdr_cd cohort cohort_new lpa_grp lpa_grp_new var est_mean lowermean uppermean ExpEstimate Lowerexp UpperExp;
	run;

		
%end;
%mend;
%main;


data _08a_model2_final;
	set _08a_model21 _08a_model22 _08a_model23;
		gdr_cd='Overall';
	retain gdr_cd ExpEstimate Lowerexp UpperExp Time var lpa_grp_new ;
run;

ods csv file="/home/dingyig/proj/NOV-27/Feasibility/Output/_08_num_events_overall_adj.csv";
proc print data=_08a_model2_final;
run;
ods csv close;