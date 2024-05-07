
CREATE PROCEDURE SHIELDS_FILLED_PRESCRIPTION_DATA
AS
BEGIN
	DECLARE @START_dtW date = CAST(GETDATE()-7 AS date);
	DECLARE @END_dtW date = CAST(GETDATE()-1 AS date);

	DECLARE @START_dtM date = CAST(GETDATE()-42 AS date); ---previous 6 weeks.
	DECLARE @END_dtM date = CAST(GETDATE()-1 AS date);

	DECLARE @START_dt date;
	DECLARE @END_dt date;

	IF TRIM(DATENAME(dw,GETDATE())) = 'Saturday'
	BEGIN
	   SET @START_dt = @START_dtM;
	   SET @END_dt = @END_dtM;
	END
	ELSE
	BEGIN
	   SET @START_dt = @START_dtW;
	   SET @END_dt = @END_dtW;  
	END;

	WITH SORT_CODE AS (
	      SELECT	
	         X.PAT_LINK_ID	
	       , X.SORT_CODE	
	       , ROW_NUMBER() OVER (PARTITION BY X.PAT_LINK_ID ORDER BY PAT_LINK_ID) RN	
	      FROM	
	         (	
	            SELECT DISTINCT	
	                     E.PAT_LINK_ID, EPISODE_DEF.EPISODE_DEF_NAME	
	                   , CASE WHEN zep.ABBR IN (	
	                                                                'HB' -- Hepatology -- logic required by	
	                                                              , '' -- Ankylosing Spondylitis	
	                                                              , 'IPF'	
	                                                              , 'JIA'	
	                                                              , 'PR' -- Psoriasis	
	                                                              , 'PA' -- Psoriatic Arthritis	
	                                                              , 'RIC' -- Rare Inflammatory Condition	
	                                                              , 'HM' -- Hematology	
	                                                             )	
	                                            THEN 'OT'	
	                                            ELSE zep.ABBR	
	                                         END SORT_CODE	
	            FROM EPISODE E	
	            INNER JOIN EPISODE_2 e2 ON e2.EPISODE_ID = E.EPISODE_ID	
	            LEFT JOIN ZC_ENROLL_PROG zep ON zep.ENROLL_PROG_C = e2.ENROLL_PROG_C	
	            JOIN EPISODE_DEF ON EPISODE_DEF.EPISODE_DEF_ID = E.SUM_BLK_TYPE_ID	
	            WHERE	
	               E.SUM_BLK_TYPE_ID = 29 -- SPECIALTY PHARMACY ENROLLMENT	
	         ) X	
	)
	SELECT TRIM(str) str	
	FROM (
	  SELECT ' UNIQUE_RECORD_ID|SORTCODE1_PATIENT|SORTCODE2_PATIENT|SORTCODE3_PATIENT|SORTCODE4_PATIENT|MRN_PATIENT|SP_PATIENT_ID|NAMEFIRST_PATIENT|NAMEMIDDLE_PATIENT|NAMELAST_PATIENT|NAMESUFFIX_PATIENT|DOB_PATIENT|ADRSADD1_PATIENT|ADRSADD2_PATIENT|ADRSCITY_PATIENT|ADRSSTATE_PATIENT|ADRSZIP_PATIENT|ADRSPHONENUMBER_PATIENT|SEX_PATIENT|NAMEFIRST_DOC|NAMEMIDDLE_DOC|NAMELAST_DOC|PRESCRIBING_NPI|PRESCRIBER_DEA|PRESCRIBER_STATE_LICENSE|PRESCRIBER_ME|ADRSADD1_DOC|ADRSADD2_DOC|ADRSCITY_DOC|ADRSSTATE_DOC|ADRZIP_DOC|ADRSPHONENUMBER_DOC|ADRSFAXNUMBER_DOC|SPECIALTY_DOC|PROVIDER_AFFILIATION|CLINICIAN_CREDENTIALS|NAME_DRUG|DRUGNDCNBR_DRUG|DV_MEDID|RXNBR_RX|RX_REFILL_NUMBER|REFILLS_RX|QTY_REMAIN_RX|DRUG_STRENGTH|DRUG_FREQUENCY|RXQTY_RX|DAYSUPP_RX|BRANDNAME_DRUG|UNIT_STRENGTH_DRUG|DISPENSED_FREQUENCY|DISPENSEDQTY1_RX|REGIMEN|LOT_NUMBER|LOT_EXPIRATION|SKU_NUMBER|DATE_RECEIVED|DATE_WRITTEN|DATE_ORDERED|DATE_EXPIRE|DATE_LAST_ADJUDICATED|DATE_FILLED|DATE_VERIFIED|DATE_SHIPPED|FIRST_SHIP_DATE|SHIPMENT_ID|DRUG_INVOICE_COST|USUAL_CUSTOMARY_PRICE|PHARMACY_NAME|PHARMACY_ADDRESS|ICD1_RX|ICD2_RX|ICD3_RX|BENEFIT_PLAN_NAME|PRIMARY_INSURANCE|PRIMARY_BIN|PRIMARY_PCN|PRIMARY_GROUP|PRIMARY_SPONSOR|PRIMARY_SPONSOR_TYPE|PRIMARY_COPAY|PRIMARY_PAID|PRIMARY_MEMBER_ID|PRIMARY_PERSON_CODE|BENEFIT_PLAN_NAME2|SECONDARY_INSURANCE|SECONDARY_BIN|SECONDARY_PCN|SECONDARY_GROUP|SECONDARY_SPONSOR|SECONDARY_SPONSOR_TYPE|SECONDARY_COPAY|SECONDARY_PAID|BENEFIT_PLAN_NAME3|TERTIARY_INSURANCE|TERTIARY_BIN|TERTIARY_PCN|TERTIARY_GROUP|TERTIARY_SPONSOR|TERTIARY_SPONSOR_TYPE|TERTIARY_COPAY|TERTIARY_PAID|PATIENT_RESPONSIBLE_AMOUNT|PARTIAL_FILL_YN|CASH_PAY_FILL_YN|YN_340B|OTH_PAY_COV_AMT|PRIMARY_CLAIM_AUTH_NUMBER|PRIMARY_OTHER_COVERAGE_CODE|SECONDARY_CLAIM_AUTH_NUMBER|SECONDARY_OTHER_COVERAGE_CODE|TERTIARY_CLAIM_AUTH_NUMBER|TERTIARY_OTHER_COVERAGE_CODE|FILL_INITIATED_DATE|FILL_INITIATED_TIME' str	
	  
	  UNION ALL
	    
	  SELECT	
	       X.F_01_unique_record_id                   	
	       +'|'+ CASE WHEN X.F_02_sortcode2_patient IS NULL THEN ''	
	       ELSE X.F_02_sortcode2_patient	
	           END  	
	       +'|'+ CASE WHEN X.F_03_sortcode2_patient IS NULL THEN ''	
	           ELSE X.F_03_sortcode2_patient	
	       END  	
	       +'|'+ CASE WHEN X.F_04_sortcode3_patient IS NULL THEN ''	
	       ELSE X.F_04_sortcode3_patient	
	       END  	
	       +'|'+ CASE WHEN X.F_05_sortcode4_patient IS NULL THEN ''	
	           ELSE X.F_05_sortcode4_patient	
	       END  	
	     +'|'+ CASE WHEN  X.F_06_mrn_patient IS NULL THEN ''	
	        ELSE  X.F_06_mrn_patient	
	      END   	
	       +'|'+ CASE WHEN F_06b_sp_patientID IS NULL THEN ''	
	           ELSE F_06b_sp_patientID	
	           END  	
	       +'|'+  X.F_07_namefirst_patient                	
	     +'|'+ CASE WHEN x.f_07_Namemiddle_patient IS NULL THEN ''	
	       ELSE x.f_07_Namemiddle_patient	
	           END  	
	       +'|'+  X.F_08_namelt_patient                 	
	     +'|'+ CASE WHEN x.f_08_namesuffix_patient IS NULL THEN ''	
	           ELSE x.f_08_namesuffix_patient	
	       END  	
	       +'|'+  CONVERT(varchar, X.F_09_dob_patient, 112)                      	
	       +'|'+  X.F_10_adrsadd1_patient                 	
	       +'|'+ CASE WHEN X.F_11_adrsadd2_patient IS NULL THEN ''	
	       ELSE X.F_11_adrsadd2_patient	
	       END  	
	       +'|'+  X.F_12_adrscity_patient                 	
	       +'|'+  X.F_13_adrsstate_patient                	
	       +'|'+  X.F_14_adrszip_patient                  	
	       +'|'+ CASE WHEN X.F_15_adrsphonenumber_patient IS NULL THEN ''	
	         ELSE X.F_15_adrsphonenumber_patient	
	       END  	
	       +'|'+  X.F_16_sex_patient                      	
	       +'|'+ CASE WHEN X.F_17_namefirst_doc IS NOT NULL 
	              THEN UPPER(CASE WHEN X.F_17_namefirst_doc LIKE '%,%'
	                        THEN REVERSE(PARSENAME(REPLACE(REVERSE(X.F_17_namefirst_doc), ' ', '.'), 1)) 
	                        ELSE LTRIM(SUBSTRING(X.F_17_namefirst_doc, CHARINDEX(' ', X.F_17_namefirst_doc), LEN(X.F_17_namefirst_doc)))
	                   END)
	            END	

	        +'|'+ CASE WHEN X.F_17_namemiddle_doc IS NULL THEN ''	
	              ELSE X.F_17_namemiddle_doc END  	

	        +'|'+ CASE WHEN X.F_18_namelt_doc IS NOT NULL 
	              THEN UPPER(CASE WHEN X.F_18_namelt_doc LIKE '%,%'
	                        THEN PARSENAME(REPLACE(X.F_18_namelt_doc, ',', '.'), 2) 
	                        ELSE SUBSTRING(X.F_18_namelt_doc, 1, CHARINDEX(' ', X.F_18_namelt_doc))
	                   END)
	           END	

	       +'|'+ CASE WHEN X.F_19_prescribing_NPI IS NULL THEN ''	
	       ELSE x.F_19_prescribing_NPI	
	       END  	

	       +'|'+ CASE WHEN X.F_20_prescriber_DEA IS NULL THEN ''	
	           ELSE X.F_20_prescriber_DEA	
	       END  	
	       +'|'+ CASE WHEN X.prescriber_state_license IS NULL THEN ''	
	       ELSE X.prescriber_state_license	
	           END  	
	     +'|'+  x.prescriber_me 	
	       +'|'+ CASE WHEN X.F_21_adrsadd1_doc IS NULL THEN ''	
	         ELSE X.F_21_adrsadd1_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_22_adrsadd2_doc IS NULL THEN ''	
	           ELSE X.F_22_adrsadd2_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_23_adrscity_doc IS NULL THEN ''	
	           ELSE X.F_23_adrscity_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_24_adrsstate_doc IS NULL THEN ''	
	           ELSE X.F_24_adrsstate_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_25_adrzip_doc IS NULL THEN ''	
	           ELSE X.F_25_adrzip_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_26_adrsphonenumber_doc IS NULL THEN ''	
	       ELSE  X.F_26_adrsphonenumber_doc	
	       END  	
	     +'|'+ CASE WHEN x.F_26_adrsfaxnumber_doc IS NULL THEN ''	
	         ELSE x.F_26_adrsfaxnumber_doc	
	           END  	
	       +'|'+ CASE WHEN X.F_27_specialty_doc IS NULL THEN ''	
	       ELSE X.F_27_specialty_doc	
	           END  	
	       +'|'+  X.F_28_provider_affiliation             	
	       +'|'+ CASE WHEN X.F_29_clinician_credentials IS NULL THEN ''	
	       ELSE X.F_29_clinician_credentials	
	       END  	
	       +'|'+  X.F_30_name_drug                        	
	       +'|'+  X.F_31_drugndcnbr_drug                  	
	       +'|'+ CASE WHEN X.F_32_dv_medid IS NULL THEN ''	
	           ELSE X.F_32_dv_medid	
	       END  	
	       +'|'+  X.F_33_rxnbr_rx                         	
	       +'|'+  X.F_34_rx_refill_number                 	
	       +'|'+  X.F_35_refills_rx                       	
	       +'|'+  X.F_36_qty_remain_rx                    	
	       +'|'+ CASE WHEN X.F_37_drug_strength IS NULL THEN ''	
	       ELSE X.F_37_drug_strength	
	           END  	
	       +'|'+ CASE WHEN X.F_38_drug_frequency IS NULL THEN ''	
	       ELSE X.F_38_drug_frequency	
	           END  	
	       +'|'+  X.F_39_rxqty_rx                         	
	       +'|'+  X.F_40_daysupp_rx                       	
	       +'|'+  X.F_41_brandname_drug           	
	       +'|'+ CASE WHEN X.F_42_unit_strength_drug IS NULL THEN ''	
	           ELSE X.F_42_unit_strength_drug	
	           END  	
	       +'|'+ CASE WHEN X.F_43_dispensed_frequency IS NULL THEN ''	
	       ELSE X.F_43_dispensed_frequency	
	           END  	
	       +'|'+  X.F_44_dispensedqty1_rx                 	
	       +'|'+  X.F_45_regimen                          	
	       +'|'+ CASE WHEN X.F_46_lot_number IS NULL THEN ''	
	       ELSE X.F_46_lot_number	
	           END  	
	       +'|'+ CASE WHEN X.F_47_lot_expiration IS NOT NULL 
	              THEN CONVERT(VARCHAR(8), X.F_47_lot_expiration, 112)
	              ELSE ' '	
	           END  	

	       +'|'+  x.sku_number                            	
       +'|'+  CONVERT(VARCHAR(8), X.date_received, 112)                         	
       +'|'+  CONVERT(VARCHAR(8), X.F_48_date_written, 112)                     	
     +'|'+  CONVERT(VARCHAR(8), date_ordered, 112)	
       +'|'+  CONVERT(VARCHAR(8), X.F_49_date_expire, 112)                      	

     +'|'+ CASE WHEN x.F_89_date_lt_adjudicated IS NULL THEN ''	
       ELSE CONVERT(VARCHAR(8), x.F_89_date_lt_adjudicated, 112)	
       END  	

      +'|'+  CONVERT(VARCHAR(8), X.F_50_date_filled, 112)              	
     +'|'+  CONVERT(VARCHAR(8), date_verified, 112)	
       +'|'+ CASE WHEN X.F_51_date_shipped IS NULL THEN ''	
       ELSE X.F_51_date_shipped	
           END  	
       +'|'+ CASE WHEN X.F_52_first_ship_date IS NULL THEN ''	
           ELSE X.F_52_first_ship_date	
           END  	
       +'|'+  X.F_53_shipment_ID                      	
       +'|'+  X.F_54_drug_invoice_cost                	
       +'|'+ CASE WHEN X.F_55_usual_customary_price IS NOT NULL THEN  CONVERT(VARCHAR(20), X.F_55_usual_customary_price)	
       ELSE ' '	
           END  	
       +'|'+  X.F_56_pharmacy_name                    	
       +'|'+  X.F_57_pharmacy_address                 	
       +'|'+ CASE WHEN X.F_58_icd1_rx IS NULL THEN ''	
           ELSE X.F_58_icd1_rx	
           END  	
       +'|'+ CASE WHEN X.F_59_icd2_rx IS NULL THEN ''	
           ELSE X.F_59_icd2_rx	
           END  	
       +'|'+ CASE WHEN X.F_60_icd3_rx  IS NULL THEN ''	
       ELSE X.F_60_icd3_rx	
           END  	
       +'|'+ CASE WHEN X.F_64_benefit_plan_name IS NULL THEN ''	
           ELSE X.F_64_benefit_plan_name	
       END  	
       +'|'+ CASE WHEN X.F_61_primary_insurance IS NULL THEN ''	
           ELSE X.F_61_primary_insurance	
           END  	
     +'|'+ CASE WHEN X.F_62_primary_BIN IS NULL THEN ''	
           ELSE X.F_62_primary_BIN	
           END  	
       +'|'+ CASE WHEN X.F_63_primary_PCN IS NULL THEN ''	
           ELSE X.F_63_primary_PCN	
           END  	
       +'|'+ CASE WHEN X.F_65_primary_group IS NULL THEN ''	
       ELSE X.F_65_primary_group	
           END  	
       +'|'+ CASE WHEN X.F_66_primary_sponsor IS NULL THEN ''	
       ELSE X.F_66_primary_sponsor	
           END  	
       +'|'+ CASE WHEN X.F_67_primary_sponsor_type IS NULL THEN ''	
           ELSE X.F_67_primary_sponsor_type	
           END  	
       +'|'+ CASE WHEN X.F_68_primary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), X.F_68_primary_copay)	
      ELSE ' '	
          END  	
       +'|'+ CASE WHEN X.F_69_primary_paid IS NOT NULL THEN CONVERT(VARCHAR(20), F_69_primary_paid)	
           ELSE ' '	
           END  	
       +'|'+ CASE WHEN primary_member_id IS NULL THEN ''	
         ELSE primary_member_id	
       END  	
     +'|'+ CASE WHEN primary_person_code IS NULL THEN ''	
       ELSE primary_person_code	
       END  	
       +'|'+ CASE WHEN X.F_70_benefit_plan_name2 IS NULL THEN ''	
       ELSE X.F_70_benefit_plan_name2	
           END  	
       +'|'+ CASE WHEN X.F_70_secondary_insurance IS NULL THEN ''	
           ELSE X.F_70_secondary_insurance	
       END  	
       +'|'+ CASE WHEN  X.F_71_secondary_BIN IS NULL THEN ''	
       ELSE X.F_71_secondary_BIN	
           END  	
       +'|'+ CASE WHEN X.F_72_secondary_PCN  IS NULL THEN ''	
           ELSE X.F_72_secondary_PCN	
           END  	
       +'|'+ CASE WHEN X.F_74_secondary_group IS NULL THEN ''	
           ELSE X.F_74_secondary_group	
           END  	
       +'|'+ CASE WHEN X.F_75_secondary_sponsor IS NULL THEN ''	
         ELSE X.F_75_secondary_sponsor	
         END  	
       +'|'+ CASE WHEN X.F_76_secondary_sponsor_type IS NULL THEN ''	
           ELSE X.F_76_secondary_sponsor_type	
           END  	
       +'|'+ CASE WHEN X.F_77_secondary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), X.F_77_secondary_copay)	
       ELSE ' '	
           END  	
       +'|'+ CASE WHEN X.F_78_secondary_paid IS NOT NULL THEN CONVERT(VARCHAR(20), X.F_78_secondary_paid)	
           ELSE ' '	
       END  	
       +'|'+ CASE WHEN X.F_79_benefit_plan_name3 IS NULL THEN ''	
           ELSE X.F_79_benefit_plan_name3	
           END  	
       +'|'+ CASE WHEN X.F_79_tertiary_insurance IS NULL THEN ''	
       ELSE X.F_79_tertiary_insurance	
           END  	
       +'|'+ CASE WHEN X.F_80_tertiary_BIN IS NULL THEN ''	
           ELSE X.F_80_tertiary_BIN	
           END  	
       +'|'+ CASE WHEN X.F_81_tertiary_PCN IS NULL THEN ''	
           ELSE X.F_81_tertiary_PCN	
           END  	
       +'|'+ CASE WHEN X.F_83_tertiary_group IS NULL THEN ''	
           ELSE X.F_83_tertiary_group	
           END  	
       +'|'+ CASE WHEN X.F_84_tertiary_sponsor IS NULL THEN ''	
           ELSE X.F_84_tertiary_sponsor	
           END  	
       +'|'+ CASE WHEN X.F_85_tertiary_sponsor_type IS NULL THEN ''	
           ELSE X.F_85_tertiary_sponsor_type	
           END  	
       +'|'+ CASE WHEN X.F_86_tertiary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), X.F_86_tertiary_copay)	
       ELSE ' '	
           END  	
       +'|'+ CASE WHEN X.F_87_tertiary_paid  IS NOT NULL THEN CONVERT(VARCHAR(20), X.F_87_tertiary_paid)	
           ELSE ' '	
           END  	
       +'|'+  CONVERT(VARCHAR(20), X.F_88_patient_responsible_amount)  	
       +'|'+  X.partial_fill_yn	
       +'|'+  X.ch_pay_fill_yn 	
       +'|'+  X.yn_340b	
       +'|'+  CONVERT(VARCHAR(20), oth_pay_cov_amt) 	
       +'|'+  AUTH_NUM_primary	
       +'|'+  OTH_CVG_CODE_ID_primary 	
       +'|'+  AUTH_NUM_secondary	
       +'|'+  OTH_CVG_CODE_ID_secondary 	
       +'|'+  AUTH_NUM_tertiary	
       +'|'+  OTH_CVG_CODE_ID_tertiary 	
       +'|'+  CONVERT(VARCHAR(8), Fill_Initiated_Date, 112) 	
       +'|'+  CONVERT(VARCHAR(5), Fill_Initiated_Time, 108)	
      FROM (	
            SELECT	
            O_DISP_INFO.ORDER_MED_ID + '.' + O_STATUS.CONTACT_NUMBER unique_record_id	
             , O_med.ORDER_MED_ID	
             , O_DISP_INFO.RX_NUM_FORMATTED_HX	
             , O_DISP_INFO.FILL_SERVICE_DATE	
             , O_DISP_INFO.FILL_NUMBER	

             , O_MED.REFILLS	
             , O_MED.QUANTITY	
             , O_MED_2.DISP_QTY_REM	
             , O_MED.MED_DIS_DISP_QTY	

             , O_DISP_INFO.FILL_IS_PARTIAL_YN	
             , O_DISP_INFO.FILL_STATUS_C CURR_FILL_STATUS_C	
             , CURR_FILL_STS.NAME CURRENT_FILL_STATUS	
             ------------------------------------------------------------------------------------	
             , NULL TOTAL_REFILL_AMT	
             , NULL TOTAL_USED_AMT	
             , O_MED_2.DISP_QTY_REM REMAINING_AMT	
             ------------------------------------------------------------------------------------	
             , ORD_ACTION_READY_TO_DISPENSE.ACTION_DTTM_LOCAL READY_TO_DISPENSE_ACTION_DTTM	
             ------------------------------------------------------------------------------------	
             , ORD_ACTION_FORCED_DISPENSED.ACTION_DTTM_LOCAL FORCED_DISPENSED_ACTION_DTTM	
             ------------------------------------------------------------------------------------	
             , ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL DISPENSE_ACTION_DTTM	
             ------------------------------------------------------------------------------------	
             , ORD_ACTION_FILL_RETURNED.ACTION_DTTM_LOCAL FILL_RETURNED_ACTION_DTTM	
             ------------------------------------------------------------------------------------	
             , O_DISP_INFO.CasH_PAY_YN	
             , O_DISP_INFO_PAT_PAY.PAT_PAY_AMT_POSTED	
             , O_DISP_INFO.PAT_PAY_AMOUNT	
             ------------------------------------------------------------------------------------	
             ,   PrimaryRxa.ADJ_ATTEMPT_ID 	
             ,   SecondaryRxa.ADJ_ATTEMPT_ID RXA_2	
             ,   TertiaryRxa.ADJ_ATTEMPT_ID RXA_3	

             --====================================================================================================================	
             --  Extract Data Fields	
             --====================================================================================================================	

             ,  O_MED.ORDER_MED_ID + '.' + O_STATUS.CONTACT_NUMBER F_01_unique_record_id	

             -------------------------------------	
             --  Data Category: Patient --	
             -------------------------------------	


             ,   S_CODE.SORT_CODE_2 F_02_sortcode2_patient	
             ,   S_CODE.SORT_CODE_2 F_03_sortcode2_patient	
             ,   S_CODE.SORT_CODE_3 F_04_sortcode3_patient	
             ,   S_CODE.SORT_CODE_4 F_05_sortcode4_patient	
             , cmrn.IDENTITY_ID F_06_mrn_patient	
             , cmrn.IDENTITY_TYPE_ID F_06_mrn_patientIDtype	
             , emrn.IDENTITY_ID F_06b_sp_patientID	
             , emrn.IDENTITY_TYPE_ID F_06b_sp_patientIDtype	
             , PAT.PAT_FIRST_NAME F_07_namefirst_patient	
             , PAT.PAT_middle_NAME F_07_namemiddle_patient	
             , PAT.PAT_LasT_NAME F_08_namelt_patient	
             , zc_suffix.Name F_08_namesuffix_patient	
             , PAT.BIRTH_DATE F_09_dob_patient	
             , PAT.ADD_LINE_1 F_10_adrsadd1_patient	
             , PAT.ADD_LINE_2 F_11_adrsadd2_patient	
             , PAT.CITY F_12_adrscity_patient	
             , ZC_STATE.ABBR F_13_adrsstate_patient	
             , PAT.ZIP F_14_adrszip_patient	
             , PAT.HOME_PHONE F_15_adrsphonenumber_patient	
             ,  CASE WHEN ZC_SEX.NAME= 'Male'	
                                     THEN '1'	
                                     WHEN ZC_SEX.NAME='Female'	
                                     THEN '2'	
                                     ELSE '0'	
                                  END F_16_sex_patient	

             --------------------------------------	
             --  Data Category: Clinician --	

              , COALESCE(authprov.prov_name, OutsideProv.prov_name, OrderProv.prov_name, PrscProv.prov_name,O_MED_2.TXT_AUTHPROV_NAME) F_17_namefirst_doc	
              , ' ' F_17_namemiddle_doc	
              , COALESCE(authprov.prov_name, OutsideProv.prov_name, OrderProv.prov_name, PrscProv.prov_name,O_MED_2.TXT_AUTHPROV_NAME) F_18_Namelt_doc	
        	
             , COALESCE(authprov_ser_2.npi, OutsideProv_Ser_2.npi, o_med_2.txt_authprov_npi, OrderProv_ser_2.NPI, PRSCProv_SER_2.npi ,O_MED_2.TXT_AUTHPROV_NPI) F_19_prescribing_NPI	
             , COALESCE(AuthProv.DEA_NUMBER, OutsideProv.DEA_Number, O_MED_2.TXT_AUTHPROV_DEA, OrderProv.DEA_Number, PRSCProv.DEA_Number) F_20_prescriber_DEA	
             , COALESCE(AuthPROV_LIC.LICENSE_NUM,OutsidePROV_LIC.LICENSE_NUM, OrderPROV_LIC.LICENSE_NUM, PrscPROV_LIC.LICENSE_NUM ,O_MED_2.TXT_AUTHPROV_ST_ID) prescriber_state_license	
             , '               ' prescriber_me	
             , COALESCE(AuthProv_ADDR.ADDR_LINE_1, Outsidsku_number                            	
       +'|'+  CONVERT(VARCHAR(8), date_received, 112)                         	
       +'|'+  CONVERT(VARCHAR(8), F_48_date_written, 112)                     	
     +'|'+  CONVERT(VARCHAR(8), date_ordered, 112)	
       +'|'+  CONVERT(VARCHAR(8), F_49_date_expire, 112)                      	

     +'|'+ CASE WHEN F_89_date_lt_adjudicated IS NULL THEN ''	
       ELSE CONVERT(VARCHAR(8), F_89_date_lt_adjudicated, 112)	
       END  	

      +'|'+  CONVERT(VARCHAR(8), F_50_date_filled, 112)              	
     +'|'+  CONVERT(VARCHAR(8), date_verified, 112)	
       +'|'+ CASE WHEN F_51_date_shipped IS NULL THEN ''	
       ELSE F_51_date_shipped	
           END  	
       +'|'+ CASE WHEN F_52_first_ship_date IS NULL THEN ''	
           ELSE F_52_first_ship_date	
           END  	
       +'|'+  F_53_shipment_ID                      	
       +'|'+  F_54_drug_invoice_cost                	
       +'|'+ CASE WHEN F_55_usual_customary_price IS NOT NULL THEN  CONVERT(VARCHAR(20), F_55_usual_customary_price)	
       ELSE ' '	
           END  	
       +'|'+  F_56_pharmacy_name                    	
       +'|'+  F_57_pharmacy_address                 	
       +'|'+ CASE WHEN F_58_icd1_rx IS NULL THEN ''	
           ELSE F_58_icd1_rx	
           END  	
       +'|'+ CASE WHEN F_59_icd2_rx IS NULL THEN ''	
           ELSE F_59_icd2_rx	
           END  	
       +'|'+ CASE WHEN F_60_icd3_rx  IS NULL THEN ''	
       ELSE F_60_icd3_rx	
           END  	
       +'|'+ CASE WHEN F_64_benefit_plan_name IS NULL THEN ''	
           ELSE F_64_benefit_plan_name	
       END  	
       +'|'+ CASE WHEN F_61_primary_insurance IS NULL THEN ''	
           ELSE F_61_primary_insurance	
           END  	
     +'|'+ CASE WHEN F_62_primary_BIN IS NULL THEN ''	
           ELSE F_62_primary_BIN	
           END  	
       +'|'+ CASE WHEN F_63_primary_PCN IS NULL THEN ''	
           ELSE F_63_primary_PCN	
           END  	
       +'|'+ CASE WHEN F_65_primary_group IS NULL THEN ''	
       ELSE F_65_primary_group	
           END  	
       +'|'+ CASE WHEN F_66_primary_sponsor IS NULL THEN ''	
       ELSE F_66_primary_sponsor	
           END  	
       +'|'+ CASE WHEN F_67_primary_sponsor_type IS NULL THEN ''	
           ELSE F_67_primary_sponsor_type	
           END  	
       +'|'+ CASE WHEN F_68_primary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), F_68_primary_copay)	
      ELSE ' '	
          END  	
       +'|'+ CASE WHEN F_69_primary_paid IS NOT NULL THEN CONVERT(VARCHAR(20), F_69_primary_paid)	
           ELSE ' '	
           END  	
       +'|'+ CASE WHEN primary_member_id IS NULL THEN ''	
         ELSE primary_member_id	
       END  	
     +'|'+ CASE WHEN primary_person_code IS NULL THEN ''	
       ELSE primary_person_code	
       END  	
       +'|'+ CASE WHEN F_70_benefit_plan_name2 IS NULL THEN ''	
       ELSE F_70_benefit_plan_name2	
           END  	
       +'|'+ CASE WHEN F_70_secondary_insurance IS NULL THEN ''	
           ELSE F_70_secondary_insurance	
       END  	
       +'|'+ CASE WHEN  F_71_secondary_BIN IS NULL THEN ''	
       ELSE F_71_secondary_BIN	
           END  	
       +'|'+ CASE WHEN F_72_secondary_PCN  IS NULL THEN ''	
           ELSE F_72_secondary_PCN	
           END  	
       +'|'+ CASE WHEN F_74_secondary_group IS NULL THEN ''	
           ELSE F_74_secondary_group	
           END  	
       +'|'+ CASE WHEN F_75_secondary_sponsor IS NULL THEN ''	
         ELSE F_75_secondary_sponsor	
         END  	
       +'|'+ CASE WHEN F_76_secondary_sponsor_type IS NULL THEN ''	
           ELSE F_76_secondary_sponsor_type	
           END  	
       +'|'+ CASE WHEN F_77_secondary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), F_77_secondary_copay)	
       ELSE ' '	
           END  	
       +'|'+ CASE WHEN F_78_secondary_paid IS NOT NULL THEN CONVERT(VARCHAR(20), F_78_secondary_paid)	
           ELSE ' '	
       END  	
       +'|'+ CASE WHEN F_79_benefit_plan_name3 IS NULL THEN ''	
           ELSE F_79_benefit_plan_name3	
           END  	
       +'|'+ CASE WHEN F_79_tertiary_insurance IS NULL THEN ''	
       ELSE F_79_tertiary_insurance	
           END  	
       +'|'+ CASE WHEN F_80_tertiary_BIN IS NULL THEN ''	
           ELSE F_80_tertiary_BIN	
           END  	
       +'|'+ CASE WHEN F_81_tertiary_PCN IS NULL THEN ''	
           ELSE F_81_tertiary_PCN	
           END  	
       +'|'+ CASE WHEN F_83_tertiary_group IS NULL THEN ''	
           ELSE F_83_tertiary_group	
           END  	
       +'|'+ CASE WHEN F_84_tertiary_sponsor IS NULL THEN ''	
           ELSE F_84_tertiary_sponsor	
           END  	
       +'|'+ CASE WHEN F_85_tertiary_sponsor_type IS NULL THEN ''	
           ELSE F_85_tertiary_sponsor_type	
           END  	
       +'|'+ CASE WHEN F_86_tertiary_copay IS NOT NULL THEN CONVERT(VARCHAR(20), F_86_tertiary_copay)	
       ELSE ' '	
           END  	
       +'|'+ CASE WHEN F_87_tertiary_paid  IS NOT NULL THEN CONVERT(VARCHAR(20), F_87_tertiary_paid)	
           ELSE ' '	
           END  	
       +'|'+  CONVERT(VARCHAR(20), F_88_patient_responsible_amount)  	
       +'|'+  partial_fill_yn	
       +'|'+  ch_pay_fill_yn 	
       +'|'+  yn_340b	
       +'|'+  CONVERT(VARCHAR(20), oth_pay_cov_amt) 	
       +'|'+  AUTH_NUM_primary	
       +'|'+  OTH_CVG_CODE_ID_primary 	
       +'|'+  AUTH_NUM_secondary	
       +'|'+  OTH_CVG_CODE_ID_secondary 	
       +'|'+  AUTH_NUM_tertiary	
       +'|'+  OTH_CVG_CODE_ID_tertiary 	
       +'|'+  CONVERT(VARCHAR(8), Fill_Initiated_Date, 112) 	
       +'|'+  CONVERT(VARCHAR(5), Fill_Initiated_Time, 108)	

         FROM	
            ORDER_MED  O_MED	

            INNER JOIN ORDER_MED_2  O_MED_2 ON O_MED_2.ORDER_ID = O_MED.ORDER_MED_ID	
            LEFT JOIN ORDER_MED_3  O_MED_3 ON O_MED_3.ORDER_ID = O_MED_2.ORDER_ID
            LEFT OUTER JOIN ORDER_MED_SIG SIG on O_MED.ORDER_MED_ID=SIG.ORDER_ID
            INNER JOIN ORDER_DISP_INFO  O_DISP_INFO ON O_DISP_INFO.ORDER_MED_ID = O_MED.ORDER_MED_ID 	
            INNER JOIN RX_PHR  RX_PHR ON O_DISP_INFO.DISPENSE_PHR_ID = RX_PHR.PHARMACY_ID	
            INNER JOIN RX_PHR_ADDRESS  RX_ADDR ON RX_ADDR.PHARMACY_ID = RX_PHR.PHARMACY_ID	
            INNER JOIN ORDER_DISP_INFO_2  O_DISP_INFO_PAT_PAY ON O_DISP_INFO_PAT_PAY.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND O_DISP_INFO_PAT_PAY.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            INNER JOIN ORDER_STATUS  O_STATUS ON O_STATUS.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND O_STATUS.ORD_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            INNER JOIN ORD_ACT_ORD_INFO  oaoi ON oaoi.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND oaoi.ORDER_DATE = O_DISP_INFO.CONTACT_DATE_REAL	
            INNER JOIN ORD_ACT_OT  ORD_ACTION_READY_TO_DISPENSE ON ORD_ACTION_READY_TO_DISPENSE.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_READY_TO_DISPENSE.ACTION_TYPE_C = 70	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILLED ON ORD_ACTION_FILLED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILLED.ACTION_TYPE_C = 45	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILLED_Ini ON ORD_ACTION_FILLED_Ini.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILLED_Ini.ACTION_TYPE_C = 40	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_READY_TO_VERIFY ON ORD_ACTION_READY_TO_VERIFY.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_READY_TO_VERIFY.ACTION_TYPE_C = 50	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_DATE_VERIFIED ON ORD_ACTION_DATE_VERIFIED.ACTION_ID = oaoi.ACTION_ID	
                                AND  ORD_ACTION_DATE_VERIFIED.ACTION_TYPE_C = 60	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FORCED_DISPENSED ON ORD_ACTION_FORCED_DISPENSED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FORCED_DISPENSED.ACTION_TYPE_C = 75	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_EXT_SYS_DISP ON ORD_ACTION_EXT_SYS_DISP.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_EXT_SYS_DISP.ACTION_TYPE_C = 76	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_DISPENSED ON ORD_ACTION_DISPENSED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_DISPENSED.ACTION_TYPE_C = 80	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILL_RETURNED ON ORD_ACTION_FILL_RETURNED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILL_RETURNED.ACTION_TYPE_C = 130	
            LEFT JOIN ZC_ACTION_TYPE_2  CURR_FILL_STS ON CURR_FILL_STS.ACTION_TYPE_2_C = O_DISP_INFO.FILL_STATUS_C	



            INNER JOIN CLARITY_MEDICATION  MED ON MED.MEDICATION_ID = O_MED.MEDICATION_ID	
            INNER JOIN PATIENT  PAT ON PAT.PAT_ID = O_MED.PAT_ID	
            Left Join	
                      (Select	
                          pat_id	
                        ,identity_id.IDENTITY_ID	
                        ,IDENTITY_TYPE_ID	
                        ,identity_id.LINE	
                         , MAX(identity_id.line) OVER (PARTITION BY Identity_id.Pat_id ) max_line	
                       From IDENTITY_ID	
                       Where IDENTITY_ID.IDENTITY_TYPE_ID = '1000'   --Community MRN of Patient	

                       )cmrn  on Pat.pat_id = cmrn.pat_id and cmrn.line = cmrn.max_line	
          Left Join	
                  (Select	
                      pat_id	
                    ,identity_id.IDENTITY_ID	
                    ,IDENTITY_TYPE_ID	
                    ,identity_id.LINE	
                     , MAX(identity_id.line) OVER (PARTITION BY Identity_id.Pat_id ) max_line	
                   From  IDENTITY_ID	
                   Where identity_id.IDENTITY_TYPE_ID = '0 '    --Enterprise MRN of Patient	
                   ) emrn  on Pat.pat_id = emrn.pat_id and	
          emrn.line = emrn.max_line	


      LEFT JOIN ZC_STATE  ZC_STATE ON ZC_STATE.STATE_C = PAT.STATE_C	
      LEFT JOIN ZC_SEX  ZC_SEX ON ZC_SEX.RCPT_MEM_SEX_C = PAT.SEX_C	
      LEFT JOIN zc_suffix on (pat.PAT_NAME_SUFFIX_C = zc_suffix.SUFFIX_C)	
      INNER JOIN PAT_ENC  PE ON PE.PAT_ENC_CSN_ID = O_MED.PAT_ENC_CSN_ID	
      INNER JOIN ORDER_MEDINFO  O_MED_INFO ON O_MED_INFO.ORDER_MED_ID = O_MED.ORDER_MED_ID	
      LEFT JOIN  clarity_ser  OrderProv ON OrderProv.PROV_ID = O_MED.ORD
eProv_ADDR.ADDR_LINE_1, O_MED_2.TXT_AUTHPROV_STREET, OrderProv_ADDR.ADDR_LINE_1, PRSCProv_ADDR.ADDR_LINE_1) F_21_adrsadd1_doc	
             , COALESCE(AuthProv_ADDR.ADDR_LINE_2, OutsideProv_ADDR.ADDR_LINE_2, NULL, OrderProv_ADDR.ADDR_LINE_2, PRSCProv_ADDR.ADDR_LINE_2) F_22_adrsadd2_doc	
             , COALESCE(AuthProv_ADDR.City, OutsideProv_ADDR.City, O_MED_2.TXT_AUTHPROV_CITY, OrderProv_ADDR.City, PRSCProv_ADDR.City) F_23_adrscity_doc	
             , COALESCE(ZC_AuthProv_STATE.ABBR, ZC_OutsideProv_STATE.ABBR, ZC_OutsideProv_2_STATE.ABBR, ZC_OrderProv_STATE.ABBR, ZC_PRSCProv_STATE.ABBR,O_MED_2.TXT_AUTHPROV_STAT_C ) F_24_adrsstate_doc	
             , COALESCE(AuthProv_ADDR.ZIP, OutsideProv_ADDR.ZIP, O_MED_2.TXT_AUTHPROV_ZIP, OrderProv_ADDR.Zip, PRSCProv_ADDR.Zip) F_25_adrzip_doc	
             , COALESCE(AuthProv_ADDR.PHONE, OutsideProv_ADDR.PHONE, O_MED_2.TXT_AUTHPROV_PHONE, OrderProv_ADDR.Phone, PRSCProv_ADDR.Phone) F_26_adrsphonenumber_doc	
             , COALESCE(AuthProv_ADDR.Fax, OutsideProv_ADDR.Fax, O_MED_2.TXT_AUTHPROV_Fax, OrderProv_ADDR.fax, PRSCProv_ADDR.fax) F_26_adrsfaxnumber_doc	
             , COALESCE(AuthProv_ZC_SPEC.NAME, OutsideProv_ZC_SPEC.NAME, NULL, OrderProv_ZC_SPEC.NAME, PRSCProv_ZC_SPEC.NAME) F_27_specialty_doc	
             , dept.DEPARTMENT_NAME F_28_provider_affiliation	
             , COALESCE(AuthProv.CLINICIAN_TITLE, OutsideProv.CLINICIAN_TITLE, OrderProv.CLINICIAN_TITLE, PrscProv.CLINICIAN_TITLE) F_29_clinician_credentials	
             ---------------------------------------	
             --  Data Category: Medication --	
             ---------------------------------------	
             , O_MED.DESCRIPTION F_30_name_drug	
             , NDC.RAW_11_DIGIT_NDC F_31_drugndcnbr_drug	
             , COALESCE(RX_NORM_CD_SCD.RXNORM_CODE, RX_NORM_CD_SBD.RXNORM_CODE) F_32_dv_medid	
             , O_DISP_INFO.RX_NUM_FORMATTED_HX F_33_rxnbr_rx	
             , O_DISP_INFO.FILL_NUMBER F_34_rx_refill_number	

             , O_MED.REFILLS F_35_refills_rx	
             , O_MED_2.DISP_QTY_REM F_36_qty_remain_rx	
             , MED.STRENGTH F_37_drug_strength	
             , IP_FREQ.FREQ_NAME F_38_drug_frequency	
             , O_MED.MED_DIS_DISP_QTY F_39_rxqty_rx	
             , O_DISP_INFO.FILL_SUPPLY_DAYS F_40_daysupp_rx	
             , DISPENSED_RX.NAME F_41_brandname_drug	
             , DISPENSED_RX.STRENGTH F_42_unit_strength_drug	
             , IP_FREQ.FREQ_NAME F_43_dispensed_frequency	
             , O_DISP_INFO.FILL_DISP_QTY F_44_dispensedqty1_rx	
             , SIG.SIG_TEXT F_45_regimen	
             , RX_DISP_LOT.RX_DISP_LOT_NUM F_46_lot_number	
             , RX_DISP_LOT_EXP_DATE.RX_DISP_LOT_EXP_DATE F_47_lot_expiration	
             , '              ' sku_number	
             , O_STATUS_First.INSTANT_OF_ENTRY date_received	
             ,   CASE WHEN O_MED_2.RX_WRITTEN_DATE >= COALESCE(FIRST_FILL.FILL_SERVICE_DATE, RxExtSysDispensedAction_FirstFill.ACTION_DTTM_LOCAL, RxDispensedAction_FirstFill.ACTION_DTTM_LOCAL)	
                                                            THEN O_MED_2.PRIORITIZED_INST_TM	
                                                            ELSE O_MED_2.RX_WRITTEN_DATE	
                                                         END F_48_date_written	
             , O_MED_3.PRESCRIP_EXP_DATE F_49_date_expire	
             , COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE) F_50_date_filled	
             , CASE WHEN ORD_ACTION_FILLED.ACTION_DTTM_LOCAL > ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL	
                                                            THEN COALESCE(ORD_ACTION_EXT_SYS_DISP.ACTION_DTTM_LOCAL, ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL, ORD_ACTION_FORCED_DISPENSED.ACTION_DTTM_LOCAL) -- to account for unusual workflows	
                                                            WHEN O_DISP_INFO.FILL_STATUS_C = 70 -- Ready to Dispense	
                                                            THEN NULL	
                                                            ELSE COALESCE(ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL, O_DISP_INFO.ACTION_INSTANT)	
                                                         END F_51_date_shipped	
             , COALESCE(RxExtSysDispensedAction_FirstFill.ACTION_DTTM_LOCAL, RxDispensedAction_FirstFill.ACTION_DTTM_LOCAL) F_52_first_ship_date	
             , O_MED.ORDER_MED_ID + '.' + O_STATUS.CONTACT_NUMBER F_53_shipment_ID	
             , O_DISP_INFO.ACQUISITION_COST F_54_drug_invoice_cost	
             , COALESCE(PrimaryRxa.O_USUAL_AND_CUSTOM, SecondaryRxa.O_USUAL_AND_CUSTOM, TertiaryRxa.O_USUAL_AND_CUSTOM, FILL_REQ_1.PLAN_PRICE_FOR_CVG) F_55_usual_customary_price	

             ---------------------------------------	
             --  Data Category: Pharmacy   --	
             ---------------------------------------	

             , RX_PHR.PHARMACY_NAME F_56_pharmacy_name	
             , RX_ADDR.ADDRESS F_57_pharmacy_address	

             ---------------------------------------	
             --  Data Category: Condition  --	
             ---------------------------------------	

             , DX_1.CURRENT_ICD10_LIST F_58_icd1_rx	
             , DX_2.CURRENT_ICD10_LIST F_59_icd2_rx	
             , DX_3.CURRENT_ICD10_LIST F_60_icd3_rx	

             ---------------------------------------	
             --  Data Category: Insurance  --	
             ---------------------------------------	
             ,  PLAN_1.BENEFIT_PLAN_NAME F_64_benefit_plan_name	
             , PAYOR_1.PAYOR_NAME F_61_primary_insurance	
             , COALESCE(PLAN_1_EPP_2.BIN_NUM, CONVERT(VARCHAR(20), PRIMARYRxa.OVR_NCPDP_VALUE)) F_62_primary_BIN 	
             , COALESCE(PLAN_1_EPP_2.PROCESSOR_CNTRL_NUM,COVERAGE_MEM_LIST.PCN_OVERRIDE,CONVERT(VARCHAR(20), PRIMARYRxa.OVR_NCPDP_VALUEA4)) F_63_primary_PCN	
             , CVG_1.GROUP_NUM F_65_primary_group	
             , NULL F_66_primary_sponsor	
             , FIN_CLS_1.financial_class_NAME F_67_primary_sponsor_type	
             , PrimaryRxa.CO_PAY F_68_primary_copay	
             , FILL_REQ_1.PAYOR_PAY_AMOUNT F_69_primary_paid	
             , PLAN_2.BENEFIT_PLAN_NAME F_70_benefit_plan_name2	
             , PAYOR_2.PAYOR_NAME F_70_secondary_insurance	
             , COALESCE(PLAN_2_EPP_2.BIN_NUM, CONVERT(VARCHAR(20), SecondaryRxa.OVR_NCPDP_VALUE  )) F_71_secondary_BIN	
             , COALESCE(PLAN_2_EPP_2.PROCESSOR_CNTRL_NUM,LST2.PCN_OVERRIDE,CONVERT(VARCHAR(20), SecondaryRxa.OVR_NCPDP_VALUEA4)) F_72_secondary_PCN	
             , CVG_2.GROUP_NUM F_74_secondary_group	
             , NULL F_75_secondary_sponsor	
             , FIN_CLS_2.financial_class_NAME F_76_secondary_sponsor_type	
             , SecondaryRxa.CO_PAY F_77_secondary_copay	
             , FILL_REQ_2.PAYOR_PAY_AMOUNT F_78_secondary_paid	
             , PLAN_3.BENEFIT_PLAN_NAME F_79_benefit_plan_name3	
             , PAYOR_3.PAYOR_NAME F_79_tertiary_insurance	
             , COALESCE(PLAN_3_EPP_2.BIN_NUM, CONVERT(VARCHAR(20), TertiaryRxa.OVR_NCPDP_VALUE )) F_80_tertiary_BIN	
             , COALESCE(PLAN_3_EPP_2.PROCESSOR_CNTRL_NUM,LST3.PCN_OVERRIDE,CONVERT(VARCHAR(20), TertiaryRxa.OVR_NCPDP_VALUEA4)) F_81_tertiary_PCN	
             , CVG_3.GROUP_NUM F_83_tertiary_group	
             , NULL F_84_tertiary_sponsor	
             , FIN_CLS_3.financial_class_NAME F_85_tertiary_sponsor_type	
             , TertiaryRxa.CO_PAY F_86_tertiary_copay	
             , FILL_REQ_3.PAYOR_PAY_AMOUNT F_87_tertiary_paid	
             , O_DISP_INFO.PAT_PAY_AMOUNT F_88_patient_responsible_amount	
             , O_DISP_INFO.CONTACT_DATE date_ordered	
             , O_DISP_INFO.FILL_IS_PARTIAL_YN partial_fill_yn	
             , O_DISP_INFO.cash_pay_yn  ch_pay_fill_yn	
             , COALESCE(PrimaryRxa.contact_date, SecondaryRxa.contact_date , TertiaryRxa.contact_date ) F_89_date_lt_adjudicated	
             , ORD_ACTION_DATE_VERIFIED.ACTION_DTTM date_verified	

             , COVERAGE_MEM_LIST.MEM_NUMBER primary_member_id	
             , COVERAGE_MEM_LIST.MEM_PERSON_CODE primary_person_code	
            ,CASE WHEN cl.mpi_id LIKE 'DSH330214%' THEN 'Y' ELSE 'N' END yn_340b

            --------------------------------------------------------------------------------	
            -- Columns for creating extract files based on calendar year and quarter when needed for backloading purposes	
            --------------------------------------------------------------------------------	
             , YEAR(COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE)) ORDER_YEAR	
             , DATEPART(QUARTER,COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE)) ORDER_QUARTER	
             , ROW_NUMBER() OVER (PARTITION BY	
                                          O_MED.ORDER_MED_ID + '.' + O_STATUS.CONTACT_NUMBER	
                                       ORDER BY  O_MED.ORDER_MED_ID + '.' + O_STATUS.CONTACT_NUMBER 	
                                      ) RN -- for filtering to insure no duplicates get sent based on order med id and contact number	
            ,O_DISP_INFO_PAT_PAY.OTH_PAY_COV_AMT  	
            --8/13/21 YC per Jodi Taszymowicz	
, PrimaryRxa.AUTH_NUM AUTH_NUM_primary	
, PrimaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_primary 	
, SecondaryRxa.AUTH_NUM AUTH_NUM_secondary	
, SecondaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_secondary 	
, TertiaryRxa.AUTH_NUM AUTH_NUM_tertiary	
, TertiaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_tertiary 	
, ORD_ACTION_FILLED_ini.ACTION_DTTM_LOCAL Fill_Initiated_Date           	
, CONVERT(VARCHAR(5), ORD_ACTION_FILLED_ini.ACTION_DTTM_LOCAL, 108)  Fill_Initiated_Time           	

            FROM ORDER_MED  O_MED	

            INNER JOIN ORDER_MED_2  O_MED_2 ON O_MED_2.ORDER_ID = O_MED.ORDER_MED_ID	
            LEFT JOIN ORDER_MED_3  O_MED_3 ON O_MED_3.ORDER_ID = O_MED_2.ORDER_ID
            LEFT OUTER JOIN ORDER_MED_SIG SIG on O_MED.ORDER_MED_ID=SIG.ORDER_ID
            INNER JOIN ORDER_DISP_INFO  O_DISP_INFO ON O_DISP_INFO.ORDER_MED_ID = O_MED.ORDER_MED_ID 	
            INNER JOIN RX_PHR  RX_PHR ON O_DISP_INFO.DISPENSE_PH
_ID = RX_PHR.PHARMACY_ID	
            INNER JOIN RX_PHR_ADDRESS  RX_ADDR ON RX_ADDR.PHARMACY_ID = RX_PHR.PHARMACY_ID	
            INNER JOIN ORDER_DISP_INFO_2  O_DISP_INFO_PAT_PAY ON O_DISP_INFO_PAT_PAY.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND O_DISP_INFO_PAT_PAY.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            INNER JOIN ORDER_STATUS  O_STATUS ON O_STATUS.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND O_STATUS.ORD_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            INNER JOIN ORD_ACT_ORD_INFO  oaoi ON oaoi.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND oaoi.ORDER_DATE = O_DISP_INFO.CONTACT_DATE_REAL	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_READY_TO_DISPENSE ON ORD_ACTION_READY_TO_DISPENSE.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_READY_TO_DISPENSE.ACTION_TYPE_C = 70	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILLED ON ORD_ACTION_FILLED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILLED.ACTION_TYPE_C = 45	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILLED_Ini ON ORD_ACTION_FILLED_Ini.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILLED_Ini.ACTION_TYPE_C = 40	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_READY_TO_VERIFY ON ORD_ACTION_READY_TO_VERIFY.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_READY_TO_VERIFY.ACTION_TYPE_C = 50	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_DATE_VERIFIED ON ORD_ACTION_DATE_VERIFIED.ACTION_ID = oaoi.ACTION_ID	
                                AND  ORD_ACTION_DATE_VERIFIED.ACTION_TYPE_C = 60	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FORCED_DISPENSED ON ORD_ACTION_FORCED_DISPENSED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FORCED_DISPENSED.ACTION_TYPE_C = 75	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_EXT_SYS_DISP ON ORD_ACTION_EXT_SYS_DISP.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_EXT_SYS_DISP.ACTION_TYPE_C = 76	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_DISPENSED ON ORD_ACTION_DISPENSED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_DISPENSED.ACTION_TYPE_C = 80	
            LEFT JOIN ORD_ACT_OT  ORD_ACTION_FILL_RETURNED ON ORD_ACTION_FILL_RETURNED.ACTION_ID = oaoi.ACTION_ID	
                                AND ORD_ACTION_FILL_RETURNED.ACTION_TYPE_C = 130	
            LEFT JOIN ZC_ACTION_TYPE_2  CURR_FILL_STS ON CURR_FILL_STS.ACTION_TYPE_2_C = O_DISP_INFO.FILL_STATUS_C	
            INNER JOIN CLARITY_MEDICATION  MED ON MED.MEDICATION_ID = O_MED.MEDICATION_ID	
            INNER JOIN PATIENT  PAT ON PAT.PAT_ID = O_MED.PAT_ID	
            LEFT JOIN (
                        SELECT pat_id, identity_id.IDENTITY_ID, IDENTITY_TYPE_ID, identity_id.LINE, 
                               MAX(identity_id.line) OVER (PARTITION BY Identity_id.Pat_id) max_line
                        FROM IDENTITY_ID	
                        WHERE IDENTITY_ID.IDENTITY_TYPE_ID = '1000'
                      ) cmrn ON Pat.pat_id = cmrn.pat_id AND cmrn.line = cmrn.max_line	
            LEFT JOIN (
                        SELECT pat_id, identity_id.IDENTITY_ID, IDENTITY_TYPE_ID, identity_id.LINE,
                               MAX(identity_id.line) OVER (PARTITION BY Identity_id.Pat_id) max_line	
                        FROM IDENTITY_ID	
                        WHERE identity_id.IDENTITY_TYPE_ID = '0'
                      ) emrn ON Pat.pat_id = emrn.pat_id AND emrn.line = emrn.max_line
            LEFT JOIN ZC_STATE ON ZC_STATE.STATE_C = PAT.STATE_C	
            LEFT JOIN ZC_SEX ON ZC_SEX.RCPT_MEM_SEX_C = PAT.SEX_C	
            LEFT JOIN zc_suffix ON (pat.PAT_NAME_SUFFIX_C = zc_suffix.SUFFIX_C)	
            INNER JOIN PAT_ENC  PE ON PE.PAT_ENC_CSN_ID = O_MED.PAT_ENC_CSN_ID	
            INNER JOIN ORDER_MEDINFO  O_MED_INFO ON O_MED_INFO.ORDER_MED_ID = O_MED.ORDER_MED_ID	
            LEFT JOIN clarity_ser OrderProv ON OrderProv.PROV_ID = O_MED.ORD_PROV_ID	
            LEFT JOIN CLARITY_SER_ADDR OrderProv_ADDR ON OrderProv_ADDR.PROV_ID = OrderProv.PROV_ID	
                                  AND OrderProv_ADDR.LINE = 1	
            LEFT JOIN ZC_STATE ZC_OrderProv_STATE ON ZC_OrderProv_STATE.STATE_C = OrderProv_ADDR.STATE_C	

            LEFT JOIN clarity_ser_2 orderProv_ser_2 ON (orderprov_ser_2.prov_id = OrderProv.PROV_ID)	
            LEFT JOIN CLARITY_SER_SPEC OrderPROV_SPEC ON OrderPROV_SPEC.PROV_ID = OrderProv.PROV_ID	
                                AND OrderPROV_SPEC.LINE = 1	
            LEFT JOIN ZC_SPECIALTY OrderProv_ZC_SPEC ON OrderProv_ZC_SPEC.SPECIALTY_C = OrderPROV_SPEC.SPECIALTY_C	
            LEFT JOIN CLARITY_SER_LICEN2 OrderPROV_LIC ON OrderPROV_LIC.PROV_ID = OrderProv.PROV_ID	
            LEFT JOIN clarity_ser PRSCProv ON PRSCProv.PROV_ID = O_MED.MED_PRESC_PROV_ID	
            LEFT JOIN CLARITY_SER_ADDR PRSCProv_ADDR ON PRSCProv_ADDR.PROV_ID = PRSCProv.PROV_ID	
                                AND PRSCProv_ADDR.LINE = 1	
            LEFT JOIN ZC_STATE ZC_PRSCProv_STATE ON ZC_PRSCProv_STATE.STATE_C = PRSCProv_ADDR.STATE_C	
            LEFT JOIN clarity_ser_2 PRSCProv_SER_2 ON (PRSCProv_SER_2.prov_id = PRSCProv.PROV_ID)		
            LEFT JOIN CLARITY_SER_SPEC PRSCProv_SPEC ON PRSCProv_SPEC.PROV_ID = PRSCProv.PROV_ID	
                                AND PRSCProv_SPEC.LINE = 1	
            LEFT JOIN ZC_SPECIALTY PRSCProv_ZC_SPEC ON PRSCProv_ZC_SPEC.SPECIALTY_C = PRSCProv_SPEC.SPECIALTY_C	
            LEFT JOIN CLARITY_SER_LICEN2 PrscPROV_LIC ON PrscPROV_LIC.PROV_ID = PrscProv.PROV_ID	
                                  AND PrscPROV_LIC.LINE = 1	
            LEFT JOIN clarity_ser AuthProv ON AuthProv.PROV_ID = O_MED.AUTHRZING_PROV_ID	
            LEFT JOIN CLARITY_SER_ADDR AuthProv_ADDR ON AuthProv_ADDR.PROV_ID = AuthProv.PROV_ID	
                                  AND AuthProv_ADDR.LINE = 1	
            LEFT JOIN ZC_STATE ZC_AuthProv_STATE ON ZC_AuthProv_STATE.STATE_C = AuthProv_ADDR.STATE_C	
            LEFT JOIN clarity_ser_2 AuthProv_Ser_2 ON (AuthProv_Ser_2.prov_id = AuthProv.PROV_ID)	
            LEFT JOIN CLARITY_SER_SPEC AUTHPROV_SPEC ON AUTHPROV_SPEC.PROV_ID = AUTHPROV.PROV_ID	
                                AND AUTHPROV_SPEC.LINE = 1	
            LEFT JOIN ZC_SPECIALTY AUTHProv_ZC_SPEC ON AUTHProv_ZC_SPEC.SPECIALTY_C = AUTHPROV_SPEC.SPECIALTY_C	
            LEFT JOIN CLARITY_SER_LICEN2 AuthPROV_LIC ON AuthPROV_LIC.PROV_ID = AuthProv.PROV_ID	
                                  AND AuthProv_LIC.LINE = 1	

            LEFT JOIN clarity_ser_2 outsideprov_ser_2 ON (outsideprov_ser_2.npi = O_MED_2.TXT_AUTHPROV_NPI)	
            LEFT JOIN clarity_ser outsideprov ON (outsideprov_ser_2.prov_id = outsideprov.prov_id)	

            LEFT JOIN CLARITY_SER_ADDR OutsideProv_ADDR ON OutsideProv_ADDR.PROV_ID = OutsideProv.PROV_ID	
                                  AND OutsideProv_ADDR.LINE = 1	
            LEFT JOIN ZC_STATE ZC_OutsideProv_STATE ON ZC_OutsideProv_STATE.STATE_C = OutsideProv_ADDR.STATE_C	
            LEFT JOIN ZC_STATE ZC_OutsidePROV_2_STATE ON ZC_OutsidePROV_2_STATE.STATE_C = O_MED_2.TXT_AUTHPROV_STAT_C	

            LEFT JOIN CLARITY_SER_SPEC OutsidePROV_SPEC ON OutsidePROV_SPEC.PROV_ID = OutsideProv.PROV_ID	
                                AND OutsidePROV_SPEC.LINE = 1	
            LEFT JOIN ZC_SPECIALTY OutsideProv_ZC_SPEC ON OutsideProv_ZC_SPEC.SPECIALTY_C = OutsidePROV_SPEC.SPECIALTY_C	
            LEFT JOIN CLARITY_SER_LICEN2 OutsidePROV_LIC ON OutsidePROV_LIC.PROV_ID = OutsideProv.PROV_ID	
                                  AND OutsidePROV_LIC.LINE = 1	


            LEFT JOIN RX_MED_ONE RX_MED_1 ON RX_MED_1.MEDICATION_ID = MED.MEDICATION_ID	
            LEFT JOIN RX_MED_THREE RX_MED_3 ON RX_MED_3.MEDICATION_ID = MED.MEDICATION_ID	

            OUTER APPLY	
               (	
                  SELECT  
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
                         , ooa.CONTACT_DATE	
                         ,  CASE  WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                         ,rno.OVR_NCPDP_VALUE	
                         ,rno1.OVR_NCPDP_VALUE AS OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS ooa	
                  LEFT JOIN RXA_ADJUD_MESSAGE rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2 rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4 rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3 rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN FCL_EXTRNL_CDE_LST fcl ON fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                  LEFT JOIN RXA_NCPDP_OVERRIDE rno ON rxa.RECORD_ID=rno.RECORD_ID	
                                    AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                                    AND rno.OVR_NCPDP_FIELD='101-A1'	
                  LEFT JOIN RXA_NCPDP_OVERRIDE rno1 ON rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                                    AND rno1.OVR_NCPDP_FIELD='104-A4'	

                 WHERE	
                     rxa.CONTACT_TYPE_C = 1 -- Primary	
                     AND rxa.STATUS_C <> 4 -- Failure	
                     AND ooa
                 WHERE	
                     rxa.CONTACT_TYPE_C = 1 -- Primary	
                     AND rxa.STATUS_C <> 4 -- Failure	
                     AND ooa.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                     AND ooa.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                  ORDER BY	
                     rxa.RECORD_ID DESC	
                   , rxa.CONTACT_SERIAL_NUM DESC	
               )  PrimaryRxa	


            OUTER APPLY	
               (	
                  SELECT  
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
                         , ooa.CONTACT_DATE	
                         , CASE  WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                         ,rno.OVR_NCPDP_VALUE	
                         ,rno1.OVR_NCPDP_VALUE OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS ooa	
                  LEFT JOIN RXA_ADJUD_MESSAGE rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2 rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4 rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3 rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                 LEFT JOIN FCL_EXTRNL_CDE_LST fcl ON fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                LEFT JOIN RXA_NCPDP_OVERRIDE rno ON rxa.RECORD_ID=rno.RECORD_ID	
                                    AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                                    AND rno.OVR_NCPDP_FIELD='101-A1'	
                 LEFT JOIN RXA_NCPDP_OVERRIDE rno1 ON rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                                    AND rno1.OVR_NCPDP_FIELD='104-A4'	
                 WHERE	
                     rxa.CONTACT_TYPE_C = 2 -- Secondary	
                     AND rxa.STATUS_C <> 4 -- Failure	
                     AND ooa.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                     AND ooa.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                  ORDER BY	
                     rxa.RECORD_ID DESC	
                   , rxa.CONTACT_SERIAL_NUM DESC	

               )  SecondaryRxa	

            OUTER APPLY	
               (	
                  SELECT  
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
                         , ooa.CONTACT_DATE	
                         , CASE WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                        ,rno.OVR_NCPDP_VALUE	
                        ,rno1.OVR_NCPDP_VALUE AS OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS ooa	
                  LEFT JOIN RXA_ADJUD_MESSAGE rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2 rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4 rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3 rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN FCL_EXTRNL_CDE_LST fcl ON fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                  LEFT JOIN RXA_NCPDP_OVERRIDE rno ON rxa.RECORD_ID=rno.RECORD_ID	
                              AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                              AND rno.OVR_NCPDP_FIELD='101-A1'	
                  LEFT JOIN RXA_NCPDP_OVERRIDE rno1 ON rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL	
                                    AND rno1.OVR_NCPDP_FIELD='104-A4'	

                 WHERE	
                     rxa.CONTACT_TYPE_C = 3 -- Tertiary	
                     AND rxa.STATUS_C <> 4 -- Failure	
                     AND ooa.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                     AND ooa.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                  ORDER BY	
                     rxa.RECORD_ID DESC	
                   , rxa.CONTACT_SERIAL_NUM DESC	
               )  TertiaryRxa	

            LEFT OUTER JOIN ORDER_DISP_MEDS O_DISP_MED ON O_DISP_MED.ORDER_MED_ID = O_DISP_INFO.ORDER_MED_ID	
                            AND O_DISP_MED.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                            AND O_DISP_MED.LINE = 1 	
            LEFT JOIN ORDER_DISP_INFO_2 O_DISP_INFO_2 ON O_DISP_INFO_2.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                            AND O_DISP_INFO_2.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            LEFT OUTER JOIN CLARITY_MEDICATION GENERIC_RX ON GENERIC_RX.MEDICATION_ID = O_DISP_MED.DISP_MED_ID	
      LEFT OUTER JOIN RX_NDC_STATUS NDC_STS ON O_DISP_MED.DISP_NDC_CSN = NDC_STS.CNCT_SERIAL_NUM	
      LEFT OUTER JOIN RX_NDC NDC ON NDC_STS.NDC_ID = NDC.NDC_ID	
      LEFT OUTER JOIN CLARITY_MEDICATION DISPENSED_RX ON DISPENSED_RX.MEDICATION_ID = NDC_STS.MEDICATION_ID	

            LEFT OUTER JOIN RX_FILL_COVERAGES FILL_REQ_1 ON FILL_REQ_1.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_1.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_1.LINE = 1	
            LEFT JOIN COVERAGE CVG_1 ON CVG_1.COVERAGE_ID = FILL_REQ_1.RX_COVERAGES_ID	
            LEFT JOIN CLARITY_EPP PLAN_1 ON PLAN_1.BENEFIT_PLAN_ID = CVG_1.PLAN_ID	
            LEFT JOIN CLARITY_EPM PAYOR_1 ON PAYOR_1.PAYOR_ID = CVG_1.PAYOR_ID	
            LEFT JOIN CLARITY_FC FIN_CLS_1 ON FIN_CLS_1.financial_class = PAYOR_1.financial_class 	
            LEFT JOIN CLARITY_EPP_2 PLAN_1_EPP_2 ON PLAN_1.BENEFIT_PLAN_ID = PLAN_1_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE PLAN_TYPE_1 ON PLAN_1_EPP_2.PROD_TYPE_C = PLAN_TYPE_1.PROD_TYPE_C	
            LEFT JOIN COVERAGE_MEM_LIST ON cvg_1.COVERAGE_ID = COVERAGE_MEM_LIST.COVERAGE_ID	
            	
            LEFT JOIN RX_FILL_COVERAGES FILL_REQ_2 ON FILL_REQ_2.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_2.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_2.LINE = 2	
            LEFT JOIN COVERAGE CVG_2 ON CVG_2.COVERAGE_ID = FILL_REQ_2.RX_COVERAGES_ID	
            LEFT JOIN CLARITY_EPP PLAN_2 ON PLAN_2.BENEFIT_PLAN_ID = CVG_2.PLAN_ID	
            LEFT JOIN CLARITY_EPM PAYOR_2 ON PAYOR_2.PAYOR_ID = CVG_2.PAYOR_ID	
            LEFT JOIN CLARITY_FC FIN_CLS_2 ON FIN_CLS_2.financial_class = PAYOR_2.financial_class 	
      LEFT JOIN CLARITY_EPP_2 PLAN_2_EPP_2 ON PLAN_2.BENEFIT_PLAN_ID = PLAN_2_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE PLAN_TYPE_2 ON PLAN_2_EPP_2.PROD_TYPE_C = PLAN_TYPE_2.PROD_TYPE_C	
            LEFT OUTER JOIN COVERAGE_MEM_LIST LST2 ON CVG_2.COVERAGE_ID=LST2.COVERAGE_ID	
            	
            LEFT JOIN RX_FILL_COVERAGES FILL_REQ_3 ON FILL_REQ_3.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_3.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_3.LINE = 3	
            LEFT JOIN COVERAGE CVG_3 ON CVG_3.COVERAGE_ID = FILL_REQ_3.RX_COVERAGES_ID	
      LEFT JOIN CLARITY_EPP PLAN_3 ON PLAN_3.BENEFIT_PLAN_ID = CVG_3.PLAN_ID	
      LEFT JOIN CLARITY_EPM PAYOR_3 ON PAYOR_3.PAYOR_ID = CVG_3.PAYOR_ID	
      LEFT JOIN CLARITY_FC FIN_CLS_3 ON FIN_CLS_3.financial_class = PAYOR_3.financial_class 	
      LEFT JOIN CLARITY_EPP_2 PLAN_3_EPP_2 ON PLAN_3.BENEFIT_PLAN_ID = PLAN_3_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE PLAN_TYPE_3 ON PLAN_3_EPP_2.PROD_TYPE_C = PLAN_TYPE_3.PROD_TYPE_C	
            LEFT OUTER JOIN COVERAGE_MEM_LIST LST3 ON CVG_3.COVERAGE_ID=LST3.COVERAGE_ID	

            LEFT JOIN IP_FREQUENCY IP_FREQ ON IP_FREQ.FREQ_ID = O_MED.HV_DISCR_FREQ_ID	
            LEFT JOIN ZC_MED_UNIT ZC_MED_UNIT ON ZC_MED_UNIT.DISP_QTYUNIT_C = O_MED.DOSE_UNIT_C	
            	
            LEFT JOIN ORDER_DISP_INFO FIRST_FILL ON FIRST_FILL.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                  AND FIRST_FILL.ORD_CNTCT_TYPE_C = 11 -- Fill	
                                  AND FIRST_FILL.FILL_NUMBER = 0 -- first fill	
                                  AND FIRST_FILL.FILL_STATUS_C <> 100 -- Canceled	
            LEFT JOIN ORDER_STATUS O_STATUS_First ON O_STATUS_First.ORDER_ID = FIRST_FILL.ORDER_MED_ID	
                                AND O_STATUS_First.ORD_DATE_REAL = FIRST_FILL.CONTACT_DATE_REAL	
            LEFT JOIN ORD_ACT_ORD_INFO O_ACT_O_INFO_FIRST_FILL ON O_ACT_O_INFO_FIRST_FILL.ORDER_ID = FIRST_FILL.ORDER_MED_ID	
                              AND O_ACT_O_INFO_FIRST_FILL.ORDER_DATE = FIRST_FILL.CONTACT_DATE_REAL	
            LEFT JOIN ORD_ACT_OT RxDispensedAction_FirstFill ON RxDispensedAction_FirstFill.ACTION_ID = O_ACT_O_INFO_FIRST_FILL.ACTION_ID	
                              AND RxDispensedAction_FirstFill.ACTION_TYPE_C =
 80 -- Dispensed	
            LEFT JOIN ORD_ACT_OT RxExtSysDispensedAction_FirstFill ON RxExtSysDispensedAction_FirstFill.ACTION_ID = O_ACT_O_INFO_FIRST_FILL.ACTION_ID	
                              AND RxExtSysDispensedAction_FirstFill.ACTION_TYPE_C = 76 -- External System Dispensed	
            	
            LEFT JOIN ORDER_DX_MED O_DX_MED_1 ON O_DX_MED_1.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_1.LINE = 1	
            LEFT JOIN CLARITY_EDG DX_1 ON DX_1.DX_ID = O_DX_MED_1.DX_ID	
            LEFT JOIN ORDER_DX_MED O_DX_MED_2 ON O_DX_MED_2.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_2.LINE = 2	
            LEFT JOIN CLARITY_EDG DX_2 ON DX_2.DX_ID = O_DX_MED_2.DX_ID	
            LEFT JOIN ORDER_DX_MED O_DX_MED_3 ON O_DX_MED_3.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_3.LINE = 3	
            LEFT JOIN CLARITY_EDG DX_3 ON DX_3.DX_ID = O_DX_MED_3.DX_ID	
            LEFT JOIN CLARITY_DEP DEPT ON DEPT.DEPARTMENT_ID = O_MED.PAT_LOC_ID	
            LEFT JOIN	
               (	
                  SELECT	
                     RX_NORM_CD.MEDICATION_ID	
                   , RX_NORM_CD.RXNORM_CODE	
                   , RX_NORM_CD.LINE	
                   , MIN(RX_NORM_CD.LINE) OVER (PARTITION BY RX_NORM_CD.MEDICATION_ID ) MIN_LINE	
                  FROM RXNORM_CODES RX_NORM_CD	
                  WHERE RX_NORM_CD.RXNORM_TERM_TYPE_C = 9 -- Semantic Clinical Drug	
               ) RX_NORM_CD_SCD	
               ON RX_NORM_CD_SCD.MEDICATION_ID = MED.MEDICATION_ID	
                  AND RX_NORM_CD_SCD.LINE = RX_NORM_CD_SCD.MIN_LINE	
            LEFT JOIN	
               (	
                  SELECT	
                     RX_NORM_CD.MEDICATION_ID	
                   , RX_NORM_CD.RXNORM_CODE	
                   , RX_NORM_CD.LINE	
                   , MIN(RX_NORM_CD.LINE) OVER (PARTITION BY RX_NORM_CD.MEDICATION_ID ) MIN_LINE	
                  FROM RXNORM_CODES RX_NORM_CD	
                  WHERE RX_NORM_CD.RXNORM_TERM_TYPE_C = 14 -- Semantic Clinical Drug	
               ) RX_NORM_CD_SBD	
               ON RX_NORM_CD_SBD.MEDICATION_ID = MED.MEDICATION_ID	
                  AND RX_NORM_CD_SBD.LINE = RX_NORM_CD_SBD.MIN_LINE	
            	
            LEFT JOIN CL_DEP_ID cl ON cl.department_id=O_MED.PAT_LOC_ID AND cl.mpi_id_type_id='143' --340B ID DSH330214xx	
            LEFT JOIN ZC_STATE EXT_PROV_STATE ON EXT_PROV_STATE.STATE_C = O_MED_2.TXT_AUTHPROV_STAT_C	
            	
            LEFT JOIN	
               (	
                  SELECT	
                     X.PAT_LINK_ID	
                   ,   MAX( CASE  WHEN X.RN = 1	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      ) SORT_CODE_1	
                   ,   MAX(  CASE   WHEN X.RN = 2	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      ) SORT_CODE_2	
                   ,   MAX(  CASE   WHEN X.RN = 3	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      )SORT_CODE_3	
                   ,   MAX(  CASE  WHEN X.RN = 4	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      )SORT_CODE_4	
                  FROM	
                     (	
                        SELECT	
                           sc.PAT_LINK_ID	
                         , sc.SORT_CODE	
                         , sc.RN	
                        FROM	
                           SORT_CODE sc	
                     ) X	
                  GROUP BY	
                     X.PAT_LINK_ID	
               ) S_CODE ON S_CODE.PAT_LINK_ID = PAT.PAT_ID 	
      LEFT JOIN RX_DISP_LOT ON (o_med.ORDER_MED_ID = rx_disp_lot.order_med_id)	
      LEFT JOIN RX_DISP_LOT_EXP_DATE ON (o_med.ORDER_MED_ID = RX_DISP_LOT_EXP_DATE.ORDER_MED_ID)	
            	
            WHERE	
               O_MED.ORDERING_MODE_C = 1 -- Outpatient script	
         AND O_DISP_INFO.DISPENSE_PHR_ID IN (4084100019) --  NYU LANGONE PHARMACY COBBLE HILL	
         AND O_DISP_INFO.ORD_CNTCT_TYPE_C = 11 -- Fill Request	
         AND O_DISP_INFO.fill_status_c IN (36, 40,45,50,60,70,80,81,82)	
                                -- 36 Ready to Fill	
                                --40 - Fill Initiated	
                                -- 45 - Filled	
                                -- 50 - Ready to Verify	
                                -- 60 - Verified	
                                -- 70 - Ready to Dispense	
                                -- 80 - Dispensed	
                                -- 81 - Shipped	
                                -- 82 - Delivered	

         AND COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE ) >= @START_dt 
             AND COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE ) < @END_dt+1
         )  X    WHERE  X.RN = 1
        ORDER BY 1
    )
         ;
END
