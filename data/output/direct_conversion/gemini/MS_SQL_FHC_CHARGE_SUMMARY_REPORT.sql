CREATE PROCEDURE FHC_CHARGE_SUMMARY_REPORT
(
  BEGIN_DATE VARCHAR(255),
  END_DATE VARCHAR(255),
  P_RECORDSET OUT CURSOR
)
BEGIN
  --LOAD POPULATION INTO MEMORY
  SET @CLEANUP_STATEMENT = CONCAT('TRUNCATE TABLE FHC_CHARGE_SUMMARY_POPULATION_GTT');
  PREPARE STMT FROM @CLEANUP_STATEMENT;
  EXECUTE STMT;
  DEALLOCATE PREPARE STMT;
  
  INSERT INTO FHC_CHARGE_SUMMARY_POPULATION_GTT
  WITH REPORT_PARAM AS (
    SELECT -- SP-SQL UUID: 7f97f9c3-2be6-4777-9557-5e027a65e80f
    DATE_FORMAT(BEGIN_DATE, '%Y%m%d') AS START_DATE, DATE_FORMAT(END_DATE, '%Y%m%d') AS END_DATE
    FROM DUAL
  )
  ,POPULATION AS (
    SELECT PE.PAT_ENC_CSN_ID, PE.PAT_ENC_DATE_REAL, PE.PAT_ID, PT.PAT_MRN_ID, PT.PAT_NAME, PE.HSP_ACCOUNT_ID, PE.CONTACT_DATE,
    IFNULL(PE.CHARGE_SLIP_NUMBER, '') AS CHARGE_SLIP_NUMBER, ser.PROV_TYPE AS PROV_PRIM_SPEC, ENC_TYPE.name AS ENC_TYPE,
    ZAS.NAME AS APPT_STATUS_NAME,
    CASE WHEN PT.PAT_MRN_ID IS NULL THEN CONCAT('*', 'No Patient Record for #', PE.PAT_ID, ' *')
    WHEN PT.PAT_NAME IS NULL THEN PT.PAT_MRN_ID 
    ELSE PT.PAT_NAME END AS PATIENT,
    CASE WHEN PE.VISIT_PROV_ID IS NULL THEN '*No Visit Provider*'
    WHEN SER.PROV_ID IS NULL THEN '*No SER Record*'
    ELSE CONCAT(SER.PROV_NAME, ' [', SER.PROV_ID, ']') END AS VISIT_PROVIDER, DEP.DEPARTMENT_ID, 
    DEP.DEPARTMENT_NAME, center.name AS DEPARTMENT_CENTER, LOC.LOC_ID, LOC.LOC_NAME, PRC.PRC_NAME,
    CASE WHEN PE.ENC_CLOSED_YN IS NULL OR PE.ENC_CLOSED_YN = 'N' THEN 'NO' ELSE 'YES' END AS ENC_CLOSED
    FROM PAT_ENC PE
    LEFT JOIN PATIENT PT ON PE.PAT_ID = PT.PAT_ID
    LEFT JOIN CLARITY_SER SER ON PE.VISIT_PROV_ID = SER.PROV_ID
    LEFT JOIN CLARITY_SER_SPEC CSS ON SER.PROV_ID = CSS.PROV_ID AND CSS.LINE = 1
    LEFT JOIN ZC_SPECIALTY ON CSS.SPECIALTY_C = ZC_SPECIALTY.SPECIALTY_C
    LEFT JOIN CLARITY_PRC PRC ON PE.APPT_PRC_ID = PRC.PRC_ID
    LEFT JOIN ZC_DISP_ENC_TYPE ENC_TYPE ON PE.ENC_TYPE_C = ENC_TYPE.DISP_ENC_TYPE_C
    LEFT JOIN ZC_APPT_STATUS ZAS ON PE.APPT_STATUS_C = ZAS.APPT_STATUS_C
    LEFT JOIN CLARITY_DEP DEP ON PE.DEPARTMENT_ID = DEP.DEPARTMENT_ID
    LEFT JOIN ZC_CENTER CENTER ON DEP.CENTER_C = CENTER.CENTER_C
    LEFT JOIN CLARITY_LOC LOC ON DEP.REV_LOC_ID = LOC.LOC_ID
    LEFT JOIN CLARITY_SA SA ON LOC.SERV_AREA_ID = SA.SERV_AREA_ID
    LEFT JOIN ZC_LOC_RPT_GRP_11 ZC11 ON LOC.RPT_GRP_ELEVEN_C = ZC11.RPT_GRP_ELEVEN_C
    WHERE NULL IS NULL
    AND PE.CHECKIN_TIME IS NOT NULL
    AND PE.APPT_STATUS_C NOT IN (3,4,5)
    AND PE.ENC_TYPE_C NOT IN ('2101','2505')
    AND PE.APPT_PRC_ID NOT IN ('1192')
    AND DEP.DEPARTMENT_ID NOT IN (10803010)
    AND PT.PAT_NAME NOT LIKE 'ZZZ%'
    AND PT.PAT_NAME NOT LIKE 'ZZTEST%'
    AND PE.CONTACT_DATE BETWEEN DATE_FORMAT(START_DATE, '%Y-%m-%d') AND DATE_FORMAT(END_DATE, '%Y-%m-%d')
  )
  SELECT * FROM POPULATION;

  --LOAD BILLING INFORMATION IN MEMORY
  SET @CLEANUP_STATEMENT = CONCAT('TRUNCATE TABLE FHC_CHARGE_SUMMARY_BILLING_GTT');
  PREPARE STMT FROM @CLEANUP_STATEMENT;
  EXECUTE STMT;
  DEALLOCATE PREPARE STMT;
  
  INSERT INTO FHC_CHARGE_SUMMARY_BILLING_GTT
  WITH BILLING_HTR_CODES AS(
    SELECT -- SP-SQL UUID: cf6cf9a4-9be6-4498-a305-11652fbabe0a
    PAT_ID, PAT_ENC_DATE_REAL, PAT_ENC_CSN_ID, CODE, CODE_MODIFIERS, CODE_TYPE, CODE_SERVICE_DATE, CODE_SOURCE,
    HSP_TRANSACTIONS.PROC_ID AS CODE_ID, HSP_TRANSACTIONS.CHG_ROUTER_SRC_ID AS CODE_UCL_ID, TX_AMOUNT
    FROM (
      SELECT /*+ INDEX(HSP_TRANSACTIONS EIX_HSP_TRANSACTIONS_HSACID) */
      POPULATION.PAT_ID, POPULATION.PAT_ENC_DATE_REAL, POPULATION.PAT_ENC_CSN_ID,
      HSP_TRANSACTIONS.PLACE_OF_SVC_ID AS CODE_POS_ID, HSP_TRANSACTIONS.HCPCS_CODE, HSP_TRANSACTIONS.CPT_CODE,
      HSP_TRANSACTIONS.MODIFIERS AS CODE_MODIFIERS, 'CPT' AS CODE_TYPE, SERVICE_DATE AS CODE_SERVICE_DATE,
      'HTR' AS CODE_SOURCE, HSP_TRANSACTIONS.PROC_ID AS CODE_ID, HSP_TRANSACTIONS.CHG_ROUTER_SRC_ID AS CODE_UCL_ID,
      HSP_TRANSACTIONS.TX_AMOUNT
      FROM FHC_CHARGE_SUMMARY_POPULATION_GTT POPULATION
      LEFT JOIN HSP_TRANSACTIONS ON HSP_TRANSACTIONS.HSP_ACCOUNT_ID = POPULATION.HSP_ACCOUNT_ID
        AND HSP_TRANSACTIONS.PAT_ENC_CSN_ID = POPULATION.PAT_ENC_CSN_ID
    ) UNPIVOT (
        CODE 
        FOR "BILL_CODE" IN (CPT_CODE AS 'CPT', HCPCS_CODE AS 'HCPCS')
      ) HTR_PIVOT
  )
  ,BILLING_TDL_CODES AS (
    SELECT POPULATION.PAT_ID, POPULATION.PAT_ENC_DATE_REAL, POPULATION.PAT_ENC_CSN_ID,
    ARPB_TRANSACTIONS.SERVICE_AREA_ID AS CODE_POS_ID, CLARITY_TDL_TRAN.CPT_CODE AS CODE,
    CONCAT(CLARITY_TDL_TRAN.MODIFIER_ONE,
      CASE WHEN CLARITY_TDL_TRAN.MODIFIER_TWO IS NOT NULL THEN CONCAT(',', CLARITY_TDL_TRAN.MODIFIER_TWO) END,
      CASE WHEN CLARITY_TDL_TRAN.MODIFIER_THREE IS NOT NULL THEN CONCAT(',', CLARITY_TDL_TRAN.MODIFIER_THREE) END,
      CASE WHEN CLARITY_TDL_TRAN.MODIFIER_FOUR IS NOT NULL THEN CONCAT(',', CLARITY_TDL_TRAN.MODIFIER_FOUR) END
    ) AS CODE_MODIFIERS, 'CPT' AS CODE_TYPE, ARPB_TRANSACTIONS.SERVICE_DATE AS CODE_SERVICE_DATE,
    'ETR' AS CODE_SOURCE, CLARITY_TDL_TRAN.PROC_ID AS CODE_ID, ARPB_TRANSACTIONS.CHG_ROUTER_SRC_ID AS CODE_UCL_ID,
    PRE_AR_CHG.AMOUNT AS TX_AMOUNT
    FROM FHC_CHARGE_SUMMARY_POPULATION_GTT POPULATION
    LEFT JOIN ARPB_TRANSACTIONS ON ARPB_TRANSACTIONS.PAT_ENC_CSN_ID = POPULATION.PAT_ENC_CSN_ID
    LEFT JOIN CLARITY_TDL_TRAN ON ARPB_TRANSACTIONS.TX_ID = CLARITY_TDL_TRAN.TX_ID
      AND CLARITY_TDL_TRAN.DETAIL_TYPE = 1
    LEFT JOIN ARPB_TX_MODERATE ON ARPB_TRANSACTIONS.TX_ID = ARPB_TX_MODERATE.TX_ID
    LEFT JOIN PREAR_CHG ON ARPB_TX_MODERATE.ORIGINATING_TAR_ID = PRE_AR_CHG.TAR_ID
  )

  ,UNIFIED_BILLING AS (
    SELECT BILLING_PB_HB.*, CLARITY_POS.POS_ID, CLARITY_POS.POS_CODE, CLARITY_POS.POS_NAME, CLARITY_EAP.PROC_NAME AS CODE_DESCRIPTION,
    CLARITY_UCL.CHARGE_SOURCE_C AS UCL_CHARGE_SOURCE_C, ZC_CHG_SOURCE_UCL.NAME AS UCL_CHARGE_SOURCE
    FROM (
      SELECT * from BILLING_HTR_CODES
      UNION ALL 
      SELECT * from BILLING_TDL_CODES
    ) BILLING_PB_HB
    LEFT JOIN CLARITY_EAP ON BILLING_PB_HB.CODE_ID = CLARITY_EAP.PROC_ID
    LEFT JOIN CLARITY_UCL ON BILLING_PB_HB.CODE_UCL_ID = CLARITY_UCL.UCL_ID
      AND (CLARITY_UCL.SYSTEM_FLAG_C <> 2 or CLARITY_UCL.SYSTEM_FLAG_C is null)
    LEFT JOIN ZC_CHG_SOURCE_UCL on CLARITY_UCL.CHARGE_SOURCE_C = ZC_CHG_SOURCE_UCL.CHG_SOURCE_UCL_C
    LEFT JOIN CLARITY_POS ON BILLING_PB_HB.CODE_POS_ID = CLARITY_POS.POS_ID
    WHERE (BILLING_PB_HB.CODE_UCL_ID IS NOT NULL AND CLARITY_UCL.UCL_ID IS NOT NULL)
    OR BILLING_PB_HB.CODE_UCL_ID IS NULL
  )
  ,UNIFIED_BILLING_PIVOT AS (
    SELECT PAT_ENC_CSN_ID
    ,MAX(
      CASE 
        WHEN CODE_SOURCE = 'HTR' THEN 1 
        ELSE 0 
      END
    ) HB_CHARGE_EXISTS
    ,MAX(
      CASE 
        WHEN CODE_SOURCE = 'HTR' AND UCL_CHARGE_SOURCE_C = '2' THEN 1 
        ELSE 0
      END
    ) HB_CHARGE_SOURCE_EPICCARE
    ,SUM(
      CASE 
        WHEN CODE_SOURCE = 'HTR' THEN TX_AMOUNT 
        ELSE 0
      END
    ) HB_CHARGE_TX_AMOUNT
    ,CAST(
      SUBSTR(
      LISTAGG(
        CASE 
          WHEN CODE_SOURCE = 'HTR' THEN CODE_DESCRIPTION 
        END
        ,', '
        ON OVERFLOW TRUNCATE
      ) WITHIN GROUP (ORDER BY ROW_NUM),0,4000)
      AS VARCHAR2(4000)
    ) HB_CHARGE_AGG_CODES_DESC
    ,CASE 
      WHEN
        SUM(CASE WHEN CODE_SOURCE = 'HTR' THEN LENGTH(CODE_DESCRIPTION) END) > 4000
      THEN 1
      ELSE 0
    END HB_CHARGE_AGG_CODES_OVERFLOW_FLAG
      ,MAX(
      CASE 
        WHEN CODE_SOURCE = 'ETR' THEN 1 
        ELSE 0 
      END
    ) PB_CHARGE_EXISTS
    ,MAX(
      CASE 
        WHEN CODE_SOURCE = 'ETR' AND UCL_CHARGE_SOURCE_C = '2' THEN 1 
        ELSE 0
      END
    ) PB_CHARGE_SOURCE_EPICCARE
    ,SUM(
      CASE 
        WHEN CODE_SOURCE = 'ETR' THEN TX_AMOUNT 
        ELSE 0
      END
    ) PB_CHARGE_TX_AMOUNT
    ,CAST(
      SUBSTR(
      LISTAGG(
        CASE 
          WHEN CODE_SOURCE = 'ETR' THEN CODE_DESCRIPTION 
        END
        ,', '
        ON OVERFLOW TRUNCATE
      ) WITHIN GROUP (ORDER BY ROW_NUM),0,4000)
      AS VARCHAR2(4000)
    ) PB_CHARGE_AGG_CODES_DESC
    ,CASE 
      WHEN
        SUM(CASE WHEN CODE_SOURCE = 'ETR' THEN LENGTH(CODE_DESCRIPTION) END) > 4000
      THEN 1
      ELSE 0
    END PB_CHARGE_AGG_CODES_OVERFLOW_FLAG
    FROM (
      SELECT PAT_ENC_CSN_ID
      ,CODE_SOURCE
      ,CODE
      ,CODE_MODIFIERS
      ,CODE_DESCRIPTION
      ,UCL_CHARGE_SOURCE_C
      ,TX_AMOUNT
      ,ROW_NUMBER() OVER (PARTITION BY PAT_ENC_CSN_ID ORDER BY NULL) ROW_NUM
      FROM UNIFIED_BILLING
    ) UNIFIED_BILLING_LTD
    GROUP BY PAT_ENC_CSN_ID
  )
  SELECT * FROM UNIFIED_BILLING_PIVOT;

  -- RETURN ENCOUNTERS WITH NO BILLING INFORMATION
  OPEN  P_RECORDSET FOR
    SELECT -- SP-SQL UUID: 7f0853ec-7d2f-4a98-8a04-50be45ce6fe3
    POPULATION.PAT_ENC_CSN_ID "CSN"
    ,POPULATION.CONTACT_DATE "Date"
    ,POPULATION.PRC_NAME "Visit Type"
    ,POPULATION.ENC_TYPE "Encounter Type"
    ,POPULATION.DEPARTMENT_CENTER "Center"
    ,POPULATION.LOC_NAME
    ,POPULATION.DEPARTMENT_NAME
    ,POPULATION.VISIT_PROVIDER "Provider"
    ,POPULATION.PAT_MRN_ID
    ,POPULATION.PAT_NAME "PATIENT"
    ,POPULATION.ENC_CLOSED
    ,PB_CHARGE_EXISTS "PB Charge Exists"
    ,PB_CHARGE_SOURCE_EPICCARE "PB Source EpicCare"
    ,PB_CHARGE_AGG_CODES_DESC "PB Charge List"
    ,PB_CHARGE_AGG_CODES_OVERFLOW_FLAG "PB Charge List Overflow Flag"
    ,PB_CHARGE_TX_AMOUNT "PB Charge Amount"
    ,HB_CHARGE_EXISTS "HB Charge Exists"
    ,HB_CHARGE_SOURCE_EPICCARE "HB Source EpicCare"
    ,HB_CHARGE_AGG_CODES_DESC "HB Charge List"
    ,HB_CHARGE_AGG_CODES_OVERFLOW_FLAG "HB Charge List Overflow Flag"
    ,HB_CHARGE_TX_AMOUNT "HB Charge Amount"
    FROM FHC_CHARGE_SUMMARY_POPULATION_GTT POPULATION
    LEFT JOIN FHC_CHARGE_SUMMARY_BILLING_GTT UNIFIED_BILLING_PIVOT ON POPULATION.PAT_ENC_CSN_ID = UNIFIED_BILLING_PIVOT.PAT_ENC_CSN_ID
    WHERE (
      UNIFIED_BILLING_PIVOT.PAT_ENC_CSN_ID IS NULL
      OR NOT(HB_CHARGE_SOURCE_EPICCARE = 1 AND PB_CHARGE_EXISTS = 1)
    );

END;