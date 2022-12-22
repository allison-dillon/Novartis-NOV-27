/*Secondary objective 2 setup*/

/* Lab test
Blood pressure 
	Systolic blood pressure
	Diastolic blood pressure
Low-density lipoprotein cholesterol (LDL-C)
Very Low-Density Lipoprotein Cholesterol (VLDL-C)
High-density lipoprotein cholesterol (HDL-C)
	Non-HDL-C
Total cholesterol (TC)
Triglycerides (TGs)
Lipoprotein a (Lp[a]) in mg/dL and nmol/L 
Apolipoprotein B (Apo-B)
Hemoglobin A1c (HbA1c) for overall and patients with diabetes
Alkaline transferase (ALT)
Aspartate transferase (AST)
Alkaline phosphatase (ALP)
Creatine kinase 

Lab name - Normal range
LDL-C: mg/dL - 100-129 mg/dL 
HDL-C: mg/dL - 40-50 mg/dL 
Total cholesterol: mg/dL - <200 and 239 mg/dL
High-sensitivity C-reactive Protein: mg/L - 0.5 to 10 mg/L
Triglycerides: mg/dL - <150 mg/dL */

%create(_04_cohort_setup)
	select patid, min(coalesce(index_date_overall,index_date_other)) as index_date_overall,  min(eligeff) as eligeff, max(eligend) as eligend
	FROM (
		select *
		from dingyig._01_cohort_6a
		union select *
		from dingyig._01_cohort_6b
	) a
	group by patid
%create(_04_cohort_setup);

%let sys_bp=%str('11378-7','20185-5','20186-3','8450-9','8451-7','8452-5','8459-0','8460-8','8461-6','8479-8','8480-6','8481-4','8482-2','8483-0','8484-8','8485-5','8486-3','8487-1'
				,'8488-9','8489-7','8490-5','8491-3','8492-1','8493-9','8494-7','8495-4');
%let dia_bp=%str('8462-4','11377-9','20184-8','8453-3','8454-1','8455-8','8463-2','8464-0','8465-7','8466-5','8467-3','8468-1','8469-9','8470-7','8471-5','8472-3','8473-1','8474-9'
				,'8475-6','8476-4','8477-2','8446-7','8447-5');
%let ldlc = %str('13457-7','18262-6','2089-1','22748-8','35198-1','39469-2','49026-8','49027-6','56136-5','56137-3','56138-1','56139-9','69419-0'
				,'91105-7','91106-5','91107-3','91108-1','91109-9','91110-7','91111-5','91112-3','91113-1','91114-9','91115-6','91116-4','91117-2','91118-0');
%let vldlc = %str('13458-5','2091-7','25371-6','48618-3','49133-2','66126-4');				
%let hdlc = %str('12772-0','14646-4','18263-4','2085-9','35197-3','49130-8');
%let tc = %str('2082-6','74432-6','35200-5','2093-3','48620-9');
%let tg = %str('12951-0','14927-8','35217-9','2571-8');
%let lpa_mg = %str('10835-7');
%let lpa_mol = %str('43583-4');
%let apob = %str('1873-9','1872-1','1871-3','1884-6','76482-9');
%let hba1c = %str('86910-7','17855-8','17856-6','4548-4','4549-2','62388-4','41995-2','55454-3');
%let alt = %str('16324-6','1741-8','1742-6','1743-4','1744-2','25302-1','50168-4','54491-6','54492-4','76625-3','77144-4');
%let ast = %str('14409-7','14410-5','14411-3','14412-1','14413-9','14414-7','16412-9','1917-4','1918-2','1919-0','1920-8');
%let alp = %str('12805-8','12806-6','13874-3','13875-0','14588-8','15148-0','16182-8','16337-8','1775-6','1776-4','1777-2','1778-0'
				,'1779-8','1780-6','1781-4','1782-2','1783-0','17838-4','20426-3','29639-2','32135-6','32351-9','32352-7','33063-9'
				,'33421-9','40410-3','49243-9','54907-1','55971-6','59164-4','59188-3','6768-6','71365-1','71366-9','71367-7','77141-0');
%let ck = %str('13969-1','16688-4','2151-9','2152-7','2153-5','2154-3','2155-0','2156-8','2157-6','32673-6','49551-5','51505-6','51506-4','51507-2','53433-9','83092-7');
%let cprot= %str('30522-7','76486-0');

%macro labsetup;
	%create(ldlc_04_lab)
		%do t=1 %to 16;
			%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &t., *);
			select distinct a.patid, "&lab." as grp, a.loinc_cd, a.fst_dt, a.RSLT_UNIT_NM, a.RSLT_NBR
			from (select * 
					from src_optum_claims_panther.dod_lr 
					where loinc_cd in (&&&lab.) 
						/*for blood pressure, all measures without units are good to go*/
						%if &t. >= 3 and &t. <= 8 %then %do; /*ldlc*vldlc*hdlc*tc*tg*lpa_mg*/
							and (RSLT_UNIT_NM in ('MG/DL','mg/dL','mg/dl','mg/dL','MG/DL','mg/dl','mg/DL','mg/Dl','mg/dL (calc)','MG/DL (CALC)','mg/dL F11.23','mg/dLmg/dLL','mg-dL','milligram per deci')
								or lower(RSLT_UNIT_NM)='mg/dl' or lower(RSLT_UNIT_NM) like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dL%')
						%end;		
						%if &t. = 9 %then %do; /*lpa_mol*/
							and RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
						%end;
						%if &t. = 10 %then %do; /*apob*/
							and (RSLT_UNIT_NM in ('MG/DL','mg/dL','mg/dl','mg/dL','MG/DL','mg/dl','mg/DL','mg/Dl','mg/dL (calc)','MG/DL (CALC)','mg/dL F11.23','mg/dLmg/dLL','mg-dL','milligram per deci')
								or lower(RSLT_UNIT_NM)='mg/dl' or lower(RSLT_UNIT_NM) like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dL%')
						%end;						
						%if &t. = 11 %then %do; /*hba1c*/
							and RSLT_UNIT_NM in ('%','% OF TOTAL HGB','PERCENT','% TOTAL HGB','% A1c','% tl hgb','%%L','% of total H','% HGB','%HB','%hgb','% OF TOTAL','% OF T','%HbA1c'
												,'percentage','% of total hgb','%STD HBA1C','%Std HbA1c','%STD/HBA1C')
						%end;						
						%if &t. >= 12 and &t. <= 14 %then %do; /*alt*ast*alp*/
							and (RSLT_UNIT_NM in ('U/L','u/L','UNITS','UNIT/L','u/l','IU/LIU/LL','L','Units/L','IUnit/L','U/l','iu/l') or lower(RSLT_UNIT_NM) like '%u/l%')
						%end;						
						%if &t. = 15 %then %do; /*ck*/
							and (RSLT_UNIT_NM in ('U/L','ng/mL','NG/ML','ng/ml','UNITS','Units/L','UNIT/L','u/L','L','IUnit/L','u/l','U/l') or lower(RSLT_UNIT_NM) like '%u/l%')
						%end;
						%if &t. = 16 %then %do; /*c protein*/
							and (RSLT_UNIT_NM in ('mg/L','MG/L','mg/dL'))
						%end;	
			) as a inner join dingyig._04_cohort_setup as b
			on a.patid=b.patid
			%if &t. < 16 %then %do; union %end;
		%end;
	%create(ldlc_04_lab)
	
	%create(ldlc_04_lab1)
		select a.patid, a.grp, a.loinc_cd, a.fst_dt
				,case when grp='cprot' and rslt_unit_nm='mg/dL' then 'mg/L' else rslt_unit_nm end as rslt_unit_nm
				,case when grp='cprot' and rslt_unit_nm='mg/dL' then rslt_nbr*10 else rslt_nbr end as rslt_nbr
		from dingyig.ldlc_04_lab a
	%create(ldlc_04_lab1);
	
	%create(ldlc_04_lab2)
		select a.*
		from dingyig.ldlc_04_lab1 a inner join dingyig._04_cohort_setup b
			on a.patid=b.patid and b.index_date_overall<a.fst_dt and a.fst_dt<=b.eligend
	%create(ldlc_04_lab2);

%mend labsetup;
%labsetup;


/* %select */
/* 	select RSLT_UNIT_NM, count(patid) as pats */
/* 	from src_optum_claims_panther.dod_lr  */
/* 	where loinc_cd in (&cprot.) */
/* 	group by RSLT_UNIT_NM */
/* 	order by count(patid) desc */
/* %select */
/*  */
/* %select */
/* 	select RSLT_UNIT_NM, count(patid) as pats */
/* 	from dingyig.ldlc_04_lab */
/* 	where grp='cprot' */
/* 	group by RSLT_UNIT_NM */
/* 	order by count(patid) desc */
/* %select */

/* Comorbidities
Cardiovascular Comorbidities (recorded any time prior and up to index date):
	Atrial fibrillation (chronic/permanent, persistent and paroxysmal)
	Hypertension
	Valvular heart disease
	Aortic valve stenosis
	Mitral regurgitation
	Aortic valve regurgitation
	Heart failure

Other Comorbidities (chronic comorbidities recorded any time prior and up to index date, acute comorbidities recorded within the 6 months prior to index date):
Chronic:
	Alzheimer disease
	Cancer
	Chronic kidney disease (stage II, IIIa, IIIb, stage IV-V)
	Chronic obstructive pulmonary disease
	Cognitive impairment
	Dementia
	Depression/mental disorder
	Diabetes mellitus
	Liver disease
	Mixed dyslipidemias
	Renovascular hypertension
	Rheumatoid arthritis
	Sleep apnea
Acute:
	Anemia
	Obesity 
	
Sedentarism
Smoking status
*/

* CV comorbidities - 7;
%let af = %str('42731','I480','I481','I482','I4891');
%let cardiac_amy=%str('2773','E85');
%let hypertension = %str('401','402','403','404','405','I10','I11','I12','I13','I15','I16');
%let ckd = %str('585','5851','5852','5853','5854','5855','5856','5859','403','N18','N181','N182','N183','N184','N185','N186','N189','I120');
%let ckd2 = %str('5852','N182');
%let ckd3 = %str('5853','N183');
%let ckd45 = %str('5854','5855','5856','N184','N185','N186','I120');
%let hf = %str('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493','428','4280','4281','4282','42820','42821','42822'
				,'42823','4283','42830','42831','42832','42833','4284','42840','42841','42842','42843','4289','I0981','I110','I130','I132','I50'
				,'I501','I502','I5020','I5021','I5022','I5023','I503','I5030','I5031','I5032','I5033','I504','I5040','I5041','I5042','I5043','I508'
				,'I5081','I50810','I50811','I50812','I50813','I50814','I5082','I5083','I5084','I5089','I509');

/* %let valvular = %str('4240','4241','4242','4243','I34','I35','I36','I37'); */
/*  */
/* %let valve_stenosis = %str('I350'); */
/* %let mitral_regurgitation = %str('I340'); */
/* %let valve_regurgitation = %str('I351'); */
/* 		 */
* excluded specific code;
%let ex_af = %str('NA');
%let ex_hypertension = %str('NA');
%let ex_valvular = %str('NA');
%let ex_valve_stenosis = %str('NA');
%let ex_mitral_regurgitation = %str('NA');
%let ex_valve_regurgitation = %str('NA');
%let ex_hf = %str('NA');
				
* other comorbidities - 18;
%let alzheimer = %str('3310','G30');
%let anemia = %str('280','281','282','283','284','285','D50','D51','D52','D53','D55','D56','D57','D58','D59','D60','D61','D62','D63','D64');
%let cancer = %str('140','141','142','143','144','145','146','147','148','149','150','151','152','153','154','155','156','157','158','159','160'
				,'161','162','163','164','165','170','171','172','173','174','175','176','179','180','181','182','183','184','185','186','187'
				,'188','189','190','191','192','193','194','195','196','197','198','199','200','201','202','203','204','205','206','207','208'
				,'209','C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19'
				,'C20','C21','C22','C23','C24','C25','C26','C30','C31','C32','C33','C34','C35','C36','C37','C38','C39','C40','C41','C43','C44'
				,'C45','C46','C47','C48','C49','C50','C51','C52','C53','C54','C55','C56','C57','C58','C60','C61','C62','C63','C64','C65','C66'
				,'C67','C68','C69','C70','C71','C72','C73','C74','C75','C76','C77','C78','C79','C80','C7A','C7B','C81','C82','C83','C84','C85'
				,'C86','C87','C88','C89','C90','C91','C92','C93','C94','C95','C96');

%let copd = %str('490','491','492','J40','J41','J42','J43','J44');
%let cognitive = %str('33183','G3184');
%let dementia = %str('290','2941','2942','3311','3312','F01','F02','F03');
%let depression = %str('290','291','292','293','294','295','296','297','298','299','300','301','302','303','304','305','306','307','308','309'
				,'310','311','312','313','314','315','316','317','318','319','F10','F11','F12','F13','F14','F15','F16','F17','F18','F19','F20'
				,'F21','F22','F23','F24','F25','F26','F27','F28','F29','F30','F31','F32','F33','F34','F35','F36','F37','F38','F39','F40','F41'
				,'F42','F43','F44','F45','F46','F47','F48','F50','F51','F52','F53','F54','F55','F56','F57','F58','F59','F60','F61','F62','F63'
				,'F64','F65','F66','F67','F68','F69','F70','F71','F72','F73','F74','F75','F76','F77','F78','F79','F80','F81','F82','F83','F84'
				,'F85','F86','F87','F88','F89','F90','F91','F92','F93','F94','F95','F96','F97','F98','F99');
%let diabete = %str('250','E10','E11','E13','E14');
%let mix_dyslipid = %str('2722','E782');
%let hypercholest=%str('E7801');
%let liver = %str('570','571','572','573','K70','K71','K72','K73','K74','K75','K76','K77');
%let obesity = %str('278','V853','V854','V8553','V8554','E66','Z683','Z684','Z6853','Z6854');
%let rheumathoid = %str('7140','7141','7142','7148','M05','M06');
%let sleep = %str('3272','78051','78053','78057','G473');
%let valvular = %str('4241','I35','I350','I351','I352','I358','I359');

* behavior - 2;
%let seden = %str('V690','Z723');
%let smoke = %str('3051','V1582','F17','Z87891','Z720');


%macro comor;
	%create(ldlc_04_comor)
		%do i=1 %to 25;
			%let dx =%scan(af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
						*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*seden*smoke*valvular, &i., *);
			select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, a.diag as code, "&dx." as grp
			from src_optum_claims_panther.dod_diag as a
			where year(to_date(a.fst_dt)) >= 2007
				and year(to_date(a.fst_dt)) <= 2019 
				and (substr(a.diag,1,3) in (&&&dx.) 
					or substr(a.diag,1,4) in (&&&dx.) 
					or substr(a.diag,1,5) in (&&&dx.) 
					or substr(a.diag,1,6) in (&&&dx.)) 
/* 				and a.diag not in (&&&ex_&dx..)	 */
				and a.patid in (select patid from dingyig._04_cohort_setup)
			%if &i. < 25 %then %do; union %end;
		%end;	
	%create(ldlc_04_comor)
	
%mend comor;
%comor;

%let valve_proc=%str('3521','3522','02RF07Z','02RF08Z','02RF0JZ','02RF0KZ','3505','3506','02RF37H','02RF37Z','02RF38H','02RF38Z','02RF3JH','02RF3JZ','02RF3KH','02RF3KZ');

/*procedures for Aortice valve stenosis*/
%create(ldlc_04_proc)
	select a.patid, a.fst_dt as dt, 1 as valvular_proc
	from src_optum_claims_panther.dod_proc a 
		where year(to_date(a.fst_dt)) >= 2007
				and year(to_date(a.fst_dt)) <= 2019 
				and proc in (&valve_proc.)
	and a.patid in (select patid from dingyig._04_cohort_setup)
%create(ldlc_04_proc);
/*  */
/* %connDBPassThrough(dbname=dingyig,libname1=imp); */
/* 	select * from connection to imp */
/* 	(select grp, count(distinct patid) as pts  */
/* 	from _04_cohort_setup */
/* 	group by grp); */
/* quit; */

/*medications for the analysis*/
%create(ldlc_04_drugs)

			select a.patid, a.fill_dt as dt, a.ndc, b.grp
				, case when b.grp in ('Angiotensin-converting enzyme (ACE) inhibitors','Angiotensin II Receptor Blockers') then 'ACE'
					when b.grp in ('Alpha-beta-blockers','Beta-blocker') then 'Betablocker'
					when b.grp in ('Hormone replacement therapy') then 'Hormone'
					when b.grp in ('Fibrinolytic therapy') then 'Fibrinolytic'
					when b.grp in ('Loop diuretics') then 'Loop_Diuretics'
					when b.grp in ('Mineralocorticoid Receptor Antagonists (MRA)') then 'MRA'
					else b.grp end as generic
			from src_optum_claims_panther.dod_r as a inner join dingyig.optum2_drug b
				on a.ndc=b.ndc
			where year(to_date(a.fill_dt)) >= 2007
				and year(to_date(a.fill_dt)) <= 2019 
				and a.patid in (select patid from dingyig._04_cohort_setup)
%create(ldlc_04_drugs);


/*procedures post index for analysis - only populations of interest*/
%create(optum2_01_proc1)
	select a.*
	from dingyig.optum2_01_proc0 a inner join dingyig._04_cohort_setup b
		on a.patid=b.patid
	where a.dt>=b.index_date_overall
%create(optum2_01_proc1);
