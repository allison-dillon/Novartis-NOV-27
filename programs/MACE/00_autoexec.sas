libname assign '/mnt/share/sas/';
options mstored sasmstore=assign notes;
options sastrace=',,,ds' sastraceloc=saslog nostsuffix sql_ip_trace=source;

libname derived "/home/heoji3/proj/MACE";

* CPT/HCPCS;
%let statin_proc = %str('4002F','4013F','0006F','G9507','G9441','G9664','G8816','G9796');


/*
<<Atherosclerotic cardiovascular disease (ASCVD)>>
Coronary Artery disease (MI  , angina  , coronary stenosis)
Cerebrovascular disease (ischemic stroke,  transient ischemic attack [TIA])
Peripheral arterial disease (intermittent claudication, carotid stenosis, chronic limb ischemia, acute peripheral arterial occlusion, aortic atherosclerotic disease) 
*/

*Coronary Artery disease (MI  , angina  , coronary stenosis);
%let mi = %str('410','4100','41000','41001','41002','4101','41010','41011','41012','4102','41020','41021','41022','4103'
			,'41030','41031','41032','4104','41040','41041','41042','4105','41050','41051','41052','4106','41060','41061'
			,'41062','4107','41070','41071','41072','4108','41080','41081','41082','4109','41090','41091','41092','412'
			,'I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A'
			,'I21A1','I21A9','I22','I220','I221','I222','I228','I229','I252');
%let angina = %str('4111','413','4130','4133','4139','I20','I200','I201','I208','I209','I2511','I25110','I25111','I25118','I25119','I257','I2570'
					,'I25700','I25701','I25708','I25709','I2571','I25710','I25711','I25718','I25719','I2572','I25720','I25721','I25728','I25729'
					,'I2573','I25730','I25731','I25738','I25739','I2575','I25750','I25751','I25758','I25759','I2576','I25760','I25761','I25768'
					,'I25769','I2579','I25790','I25791','I25798','I25799');
%let coronary_steno = %str('4140','I251');					
					
* Cerebrovascular disease (ischemic stroke,  transient ischemic attack [TIA]);
%let stroke = %str('43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011'
			,'I63012','I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111'
			,'I63112','I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321','I63211'
			,'I63212','I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311'
			,'I63312','I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334'
			,'I63341','I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413','I63419','I6342','I63421'
			,'I63422','I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349'
			,'I635','I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531'
			,'I63532','I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359','I636','I638','I6381','I6389','I639');				
%let tia = %str('435','4350','4351','4352','4353','4358','4359','G450','G451','G452','G453','G458','G459','H340');
* cerebrovascular code was not used;

* Peripheral arterial disease (intermittent claudication, carotid stenosis, chronic limb ischemia, acute peripheral arterial occlusion, aortic atherosclerotic disease) ;
%let pad = %str('4400','4402','44020','44021','44022','44023','44024','44029','4403','44030','44031','44032','4404','4408','4409'
			,'4450','I700','I701','I70201','I70202','I70203','I70208','I70209','I70211','I70212','I70213','I70218','I70219','I70221'
			,'I70222','I70223','I70228','I70229','I70231','I70232','I70233','I70234','I70235','I70238','I70239','I70241','I70242'
			,'I70243','I70244','I70245','I70248','I70249','I7025','I70261','I70262','I70263','I70268','I70269','I70291','I70292'
			,'I70293','I70298','I70299','I70301','I70302','I70303','I70308','I70309','I70311','I70312','I70313','I70318','I70319'
			,'I70321','I70322','I70323','I70328','I70329','I70331','I70332','I70333','I70334','I70335','I70338','I70339','I70341'
			,'I70342','I70343','I70344','I70345','I70348','I70349','I7035','I70361','I70362','I70363','I70368','I70369','I70391'
			,'I70392','I70393','I70398','I70399','I70401','I70402','I70403','I70408','I70409','I70411','I70412','I70413','I70418'
			,'I70419','I70421','I70422','I70423','I70428','I70429','I70431','I70432','I70433','I70434','I70435','I70438','I70439'
			,'I70441','I70442','I70443','I70444','I70445','I70448','I70449','I7045','I70461','I70462','I70463','I70468','I70469'
			,'I70491','I70492','I70493','I70498','I70499','I70501','I70502','I70503','I70508','I70509','I70511','I70512','I70513'
			,'I70518','I70519','I70521','I70522','I70523','I70528','I70529','I70531','I70532','I70533','I70534','I70535','I70538'
			,'I70539','I70541','I70542','I70543','I70544','I70545','I70548','I70549','I7055','I70561','I70562','I70563','I70568'
			,'I70569','I70591','I70592','I70593','I70598','I70599','I70601','I70602','I70603','I70608','I70609','I70611','I70612'
			,'I70613','I70618','I70619','I70621','I70622','I70623','I70628','I70629','I70631','I70632','I70633','I70634','I70635'
			,'I70638','I70639','I70641','I70642','I70643','I70644','I70645','I70648','I70649','I7065','I70661','I70662','I70663'
			,'I70668','I70669','I70691','I70692','I70693','I70698','I70699','I70701','I70702','I70703','I70708','I70709','I70711'
			,'I70712','I70713','I70718','I70719','I70721','I70722','I70723','I70728','I70729','I70731','I70732','I70733','I70734'
			,'I70735','I70738','I70739','I70741','I70742','I70743','I70744','I70745','I70748','I70749','I7075','I70761','I70762'
			,'I70763','I70768','I70769','I70791','I70792','I70793','I70798','I70799','I708','I7090','I7091','I7092');
%let inter_clau = %str('44021','4439','I7021','I70211','I70212','I70213','I70218','I70219','I7031','I70311','I70312','I70313','I70318','I70319','I7041'
					,'I70411','I70412','I70413','I70418','I70419','I70499','I7051','I70511','I70512','I70513','I70518','I70519','I70599','I7061','I70611'
					,'I70612','I70613','I70618','I70619','I7071','I70711','I70712','I70713','I70718','I70719','I1739');
%let carotid_steno = %str('4331','I652');					
%let limb_isch = %str('45989','4599','I879','I999','I998');					
%let acute_pao = %str('4439','I739');
%let aotic = %str('4400','I700'); 

* diabetes;
%let diabete = %str('250','E10','E11','E13','E14');
* familial hypercholesterolemia (FH);
%let fh = %str(/*'2720',*/'E7801','Z8342');
* Hypercholesterolemia;
%let hyperchol = %str('2720','E780','E7800','E7801','Z8342');

*others: not used for attrition; 		
%let cerebrovascular = %str('433','4331','4332','4333','4338','4339','I65','I650','I6501','I6502','I6503','I6509','I651','I652','I6521'
					,'I6522','I6523','I6529','I658','I659','I66','I660','I6601','I6602','I6603','I6609','I661','I6611','I6612','I6613','I6619'
					,'I662','I6621','I6622','I6623','I6629','I663','I668','I669','I672','I6781','I6782');
%let chd = %str('414','I25'); /*Coronary atherosclerosis, Coronary heart disease, and Ischemic heart disease used same code, but different MI history*/
%let stent_angina_cpt = %str('61635','92928','92929','92933','92934','0075T','0076T','0084T','33621','36903','36906','36908','37205'
			,'37206','37207','37208','37215','37216','37217','37218','37221','37223','37226','37230','37231','37234','37236','37237'
			,'37238','37239','4561F','4562F','47538','47539','47540','50382','50384','50385','50386','50688','75960','92980','92981');
%let stent_angina_drg = %str('251','250','251','250','518','526','527','526','517','556','558','557','518','517','116','518','577','036','034','035');
%let stent_angina_hcpcs = %str('A7524','C1039','C1040','C1042','C1060','C1067','C1112','C1312','C1314','C1319','C1320','C1333','C1372','C1375','C1531'
			,'C1874','C1875','C2617','C2625','C5001','C5002','C5003','C5006','C5009','C5010','C5011','C5012','C5013','C5014','C5016','C5017','C5018'
			,'C5019','C5020','C5021','C5022','C5023','C5024','C5025','C5026','C5030','C5031','C5032','C5034','C5035','C5036','C5037','C5039','C5040'
			,'C5041','C5042','C5043','C5044','C5045','C5046','C5047','C5048','C5130','C5134','C5279','C5280','C5283','C5284','C8522','C8523','C8524'
			,'C8525','C8531','C8535','C8536','C8800','C8801','C8802','D5982','G6018','G6020','G6023','L7000');
%let stent_angina_icd10 = %str('03CG3Z7','03CH3Z7','03CJ3Z7','03CK3Z7','03CL3Z7','03CM3Z7','03CN3Z7','03CP3Z7','03CQ3Z7');
%let stent_angina_icd9 = %str('45','46','47','48','55','60','63','65','983','3193','360','3607');
%let silent = %str('4148','I256');

%let cabg_pci_icd9 = %str('NAAAA');			
%let cabg_pci_icd10 = %str('Z951','Z955','Z9861');


* excluded specific code;
%let ex_mi = %str('NA');
%let ex_stroke = %str('NA');
%let ex_pad = %str('I739');
%let ex_diabete = %str('NA');

%let ex_fh = %str('NA');
%let ex_hyperchol = %str('NA');

%let ex_angina = %str('I201','4131');
%let ex_cerebrovascular = %str('NA');
%let ex_chd = %str('I252','I25119','I25110','I25118','I25111','I25709','I25710','I25719','I25708','I25700','I25720','I25718','I25728','I25729'
				,'I25798','I25799','I2509','I25701','I25711','I25721','I25730','I25790','I25791'); /*Coronary atherosclerosis, Coronary heart disease, and Ischemic heart disease used same code, but different MI history*/
%let ex_pad = %str('I739');
%let ex_tia = %str('NA');

%let ex_stent_angina_cpt = %str('NA');
%let ex_stent_angina_drg = %str('NA');
%let ex_stent_angina_hcpcs = %str('NA');
%let ex_stent_angina_icd10 = %str('NA');
%let ex_stent_angina_icd9 = %str('NA');

%let ex_silent = %str('NA');
%let ex_acute_pao = %str('NA');
%let ex_limb_isch = %str('NA');
%let ex_inter_clau = %str('NA');
%let ex_carotid_steno = %str('NA');
%let ex_coronary_steno = %str('NA');
%let ex_aotic = %str('NA');

* cholesterol lowering treatment;
%let choletx = %str('Ezetimibe-Statin','Statins','PCSK9i','Ezetimibe','Fibrates','Niacin','Niacin-Statin','Bile acid sequestrants','Mipomersen','Lomitapide');




* coronary arlery related revascularization procedure;
%let revasc_proc = %str('0210083','0210088','0210089','021008C','021008F','021008W','0210093','0210098','0210099','021009C','021009F','021009W','02100A3','02100A8','02100A9','02100AC','02100AF','02100AW','02100J3','02100J8'
						,'02100J9','02100JC','02100JF','02100JW','02100K3','02100K8','02100K9','02100KC','02100KF','02100KW','02100Z3','02100Z8','02100Z9','02100ZC','02100ZF','0210483','0210488','0210489','021048C','021048F'
						,'021048W','0210493','0210498','0210499','021049C','021049F','021049W','02104A3','02104A8','02104A9','02104AC','02104AF','02104AW','02104J3','02104J8','02104J9','02104JC','02104JF','02104JW','02104K3'
						,'02104K8','02104K9','02104KC','02104KF','02104KW','02104Z3','02104Z8','02104Z9','02104ZC','02104ZF','0211083','0211088','0211089','021108C','021108F','021108W','0211093','0211098','0211099','021109C'
						,'021109F','021109W','02110A3','02110A8','02110A9','02110AC','02110AF','02110AW','02110J3','02110J8','02110J9','02110JC','02110JF','02110JW','02110K3','02110K8','02110K9','02110KC','02110KF','02110KW'
						,'02110Z3','02110Z8','02110Z9','02110ZC','02110ZF','0211483','0211488','0211489','021148C','021148F','021148W','0211493','0211498','0211499','021149C','021149F','021149W','02114A3','02114A8','02114A9'
						,'02114AC','02114AF','02114AW','02114J3','02114J8','02114J9','02114JC','02114JF','02114JW','02114K3','02114K8','02114K9','02114KC','02114KF','02114KW','02114Z3','02114Z8','02114Z9','02114ZC','02114ZF'
						,'0212083','0212088','0212089','021208C','021208F','021208W','0212093','0212098','0212099','021209C','021209F','021209W','02120A3','02120A8','02120A9','02120AC','02120AF','02120AW','02120J3','02120J8'
						,'02120J9','02120JC','02120JF','02120JW','02120K3','02120K8','02120K9','02120KC','02120KF','02120KW','02120Z3','02120Z8','02120Z9','02120ZC','02120ZF','0212483','0212488','0212489','021248C','021248F'
						,'021248W','0212493','0212498','0212499','021249C','021249F','021249W','02124A3','02124A8','02124A9','02124AC','02124AF','02124AW','02124J3','02124J8','02124J9','02124JC','02124JF','02124JW','02124K3'
						,'02124K8','02124K9','02124KC','02124KF','02124KW','02124Z3','02124Z8','02124Z9','02124ZC','02124ZF','0213083','0213088','0213089','021308C','021308F','021308W','0213093','0213098','0213099','021309C'
						,'021309F','021309W','02130A3','02130A8','02130A9','02130AC','02130AF','02130AW','02130J3','02130J8','02130J9','02130JC','02130JF','02130JW','02130K3','02130K8','02130K9','02130KC','02130KF','02130KW'
						,'02130Z3','02130Z8','02130Z9','02130ZC','02130ZF','0213483','0213488','0213489','021348C','021348F','021348W','0213493','0213498','0213499','021349C','021349F','021349W','02134A3','02134A8','02134A9'
						,'02134AC','02134AF','02134AW','02134J3','02134J8','02134J9','02134JC','02134JF','02134JW','02134K3','02134K8','02134K9','02134KC','02134KF','02134KW','02134Z3','02134Z8','02134Z9','02134ZC','02134ZF'
						,'33510','33511','33512','33513','33514','33516','33517','33518','33519','33521','33522','33523','33533','33534','33535','33536','3610','3611','3612','3613','3614','3615','3616','3617','3619','41402'
						,'41403','41404','41405','99603','B212','B213','V4581'				
						/*other coronary procedure was removed*/
/* 						,'4A033BC','92975','92977','92978','92979','93451','93452','93453','93454','93455','93456','93457','93458','93459','93460','93461','93462','93463' */
/* 						,'93464','93503','93505','93530','93531','93532','93533','93561','93562','93563','93564','93565','93566','93567','93568','93571','93572','93751','93752','B221Z2Z' */				
						,'93457','93459','93461','92975','92977'
						,'027034Z','027035Z','027036Z','027037Z'
						,'02703D6','02703DZ','02703EZ','02703F6','02703FZ','02703G6','02703GZ','02703T6','02703TZ','02703Z6','02703ZZ','027044Z','027045Z','027046Z','027047Z','02704D6','02704DZ','02704EZ','02704F6','02704FZ'
						,'02704G6','02704GZ','02704T6','02704TZ','02704Z6','02704ZZ','027134Z','027135Z','027136Z','027137Z','02713D6','02713DZ','02713EZ','02713F6','02713FZ','02713G6','02713GZ','02713T6','02713TZ','02713Z6'
						,'02713ZZ','027144Z','027145Z','027146Z','027147Z','02714D6','02714DZ','02714EZ','02714F6','02714FZ','02714G6','02714GZ','02714T6','02714TZ','02714Z6','02714ZZ','027234Z','027235Z','027236Z','027237Z'
						,'02723D6','02723DZ','02723EZ','02723F6','02723FZ','02723G6','02723GZ','02723T6','02723TZ','02723Z6','02723ZZ','027244Z','027245Z','027246Z','027247Z','02724D6','02724DZ','02724EZ','02724F6','02724FZ'
						,'02724G6','02724GZ','02724T6','02724TZ','02724Z6','02724ZZ','027334Z','027335Z','027336Z','027337Z','02733D6','02733DZ','02733EZ','02733F6','02733FZ','02733G6','02733GZ','02733T6','02733TZ','02733Z6'
						,'02733ZZ','027344Z','027345Z','027346Z','027347Z','02734D6','02734DZ','02734EZ','02734F6','02734FZ','02734G6','02734GZ','02734T6','02734TZ','02734Z6','02734ZZ','02C03Z6','02C03ZZ','02C04Z6','02C04ZZ'
						,'02C13Z6','02C13ZZ','02C14Z6','02C14ZZ','02C23Z6','02C23ZZ','02C24Z6','02C24ZZ','02C33Z6','02C33ZZ','02C34Z6','02C34ZZ','02N43ZZ','02Q43ZZ','2703000000','270346','270356','270366','270376','2704000000'
						,'270446','270456','270466','270476','2713000000','271346','271356','271366','271376','2714000000','271446','271456','271466','271476','2723000000','272346','272366','272376','2724000000','272446','272456'
						,'272466','272476','2733000000','273346','273356','273366','273376','2734000000','273446','273456','273466','273476','3601','3602','3605','92920','92921','92924','92925','92928','92929','92933','92934','92937'
						,'92938','92941','92943','92944','92973','92980','92981','92982','92984','92995','92996','C9600','C9601','C9602','C9603','C9604','C9605','C9606','C9607','C9608','G0290','G0291','S2220','C1375','C5030','C5031'
						,'C5032','C5048','33572','4561F','4562F','75963','02CQ0ZZ','02CQ4ZZ','02CR0ZZ','02CR4ZZ','03C00ZZ','03C04ZZ','03C10ZZ','03C14ZZ','03C20ZZ','03C24ZZ','03C30ZZ','03C34ZZ','03C40ZZ','03C44ZZ','03C50ZZ','03C53ZZ'
						,'03C54ZZ','03C60ZZ','03C63ZZ','03C64ZZ','03C70ZZ','03C73ZZ','03C74ZZ','03C80ZZ','03C83ZZ','03C84ZZ','03C90ZZ','03C93ZZ','03C94ZZ','03CA0ZZ','03CA3ZZ','03CA4ZZ','03CB0ZZ','03CB3ZZ','03CB4ZZ','03CC0ZZ','03CC3ZZ'
						,'03CC4ZZ','03CD0ZZ','03CD3ZZ','03CD4ZZ','03CF0ZZ','03CF3ZZ','03CF4ZZ','03CG0ZZ','03CG4ZZ','03CH0ZZ','03CH4ZZ','03CJ0ZZ','03CJ4ZZ','03CK0ZZ','03CK4ZZ','03CL0ZZ','03CL4ZZ','03CM0ZZ','03CM4ZZ','03CN0ZZ','03CN4ZZ'
						,'03CP0ZZ','03CP4ZZ','03CQ0ZZ','03CQ4ZZ','03CR0ZZ','03CR3ZZ','03CR4ZZ','03CS0ZZ','03CS3ZZ','03CS4ZZ','03CT0ZZ','03CT3ZZ','03CT4ZZ','03CU0ZZ','03CU3ZZ','03CU4ZZ','03CV0ZZ','03CV3ZZ','03CV4ZZ','03CY0ZZ','03CY3ZZ'
						,'03CY4ZZ','04C10ZZ','04C14ZZ','04C20ZZ','04C24ZZ','04C30ZZ','04C34ZZ','04C40ZZ','04C44ZZ','04C50ZZ','04C54ZZ','04C60ZZ','04C64ZZ','04C70ZZ','04C74ZZ','04C80ZZ','04C84ZZ','04C90ZZ','04C94ZZ','04CA0ZZ','04CA4ZZ'
						,'04CB0ZZ','04CB4ZZ','04CC0ZZ','04CC4ZZ','04CD0ZZ','04CD4ZZ','04CE0ZZ','04CE4ZZ','04CF0ZZ','04CF4ZZ','04CH0ZZ','04CH4ZZ','04CJ0ZZ','04CJ4ZZ','04CK0ZZ','04CK3ZZ','04CK4ZZ','04CL0ZZ','04CL3ZZ','04CL4ZZ','04CM0ZZ'
						,'04CM3ZZ','04CM4ZZ','04CN0ZZ','04CN3ZZ','04CN4ZZ','04CP0ZZ','04CP3ZZ','04CP4ZZ','04CQ0ZZ','04CQ3ZZ','04CQ4ZZ','04CR0ZZ','04CR3ZZ','04CR4ZZ','04CS0ZZ','04CS3ZZ','04CS4ZZ','04CT0ZZ','04CT3ZZ','04CT4ZZ','04CU0ZZ'
						,'04CU3ZZ','04CU4ZZ','04CV0ZZ','04CV3ZZ','04CV4ZZ','04CW0ZZ','04CW3ZZ','04CW4ZZ','04CY0ZZ','04CY3ZZ','04CY4ZZ','33572','381','3811','3812','3813','3814','3815','3816','3818','03CG3ZZ','03CG4ZZ','03CH3ZZ','03CH4ZZ'
						,'03CJ3ZZ','03CJ4ZZ','03CK3ZZ','03CK4ZZ','03CL3ZZ','03CL4ZZ','03CM3ZZ','03CM4ZZ','03CN3ZZ','03CN4ZZ','03CP3ZZ','03CP4ZZ','03CQ3ZZ','03CQ4ZZ','03CR3ZZ','03CR4ZZ','03CS3ZZ','03CS4ZZ','03CT3ZZ','03CT4ZZ','03CU3ZZ'
						,'03CU4ZZ','03CV3ZZ','03CV4ZZ','35880');

* Diabetes mellitus;
%let dm = %str('250','E10','E11','E13','E14');

* Hypertension;
%let htn = %str('401','402','403','404','405','I10','I11','I12','I13','I15','I16');

* Inflammatory disease ;
%let infl = %str('274','711','712','713','714','715','716','M05','M06','M07','M08','M10','M11','M12','M13','M14','M1A','M15','M16','M17','M18','M19','696','L40','7100','M32','340 ','G35','555','556','K50','K51','2554','2555'
				,'E271','E274','242','E05','7102','M350 ','5790','K900 ','4462','4465','4476 ','I776 ','M310','M316','7280','72881 ','72882 ','7291','M60','7200','M45','28981','D6861','7101','M34');



/*************************************************************************************************************************************************/
/*                                                                                                                                               */
/* Macro: table1                                                                                                                                 */
/* Function: Create demographics-style output table.                                                                                             */
/* Inputs: cohort -> Dataset with all necessary variables and formatted appropriately                                                            */
/*         output_dset -> Name of output dataset. Library optional.                                                                              */
/*         cont_stats -> List all desired statistics for continuous variables separated by asterisk.                                             */
/*         autofill -> Set equal to 1 to enable. Automatically fills out the header names for some variables.  Current list includes:            */
/*                     sex, region, plantyp.                                                                                                     */
/*         headspace -> Set equal to 1 to enable. This option will leave a blank row between each variable.                                      */
/*         vars -> Names of all variables to output separated by an asterisk. Numeric values will be treated as continuous.                      */
/*         combine_cols -> Set equal to 1 to enable. Creates 1 column per stratification (instead of 2)                                          */
/*         pvalues -> Output p-values for each variable.                                                                                         */
/*         strat_whr1-5 -> Will stratify all outputs by this where statement. Leave blank to ignore. Up to 5 currently allowed.                  */
/*                                                                                                                                               */
/*************************************************************************************************************************************************/

%macro table1(cohort=, output_dset=, cont_stats=MEAN*MEDIAN, autofill=, headspace=, vars=, hide_headspace=, hide_missing=, combine_cols=, pvalues=,
	strat_whr0=1, strat_whr1=, strat_whr2=, strat_whr3=, strat_whr4=, strat_whr5=, strat_whr6=, strat_whr7=, strat_whr8=, strat_whr9=);
	
	PROC CONTENTS DATA=&cohort. OUT=contents (KEEP=name type) NOPRINT; RUN;

	%let vars=%sysfunc(COMPRESS(&vars.));
	%let n_vars=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&vars., *, **))))-%sysfunc(LENGTH(&vars.))+1);

	%if %length(&hide_headspace.) NE 0 %then %do;
		%let hide_headspace=%sysfunc(COMPRESS(&hide_headspace.));
		%let n_hide_headspace=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&hide_headspace., *, **))))-%sysfunc(LENGTH(&hide_headspace.))+1);	
	%end;
	%else %let n_hide_headspace=0;

	%if %length(&hide_missing.) NE 0 %then %do;
		%let hide_missing=%sysfunc(COMPRESS(&hide_missing.));
		%let n_hide_missing=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&hide_missing., *, **))))-%sysfunc(LENGTH(&hide_missing.))+1);	
	%end;
	%else %let n_hide_missing=0;

	%let n_stats=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&cont_stats., *, **))))-%sysfunc(LENGTH(&cont_stats.))+1);
	%let stats2 = %sysfunc(TRANWRD(%bquote(&cont_stats.), %str(%(), *));
	%let stats3 = %sysfunc(TRANWRD(%bquote(&stats2.), -, *));
	%let stats4 = %sysfunc(COMPRESS(%bquote(&stats3.), ') '));
	%let n_stats4=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&stats4., *, **))))-%sysfunc(LENGTH(&stats4.))+1);

	%do type=1 %to 2;
		%let name=%scan(num*char, &type., *);
		%let &name._vars=;
		PROC SQL NOPRINT;
			SELECT name INTO: &name._vars SEPARATED BY "*" FROM contents
			WHERE type=&type. AND (
				%do i=1 %to &n_vars.;
					%if &i. NE 1 %then %do; OR %end;
					UPCASE(name) EQ UPCASE("%scan(&vars., &i., *)")
				%end;
				);
			SELECT COUNT(name) INTO: n_&name._vars FROM contents
			WHERE type=&type. AND (
				%do i=1 %to &n_vars.;
					%if &i. NE 1 %then %do; OR %end;
					UPCASE(name) EQ UPCASE("%scan(&vars., &i., *)")
				%end;
				);
		QUIT;
	%end;

	%let n_strats=0;
	%do i=1 %to 9;
		%if %length(&&strat_whr&i.) %then %let n_strats=&i.;
	%end;

	%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
		%let var=%scan(&char_vars., &i., *);
		PROC SQL;
			CREATE TABLE &var._setup2 AS
			SELECT DISTINCT &var. as col1
			FROM &cohort.
			ORDER BY col1;
		QUIT;
	%end;

	%do strat=0 %to &n_strats.;

		DATA cohort_mod;
			SET &cohort.;
			WHERE &&strat_whr&strat.;
		RUN;

		PROC SQL NOPRINT;
			SELECT COUNT(*) INTO: denom FROM cohort_mod;
		QUIT; 

		PROC SQL;
			CREATE TABLE total AS
			%if &combine_cols. EQ 1 %then %do;
				SELECT "Total" as col1, PUT(COUNT(*), 8.) AS col2, COMPRESS(PUT(COUNT(*), 8.)) || " (" || COMPRESS(PUT(COUNT(*)/&denom.*100, 8.1)) || "%)" AS col3 FROM cohort_mod;
			%end;
			%else %do;
				SELECT "Total" as col1, PUT(COUNT(*), 8.) AS col2, PUT(COUNT(*)/&denom., 8.4) AS col3 FROM cohort_mod;
			%end;
		QUIT; 
		PROC MEANS DATA=cohort_mod NOPRINT;
			VAR %sysfunc(TRANWRD(&num_vars., *, ));
			OUTPUT OUT=stats
				%do i=1 %to &n_stats4.;
					%scan(&stats4., &i., *) = 
				%end;
				/ AUTONAME;
		RUN;

		%if &n_num_vars. GT 0 %then %do i=1 %to &n_num_vars.;
			%let var=%scan(&num_vars., &i., *);
			PROC SQL;
				CREATE TABLE &var._setup AS
				%do j=1 %to &n_stats.;
					%let stat=%scan(&cont_stats., &j., *);
					%if &combine_cols. EQ 1 %then %do;
						%let substat2 = %sysfunc(TRANWRD(%bquote(%sysfunc(COMPRESS(&stat.))), %str(%)), %str(, 8.2%)%) || ")")));
						%let substat3 = %sysfunc(TRANWRD(%superq(substat2), %str(%(), %str(, 8.2%)%) || " (" || COMPRESS%(PUT%(&var._)));
					%end;
					%else %do;
						%let substat2 = %sysfunc(TRANWRD(%bquote(%sysfunc(COMPRESS(&stat.))), %str(%)), %str(, 8.2%)%))));
						%let substat3 = %sysfunc(TRANWRD(%superq(substat2), %str(%(), %str(, 8.2%)%) as col2, COMPRESS%(PUT%(&var._)));
					%end;
					%let substat4 = %sysfunc(TRANWRD(%superq(substat3), %str(-), %str(, 8.2%)%) || " - " || COMPRESS%(PUT%(&var._)));
					%if "%substr(&stat.,%sysfunc(LENGTH(&stat.)),1)" EQ ")" %then %do;
						%let substat5 = %str(COMPRESS%(PUT%(&var._&substat4.) as col3;
					%end;
					%else %do;
						%let substat5 = %str(COMPRESS%(PUT%(&var._&substat4., 8.2%)%)) as col3;
					%end;
					
					%if &j. NE 1 %then %do; UNION ALL %end;
					SELECT "&stat." as col1, &substat5. FROM stats
				%end;
				;
			QUIT;
		%end;
				
		PROC FREQ DATA=cohort_mod NOPRINT;
			%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
				%let var=%scan(&char_vars., &i., *);
				TABLES &var. / OUT=&var._setup1 (KEEP=&var. count RENAME=(&var.=col1 count=col2));
			%end;
		RUN;

		%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
			%let var=%scan(&char_vars., &i., *);
			DATA &var._setup (DROP=col2 RENAME=col4=col2);
				MERGE &var._setup1 (IN=A) &var._setup2;
				BY col1;
				IF NOT A THEN col2=0;
				FORMAT col3 col4 $50.;
				%if &combine_cols. EQ 1 %then %do;
					col3 = COMPRESS(PUT(col2, 8.)) || " (" || COMPRESS(PUT(col2/&denom.*100, 8.1)) || "%)";
				%end;
				%else %do;
					col3 = PUT(col2/&denom., 8.4);
				%end;
				col4 = PUT(col2, 8.);
			RUN;
		%end;

		%if &headspace. EQ 1 %then %do;
			DATA blank; col1=""; RUN;
		%end;

		DATA output_&strat. 
			%if &combine_cols. EQ 1 %then %do; (KEEP=col0 col1 col3 RENAME=col3=strat&strat.) %end;
			%else %do; (KEEP=col0-col3 RENAME=(col2=strat&strat._n col3=strat&strat._pct)) %end;
			;
			FORMAT col0-col3 $50.;
			SET total
				%do i=1 %to &n_vars.;
					%let var=%scan(&vars., &i., *);
					%if &headspace. EQ 1 %then %do; blank (IN=&var.) %end;
					&var._setup (IN=&var. WHERE=(NOT MISSING(col1)))
					&var._setup (IN=&var. WHERE=(MISSING(col1)))
				%end;
				;
			%do i=1 %to &n_vars.;
				%let var=%scan(&vars., &i., *);
				%if &i. NE 1 %then %do; ELSE %end;
				IF &var. THEN col0="&var.";
			%end;
			IF MISSING(col1) AND NOT MISSING(col2) THEN col1="Missing";
			%if &autofill. EQ 1 %then %do;
				IF col0 IN ("sex","gender") THEN DO;
					IF col1 IN ('1','M') THEN col1="Male";
					ELSE IF col1 IN ('2','F') THEN col1="Female";
				END;
				ELSE IF col0="region" THEN DO;
					IF col1='1' THEN col1="Northeast";
					ELSE IF col1='2' THEN col1="North Central";
					ELSE IF col1='3' THEN col1="South";
					ELSE IF col1='4' THEN col1="West";
					ELSE IF col1='5' THEN col1="Unknown";
				END;
				ELSE IF col0="plantyp" THEN DO;
					IF col1='1' THEN col1="Basic/major medical";
					ELSE IF col1='2' THEN col1="Comprehensive";
					ELSE IF col1='3' THEN col1="EPO";
					ELSE IF col1='4' THEN col1="HMO"; 
					ELSE IF col1='5' THEN col1="POS"; 
					ELSE IF col1='6' THEN col1="PPO"; 
					ELSE IF col1='7' THEN col1="POS with capitation";
					ELSE IF col1='8' THEN col1="CDHP";
					ELSE IF col1='9' THEN col1="HDHP";
				END;
			%end;
		RUN;
	%end;

	DATA &output_dset.;
		MERGE output_0-output_&n_strats.;
		%if &n_hide_headspace. GT 0 %then %do i=1 %to &n_hide_headspace.;
			%if &i. NE 1 %then %do; ELSE %end;
			IF col0="%scan(&hide_headspace., &i., *)" AND MISSING(col1) THEN DELETE;
		%end;
		%if &n_hide_missing. GT 0 %then %do i=1 %to &n_hide_missing.;
			%if &i. NE 1 %then %do; ELSE %end;
			IF col0="%scan(&hide_missing., &i., *)" AND col1="Missing" THEN DELETE;
		%end;
	RUN;

	%if &pvalues. EQ 1 AND &n_strats. GE 2 %then %do;
		ODS GRAPHICS OFF;
		ODS SELECT NONE;

		DATA pval_setup;
			SET 
			%do i=1 %to &n_strats.;
				&cohort. (IN=in&i. WHERE=(&&strat_whr&i.))
			%end;
			;
			%do i=1 %to &n_strats.;
				%if &i. NE 1 %then %do; ELSE %end;
				IF in&i. THEN strat="&i.";
			%end;
			%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
				%let var=%scan(&char_vars., &j., *);
				IF MISSING(&var.) THEN &var.=".";
			%end;
		RUN;
		
		%if &n_num_vars. GT 0 %then %do j=1 %to &n_num_vars.;
			%let var=%scan(&num_vars., &j., *);
			%if &n_strats. EQ 2 %then %do;
				ODS OUTPUT EQUALITY=variance_test TTESTS=tests; 
				PROC TTEST DATA=pval_setup;
					VAR &var.; 
					CLASS strat;
				RUN; 

				PROC SQL NOPRINT;
					SELECT CASE WHEN ProbF < 0.05 THEN 'Unequal' ELSE 'Equal' END INTO: var_type FROM variance_test;
					SELECT probt INTO: pval1_&var. FROM tests WHERE Variances = "&var_type.";
				QUIT; 
							
				PROC NPAR1WAY DATA=pval_setup WILCOXON;
					VAR &var.; 
					CLASS strat;
					OUTPUT OUT=tests; 
				RUN; 

				PROC SQL NOPRINT;
					SELECT p2_wil INTO: pval3_&var. FROM tests;
				QUIT; 
			%end;
			%else %do;
				%let pval1_&var.=.;
				%let pval3_&var.=.;
			%end;

			PROC ANOVA DATA=pval_setup OUTSTAT=tests;
				CLASS strat;
				MODEL &var. = strat; 
			RUN; 
			QUIT; 

			PROC SQL NOPRINT;
				SELECT prob INTO: pval2_&var. FROM tests WHERE _TYPE_ = "ANOVA";
			QUIT; 
		%end;

		%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
			%let var=%scan(&char_vars., &j., *);

			PROC SQL NOPRINT;
				SELECT COUNT(distinct &var.) INTO: cols FROM pval_setup;
			QUIT; 
			 
			PROC FREQ DATA=pval_setup;
				TABLES strat*&var. / LIST CHISQ FISHER %if &n_strats. EQ 2 AND &cols. EQ 2 %then %do; AGREE %end; WARN=OUTPUT;
				EXACT TREND / MAXTIME=5; 
				OUTPUT CHISQ %if &n_strats. EQ 2 AND &cols. EQ 2 %then %do; MCNEM %end; OUT=tests; 
			RUN; 

			PROC SQL NOPRINT;
				SELECT warn_pchi INTO: fisher FROM tests;
				%if &fisher. EQ 0 %then %do;
					SELECT p_pchi INTO: pval1_&var. FROM tests;
				%end;
				%else %do;
					SELECT xp2_fish INTO: pval1_&var. FROM tests;
				%end;
			QUIT;
		%end;

		ODS SELECT ALL;

		DATA &output_dset.;
			SET &output_dset.;
			BY col0 NOTSORTED;
			IF first.col0 THEN DO;
				%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
					%let var=%scan(&char_vars., &j., *);
					%if &j. NE 1 %then %do; ELSE %end;
					IF UPCASE(col0)=UPCASE("&var.") THEN p_chisq=&&pval1_&var.;
				%end;
				%if &n_num_vars. GT 0 %then %do j=1 %to &n_num_vars.;
					%let var=%scan(&num_vars., &j., *);
					%if &j. NE 1 %then %do; ELSE %end;
					IF UPCASE(col0)=UPCASE("&var.") THEN DO;
						p_ttest=&&pval1_&var.;
						p_anova=&&pval2_&var.;
						p_wilcoxon=&&pval3_&var.;
					END;
				%end;
			END;
		RUN;
	%end;

%mend table1;



/*contents*/
%macro contents(dataset);
proc contents data=&dataset.; run;
%mend contents;

/*freq table*/
%macro freq(dataset,var);
	proc freq data=&dataset.; tables &var.; run;
%mend freq;
%macro freq2(table, vars);
	%connDBPassThrough(dbname=heoji3,libname1=imp);
		select * from connection to imp
		(select &vars., count(distinct enrolid) as pts from &table. group by &vars.);
	quit;
%mend freq2;
%macro freq3(table, vars);
	%connDBPassThrough(dbname=heoji3,libname1=imp);
		select * from connection to imp
		(select &vars., count(&vars.) as freq from &table. group by &vars.);
	quit;
%mend freq3;

/*Print in SAS*/
%macro print(dataset);
proc print data=&dataset.; run;
%mend print;

/*Count patients*/
%macro countid(table);
	proc sql;
		select "&table." as title, count(enrolid) as obs, count(distinct enrolid) as pts 
		from &table.;
	quit;
%mend countid;

%macro countid2(table);
	%connDBPassThrough(dbname=heoji3,libname1=imp);
		select * from connection to imp
		(select "&table." as title, count(enrolid) as obs, count(distinct enrolid) as pts from &table.);
	quit;
%mend countid2;

%macro countid3(table);
	proc sql;
		select "&table." as title, count(enrolidgrp) as obs, count(distinct enrolidgrp) as pts 
		from &table.;
	quit;
%mend countid3;

/*show database*/
%macro output(table);
	%connDBPassThrough(dbname=heoji3,libname1=imp);
		select * from connection to imp
		(select z.* from (select a.* from &table. as a order by a.enrolid) as z limit 100);
	quit;
%mend output;
%macro output2(table);
	%connDBPassThrough(dbname=heoji3,libname1=imp);
		select * from connection to imp
		(select z.* from &table. as z limit 100);
	quit;
%mend output2;

/*summary*/
%macro sum(table);
	%countid2(&table.);
	%output2(&table.);
%mend sum;
