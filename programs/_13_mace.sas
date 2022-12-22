
%let revasc_CPT=%str('33510','33511','33512','33513','33514','33516','33517','33518','33519','33521','33522','33523','33533','33534','33535','33536','92975','92977','92920','92921','92924','92925','92928','92929','92933','92934','92937','92938','92941','92943','92944','92973','92980','92981','92982','92984','92995','92996','C9600','C9601','C9602','C9603','C9604','C9605','C9606','C9607','C9608','G0290','G0291','S2220','4561F','4562F','C1375','C5030','C5031','C5032','C5048','33572','C5046','C5047');
%let revasc_DRG=%str('106','107','109','231','232','233','234','235','236','547','548','549','550','112','246','247','248','249','273','274','286','287','516','518','526','527');
%let PCS_10=%str('210083','210088','210089','021008C','021008F','021008W','210093','210098','210099','021009C','021009F','021009W','02100A3','02100A8','02100A9',
'02100AC','02100AF','02100AW','02100J3','02100J8','02100J9','02100JC','02100JF','02100JW','02100K3','02100K8','02100K9','02100KC','02100KF','02100KW','02100Z3',
'02100Z8','02100Z9','02100ZC','02100ZF','210483','210488','210489','021048C','021048F','021048W','210493','210498','210499','021049C','021049F','021049W',
'02104A3','02104A8','02104A9','02104AC','02104AF','02104AW','02104J3','02104J8','02104J9','02104JC','02104JF','02104JW','02104K3','02104K8','02104K9','02104KC',
'02104KF','02104KW','02104Z3','02104Z8','02104Z9','02104ZC','02104ZF','211083','211088','211089','021108C','021108F','021108W','211093','211098','211099',
'021109C','021109F','021109W','02110A3','02110A8','02110A9','02110AC','02110AF','02110AW','02110J3','02110J8','02110J9','02110JC','02110JF','02110JW','02110K3','02110K8','02110K9','02110KC','02110KF','02110KW','02110Z3','02110Z8','02110Z9','02110ZC','02110ZF','211483','211488','211489','021148C','021148F','021148W','211493','211498','211499','021149C','021149F','021149W','02114A3','02114A8','02114A9','02114AC','02114AF','02114AW','02114J3','02114J8','02114J9','02114JC','02114JF','02114JW','02114K3','02114K8','02114K9','02114KC','02114KF','02114KW','02114Z3','02114Z8','02114Z9','02114ZC','02114ZF','212083','212088','212089','021208C','021208F','021208W','212093','212098','212099','021209C','021209F','021209W','02120A3','02120A8','02120A9','02120AC','02120AF','02120AW','02120J3','02120J8','02120J9','02120JC','02120JF','02120JW','02120K3','02120K8','02120K9','02120KC','02120KF','02120KW','02120Z3','02120Z8','02120Z9','02120ZC','02120ZF','212483','212488','212489','021248C','021248F','021248W','212493','212498','212499','021249C','021249F','021249W','02124A3','02124A8','02124A9','02124AC','02124AF','02124AW','02124J3','02124J8','02124J9','02124JC','02124JF','02124JW','02124K3','02124K8','02124K9','02124KC','02124KF','02124KW','02124Z3','02124Z8','02124Z9','02124ZC','02124ZF','213083','213088','213089','021308C','021308F','021308W','213093','213098','213099','021309C','021309F','021309W','02130A3','02130A8','02130A9','02130AC','02130AF','02130AW','02130J3','02130J8','02130J9','02130JC','02130JF','02130JW','02130K3','02130K8','02130K9','02130KC','02130KF','02130KW','02130Z3','02130Z8','02130Z9','02130ZC','02130ZF','213483','213488','213489','021348C','021348F','021348W','213493','213498','213499','021349C','021349F','021349W','02134A3','02134A8','02134A9','02134AC','02134AF','02134AW','02134J3','02134J8','02134J9','02134JC','02134JF','02134JW','02134K3','02134K8','02134K9','02134KC','02134KF','02134KW','02134Z3','02134Z8','02134Z9','02134ZC','02134ZF','B212','B213','027034Z','027035Z','027036Z','027037Z','02703D6','02703DZ','02703EZ','02703F6','02703FZ','02703G6','02703GZ','02703T6','02703TZ','02703Z6','02703ZZ','027044Z','027045Z','027046Z','027047Z','02704D6','02704DZ','02704EZ','02704F6','02704FZ','02704G6','02704GZ','02704T6','02704TZ','02704Z6','02704ZZ','027134Z','027135Z','027136Z','027137Z','02713D6','02713DZ','02713EZ','02713F6','02713FZ','02713G6','02713GZ','02713T6','02713TZ','02713Z6','02713ZZ','027144Z','027145Z','027146Z','027147Z','02714D6','02714DZ','02714EZ','02714F6','02714FZ','02714G6','02714GZ','02714T6','02714TZ','02714Z6','02714ZZ','027234Z','027235Z','027236Z','027237Z','02723D6','02723DZ','02723EZ','02723F6','02723FZ','02723G6','02723GZ','02723T6','02723TZ','02723Z6','02723ZZ','027244Z','027245Z','027246Z','027247Z','02724D6','02724DZ','02724EZ','02724F6','02724FZ','02724G6','02724GZ','02724T6','02724TZ','02724Z6','02724ZZ','027334Z','027335Z','027336Z','027337Z','02733D6','02733DZ','02733EZ','02733F6','02733FZ','02733G6','02733GZ','02733T6','02733TZ','02733Z6','02733ZZ','027344Z','027345Z','027346Z','027347Z','02734D6','02734DZ','02734EZ','02734F6','02734FZ','02734G6','02734GZ','02734T6','02734TZ','02734Z6','02734ZZ','02C03Z6','02C03ZZ','02C04Z6','02C04ZZ','02C13Z6','02C13ZZ','02C14Z6','02C14ZZ','02C23Z6','02C23ZZ','02C24Z6','02C24ZZ','02C33Z6','02C33ZZ','02C34Z6','02C34ZZ','02N43ZZ','02Q43ZZ','2703000000','270346','270356','270366','270376','2704000000','270446','270456','270466','270476','2713000000','271346','271356','271366','271376','2714000000','271446','271456','271466','271476','2723000000','272346','272366','272376','2724000000','272446','272456','272466','272476','2733000000','273346','273356','273366','273376','2734000000','273446','273456','273466','273476');
%let PCS_9=%str('3610','3611','3612','3613','3614','3615','3616','3617','3619','41402','41403','41404','41405','99603','V4581','3601','3602','3605','360','3607');

/* %macro MACE; */
/* 	%create(_13_mace) */
/* 		%do i=1 %to 3; */
/* 			 */
/* 			%let dx =%scan(mi*stroke*gang, &i., *); */
/* 			select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, a.diag as code, "&dx." as grp */
/* 			from src_optum_claims_panther.dod_diag as a */
/* 			where year(to_date(a.fst_dt)) >= 2008 */
/* 				and year(to_date(a.fst_dt)) <= 2020  */
/* 				and a.diag in (&&&dx.) 	 */
/* 			%if &i. < 3 %then %do; union %end; */
/* 		%end; */
/* 	%create(_13_mace); */
/* %mend MACE; */
/* %MACE; */

/*import revasc codes for MACE*/
/* FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/Revascularization_MACE.xlsx'; */
/* PROC IMPORT DATAFILE=REFFILE replace */
/* 	DBMS=XLSX */
/* 	OUT=revasc_MACE; */
/* 	GETNAMES=YES; */
/* RUN; */
/*  */
/*  */
/* data derived.revasc_MACE; */
/* 	set revasc_MACE; */
/* run; */
/*  */
/* * revasc codes; */
/* %connDBPassThrough(dbname=dingyig, libname1=imp); */
/* execute (drop table if exists revasc_MACE PURGE) by imp;  */
/* %connDBRef(dbname=dingyig, libname=imp);   */
/* data imp.revasc_MACE; set derived.revasc_MACE; run; */


/*change to MACE procedures*/
%macro proc;	
%create(_13_MACE_proc)
		
			/*Medical table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, 'CPT/HCPCS' as codetype, "revasc" as grp, 1 as num
			from  src_optum_claims_panther.dod_m as a 
			where a.proc_cd in (&revasc_CPT.)
			UNION
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, DRG as codetype, "revasc" as grp, 1 as num
			from  src_optum_claims_panther.dod_m as a 
			where a.proc_cd in (&revasc_DRG.)
			UNION
/* 			Procedure table */
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "revasc" as grp, 1 as num
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, 'ICD-10-PCS' as codetype
							from  src_optum_claims_panther.dod_proc as a
							where a.icd_flag='10' and a.proc in (&PCS_10.)
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union	
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "revasc" as grp, 1 as num
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, 'ICD-9-PCS' as codetype
							from  src_optum_claims_panther.dod_proc as a 
							where a.icd_flag='9' and a.proc in (&PCS_9.) /*ICD-Procedure in Procedure table*/
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union		
			/*Facility Detail table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc_cd as code, b.codetype, "revasc" as grp, 1 as num
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, 'CPT/HCPCS' as codetype
							from  src_optum_claims_panther.dod_fd a
							where a.proc_cd in (&revasc_CPT.) /*CPT/HCPCS in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
						
/* 			Confinement table */
			%do r=1 %to 5;
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, 'ICD-10-PCS' as codetype, "revasc" as grp, &r. as num /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c a
								where a.icd_flag='10' and a.proc&r. in (&PCS_10.) /*ICD-Procedure in Confinement table*/
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, 'ICD-9-PCS' as codetype, "revasc" as grp, &r. as num /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c as a 
								where a.icd_flag='9' and a.proc&r. in (&PCS_9.) /*ICD-Procedure in Confinement table*/
			%end;
%create(_13_MACE_proc);

		
%mend proc;
%proc;
