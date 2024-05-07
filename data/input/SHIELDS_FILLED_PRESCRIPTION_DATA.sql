CREATE OR REPLACE PROCEDURE SHIELDS_FILLED_PRESCRIPTION_DATA (  p_recordset OUT SYS_REFCURSOR) as
begin
--SET NOCOUNT ON;
--USE CLARITY;
--
-- Set start and end dates. This script runs daily and has two outputs:
-- Frequency of upload: On Saturday, weekly for previous 7 days (Saturday ? Friday). On 1st of each month, previous 6 weeks.

--DECLARE @START_DATE AS DATETIME;
--DECLARE @END_DATE   AS DATETIME = CAST(getdate() AS DATE); -- Cast sets time to midnight (00:00:00.000)
DECLARE
START_dtW date:= trunc(sysdate-7);
END_dtW date:= trunc(sysdate-1);

START_dtM date:=trunc(sysdate-42); ---previous 6 weeks.
END_dtM date:= trunc(sysdate-1);

START_dt date;
END_dt date;

/*IF (UPPER(DATENAME(dw,END_DATE)) <> 'SATURDAY')
BEGIN
    -- Today is Sunday-Friday
    SET START_DATE = END_DATE - 7;
END
ELSE
BEGIN
    -- Today is Saturday
    SET START_DATE = END_DATE - 6;
END
end if;
-- BETWEEN is inclusive. Set end date to yesterday at 23:59:59.997 so midnight today is not included.
SET END_DATE = DATEADD(ms, -3, END_DATE);
--
-- END DATE CONDITIONS
--
*/
--      DROP TABLE IF EXISTS SORT_CODE;
begin
if trim(to_char(SYSDATE, 'DAY'))='SATURDAY' then --- YC 7/19/21 should be trimmed -> to_char(SYSDATE, 'DAY') returns 'SATURDAY '
   START_dt := START_dtM;
   END_dt := END_dtM;
else 
   START_dt := START_dtW;
   END_dt := END_dtW;
end if;

open p_recordset for	
with SORT_CODE as (	

      SELECT	
         X.PAT_LINK_ID	
       , X.SORT_CODE	
       , ROW_NUMBER() OVER (PARTITION BY X.PAT_LINK_ID ORDER BY PAT_LINK_ID) RN	
      FROM	
         (	
            SELECT   DISTINCT	
                     E.PAT_LINK_ID,EPISODE_DEF.EPISODE_DEF_NAME	
                   , case when zep.ABBR IN (	
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
            FROM EPISODE  E	
            INNER JOIN EPISODE_2 e2 ON e2.EPISODE_ID = E.EPISODE_ID	
      LEFT JOIN ZC_ENROLL_PROG  zep ON zep.ENROLL_PROG_C = e2.ENROLL_PROG_C	
        join EPISODE_DEF on   EPISODE_DEF.EPISODE_DEF_ID=E.SUM_BLK_TYPE_ID	
            WHERE	
               E.SUM_BLK_TYPE_ID = 29 -- SPECIALTY PHARMACY ENROLLMENT	
         )  X	
     )  	
     SELECT trim(str) str	
  FROM	
     (SELECT ' UNIQUE_RECORD_ID|SORTCODE1_PATIENT|SORTCODE2_PATIENT|SORTCODE3_PATIENT|SORTCODE4_PATIENT|MRN_PATIENT|SP_PATIENT_ID|NAMEFIRST_PATIENT|NAMEMIDDLE_PATIENT|NAMELAST_PATIENT|NAMESUFFIX_PATIENT|DOB_PATIENT|ADRSADD1_PATIENT|ADRSADD2_PATIENT|ADRSCITY_PATIENT|ADRSSTATE_PATIENT|ADRSZIP_PATIENT|ADRSPHONENUMBER_PATIENT|SEX_PATIENT|NAMEFIRST_DOC|NAMEMIDDLE_DOC|NAMELAST_DOC|PRESCRIBING_NPI|PRESCRIBER_DEA|PRESCRIBER_STATE_LICENSE|PRESCRIBER_ME|ADRSADD1_DOC|ADRSADD2_DOC|ADRSCITY_DOC|ADRSSTATE_DOC|ADRZIP_DOC|ADRSPHONENUMBER_DOC|ADRSFAXNUMBER_DOC|SPECIALTY_DOC|PROVIDER_AFFILIATION|CLINICIAN_CREDENTIALS|NAME_DRUG|DRUGNDCNBR_DRUG|DV_MEDID|RXNBR_RX|RX_REFILL_NUMBER|REFILLS_RX|QTY_REMAIN_RX|DRUG_STRENGTH|DRUG_FREQUENCY|RXQTY_RX|DAYSUPP_RX|BRANDNAME_DRUG|UNIT_STRENGTH_DRUG|DISPENSED_FREQUENCY|DISPENSEDQTY1_RX|REGIMEN|LOT_NUMBER|LOT_EXPIRATION|SKU_NUMBER|DATE_RECEIVED|DATE_WRITTEN|DATE_ORDERED|DATE_EXPIRE|DATE_LAST_ADJUDICATED|DATE_FILLED|DATE_VERIFIED|DATE_SHIPPED|FIRST_SHIP_DATE|SHIPMENT_ID|DRUG_INVOICE_COST|USUAL_CUSTOMARY_PRICE|PHARMACY_NAME|PHARMACY_ADDRESS|ICD1_RX|ICD2_RX|ICD3_RX|BENEFIT_PLAN_NAME|PRIMARY_INSURANCE|PRIMARY_BIN|PRIMARY_PCN|PRIMARY_GROUP|PRIMARY_SPONSOR|PRIMARY_SPONSOR_TYPE|PRIMARY_COPAY|PRIMARY_PAID|PRIMARY_MEMBER_ID|PRIMARY_PERSON_CODE|BENEFIT_PLAN_NAME2|SECONDARY_INSURANCE|SECONDARY_BIN|SECONDARY_PCN|SECONDARY_GROUP|SECONDARY_SPONSOR|SECONDARY_SPONSOR_TYPE|SECONDARY_COPAY|SECONDARY_PAID|BENEFIT_PLAN_NAME3|TERTIARY_INSURANCE|TERTIARY_BIN|TERTIARY_PCN|TERTIARY_GROUP|TERTIARY_SPONSOR|TERTIARY_SPONSOR_TYPE|TERTIARY_COPAY|TERTIARY_PAID|PATIENT_RESPONSIBLE_AMOUNT|PARTIAL_FILL_YN|CASH_PAY_FILL_YN|YN_340B|OTH_PAY_COV_AMT|PRIMARY_CLAIM_AUTH_NUMBER|PRIMARY_OTHER_COVERAGE_CODE|SECONDARY_CLAIM_AUTH_NUMBER|SECONDARY_OTHER_COVERAGE_CODE|TERTIARY_CLAIM_AUTH_NUMBER|TERTIARY_OTHER_COVERAGE_CODE|FILL_INITIATED_DATE|FILL_INITIATED_TIME' str	


    FROM dual    	
    UNION	
   SELECT	

       X.F_01_unique_record_id                   	
       ||'|'|| case when X.F_02_sortcode2_patient is null then ''	
       else X.F_02_sortcode2_patient	
           end  	
       ||'|'|| case when X.F_03_sortcode2_patient is null then ''	
           else X.F_03_sortcode2_patient	
       end  	
       ||'|'|| case when X.F_04_sortcode3_patient is null then ''	
       else X.F_04_sortcode3_patient	
       end  	
       ||'|'|| case when X.F_05_sortcode4_patient is null then ''	
           else X.F_05_sortcode4_patient	
       end  	
     ||'|'|| case when  X.F_06_mrn_patient is null then ''	
        else  X.F_06_mrn_patient	
      end   	
       ||'|'|| case when F_06b_sp_patientID is null then ''	
           else F_06b_sp_patientID	
           end  	
       ||'|'||  X.F_07_namefirst_patient                	
     ||'|'|| case when x.f_07_Namemiddle_patient  is null then ''	
       else x.f_07_Namemiddle_patient	
           end  	
       ||'|'||  X.F_08_namelt_patient                 	
     ||'|'|| case when x.f_08_namesuffix_patient  is null then ''	
           else x.f_08_namesuffix_patient	
       end  	
       ||'|'||  X.F_09_dob_patient                      	
       ||'|'||  X.F_10_adrsadd1_patient                 	
       ||'|'|| case when X.F_11_adrsadd2_patient is null then ''	
       else X.F_11_adrsadd2_patient	
       end  	
       ||'|'||  X.F_12_adrscity_patient                 	
       ||'|'||  X.F_13_adrsstate_patient                	
       ||'|'||  X.F_14_adrszip_patient                  	
       ||'|'|| case when X.F_15_adrsphonenumber_patient is null then ''	
         else X.F_15_adrsphonenumber_patient	
       end  	
       ||'|'||  X.F_16_sex_patient                      	
       ||'|'|| case when X.F_17_namefirst_doc is not null then UPPER(regexp_replace(X.F_17_namefirst_doc,	
              '^.+?,\s*(MD,|)([A-Za-z]\.|)\s*((.+) [A-Za-z]|(.+))$|^(.+?) ([A-Za-z][\.]{0,1} |).+$',	
             '\4\5\6', 1, 1)) end 	

        ||'|'|| case when X.F_17_namemiddle_doc is null then ''	
              else X.F_17_namemiddle_doc  end  	

        ||'|'|| case when X.F_18_namelt_doc is not null then UPPER(regexp_replace(X.F_18_namelt_doc,	
             '^(.+?),\s*(MD,|)([A-Za-z]\.|)\s*(.+ [A-Za-z]|.+)$|^.+? ([A-Za-z][\.]{0,1} |)(.+)$',	
             '\1\6', 1, 1)) end 	


      -- , X.F_18_namesuffix_doc                   'namesuffix_doc	
       ||'|'|| case when X.F_19_prescribing_NPI is null then ''	
       else x.F_19_prescribing_NPI	
       end  	

       ||'|'|| case when X.F_20_prescriber_DEA  is null then ''	
           else X.F_20_prescriber_DEA	
       end  	
       ||'|'|| case when X.prescriber_state_license is null then ''	
       else X.prescriber_state_license	
           end  	
     ||'|'||  x.prescriber_me 	
       ||'|'|| case when X.F_21_adrsadd1_doc is null then ''	
         else X.F_21_adrsadd1_doc	
           end  	
       ||'|'|| case when X.F_22_adrsadd2_doc is null then ''	
           else X.F_22_adrsadd2_doc	
           end  	
       ||'|'|| case when X.F_23_adrscity_doc is null then ''	
           else X.F_23_adrscity_doc	
           end  	
       ||'|'|| case when X.F_24_adrsstate_doc is null then ''	
           else X.F_24_adrsstate_doc	
           end  	
       ||'|'|| case when X.F_25_adrzip_doc is null then ''	
           else X.F_25_adrzip_doc	
           end  	
       ||'|'|| case when X.F_26_adrsphonenumber_doc  is null then ''	
       else  X.F_26_adrsphonenumber_doc	
       end  	
     ||'|'|| case when x.F_26_adrsfaxnumber_doc is null then ''	
         else x.F_26_adrsfaxnumber_doc	
           end  	
       ||'|'|| case when X.F_27_specialty_doc is null then ''	
       else X.F_27_specialty_doc	
           end  	
       ||'|'||  X.F_28_provider_affiliation             	
       ||'|'|| case when X.F_29_clinician_credentials is null then ''	
       else X.F_29_clinician_credentials	
       end  	
       ||'|'||  X.F_30_name_drug                        	
       ||'|'||  X.F_31_drugndcnbr_drug                  	
       ||'|'|| case when X.F_32_dv_medid is null then ''	
           else X.F_32_dv_medid	
       end  	
       ||'|'||  X.F_33_rxnbr_rx                         	
       ||'|'||  X.F_34_rx_refill_number                 	
       ||'|'||  X.F_35_refills_rx                       	
       ||'|'||  X.F_36_qty_remain_rx                    	
       ||'|'|| case when X.F_37_drug_strength is null then ''	
       else X.F_37_drug_strength	
           end  	
       ||'|'|| case when X.F_38_drug_frequency is null then ''	
       else X.F_38_drug_frequency	
           end  	
       ||'|'||  X.F_39_rxqty_rx                         	
       ||'|'||  X.F_40_daysupp_rx                       	
       ||'|'||  X.F_41_brandname_drug           	
       ||'|'|| case when X.F_42_unit_strength_drug is null then ''	
           else X.F_42_unit_strength_drug	
           end  	
       ||'|'|| case when X.F_43_dispensed_frequency is null then ''	
       else X.F_43_dispensed_frequency	
           end  	
       ||'|'||  X.F_44_dispensedqty1_rx                 	
       ||'|'||  X.F_45_regimen                          	
       ||'|'|| case when X.F_46_lot_number is null then ''	
       else X.F_46_lot_number	
           end  	
       ||'|'|| case when X.F_47_lot_expiration  is not null then to_char(X.F_47_lot_expiration,'yyyymmdd') --  nvarchar(20))	
       else ' '	
           end  	

       ||'|'||  x.sku_number                            	
       ||'|'||  X.date_received                         	
       ||'|'||  X.F_48_date_written                     	
     ||'|'|| to_char(date_ordered,'yyyymmdd')  --CONVERT(VARCHAR(10),date_ordered,112)	
       ||'|'||  X.F_49_date_expire                      	

     ||'|'|| case when x.F_89_date_lt_adjudicated is null then ''	
       else to_char(x.F_89_date_lt_adjudicated,'yyyymmdd') --convert(varchar(10),x.F_89_date_lt_adjudicated,112)	
       end  	

      ||'|'||  X.F_50_date_filled              	
     ||'|'|| to_char(date_verified,'yyyymmdd')    --convert(varchar(10),date_verified,112)	
       ||'|'|| case when X.F_51_date_shipped is null then ''	
       else X.F_51_date_shipped	
           end  	
       ||'|'|| case when X.F_52_first_ship_date is null then ''	
           else X.F_52_first_ship_date	
           end  	
       ||'|'||  X.F_53_shipment_ID                      	
       ||'|'||  X.F_54_drug_invoice_cost                	
       ||'|'|| case when X.F_55_usual_customary_price is not null then  to_char(X.F_55_usual_customary_price)--CT(X.F_55_usual_customary_price  nvarchar(20))	
       else ' '	
           end  	
       ||'|'||  X.F_56_pharmacy_name                    	
       ||'|'||  X.F_57_pharmacy_address                 	
       ||'|'|| case when X.F_58_icd1_rx is null then ''	
           else X.F_58_icd1_rx	
           end  	
       ||'|'|| case when X.F_59_icd2_rx is null then ''	
           else X.F_59_icd2_rx	
           end  	
       ||'|'|| case when X.F_60_icd3_rx  is null then ''	
       else X.F_60_icd3_rx	
           end  	
       ||'|'|| case when X.F_64_benefit_plan_name is null then ''	
           else X.F_64_benefit_plan_name	
       end  	
       ||'|'|| case when X.F_61_primary_insurance is null then ''	
           else X.F_61_primary_insurance	
           end  	
     ||'|'|| case when X.F_62_primary_BIN is null then ''	
           else X.F_62_primary_BIN	
           end  	
       ||'|'|| case when X.F_63_primary_PCN is null then ''	
           else X.F_63_primary_PCN	
           end  	
       ||'|'|| case when X.F_65_primary_group is null then ''	
       else X.F_65_primary_group	
           end  	
       ||'|'|| case when X.F_66_primary_sponsor is null then ''	
       else X.F_66_primary_sponsor	
           end  	
       ||'|'|| case when X.F_67_primary_sponsor_type is null then ''	
           else X.F_67_primary_sponsor_type	
           end  	
       ||'|'|| case when X.F_68_primary_copay is not null then to_char(X.F_68_primary_copay)--CT(X.F_68_primary_copay  nvarchar(20))	
      else ' '	
          end  	
       ||'|'|| case when X.F_69_primary_paid is not null then to_char(F_69_primary_paid)--CT(X.F_69_primary_paid  nvarchar(20))	
           else ' '	
           end  	
       ||'|'|| case when primary_member_id is null then ''	
         else primary_member_id	
       end  	
     ||'|'|| case when primary_person_code is null then ''	
       else primary_person_code	
       end  	
       ||'|'|| case when X.F_70_benefit_plan_name2 is null then ''	
       else X.F_70_benefit_plan_name2	
           end  	
       ||'|'|| case when X.F_70_secondary_insurance is null then ''	
           else X.F_70_secondary_insurance	
       end  	
       ||'|'|| case when  X.F_71_secondary_BIN is null then ''	
       else X.F_71_secondary_BIN	
           end  	
       ||'|'|| case when X.F_72_secondary_PCN  is null then ''	
           else X.F_72_secondary_PCN	
           end  	
       ||'|'|| case when X.F_74_secondary_group is null then ''	
           else X.F_74_secondary_group	
           end  	
       ||'|'|| case when X.F_75_secondary_sponsor is null then ''	
         else X.F_75_secondary_sponsor	
         end  	
       ||'|'|| case when X.F_76_secondary_sponsor_type is null then ''	
           else X.F_76_secondary_sponsor_type	
           end  	
       ||'|'|| case when X.F_77_secondary_copay is not null then to_char(X.F_77_secondary_copay)--CT(X.F_77_secondary_copay  nvarchar(20))	
       else ' '	
           end  	
       ||'|'|| case when X.F_78_secondary_paid is not null then to_char(X.F_78_secondary_paid)--CT(X.F_78_secondary_paid  nvarchar(20))	
           else ' '	
       end  	
       ||'|'|| case when X.F_79_benefit_plan_name3 is null then ''	
           else X.F_79_benefit_plan_name3	
           end  	
       ||'|'|| case when X.F_79_tertiary_insurance is null then ''	
       else X.F_79_tertiary_insurance	
           end  	
       ||'|'|| case when X.F_80_tertiary_BIN is null then ''	
           else X.F_80_tertiary_BIN	
           end  	
       ||'|'|| case when X.F_81_tertiary_PCN is null then ''	
           else X.F_81_tertiary_PCN	
           end  	
       ||'|'|| case when X.F_83_tertiary_group is null then ''	
           else X.F_83_tertiary_group	
           end  	
       ||'|'|| case when X.F_84_tertiary_sponsor is null then ''	
           else X.F_84_tertiary_sponsor	
           end  	
       ||'|'|| case when X.F_85_tertiary_sponsor_type is null then ''	
           else X.F_85_tertiary_sponsor_type	
           end  	
       ||'|'|| case when X.F_86_tertiary_copay is not null then to_char(X.F_86_tertiary_copay)--CT(X.F_86_tertiary_copay  nvarchar(20))	
       else ' '	
           end  	
       ||'|'|| case when X.F_87_tertiary_paid  is not null then to_char(X.F_87_tertiary_paid)--CT(X.F_87_tertiary_paid  nvarchar(20))	
           else ' '	
           end  	
       ||'|'||  X.F_88_patient_responsible_amount  	
       ||'|'||  X.partial_fill_yn	
       ||'|'||  X.ch_pay_fill_yn 	
       ||'|'||  X.yn_340b	
       ||'|'|| oth_pay_cov_amt 	
       ||'|'||AUTH_NUM_primary	
       --8/13/21 YC added	
        ||'|'||OTH_CVG_CODE_ID_primary 	
        ||'|'||AUTH_NUM_secondary	
        ||'|'||OTH_CVG_CODE_ID_secondary 	
        ||'|'||AUTH_NUM_tertiary	
        ||'|'||OTH_CVG_CODE_ID_tertiary 	
        ||'|'||Fill_Initiated_Date -- 9/23/20 YC added	
        ||'|'||Fill_Initiated_Time -- 9/23/20 YC added	

      -- , X.pat_loc_id	
      -- , X.ORDER_YEAR	
      -- , X.ORDER_QUARTER	
    -- , X.EXTRACT_FREQ	
      FROM	
         (	
            SELECT	
            O_DISP_INFO.ORDER_MED_ID|| '.'|| O_STATUS.CONTACT_NUMBER unique_record_id	
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

             ,  O_MED.ORDER_MED_ID|| '.'|| O_STATUS.CONTACT_NUMBER F_01_unique_record_id	

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
             , to_char(PAT.BIRTH_DATE,'yyyymmdd') F_09_dob_patient	
             , PAT.ADD_LINE_1 F_10_adrsadd1_patient	
             , PAT.ADD_LINE_2 F_11_adrsadd2_patient	
             , PAT.CITY F_12_adrscity_patient	
             , ZC_STATE.ABBR F_13_adrsstate_patient	
             , PAT.ZIP F_14_adrszip_patient	
             , PAT.HOME_PHONE F_15_adrsphonenumber_patient	
             ,  case WHEN ZC_SEX.NAME= 'Male'	
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
         --    , F_18_NameSuffix_doc = COALESCE(authprov.Suffix, OutsideProv.Suffix, OrderProv.Suffix, PrscProv.Suffix)	
             , COALESCE(authprov_ser_2.npi, OutsideProv_Ser_2.npi, o_med_2.txt_authprov_npi, OrderProv_ser_2.NPI, PRSCProv_SER_2.npi ,O_MED_2.TXT_AUTHPROV_NPI) F_19_prescribing_NPI	
             , COALESCE(AuthProv.DEA_NUMBER, OutsideProv.DEA_Number, O_MED_2.TXT_AUTHPROV_DEA, OrderProv.DEA_Number, PRSCProv.DEA_Number) F_20_prescriber_DEA	
             , COALESCE(AuthPROV_LIC.LICENSE_NUM,OutsidePROV_LIC.LICENSE_NUM, OrderPROV_LIC.LICENSE_NUM, PrscPROV_LIC.LICENSE_NUM ,O_MED_2.TXT_AUTHPROV_ST_ID) prescriber_state_license	
             , '               ' prescriber_me	
             , COALESCE(AuthProv_ADDR.ADDR_LINE_1, OutsideProv_ADDR.ADDR_LINE_1, O_MED_2.TXT_AUTHPROV_STREET, OrderProv_ADDR.ADDR_LINE_1, PRSCProv_ADDR.ADDR_LINE_1) F_21_adrsadd1_doc	
             , COALESCE(AuthProv_ADDR.ADDR_LINE_2, OutsideProv_ADDR.ADDR_LINE_2, null, OrderProv_ADDR.ADDR_LINE_2, PRSCProv_ADDR.ADDR_LINE_2) F_22_adrsadd2_doc	
             , COALESCE(AuthProv_ADDR.City, OutsideProv_ADDR.City, O_MED_2.TXT_AUTHPROV_CITY, OrderProv_ADDR.City, PRSCProv_ADDR.City) F_23_adrscity_doc	
             , COALESCE(ZC_AuthProv_STATE.ABBR, ZC_OutsideProv_STATE.ABBR, ZC_OutsideProv_2_STATE.ABBR, ZC_OrderProv_STATE.ABBR, ZC_PRSCProv_STATE.ABBR,O_MED_2.TXT_AUTHPROV_STAT_C ) F_24_adrsstate_doc	
             , COALESCE(AuthProv_ADDR.ZIP, OutsideProv_ADDR.ZIP, O_MED_2.TXT_AUTHPROV_ZIP, OrderProv_ADDR.Zip, PRSCProv_ADDR.Zip) F_25_adrzip_doc	
             , COALESCE(AuthProv_ADDR.PHONE, OutsideProv_ADDR.PHONE, O_MED_2.TXT_AUTHPROV_PHONE, OrderProv_ADDR.Phone, PRSCProv_ADDR.Phone) F_26_adrsphonenumber_doc	
             , COALESCE(AuthProv_ADDR.Fax, OutsideProv_ADDR.Fax, O_MED_2.TXT_AUTHPROV_Fax, OrderProv_ADDR.fax, PRSCProv_ADDR.fax) F_26_adrsfaxnumber_doc	
             , COALESCE(AuthProv_ZC_SPEC.NAME, OutsideProv_ZC_SPEC.NAME, null, OrderProv_ZC_SPEC.NAME, PRSCProv_ZC_SPEC.NAME) F_27_specialty_doc	
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
             , to_char( O_STATUS_First.INSTANT_OF_ENTRY, 'yyyymmdd') date_received	
             , to_char(  case WHEN O_MED_2.RX_WRITTEN_DATE >= COALESCE(FIRST_FILL.FILL_SERVICE_DATE, RxExtSysDispensedAction_FirstFill.ACTION_DTTM_LOCAL, RxDispensedAction_FirstFill.ACTION_DTTM_LOCAL)	
                                                            THEN O_MED_2.PRIORITIZED_INST_TM	
                                                            ELSE O_MED_2.RX_WRITTEN_DATE	
                                                         END, 'yyyymmdd'	
                                          ) F_48_date_written	
             , to_char(O_MED_3.PRESCRIP_EXP_DATE, 'yyyymmdd') F_49_date_expire	
             , to_char (COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE), 'yyyymmdd') F_50_date_filled	
             , to_char (case WHEN ORD_ACTION_FILLED.ACTION_DTTM_LOCAL > ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL	
                                                            THEN COALESCE(ORD_ACTION_EXT_SYS_DISP.ACTION_DTTM_LOCAL, ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL, ORD_ACTION_FORCED_DISPENSED.ACTION_DTTM_LOCAL) -- to account for unusual workflows	
                                                            WHEN O_DISP_INFO.FILL_STATUS_C = 70 -- Ready to Dispense	
                                                            THEN NULL	
                                                            ELSE COALESCE(ORD_ACTION_DISPENSED.ACTION_DTTM_LOCAL, O_DISP_INFO.ACTION_INSTANT)	
                                                         END, 'yyyymmdd'	
                                          ) F_51_date_shipped	
             , to_char( COALESCE(RxExtSysDispensedAction_FirstFill.ACTION_DTTM_LOCAL, RxDispensedAction_FirstFill.ACTION_DTTM_LOCAL), 'yyyymmdd') F_52_first_ship_date	
             , O_MED.ORDER_MED_ID|| '.'|| O_STATUS.CONTACT_NUMBER F_53_shipment_ID	
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
             , COALESCE(PLAN_1_EPP_2.BIN_NUM, to_char(PRIMARYRxa.OVR_NCPDP_VALUE)) F_62_primary_BIN --PLAN_1.BENEFIT_PLAN_ID  varchar(20))	
             , COALESCE(PLAN_1_EPP_2.PROCESSOR_CNTRL_NUM,COVERAGE_MEM_LIST.PCN_OVERRIDE,To_CHAR(PRIMARYRxa.OVR_NCPDP_VALUEA4)) F_63_primary_PCN	
             , CVG_1.GROUP_NUM F_65_primary_group	
             , NULL F_66_primary_sponsor	
             , FIN_CLS_1.financial_class_NAME F_67_primary_sponsor_type	
             , PrimaryRxa.CO_PAY F_68_primary_copay	
             , FILL_REQ_1.PAYOR_PAY_AMOUNT F_69_primary_paid	
             , PLAN_2.BENEFIT_PLAN_NAME F_70_benefit_plan_name2	
             , PAYOR_2.PAYOR_NAME F_70_secondary_insurance	
             , COALESCE(PLAN_2_EPP_2.BIN_NUM, to_char(SecondaryRxa.OVR_NCPDP_VALUE  )) F_71_secondary_BIN	
             , COALESCE(PLAN_2_EPP_2.PROCESSOR_CNTRL_NUM,LST2.PCN_OVERRIDE,To_CHAR(SecondaryRxa.OVR_NCPDP_VALUEA4)) F_72_secondary_PCN	
             --, F_73_secondary_plan = PLAN_2.BENEFIT_PLAN_NAME	
             , CVG_2.GROUP_NUM F_74_secondary_group	
             , NULL F_75_secondary_sponsor	
             , FIN_CLS_2.financial_class_NAME F_76_secondary_sponsor_type	
             , SecondaryRxa.CO_PAY F_77_secondary_copay	
             , FILL_REQ_2.PAYOR_PAY_AMOUNT F_78_secondary_paid	
             , PLAN_3.BENEFIT_PLAN_NAME F_79_benefit_plan_name3	
             , PAYOR_3.PAYOR_NAME F_79_tertiary_insurance	
             , COALESCE(PLAN_3_EPP_2.BIN_NUM, to_char(TertiaryRxa.OVR_NCPDP_VALUE )) F_80_tertiary_BIN	
             , COALESCE(PLAN_3_EPP_2.PROCESSOR_CNTRL_NUM,LST3.PCN_OVERRIDE,To_CHAR(TertiaryRxa.OVR_NCPDP_VALUEA4)) F_81_tertiary_PCN	
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
            /* , case WHEN ODP2.CALC_ACCUM_C in (410100, 410101) -- 340b contract type	
                            THEN 'Y'	
                            ELSE 'N'	
                         END yn_340b*/	
             ,case when cl.mpi_id like 'DSH330214%' then 'Y' else 'N' end yn_340b	

             --, pat_loc_id = O_MED.PAT_LOC_ID	
             ----------------------------------------------------------------------------------------------------------------	
             -- Columns for creating extract files based on calendar year and quarter when needed for backloading purposes	
             ----------------------------------------------------------------------------------------------------------------	

             , to_char(COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE),'yyyy') ORDER_YEAR	
             , to_char( COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE),'Q') ORDER_QUARTER	
             --, EXTRACT_FREQ = COALESCE(@ExtractFrequency, 'Adhoc')	
             , ROW_NUMBER() OVER (PARTITION BY	
                                          O_MED.ORDER_MED_ID|| '.'||O_STATUS.CONTACT_NUMBER	
                                       ORDER BY  O_MED.ORDER_MED_ID|| '.'|| O_STATUS.CONTACT_NUMBER 	
                                      ) RN -- for filtering to insure no duplicates get sent based on order med id and contact number	
            ,O_DISP_INFO_PAT_PAY.OTH_PAY_COV_AMT  	
            --/8/13/21 YC per Jodi Taszymowicz	
,PrimaryRxa.AUTH_NUM AUTH_NUM_primary	
,PrimaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_primary 	
,SecondaryRxa.AUTH_NUM AUTH_NUM_secondary	
,SecondaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_secondary 	
,TertiaryRxa.AUTH_NUM AUTH_NUM_tertiary	
,TertiaryRxa.OTH_CVG_CODE_ID OTH_CVG_CODE_ID_tertiary 	
,to_char(ORD_ACTION_FILLED_ini.ACTION_DTTM_LOCAL ,'yyyymmdd')  Fill_Initiated_Date           	
,to_char(ORD_ACTION_FILLED_ini.ACTION_DTTM_LOCAL ,'HH24:MI')  Fill_Initiated_Time           	

            FROM ORDER_MED  O_MED	

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
--YC 9/23/20 added Fill initial date                                	
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
                         , max(identity_id.line) over (partition by Identity_id.Pat_id ) max_line	
                       From IDENTITY_ID	
                       Where IDENTITY_ID.IDENTITY_TYPE_ID = '1000'   --Community MRN of Patient	

                       )cmrn  on Pat.pat_id = cmrn.pat_id and cmrn.line = cmrn.max_line	
          Left Join	
                  (Select	
                      pat_id	
                    ,identity_id.IDENTITY_ID	
                    ,IDENTITY_TYPE_ID	
                    ,identity_id.LINE	
                     , max(identity_id.line) over (partition by Identity_id.Pat_id ) max_line	
                   From  IDENTITY_ID	
                   Where identity_id.IDENTITY_TYPE_ID = '0 '    --Enterprise MRN of Patient	
                   ) emrn  on Pat.pat_id = emrn.pat_id and	
          emrn.line = emrn.max_line	


      LEFT JOIN ZC_STATE  ZC_STATE ON ZC_STATE.STATE_C = PAT.STATE_C	
      LEFT JOIN ZC_SEX  ZC_SEX ON ZC_SEX.RCPT_MEM_SEX_C = PAT.SEX_C	
      left join zc_suffix on (pat.PAT_NAME_SUFFIX_C = zc_suffix.SUFFIX_C)	
      INNER JOIN PAT_ENC  PE ON PE.PAT_ENC_CSN_ID = O_MED.PAT_ENC_CSN_ID	
      INNER JOIN ORDER_MEDINFO  O_MED_INFO ON O_MED_INFO.ORDER_MED_ID = O_MED.ORDER_MED_ID	
      LEFT JOIN  clarity_ser  OrderProv ON OrderProv.PROV_ID = O_MED.ORD_PROV_ID	
      LEFT JOIN CLARITY_SER_ADDR  OrderProv_ADDR ON OrderProv_ADDR.PROV_ID = OrderProv.PROV_ID	
                                  AND OrderProv_ADDR.LINE = 1	
      LEFT JOIN CLARITY_SER_ADDR  OrderProv_ADDR_2 ON OrderProv_ADDR_2.PROV_ID = OrderProv.PROV_ID	
                                  AND OrderProv_ADDR_2.LINE = 2	
      LEFT JOIN ZC_STATE  ZC_OrderProv_STATE ON ZC_OrderProv_STATE.STATE_C = OrderProv_ADDR.STATE_C	

      left join clarity_ser_2 orderProv_ser_2 on (orderprov_ser_2.prov_id = OrderProv.PROV_ID)	
      LEFT JOIN CLARITY_SER_SPEC  OrderPROV_SPEC ON OrderPROV_SPEC.PROV_ID = OrderProv.PROV_ID	
                                AND OrderPROV_SPEC.LINE = 1	
      LEFT JOIN ZC_SPECIALTY  OrderProv_ZC_SPEC ON OrderProv_ZC_SPEC.SPECIALTY_C = OrderPROV_SPEC.SPECIALTY_C	
      LEFT JOIN CLARITY_SER_LICEN2  OrderPROV_LIC ON OrderPROV_LIC.PROV_ID = OrderProv.PROV_ID	
      LEFT JOIN  clarity_ser  PRSCProv ON PRSCProv.PROV_ID = O_MED.MED_PRESC_PROV_ID	
      LEFT JOIN CLARITY_SER_ADDR  PRSCProv_ADDR ON PRSCProv_ADDR.PROV_ID = PRSCProv.PROV_ID	
                                AND PRSCProv_ADDR.LINE = 1	
      LEFT JOIN CLARITY_SER_ADDR  PRSCProv_ADDR_2 ON PRSCProv_ADDR_2.PROV_ID = PRSCProv.Prov_ID	
                                  AND PRSCProv_ADDR_2.LINE = 2	
      LEFT JOIN ZC_STATE  ZC_PRSCProv_STATE ON ZC_PRSCProv_STATE.STATE_C = PRSCProv_ADDR.STATE_C	
      left join clarity_ser_2 PRSCProv_SER_2 on (PRSCProv_SER_2.prov_id = PRSCProv.PROV_ID)		
      LEFT JOIN CLARITY_SER_SPEC  PRSCProv_SPEC ON PRSCProv_SPEC.PROV_ID = PRSCProv.PROV_ID	
                                AND PRSCProv_SPEC.LINE = 1	
      LEFT JOIN ZC_SPECIALTY  PRSCProv_ZC_SPEC ON PRSCProv_ZC_SPEC.SPECIALTY_C = PRSCProv_SPEC.SPECIALTY_C	
      LEFT JOIN CLARITY_SER_LICEN2  PrscPROV_LIC ON PrscPROV_LIC.PROV_ID = PrscProv.PROV_ID	
                                  AND PrscPROV_LIC.LINE = 1	
      LEFT JOIN  clarity_ser  AuthProv ON AuthProv.PROV_ID = O_MED.AUTHRZING_PROV_ID	
      LEFT JOIN CLARITY_SER_ADDR  AuthProv_ADDR ON AuthProv_ADDR.PROV_ID = AuthProv.PROV_ID	
                                  AND AuthProv_ADDR.LINE = 1	
      LEFT JOIN CLARITY_SER_ADDR  AuthProv_ADDR_2 ON AuthProv_ADDR_2.PROV_ID = AuthProv.PROV_ID	
                                  AND AuthProv_ADDR_2.LINE = 2	
      LEFT JOIN ZC_STATE  ZC_AuthProv_STATE ON ZC_AuthProv_STATE.STATE_C = AuthProv_ADDR.STATE_C	
      left join clarity_ser_2 AuthProv_Ser_2 on (AuthProv_Ser_2.prov_id = AuthProv.PROV_ID)	
      LEFT JOIN CLARITY_SER_SPEC  AUTHPROV_SPEC ON AUTHPROV_SPEC.PROV_ID = AUTHPROV.PROV_ID	
                                AND AUTHPROV_SPEC.LINE = 1	
      LEFT JOIN ZC_SPECIALTY  AUTHProv_ZC_SPEC ON AUTHProv_ZC_SPEC.SPECIALTY_C = AUTHPROV_SPEC.SPECIALTY_C	
      LEFT JOIN CLARITY_SER_LICEN2  AuthPROV_LIC ON AuthPROV_LIC.PROV_ID = AuthProv.PROV_ID	
                                  AND AuthProv_LIC.LINE = 1	

      left join clarity_ser_2 outsideprov_ser_2 on (outsideprov_ser_2.npi = O_MED_2.TXT_AUTHPROV_NPI)	
      left join clarity_ser outsideprov   on (outsideprov_ser_2.prov_id = outsideprov.prov_id)	

      LEFT JOIN CLARITY_SER_ADDR  OutsideProv_ADDR ON OutsideProv_ADDR.PROV_ID = OutsideProv.PROV_ID	
                                  AND OutsideProv_ADDR.LINE = 1	
      LEFT JOIN CLARITY_SER_ADDR  OutsideProv_ADDR_2 ON OutsideProv_ADDR_2.PROV_ID = OutsideProv.PROV_ID	
                                  AND OutsideProv_ADDR_2.LINE = 2	
      LEFT JOIN ZC_STATE  ZC_OutsideProv_STATE ON ZC_OutsideProv_STATE.STATE_C = OutsideProv_ADDR.STATE_C	
      LEFT JOIN ZC_STATE  ZC_OutsidePROV_2_STATE ON ZC_OutsidePROV_2_STATE.STATE_C = O_MED_2.TXT_AUTHPROV_STAT_C	

      LEFT JOIN CLARITY_SER_SPEC  OutsidePROV_SPEC ON OutsidePROV_SPEC.PROV_ID = OutsideProv.PROV_ID	
                                AND OutsidePROV_SPEC.LINE = 1	
      LEFT JOIN ZC_SPECIALTY  OutsideProv_ZC_SPEC ON OutsideProv_ZC_SPEC.SPECIALTY_C = OutsidePROV_SPEC.SPECIALTY_C	
      LEFT JOIN CLARITY_SER_LICEN2  OutsidePROV_LIC ON OutsidePROV_LIC.PROV_ID = OutsideProv.PROV_ID	
                                  AND OutsidePROV_LIC.LINE = 1	


      LEFT JOIN RX_MED_ONE  RX_MED_1 ON RX_MED_1.MEDICATION_ID = MED.MEDICATION_ID	
            LEFT JOIN RX_MED_THREE  RX_MED_3 ON RX_MED_3.MEDICATION_ID = MED.MEDICATION_ID	

            ----------------------------------------------------------------------------------------------------------------------------------------	
            -- tables regarding adjudications, flattened out by primary, secondary, tertiary payer; getting latest successful adjudication record	
            ----------------------------------------------------------------------------------------------------------------------------------------	

            OUTER APPLY	
               (	
                  SELECT  --- TOP (1)	
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
                         , ooa.CONTACT_DATE	
                         ,  case  WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                         ,rno.OVR_NCPDP_VALUE	
                         ,rno1.OVR_NCPDP_VALUE as OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS  ooa	
                  LEFT JOIN RXA_ADJUD_MESSAGE  rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS  Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2  rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4  rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3  rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  left join FCL_EXTRNL_CDE_LST fcl on fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                  left join RXA_NCPDP_OVERRIDE rno on rxa.RECORD_ID=rno.RECORD_ID	
                                    AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
                                    AND rno.OVR_NCPDP_FIELD='101-A1'	
                  left join RXA_NCPDP_OVERRIDE rno1 on rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
                                    AND rno1.OVR_NCPDP_FIELD='104-A4'	

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
                  SELECT --  TOP (1)	
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
             , ooa.CONTACT_DATE	
                         , case  WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                         ,rno.OVR_NCPDP_VALUE	
                         ,rno1.OVR_NCPDP_VALUE OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS  ooa	
                  LEFT JOIN RXA_ADJUD_MESSAGE  rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS  Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2  rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4  rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3  rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                 left join FCL_EXTRNL_CDE_LST fcl on fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                left join RXA_NCPDP_OVERRIDE rno on rxa.RECORD_ID=rno.RECORD_ID	
                                    AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
                                    AND rno.OVR_NCPDP_FIELD='101-A1'	
                 left join RXA_NCPDP_OVERRIDE rno1 on rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
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
                  SELECT ---  TOP (1)	
                           ooa.ORDER_ID	
                         , ooa.CONTACT_DATE_REAL	
                         , ooa.ADJ_ATTEMPT_ID	
             , ooa.CONTACT_DATE	
                         , case WHEN rxa2.REVERSE_OF_RXA_ID IS NULL	
                                       THEN rxa.PAT_PAY_AMOUNT	
                                       ELSE NULL	
                                    END CO_PAY	
                         , rxa4.O_USUAL_AND_CUSTOM	
                         ,rxa.AUTH_NUM	
                         ,fcl.value OTH_CVG_CODE_ID	
                        ,rno.OVR_NCPDP_VALUE	
                        ,rno1.OVR_NCPDP_VALUE as OVR_NCPDP_VALUEA4	

                  FROM ORD_ADJ_ATTEMPTS  ooa	
          LEFT JOIN RXA_ADJUD_MESSAGE  rxa ON rxa.RECORD_ID = ooa.ADJ_ATTEMPT_ID	
                  LEFT JOIN ZC_ADJ_STATUS  Rxtatus ON Rxtatus.ADJ_STATUS_C = rxa.STATUS_C	
                  LEFT JOIN RXA_ADJUD_MESSAG_2  rxa2 ON rxa2.RECORD_ID = rxa.RECORD_ID	
                                  AND rxa2.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_4  rxa4 ON rxa4.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa4.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  LEFT JOIN RXA_ADJUD_MESSAG_3  rxa3 ON rxa3.RECORD_ID = rxa.RECORD_ID	
                                    AND rxa3.CONTACT_DATE_REAL = rxa.CONTACT_DATE_REAL	
                  left join FCL_EXTRNL_CDE_LST fcl on fcl.ext_code_lst_id=rxa3.O_OTH_CVG_CODE_ID	
                  left join RXA_NCPDP_OVERRIDE rno on rxa.RECORD_ID=rno.RECORD_ID	
                              AND rno.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
                              AND rno.OVR_NCPDP_FIELD='101-A1'	
                  left join RXA_NCPDP_OVERRIDE rno1 on rxa.RECORD_ID=rno1.RECORD_ID	
                                    AND rno1.CONTACT_DATE_REAL=rxa.CONTACT_DATE_REAL------SR PRIMARY_RXA.OVR_NCPDP_VALUE	
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

            --------------------------------------------------------------------------------	
            -- Dispensed NDC, Dispensed Medication Name, Generic Medication Name	
            --------------------------------------------------------------------------------	
            LEFT OUTER JOIN ORDER_DISP_MEDS  O_DISP_MED ON O_DISP_MED.ORDER_MED_ID = O_DISP_INFO.ORDER_MED_ID	
                            AND O_DISP_MED.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                            AND O_DISP_MED.LINE = 1 -- Only get the first line, using this to get the NDC of non-mixtures	
            LEFT JOIN ORDER_DISP_INFO_2  O_DISP_INFO_2 ON O_DISP_INFO_2.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                            AND O_DISP_INFO_2.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            LEFT OUTER JOIN CLARITY_MEDICATION  GENERIC_RX ON GENERIC_RX.MEDICATION_ID = O_DISP_MED.DISP_MED_ID	
      LEFT OUTER JOIN RX_NDC_STATUS  NDC_STS ON O_DISP_MED.DISP_NDC_CSN = NDC_STS.CNCT_SERIAL_NUM	
      LEFT OUTER JOIN RX_NDC  NDC ON NDC_STS.NDC_ID = NDC.NDC_ID	
      LEFT OUTER JOIN CLARITY_MEDICATION  DISPENSED_RX ON DISPENSED_RX.MEDICATION_ID = NDC_STS.MEDICATION_ID	

            --------------------------------------------------------------------------------	
            -- Rx Coverage 1	
            --------------------------------------------------------------------------------	
            LEFT OUTER JOIN RX_FILL_COVERAGES  FILL_REQ_1 ON FILL_REQ_1.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_1.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_1.LINE = 1	
            LEFT JOIN COVERAGE  CVG_1 ON CVG_1.COVERAGE_ID = FILL_REQ_1.RX_COVERAGES_ID	
            LEFT JOIN CLARITY_EPP  PLAN_1 ON PLAN_1.BENEFIT_PLAN_ID = CVG_1.PLAN_ID	
            LEFT JOIN CLARITY_EPM  PAYOR_1 ON PAYOR_1.PAYOR_ID = CVG_1.PAYOR_ID	
            LEFT JOIN CLARITY_FC  FIN_CLS_1 ON FIN_CLS_1.financial_class = PAYOR_1.financial_class 	
            LEFT JOIN CLARITY_EPP_2  PLAN_1_EPP_2 ON PLAN_1.BENEFIT_PLAN_ID = PLAN_1_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE  PLAN_TYPE_1 ON PLAN_1_EPP_2.PROD_TYPE_C = PLAN_TYPE_1.PROD_TYPE_C	
            left join COVERAGE_MEM_LIST on cvg_1.COVERAGE_ID = COVERAGE_MEM_LIST.COVERAGE_ID	
            --------------------------------------------------------------------------------	
            -- Rx Coverage 2	
            --------------------------------------------------------------------------------	
            LEFT JOIN RX_FILL_COVERAGES  FILL_REQ_2 ON FILL_REQ_2.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_2.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_2.LINE = 2	
            LEFT JOIN COVERAGE  CVG_2 ON CVG_2.COVERAGE_ID = FILL_REQ_2.RX_COVERAGES_ID	
            LEFT JOIN CLARITY_EPP  PLAN_2 ON PLAN_2.BENEFIT_PLAN_ID = CVG_2.PLAN_ID	
            LEFT JOIN CLARITY_EPM  PAYOR_2 ON PAYOR_2.PAYOR_ID = CVG_2.PAYOR_ID	
            LEFT JOIN CLARITY_FC  FIN_CLS_2 ON FIN_CLS_2.financial_class = PAYOR_2.financial_class 	
      LEFT JOIN CLARITY_EPP_2  PLAN_2_EPP_2 ON PLAN_2.BENEFIT_PLAN_ID = PLAN_2_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE  PLAN_TYPE_2 ON PLAN_2_EPP_2.PROD_TYPE_C = PLAN_TYPE_2.PROD_TYPE_C	
            LEFT OUTER JOIN COVERAGE_MEM_LIST LST2 on CVG_2.COVERAGE_ID=LST2.COVERAGE_ID	
            --------------------------------------------------------------------------------	
            -- Rx Coverage 3	
            --------------------------------------------------------------------------------	
            LEFT JOIN RX_FILL_COVERAGES  FILL_REQ_3 ON FILL_REQ_3.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                AND FILL_REQ_3.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
                                AND FILL_REQ_3.LINE = 3	
            LEFT JOIN COVERAGE  CVG_3 ON CVG_3.COVERAGE_ID = FILL_REQ_3.RX_COVERAGES_ID	
      LEFT JOIN CLARITY_EPP  PLAN_3 ON PLAN_3.BENEFIT_PLAN_ID = CVG_3.PLAN_ID	
      LEFT JOIN CLARITY_EPM  PAYOR_3 ON PAYOR_3.PAYOR_ID = CVG_3.PAYOR_ID	
      LEFT JOIN CLARITY_FC  FIN_CLS_3 ON FIN_CLS_3.financial_class = PAYOR_3.financial_class 	
      LEFT JOIN CLARITY_EPP_2  PLAN_3_EPP_2 ON PLAN_3.BENEFIT_PLAN_ID = PLAN_3_EPP_2.BENEFIT_PLAN_ID	
            LEFT JOIN ZC_PROD_TYPE  PLAN_TYPE_3 ON PLAN_3_EPP_2.PROD_TYPE_C = PLAN_TYPE_3.PROD_TYPE_C	
            LEFT OUTER JOIN COVERAGE_MEM_LIST LST3 on CVG_3.COVERAGE_ID=LST3.COVERAGE_ID	

            --------------------------------------------------------------------------------	
            LEFT JOIN IP_FREQUENCY  IP_FREQ ON IP_FREQ.FREQ_ID = O_MED.HV_DISCR_FREQ_ID	
            LEFT JOIN ZC_MED_UNIT  ZC_MED_UNIT ON ZC_MED_UNIT.DISP_QTYUNIT_C = O_MED.DOSE_UNIT_C	
            INNER JOIN ORD_ACT_ORD_INFO  O_ACT_O_INFO ON O_ACT_O_INFO.ORDER_ID = O_DISP_INFO.ORDER_MED_ID	
                                  AND O_ACT_O_INFO.ORDER_DATE = O_DISP_INFO.CONTACT_DATE_REAL	
            --------------------------------------------------------------------------------	
            -- First fill data	
            --------------------------------------------------------------------------------	
            LEFT JOIN ORDER_DISP_INFO  FIRST_FILL ON FIRST_FILL.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                  AND FIRST_FILL.ORD_CNTCT_TYPE_C = 11 -- Fill	
                                  AND FIRST_FILL.FILL_NUMBER = 0 -- first fill	
                                  AND FIRST_FILL.FILL_STATUS_C <> 100 -- Canceled	
            left JOIN ORDER_STATUS  O_STATUS_First ON O_STATUS_First.ORDER_ID = FIRST_FILL.ORDER_MED_ID	
                                AND O_STATUS_First.ORD_DATE_REAL = FIRST_FILL.CONTACT_DATE_REAL	
            left JOIN ORD_ACT_ORD_INFO  O_ACT_O_INFO_FIRST_FILL ON O_ACT_O_INFO_FIRST_FILL.ORDER_ID = FIRST_FILL.ORDER_MED_ID	
                              AND O_ACT_O_INFO_FIRST_FILL.ORDER_DATE = FIRST_FILL.CONTACT_DATE_REAL	
            left JOIN ORD_ACT_OT  RxDispensedAction_FirstFill ON RxDispensedAction_FirstFill.ACTION_ID = O_ACT_O_INFO_FIRST_FILL.ACTION_ID	
                              AND RxDispensedAction_FirstFill.ACTION_TYPE_C = 80 -- Dispensed	
            LEFT JOIN ORD_ACT_OT  RxExtSysDispensedAction_FirstFill ON RxExtSysDispensedAction_FirstFill.ACTION_ID = O_ACT_O_INFO_FIRST_FILL.ACTION_ID	
                              AND RxExtSysDispensedAction_FirstFill.ACTION_TYPE_C = 76 -- External System Dispensed	
            --------------------------------------------------------------------------------	
            -- Rx Associated Patient Diagnosis	
            --------------------------------------------------------------------------------	
            LEFT JOIN ORDER_DX_MED  O_DX_MED_1 ON O_DX_MED_1.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_1.LINE = 1	
            LEFT JOIN CLARITY_EDG  DX_1 ON DX_1.DX_ID = O_DX_MED_1.DX_ID	
            LEFT JOIN ORDER_DX_MED  O_DX_MED_2 ON O_DX_MED_2.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_2.LINE = 2	
            LEFT JOIN CLARITY_EDG  DX_2 ON DX_2.DX_ID = O_DX_MED_2.DX_ID	
            LEFT JOIN ORDER_DX_MED  O_DX_MED_3 ON O_DX_MED_3.ORDER_MED_ID = O_MED.ORDER_MED_ID	
                                AND O_DX_MED_3.LINE = 3	
            LEFT JOIN CLARITY_EDG  DX_3 ON DX_3.DX_ID = O_DX_MED_3.DX_ID	
            LEFT JOIN CLARITY_DEP  DEPT ON DEPT.DEPARTMENT_ID = O_MED.PAT_LOC_ID	
            LEFT JOIN	
               (	
                  SELECT	
                     RX_NORM_CD.MEDICATION_ID	
                   , RX_NORM_CD.RXNORM_CODE	
                   , RX_NORM_CD.LINE	
                   , MIN(RX_NORM_CD.LINE) OVER (PARTITION BY RX_NORM_CD.MEDICATION_ID ) MIN_LINE	
                  FROM RXNORM_CODES  RX_NORM_CD	
                  WHERE RX_NORM_CD.RXNORM_TERM_TYPE_C = 9 -- Semantic Clinical Drug	
               )  RX_NORM_CD_SCD	
               ON RX_NORM_CD_SCD.MEDICATION_ID = MED.MEDICATION_ID	
                  AND RX_NORM_CD_SCD.LINE = RX_NORM_CD_SCD.MIN_LINE	
            LEFT JOIN	
               (	
                  SELECT	
                     RX_NORM_CD.MEDICATION_ID	
                   , RX_NORM_CD.RXNORM_CODE	
                   , RX_NORM_CD.LINE	
                   , MIN(RX_NORM_CD.LINE) OVER (PARTITION BY RX_NORM_CD.MEDICATION_ID ) MIN_LINE	
                  FROM RXNORM_CODES  RX_NORM_CD	
                  WHERE RX_NORM_CD.RXNORM_TERM_TYPE_C = 14 -- Semantic Clinical Drug	
               )  RX_NORM_CD_SBD	
               ON RX_NORM_CD_SBD.MEDICATION_ID = MED.MEDICATION_ID	
                  AND RX_NORM_CD_SBD.LINE = RX_NORM_CD_SBD.MIN_LINE	
            --------------------------------------------------------------------------------	
            -- 340b eligibility	
            --------------------------------------------------------------------------------	
        -- YC this is not applicable for NYU    LEFT JOIN ORDER_DISP_INFO_2  ODP2 ON ODP2.ORDER_ID = O_DISP_INFO.ORDER_MED_ID  AND ODP2.CONTACT_DATE_REAL = O_DISP_INFO.CONTACT_DATE_REAL	
            left join CL_DEP_ID cl on cl.department_id=O_MED.PAT_LOC_ID and cl.mpi_id_type_id='143' --340B ID DSH330214xx	
            LEFT JOIN ZC_STATE  EXT_PROV_STATE ON EXT_PROV_STATE.STATE_C = O_MED_2.TXT_AUTHPROV_STAT_C	
            --------------------------------------------------------------------------------	
            --  Sort Code	
            --------------------------------------------------------------------------------	
            LEFT JOIN	
               (	
                  SELECT	
                     X.PAT_LINK_ID	
                   ,   MAX( case  WHEN X.RN = 1	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      ) SORT_CODE_1	
                   ,   MAX(  case   WHEN X.RN = 2	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      ) SORT_CODE_2	
                   ,   MAX(  case   WHEN X.RN = 3	
                                            THEN X.SORT_CODE	
                                            ELSE NULL	
                                         END	
                                      )SORT_CODE_3	
                   ,   MAX(  case  WHEN X.RN = 4	
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
                           SORT_CODE  sc	
                     )  X	
                  GROUP BY	
                     X.PAT_LINK_ID	
               )  S_CODE               ON S_CODE.PAT_LINK_ID = PAT.PAT_ID 	
      left join RX_DISP_LOT on (o_med.ORDER_MED_ID = rx_disp_lot.order_med_id)	
      --outer apply [PARTNER].[fn_Break_LotNumber] (RX_DISP_LOT.RX_DISP_LOT_NUM) as BreakLot	
      left join RX_DISP_LOT_EXP_DATE on (o_med.ORDER_MED_ID = RX_DISP_LOT_EXP_DATE.ORDER_MED_ID)	
-------------YC 8/3/2021 Authorization 	
  /*8/13/21     left join (select har.hsp_account_id,har.ASSOC_AUTHCERT_ID	
                ,max(nvl(case when line=1 then CARRIER_AUTH_CMT end,ref.AUTH_NUM )) Primary_Claim_Auth_num	
                ,max(case when line=2 then CARRIER_AUTH_CMT end) Secondary_Claim_Auth_num	
                ,max(case when line=3 then CARRIER_AUTH_CMT end) Tertiary_Claim_Auth_num	
             from  hsp_account har 	
                   join REFERRAL ref on ref.referral_id=har.ASSOC_AUTHCERT_ID 	
                   left join REFERRAL_CVG refcvg on refcvg.referral_id=har.ASSOC_AUTHCERT_ID	
                    group by har.hsp_account_id,har.ASSOC_AUTHCERT_ID	
                  ) refcvg on refcvg.hsp_account_id=pe.hsp_account_id 	
*/                  	
-------------                  	
            WHERE	
               O_MED.ORDERING_MODE_C = 1 -- Outpatient script	
         AND O_DISP_INFO.DISPENSE_PHR_ID in (4084100019) --  NYU LANGONE PHARMACY COBBLE HILL	
            -- (4084100160)--  SUNSET PARK HEALTH COUNCIL, INC. 514 49TH STREET, BROOKLYN, NY 11220--(93942)---   NYUHC/COBBLE HILL 83 AMITY STREET, BROOKLYN, NY 11201 877-698-2330 929-455-6401	
         AND O_DISP_INFO.ORD_CNTCT_TYPE_C = 11 -- Fill Request	
         and O_DISP_INFO.fill_status_c in (36, 40,45,50,60,70,80,81,82)	
                                -- 36 Ready to Fill	
                                --40 - Fill Initiated	
                                -- 45 - Filled	
                                -- 50 - Ready to Verify	
                                -- 60 - Verified	
                                -- 70 - Ready to Dispense	
                                -- 80 - Dispensed	
                                -- 81 - Shipped	
                                -- 82 - Delivered	

         --AND COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL, O_DISP_INFO.FILL_SERVICE_DATE) between '04-01-2020' and '07-24-2020	
         AND COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE ) >= START_dt 
             and COALESCE(ORD_ACTION_FILLED.ACTION_DTTM_LOCAL,O_DISP_INFO.FILL_SERVICE_DATE )< END_dt+1
         )  X    WHERE         X.RN = 1
            ORDER BY 1
    )
         ;

--GO

/*1.  Action type: Filled
2.  Fill request statuses: Not equal to Canceled
3.  Is Test Patient (EPT 108): No

Dispensing pharmacy:
1.  Cobble Hill

Columns:
1.  Rx Prescription Number [ORD 84701] -- don't exist
2.  Rx Claim Submission Fill Number [ORD 84700] -- don't exist
3.  Rx Filled Date [ORD 84732] --don't exist
4.  Rx Dispensed Date [ORD 84781]
5.  Rx Medication [ORD 84712]
6.  Medication Name [ORD 84023]
7.  Rx Reimbursement Amount [ORD 84741]
8.  Rx Payor Pay Amounts [ORD 84704]
9.  Rx Patient Pay Amount [ORD 84703]
10.  Rx Partial Fill Indicator Version 4.2 [ORD 4100001] - this might be a custom field
11.  Rx Dispense Pharmacy [ORD 84711]
12.  Rx Plan Names [ORD 84538]
13.  Primary Payor Plan Patient ID [ORD 84099]
14.  Primary Payor BIN [ORD 84103]
15.  Primary Payor PCN [ORD 84104]
16.  Primary Payor Group Number [ORD 84105]
17.  Secondary Payor Plan Patient ID [ORD 84109]
18.  Secondary Payor BIN [ORD 84112]
19.  Secondary Payor PCN [ORD 84113]
20.  Secondary Payor Group Number [ORD 84114]
21.	Is Test Patient? [66058]
22.	OTHER PAYOR COVERED AMOUNT [ORD 47217]
*/
end;
end;
/