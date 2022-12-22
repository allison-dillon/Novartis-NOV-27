/*p-values for HCRU meds and procedures*/


/*count number of procedures and labs in post index period*/	
options mprint;
%macro hcru_proc;
	proc sql;
	create table cohort2_overallone_year as 
	select a.patid
		, a.rslt_grp65
		, a.rslt_grp150
		, b.index_date_overall
		%let vars=dial*aphe*revasc*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet
				*statin_tot_index*pcsk9i_index*Eze_index*fibrates_index*Niacin_tot_index*mipomersen_index*tocilizumab_index*hormone_index*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index;
		%do i=1 %to %sysfunc(countw(&vars.));
		%let var=%scan(&vars., &i., *);
			,case when &var. is null  or COMPRESS(&var)='.' OR  COMPRESS(&var)='0' THEN 'ZZ' else &var. end as &var.
		%end;
	from derived._07_primary_2overall a inner join derived._13_hcru1_overall2one_year b
		on a.patid=b.patid
	where b.index_date_overall is not null and one_year is not null
	;
	quit;

	
	data HCRU_proc;
		set cohort2_overallone_year ;
		where index_date_overall is not null and (rslt_grp65 is not null or rslt_grp150 is not null );
				if rslt_grp65='<65 ' then rslt_grp='LT_65 ';
				else rslt_grp='GE_150';
		;
	run;
	
%let source_dset=HCRU_proc;
%let output_dset=HCRU_proc_pval;
%let global_options=HEADER ONECOL NOMISSING PVALS FISH STTEST MEDIANS MWUTEST; /* DEFAULTS = AUTOTYPE MISSING NOHEADER NOONECOL NOPVALS INDEPENDENT PARAMETRIC NOSMD MEANS QUARTILES RANGES */ /*ALLCHARS ALLNUMS */
%let strat_var=rslt_grp;
%let weight_var=;
%let pval_comparators=('LT_65 ' 'GE_150');

%let vars=dial*aphe*revasc
				/*medications at index*/
				*statin_tot*PCSK9i*Eze*Fibrates*Niacin_tot*Mipomersen*tocilizumab*hormone*fibrinolytic*betablocker*ace*antiplatelet
				/*medications post index*/
				*statin_tot_index*pcsk9i_index*Eze_index*fibrates_index*Niacin_tot_index*mipomersen_index*tocilizumab_index*hormone_index
				*fibrinolytic_index*betablocker_index*ace_index*antiplatelet_index;
%table1_init;
%do i=1 %to %sysfunc(countw(&vars.));
	%let var=%scan(&vars., &i., *);
	%table1_row(&var., C, &var.); 
%end;

DATA HCRU_proc_pval1;
	SET HCRU_proc_pval;
	IF p1_test='NA' THEN p1_val=' ';
RUN;

PROC PRINT DATA=HCRU_proc_pval1;
WHERE trim(value) NOT LIKE  'Z%';
VAR var value LT_65_1 GE_150_1	p1_test	p1_val;
RUN;

%mend;
%hcru_proc;
