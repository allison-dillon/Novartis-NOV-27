
*one-time code to retrive all diag and proc codes from marketscan database: ccae_mdcr and medicaid;
%macro all_codes;

	%connDBPassThrough(dbname=src_marketscan,libname1=imp);
	
	execute (DROP TABLE IF EXISTS heoji3.mace_01_all_dx_codes PURGE) by imp;
	execute	(CREATE table heoji3.mace_01_all_dx_codes as 				
		SELECT DISTINCT pdx as code FROM src_marketscan.ccae_mdcr_s
		UNION SELECT DISTINCT pdx as code FROM src_marketscan.medicaid_s
		%do dxn=1 %to 5;
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.ccae_mdcr_o
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.ccae_mdcr_s
		%end;
		%do dxn=1 %to 4;
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.medicaid_o
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.medicaid_s
		%end;
		%do dxn=1 %to 9;
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.ccae_mdcr_f
			UNION SELECT DISTINCT dx&dxn. as code FROM src_marketscan.ccae_mdcr_f
		%end;) by imp;
		
	
	execute (DROP TABLE IF EXISTS heoji3.mace_01_all_pc_codes PURGE) by imp;
	execute	(CREATE table heoji3.mace_01_all_pc_codes as 			
		SELECT DISTINCT pproc as code FROM src_marketscan.ccae_mdcr_s
		UNION SELECT DISTINCT pproc as code FROM src_marketscan.medicaid_s
		UNION SELECT DISTINCT proc1 as code FROM src_marketscan.ccae_mdcr_o
		UNION SELECT DISTINCT proc1 as code FROM src_marketscan.ccae_mdcr_s
	    UNION SELECT DISTINCT proc1 as code FROM src_marketscan.medicaid_o
		UNION SELECT DISTINCT proc1 as code FROM src_marketscan.medicaid_s		
		%do dxn=1 %to 6;
			UNION SELECT DISTINCT proc&dxn. as code FROM src_marketscan.ccae_mdcr_f
			UNION SELECT DISTINCT proc&dxn. as code FROM src_marketscan.medicaid_f
		%end;) by imp;
		
%mend all_codes;


*marketscan firstcut macro*;
%macro ms_firstcut(implib=, output=, databases=, cm_ver=, md_ver=, date_start=, date_end=, dx_codes=, pc_codes=, ndc_codes=, dx_dset=, pc_dset=, ndc_dset=, ndc_drugs=, total_drugn=, i_o=);
	%let final_dx_codes=;
	%let final_pc_codes=;
	
	%connDBPassThrough(dbname=src_marketscan, libname1=imp);
	%if &dx_codes. NE OR &dx_dset. NE %then %do;
		SELECT QUOTE(COMPRESS(code),"'") INTO: final_dx_codes SEPARATED BY "," from connection to imp
			(SELECT *
			FROM heoji3.mace_01_all_dx_codes
			WHERE 1=0
			%if &dx_codes. NE %then %do;
				%do len=1 %to 7;
					OR SUBSTR(code,1,&len.) IN (&dx_codes.)
				%end;
			%end;
			%if &dx_dset. NE %then %do;
				%do len=1 %to 7;
					OR SUBSTR(code,1,&len.) IN (SELECT DISTINCT code FROM &dx_dset.)
				%end;
			%end;
			ORDER BY code);
	%end;
	
	%if &pc_codes. NE OR &pc_dset. NE %then %do;
		SELECT QUOTE(COMPRESS(code),"'") INTO: final_pc_codes SEPARATED BY "," from connection to imp
			(SELECT *
			FROM heoji3.mace_01_all_pc_codes
			WHERE 1=0
			%if &pc_codes. NE %then %do;
				OR code IN (&pc_codes.)
			%end;
			%if &pc_dset. NE %then %do;
				OR code IN (SELECT DISTINCT code FROM &pc_dset.)
			%end;
			ORDER BY code);
	%end;

	%if &ndc_codes. NE OR &ndc_drugs. NE %then %do;		
			execute (DROP TABLE IF EXISTS &implib..cc_ndc_codes PURGE) by imp;
			execute (CREATE TABLE &implib..cc_ndc_codes AS
			SELECT DISTINCT *
			FROM src_marketscan.redbook where 1=0
			%if &ndc_codes. NE %then %do;
				OR ndcnum IN (&ndc_codes.)
			%end;
			%if %quote(&ndc_drugs.) NE %then %do drugn=1 %to &total_drugn.;
				%let drug=%scan(&ndc_drugs., &drugn., *);
				OR regexp_like(gennme, "&drug.", 'i')=True
				OR regexp_like(prodnme, "&drug.", 'i')=True
				OR regexp_like(thrdtds, "&drug.", 'i')=True
			%end;) by imp;
	%end;
	
		execute (DROP TABLE IF EXISTS &implib..&output. PURGE) by imp;
		execute (create table &implib..&output. as 
		%do dbn=1 %to 2;
			%let db=%scan(&databases., &dbn., *);
			%if &db. NE %then %do;
				%let tabnmin=1; 
				%let tabnmax=3;
				%if &i_o. EQ outpatient %then %let tabnmax=2;
				%else %if &i_o. EQ inpatient %then %let tabnmin=2;			
				%if &final_dx_codes. NE OR &final_pc_codes. NE %then %do tabn=&tabnmin. %to &tabnmax.;
					%let tab=%scan(o*f*s, &tabn., *);
					%let tabs=%scan(o*f*s, &tabn., *);
					%if &db. EQ medicaid %then %let dx_max=%scan(4*9*4, &tabn., *);
					%else %let dx_max=%scan(5*9*5, &tabn., *);
					%let pc_max=%scan(1*6*1, &tabn., *);
					%if &dbn. NE 1 OR &tabn. NE &tabnmin. %then UNION;				
					SELECT DISTINCT enrolid, svcdate						
						%if &tab. EQ o %then %do;
							, "O" AS i_o 
						%end;
						%else %if &tab. EQ s %then %do;
							, "I" AS i_o 
						%end;
						%else %if &tab. EQ f %then %do;
							, CASE WHEN stdplac IN (21, 27, 28, 51, 61) THEN "I" ELSE "O" END AS i_o 
						%end;
						%if &db. EQ ccae_mdcr %then %do;
							, "ccae_mdcr" AS db
						%end;
						%else %if &db. EQ medicaid %then %do;
							, "medicaid" AS db
						%end;
					FROM src_marketscan.&db._&tab. 
					WHERE (
						%if &final_dx_codes. NE %then %do dxn=1 %to &dx_max.;
							%if &dxn. NE 1 %then OR; 
							%if &dxn. EQ 1 AND &tab. EQ s %then %do;
								pdx IN (&final_dx_codes.) OR
							%end;
							dx&dxn. IN (&final_dx_codes.)
						%end;
						%if &final_pc_codes. NE %then %do pcn=1 %to &pc_max.; 
							%if &pcn. NE 1 OR &final_dx_codes. NE %then OR; 
							%if &pcn. EQ 1 AND &tab. EQ s %then %do;
								pproc IN (&final_pc_codes.) OR
							%end;
							proc&pcn. IN (&final_pc_codes.) 
						%end;
						)
						%if &date_start. NE %then %do;
							AND DATEDIFF(svcdate, CAST(&date_start. AS TIMESTAMP)) >= 0
						%end;
						%if &date_end. NE %then %do;
							AND DATEDIFF(svcdate, CAST(&date_end. AS TIMESTAMP)) <= 0
						%end;
						%if &i_o. EQ inpatient AND &tabs. EQ f %then %do;
							AND stdplac IN (21, 27, 28, 51, 61)
						%end;
						%else %if &i_o. EQ outpatient AND &tabs. EQ f %then %do;
							AND stdplac NOT IN (21, 27, 28, 51, 61)						
						%end;
				%end;
				%if &ndc_codes. NE  OR &ndc_drugs. NE %then %do;	
					%if &dbn. NE 1 OR &final_dx_codes. NE OR &final_pc_codes. NE %then UNION;
					SELECT DISTINCT a.enrolid, a.svcdate, a.ndcnum, b.prodnme, b.gennme, a.daysupp, a.metqty, "O" AS i_o 
						%if &db. EQ ccae_mdcr %then %do;
							, "ccae_mdcr" AS db
						%end;
						%else %if &db. EQ medicaid %then %do;
							, "medicaid" AS db
						%end;
					FROM src_marketscan.&db._d AS a
					INNER JOIN &implib..cc_ndc_codes AS b
					ON a.ndcnum=b.ndcnum
					WHERE 1=1
						%if &date_start. NE %then %do;
							AND DATEDIFF(a.svcdate, CAST(&date_start. AS TIMESTAMP)) >= 0
						%end;
						%if &date_end. NE %then %do;
							AND DATEDIFF(a.svcdate, CAST(&date_end. AS TIMESTAMP)) <= 0
						%end;					
				%end;
				%else %if &ndc_dset. NE %then %do;
					%if &dbn. NE 1 OR &final_dx_codes. NE OR &final_pc_codes. NE %then UNION;
					SELECT DISTINCT a.enrolid, a.svcdate, a.ndcnum, b.prodnme, b.gennme, a.daysupp, a.metqty, "O" AS i_o 
						%if &db. EQ ccae_mdcr %then %do;
							, "ccae_mdcr" AS db
						%end;
						%else %if &db. EQ medicaid %then %do;
							, "medicaid" AS db
						%end;
					FROM src_marketscan.&db._d AS a
					INNER JOIN &implib..&ndc_dset. AS b
					ON a.ndcnum=b.ndcnum
					WHERE 1=1
						%if &date_start. NE %then %do;
							AND DATEDIFF(a.svcdate, CAST(&date_start. AS TIMESTAMP)) >= 0
						%end;
						%if &date_end. NE %then %do;
							AND DATEDIFF(a.svcdate, CAST(&date_end. AS TIMESTAMP)) <= 0
						%end;					
				%end;
			%end;
		%end; ) by imp;

%mend;

*marketscan enrollment macro*;
%macro ms_enrollment(implib= /*impala schema name for which input cohort and output cohort are stored*/, 
					 cohort= /*impala table name for input cohort for which enrollment is needed*/, 
					 output= /*impala table name for output cohort*/, 
					 databases= /*impala table name:ccae_mdcr or medicaid*/, 
					 rx= /*drug coverage, 1-yes; 0-no*/, 
					 ffs= /*fee for service coverage*/, 
					 gap= /*allowed gap in days for defining continuous enrollment*/);

					 
	%connDBPassThrough(dbname=src_marketscan,libname1=imp);


	execute (DROP TABLE IF EXISTS &implib..&cohort._t PURGE) by imp;
	execute	(CREATE table &implib..&cohort._t as 				
			%do dbn=1 %to 2;
			 %let db=%scan(&databases.,&dbn.,*);
			   %if &db. NE %then %do;				
				%if &dbn. NE 1 %then UNION ALL;
	
				
				SELECT a.enrolid, a.dtstart, a.dtend, a.sex, a.dobyr, a.plantyp, a.dbname as dbname_t
					%if &db. NE medicaid %then %do;
						, a.region, CAST(NULL AS STRING) AS stdrace
					%end;					
					%if &db. EQ medicaid %then %do;
						, CAST(NULL AS STRING) AS region, a.stdrace
					%end;	
				FROM src_marketscan.&db._t AS a 
				INNER JOIN &implib..&cohort. AS b ON a.enrolid=b.enrolid
				%if &rx. EQ 1 AND &db. NE medicaid %then %do;
					WHERE a.rx = "1"
				%end;
				%else %if &rx. EQ 1 AND &db. EQ medicaid %then %do;
					WHERE a.drugcovg = "1"
				%end;
				%if &ffs. EQ 1 %then %do;
					%if &rx. EQ 1 %then AND; %else WHERE;
					a.plantyp NOT IN (4,7)
				%end;
					%end;
		%end;) by imp;

	
	execute (DROP TABLE IF EXISTS &implib..&output. PURGE) by imp;
	execute (create table &implib..&output. as 
			SELECT DISTINCT starts.enrolid, starts.dtstart AS enroll_start, ends.dtend AS enroll_end, starts.sex, starts.dobyr, starts.region, starts.plantyp, dbname_t
				FROM ( 
						SELECT enrolid, dtstart, ROW_NUMBER() OVER (ORDER BY enrolid, dtstart) AS rn, sex, dobyr, region, plantyp, dbname_t
		 				FROM ( 
								SELECT enrolid, dtstart, dtend, sex, dobyr, region, plantyp, dbname_t,
					 			CASE WHEN DATEDIFF(dtstart, prev_end) <= (&gap.+1) THEN "cont" ELSE "new" END AS start_status,
					 			CASE WHEN DATEDIFF(next_start, dtend) <= (&gap.+1) THEN "cont" ELSE "new" END AS end_status
						FROM ( 
								SELECT enrolid, dtstart, dtend, sex, dobyr, region, plantyp, dbname_t,
								COALESCE(LAG(dtend,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as prev_end,
								COALESCE(LEAD(dtstart,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as next_start
			 					FROM &implib..&cohort._t 
			 					) AS t1
							) AS t2
				 		WHERE start_status= "new"
					) AS starts,
					( 
						SELECT enrolid, dtend, ROW_NUMBER() OVER (ORDER BY enrolid, dtstart) AS rn
	 					FROM ( 
								SELECT enrolid, dtstart, dtend,
					 			CASE WHEN DATEDIFF(dtstart, prev_end) <= (&gap.+1) THEN "cont" ELSE "new" END AS start_status,
					 			CASE WHEN DATEDIFF(next_start, dtend) <= (&gap.+1) THEN "cont" ELSE "new" END AS end_status
		 				FROM ( 
								SELECT enrolid, dtstart, dtend,
								COALESCE(LAG(dtend,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as prev_end,
								COALESCE(LEAD(dtstart,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as next_start
		 						FROM &implib..&cohort._t 
		 					  ) AS t3
						) AS t4
						WHERE end_status= "new"
						) AS ends
						WHERE starts.rn = ends.rn) by imp;
%mend;


%macro ms_secondcut(implib=/*impala schema name for which output data are stored*/, 
					cohort=/*impala table name for input cohort*/, 
					databases=/*ccae_mdcr or medicaid*/, 
					skinny=/*1-create skinny data, 0-no skinny data*/,
					prefix=/*prefix for impala output table. eg._02_index_*/);
	
	%connDBPassThrough(dbname=src_marketscan,libname1=imp);
	
	execute (DROP TABLE IF EXISTS &implib..&prefix.uniq PURGE) by imp;
	execute	(create table &implib..&prefix.uniq as
			SELECT DISTINCT enrolid FROM &implib..&cohort.) by imp;
	
	%do dbn=1 %to 2;
		%let db=%scan(&databases., &dbn., *);
		%if &db. NE %then %do;
			%do tabn=1 %to 3;
				%let tab=%scan(o*s*f, &tabn., *);
				%let tabs=%scan(o*s*f, &tabn., *);
				%if &db. EQ medicaid %then %let dx_max=%scan(4*4*9, &tabn., *);
				%else %let dx_max=%scan(5*5*9, &tabn., *);
				%let pc_max=%scan(1*1*6, &tabn., *);
				
				execute (DROP TABLE IF EXISTS &implib..&prefix.&db._&tabs. PURGE) by imp;
				execute (create table &implib..&prefix.&db._&tabs. as 
					SELECT a.enrolid, a.svcdate
						%if &tab. EQ s %then %do;
							, a.pdx, a.pproc
						%end;
						%do dxn=1 %to &dx_max.; 
							, a.dx&dxn.
						%end;
						%if &db. EQ medicaid AND &tabs. NE f %then %do;
							, CAST(NULL AS STRING) AS dx5
						%end;
						%do pcn=1 %to &pc_max.; 
							, a.proc&pcn.
						%end;
						, a.sex, a.plantyp, a.dobyr, a.stdplac
						%if &db. EQ medicaid %then %do;
							, CAST(NULL AS BIGINT) AS age, CAST(NULL AS STRING) AS region
						%end;
						%else %do;
							, a.age, a.region
						%end;
						, "&db." AS _db, "&tabs." AS _table
					FROM &implib..&prefix.uniq AS b
					INNER JOIN src_marketscan.&db._&tab. AS a
					ON a.enrolid=b.enrolid) by imp;			
			
			%end;
			
			execute (DROP TABLE IF EXISTS &implib..&prefix.&db._d PURGE) by imp;
			execute (create table &implib..&prefix.&db._d as
				SELECT a.enrolid, a.svcdate, a.ndcnum
					, a.sex, a.plantyp, a.dobyr, CAST(NULL AS BIGINT) AS stdplac
					%if &db. EQ medicaid %then %do;
						, CAST(NULL AS BIGINT) AS age, CAST(NULL AS STRING) AS region
					%end;
					%else %do;
						, a.age, a.region
					%end;
					, "&db." AS _db, "d" AS _table
				FROM &implib..&prefix.uniq AS b
				INNER JOIN src_marketscan.&db._d AS a
				ON a.enrolid=b.enrolid ) by imp;
		%end;
	%end;
	
	%if &skinny. EQ 1 %then %do;
		
		execute (DROP TABLE IF EXISTS &implib..&prefix.diags PURGE) by imp;
		execute (create table &implib..&prefix.diags as 
			%do dbn=1 %to 2;
				%let db=%scan(&databases., &dbn., *);
				%if &db. NE %then %do;
					%if &dbn. NE 1 %then UNION ALL;
					SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, pdx AS diag FROM &implib..&prefix.&db._s WHERE pdx IS NOT NULL
					%do dxn=1 %to 5;
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, dx&dxn. AS diag FROM &implib..&prefix.&db._s WHERE dx&dxn. IS NOT NULL
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, dx&dxn. AS diag FROM &implib..&prefix.&db._o WHERE dx&dxn. IS NOT NULL
					%end;
					%do dxn=1 %to 9;
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, dx&dxn. AS diag FROM &implib..&prefix.&db._f WHERE dx&dxn. IS NOT NULL
					%end;
				%end;
			%end;) by imp;
		
		
		execute (DROP TABLE IF EXISTS &implib..&prefix.procs PURGE) by imp;
		execute (create table &implib..&prefix.procs as
			%do dbn=1 %to 2;
				%let db=%scan(&databases., &dbn., *);
				%if &db. NE %then %do;
					%if &dbn. NE 1 %then UNION ALL;
					SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, pproc AS proc FROM &implib..&prefix.&db._s WHERE pproc IS NOT NULL
					%do pcn=1 %to 1;
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, proc&pcn. AS proc FROM &implib..&prefix.&db._s WHERE proc&pcn. IS NOT NULL
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, proc&pcn. AS proc FROM &implib..&prefix.&db._o WHERE proc&pcn. IS NOT NULL
					%end;
					%do pcn=1 %to 6;
						UNION ALL SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, proc&pcn. AS proc FROM &implib..&prefix.&db._f WHERE proc&pcn. IS NOT NULL
					%end;
				%end;
			%end;) imp;
		
		execute (DROP TABLE IF EXISTS &implib..&prefix.meds PURGE) by imp;
		execute (create table &implib..&prefix.meds as
			%do dbn=1 %to 2;
				%let db=%scan(&databases., &dbn., *);
				%if &db. NE %then %do;
					%if &dbn. NE 1 %then UNION ALL;
					SELECT enrolid, svcdate, age, sex, region, plantyp, stdplac, ndcnum FROM &implib..&prefix.&db._d WHERE ndcnum IS NOT NULL
				%end;
			%end;) by imp;
	%end;
%mend;
