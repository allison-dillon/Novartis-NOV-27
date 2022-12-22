/*code for Attrition*/
*Medication NDC - cholesterol-lowering treatment;
FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/NDC_list_import_updated_04Nov2020 (Ezetimibe corrected).xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=ndc;
	GETNAMES=YES;
RUN; /*4,994 obs*/
data derived.ndc;
	set ndc;
	rename group=grp;
run;
proc print data=derived.ndc;
run;

* statin procedure;
%let statin_proc = %str('4002F','4013F','0006F','G9507','G9441','G9664','G8816','G9796');

* Procedure;
FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/proc_list_import_updated_3Nov2020.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=proc_updated;
	GETNAMES=YES;
RUN;
data derived.proc_updated (drop= effdt enddt);
	set proc_updated;
	format eff_startdt eff_enddt date9.;
	eff_startdt=mdy(substr(effdt,1,2),substr(effdt,4,2),substr(effdt,7,4)); /*effective range of specific procedure code*/
	eff_enddt=mdy(substr(enddt,1,2),substr(enddt,4,2),substr(enddt,7,4));
	where proc_seq ne '';
run; /*1,131 obs*/


* Medication;
%connDBPassThrough(dbname=dingyig, libname1=imp);
execute (drop table if exists optum2_drug PURGE) by imp; 
%connDBRef(dbname=dingyig, libname=imp);  
data imp.optum2_drug; set derived.ndc; run;

* procedures;
%connDBPassThrough(dbname=dingyig, libname1=imp);
execute (drop table if exists optum2_proc PURGE) by imp; 
%connDBRef(dbname=dingyig, libname=imp);  
data imp.optum2_proc; set derived.proc_updated; run;


* Lp(a) measurements;
%connDBPassThrough(dbname=dingyig, libname1=imp);
	execute (drop table if exists dingyig.optum2_01_lpa_mg PURGE) by imp;
	execute(create table dingyig.optum2_01_lpa_mg as
		select a.*
		from dingyig.raw_00_dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from dingyig.raw_00_dod_lr as a
							where a.LOINC_CD = '10835-7'
							and a.RSLT_NBR is not null
							and (a.RSLT_UNIT_NM='MG/DL' or a.RSLT_UNIT_NM='mg/dL' or a.RSLT_UNIT_NM='mg/dl' or lower(a.RSLT_UNIT_NM)='mg/dl')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt and b.cnt=1 /*exclude multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2019 
			and a.LOINC_CD = '10835-7'
			and a.RSLT_NBR is not null
			and (a.RSLT_UNIT_NM='MG/DL' or a.RSLT_UNIT_NM='mg/dL' or a.RSLT_UNIT_NM='mg/dl' or lower(a.RSLT_UNIT_NM)='mg/dl')
			and a.RSLT_NBR > 0 /*exclude zero value*/
	) by imp;
quit;

%connDBPassThrough(dbname=dingyig, libname1=imp);
	execute (drop table if exists dingyig.optum2_01_lpa_mol PURGE) by imp;
	execute(create table dingyig.optum2_01_lpa_mol as
		select a.*
		from dingyig.raw_00_dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from dingyig.raw_00_dod_lr as a
							where a.LOINC_CD = '43583-4'
							and a.RSLT_NBR is not null
							and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt and b.cnt=1 /*exclude multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2019 
			and a.LOINC_CD = '43583-4'
			and a.RSLT_NBR is not null
			and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
			and a.RSLT_NBR > 0 /*exclude zero value*/
	) by imp;
quit;
/* patients with multiple measurements at same day: 884 */


* patients with ASCVD - excludes other;
%macro ascvd;
	%create(optum2_01_ascvd)
		%do i=1 %to 6;
			%let dxgrp =%scan(cad*cad*cad*cerebro*cerebro*pad, &i., *);
			%let dx =%scan(mi*unsta_angina*sta_angina*stroke*tia*pad, &i., *);
			select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, a.diag as code, "&dxgrp." as cat, "&dx." as grp
			from dingyig.raw_00_dod_diag as a
			where year(to_date(a.fst_dt)) >= 2008
				and year(to_date(a.fst_dt)) <= 2018 
				and a.diag in (&&&dx.) 	
			%if &i. < 6 %then %do; union %end;
		%end;
%create(optum2_01_ascvd);
%mend ascvd;
%ascvd;


* patients with CABG, PCI or stent, endarterectomy and thrombectomy;
/*for HCRU setup, procedure datafile to make it consistent procedure date using Medical table, including POS*/
*Post-revascularization (PCI, CABG, angioplasty and/or stent placement, endarterectomy, thrombectomy);
%macro proc;	
	%connDBPassThrough(dbname=dingyig, libname1=imp);
		execute (drop table if exists dingyig.optum2_01_proc0 PURGE) by imp; 
		execute(create table dingyig.optum2_01_proc0 as
		%do i=1 %to 7;
			%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm*aphe*dial, &i., *);	
		
			%if &i.=3 %then %do; /*CABG*/
				select a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.diag as code, 'icd_dx' as codetype, "&proc_nm." as grp
				from  dingyig.raw_00_dod_m as a 
						inner join (select * from  dingyig.raw_00_dod_diag 
									where (substr(diag,1,3) in (&cabg_pci_icd9.,&cabg_pci_icd10.)
											or substr(diag,1,4) in (&cabg_pci_icd9.,&cabg_pci_icd10.)
											or substr(diag,1,5) in (&cabg_pci_icd9.,&cabg_pci_icd10.)
											or substr(diag,1,6) in (&cabg_pci_icd9.,&cabg_pci_icd10.)) ) as b
				on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd=b.loc_cd
				union
			%end;
			/*Medical table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a inner join optum2_proc as b
			on a.proc_cd=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
			where (b.proc_seq= "&proc_nm." and b.codetype= 'cpt_hcpcs') /*CPT/HCPCS in Medical table*/
			union
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.drg as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a inner join optum2_proc as b
			on a.drg=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
			where (b.proc_seq= "&proc_nm." and b.codetype= 'drg') /*DRG in Medical table*/
			union
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.rvnu_cd as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a inner join optum2_proc as b
			on a.rvnu_cd=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
			where (b.proc_seq= "&proc_nm." and b.codetype= 'revcode') /*Reven code in Medical table*/
			union
			/*Procedure table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a
				inner join (select distinct a.*, b.codetype 
							from  dingyig.raw_00_dod_proc as a inner join optum2_proc as b
							on a.proc=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
							where a.icd_flag='10' and (b.proc_seq= "&proc_nm." and b.codetype= 'icd10') /*ICD-Procedure in Procedure table*/
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union	
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a
				inner join (select distinct a.*, b.codetype 
							from  dingyig.raw_00_dod_proc as a inner join optum2_proc as b
							on a.proc=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
							where a.icd_flag='9' and (b.proc_seq= "&proc_nm." and b.codetype= 'icd9') /*ICD-Procedure in Procedure table*/
/* 							%if &i. eq 1 %then %do;	 */
/* 								union */
/* 								select distinct * */
/* 								from  dingyig.raw_00_dod_proc */
/* 								where proc like "45%" or proc like "46%" or proc like "47%" or proc like "48%" or proc like "55%" or proc like "60%" /*adding angio_stent icd9 code */
/* 							%end;		 */
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union		
			/*Facility Detail table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc_cd as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a
				inner join (select distinct a.*, b.codetype
							from  dingyig.raw_00_dod_fd as a inner join optum2_proc as b
							on a.proc_cd=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
							where (b.proc_seq= "&proc_nm." and b.codetype= 'cpt_hcpcs') /*CPT/HCPCS in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
			union
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.rvnu_cd as code, b.codetype, "&proc_nm." as grp
			from  dingyig.raw_00_dod_m as a
				inner join (select distinct a.*, b.codetype
							from  dingyig.raw_00_dod_fd as a inner join optum2_proc as b
							on a.rvnu_cd=b.code and a.fst_dt between b.eff_startdt and b.eff_enddt
							where (b.proc_seq= "&proc_nm." and b.codetype= 'revcode') /*Reven code in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
			/*Confinement table*/
			%do r=1 %to 5;
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, "&proc_nm." as grp /*confinement table will be POS 98*/
				from  dingyig.raw_00_dod_c as a inner join optum2_proc as b
								on a.proc&r.=b.code and a.admit_date between b.eff_startdt and b.eff_enddt
								where a.icd_flag='10' and (b.proc_seq= "&proc_nm." and b.codetype= 'icd10') /*ICD-Procedure in Confinement table*/
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, "&proc_nm." as grp /*confinement table will be POS 98*/
				from  dingyig.raw_00_dod_c as a inner join optum2_proc as b
								on a.proc&r.=b.code and a.admit_date between b.eff_startdt and b.eff_enddt
								where a.icd_flag='9' and (b.proc_seq= "&proc_nm." and b.codetype= 'icd9') /*ICD-Procedure in Confinement table*/
			%end;
			%if &i. < 7 %then %do; union %end;
		%end; 
		) by imp;
	quit;

	

	%create(optum2_01_proc)
		select * 
		from dingyig.optum2_01_proc0 
		where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019
	%create(optum2_01_proc)
	
%mend proc;
%proc;


FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/icd9_list.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=icd9_list;
	GETNAMES=YES;
RUN; 

data derived.icd9_list;
	set icd9_list;
run;


FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/icd10_list.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=icd10_list;
	GETNAMES=YES;
RUN; 

data derived.icd10_list;
	set icd10_list;
run;


FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/2018_I10gem.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=icd_map;
	GETNAMES=YES;
RUN; 

data derived.icd_map;
	set icd_map;
run;

