
CREATE PROCEDURE NYU_V_ED_SCPM ( @numDays integer) AS
BEGIN
    DECLARE @start_dt date;
    DECLARE @s_date date;
    DECLARE @e_date date;
    DECLARE @cnt integer;
    DECLARE @Qcnt integer;

    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'NYU_V_ED_SCPM_J', 'INFO', 'START', 'STORED PROCEDURE STARTED';

    IF (@numDays=99999 or @numDays is null) 
    BEGIN
      SET @start_dt = CONVERT(date,'06/05/2011',101);
    END
    ELSE
    BEGIN  
      SET @start_dt = CAST(GETDATE()-@numDays AS DATE);
    END;

    TRUNCATE TABLE NYUGT_ED_TMP;
    TRUNCATE TABLE NYUGT_ED_ORD_TMP; 
    TRUNCATE TABLE NYUGT_ED_ADT_TMP;
    COMMIT;

    IF (@numDays=99999 or @numDays is null) 
    BEGIN
      INSERT INTO NYUGT_ED_TMP WITH (TABLOCK)
      SELECT * FROM (
        SELECT pat_enc_csn_id,update_date,hsp_account_id,
                MAX(TRIAGE_STARTED) AS TRIAGE_STARTED ,
                MAX(IP_BED_REQUESTED) AS IP_BED_REQUESTED,
                MAX(PATIENT_DEPARTED_FROM_ED) AS PATIENT_DEPARTED_FROM_ED,
                MAX(PATIENT_ARRIVED_IN_ED) AS PATIENT_ARRIVED_IN_ED,
                MAX(PATIENT_ADMITTED) AS PATIENT_ADMITTED,
                MAX(PATIENT_ADMITTED_BY) AS PATIENT_ADMITTED_BY,
                MAX(PATIENT_ADMITTED_TITLE) AS PATIENT_ADMITTED_TITLE,
                MAX(PATIENT_ADMITTED_TO) AS PATIENT_ADMITTED_TO,
                MAX(TRIAGE_COMPLETED) AS TRIAGE_COMPLETED,
                MAX(TRIAGE_COMPLETED_BY) AS TRIAGE_COMPLETED_BY,
                MAX(ASSIGN_PHYSICIAN) AS ASSIGN_PHYSICIAN,
                MAX(ED_NOTE_FILED) AS ED_NOTE_FILED,
                MAX(FIRST_PROVIDER_CONTACT) AS FIRST_PROVIDER_CONTACT,
                MAX(DECISION_TO_ED_OBSER) AS DECISION_TO_ED_OBSER,
                MAX(SHORT_TERM_STAY) AS SHORT_TERM_STAY,
                MAX(SHORT_TERM_STAY_TIMESTAMP) AS SHORT_TERM_STAY_TIMESTAMP,
                MAX(TRANS_TO_OBSER_TIMESTAMP) AS TRANS_TO_OBSER_TIMESTAMP,
                GETDATE() AS RUN_DATE,
                MAX(ED_IP_BED_ASSIGNED) AS ED_IP_BED_ASSIGNED,
                MAX(ARRIVAL_department_id) AS ARRIVAL_department_id,
                MAX(ED_DISPOSITION_SELECTED) AS ED_DISPOSITION_SELECTED,
                MAX(PATIENT_LEFT_ED) AS PATIENT_LEFT_ED,
                MAX(CANCELED_ADM) AS CANCELED_ADM, 
                MAX(ED_PATIENT_ERROR) AS ED_PATIENT_ERROR
        FROM (
           SELECT eei.pat_enc_csn_id,peh.hsp_account_id,
              MAX(eei.update_date) OVER (PARTITION BY eei.pat_enc_csn_id ) AS update_date,
              CASE WHEN EEI.EVENT_TYPE = '205' THEN eei.event_time END AS TRIAGE_STARTED,
              CASE WHEN EEI.EVENT_TYPE = '16022281' THEN eei.event_time END AS IP_BED_REQUESTED,
              CASE WHEN EEI.EVENT_TYPE = '95' THEN eei.event_time END AS PATIENT_DEPARTED_FROM_ED,
              CASE WHEN EEI.EVENT_TYPE = '50' THEN eei.event_time END AS PATIENT_ARRIVED_IN_ED,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN eei.event_time END AS PATIENT_ADMITTED,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN emp.name END AS PATIENT_ADMITTED_BY,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN ser.clinician_title END AS PATIENT_ADMITTED_TITLE,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN dep.mpi_id END AS PATIENT_ADMITTED_TO,
              CASE WHEN EEI.EVENT_TYPE = '210' THEN eei.event_time END AS TRIAGE_COMPLETED,
              CASE WHEN EEI.EVENT_TYPE = '210' THEN EMP.NAME END AS TRIAGE_COMPLETED_BY,
              CASE WHEN eei.event_type = '16011103' THEN eei.event_time END AS ASSIGN_PHYSICIAN,
              CASE WHEN eei.event_type = '500' THEN eei.event_time END AS ED_NOTE_FILED,
              CASE WHEN eei.event_type = '16011103' THEN eei.event_time END AS FIRST_PROVIDER_CONTACT,
             MIN(CASE WHEN eei.event_type IN('160224', '1600000062') THEN eei.event_time END)
                  OVER (PARTITION BY eei.pat_enc_csn_id ) AS DECISION_TO_ED_OBSER,
            CASE WHEN eei.event_type = '160225' THEN 'Y' END AS SHORT_TERM_STAY,
            CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time END AS SHORT_TERM_STAY_TIMESTAMP,
            CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time END AS TRANS_TO_OBSER_TIMESTAMP,
            CASE WHEN EEI.EVENT_TYPE = '222' THEN eei.event_time END AS ED_DISPOSITION_SELECTED,
            CASE WHEN EEI.EVENT_TYPE = '160000777' THEN eei.event_time END AS PATIENT_LEFT_ED,
            CASE WHEN EEI.EVENT_TYPE = '49000' THEN eei.event_time END AS ED_PATIENT_ERROR,
            CASE WHEN PESH.UPDATED_CONF_STAT_C = 3 THEN PESH.UPDATE_TIME END AS CANCELED_ADM,
            MIN(CASE WHEN eei.event_type IN('236', '16023101') THEN eei.event_time END)
                  OVER (PARTITION BY eei.pat_enc_csn_id ) AS ED_IP_BED_ASSIGNED,
            CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID END AS ARRIVAL_department_id
          FROM (
            SELECT epi.pat_enc_csn_id,
              epi.update_date, 
              epi.items_edited_time,epi.pat_id,
              ROW_NUMBER() OVER (PARTITION BY epi.pat_enc_csn_id,event_type ORDER BY eei.event_time,eei.adt_event_id) rn,
              EEI.ADT_EVENT_ID,EEI.EVENT_TIME,EEI.EVENT_TYPE,EEI.EVENT_USER_ID,EEI.EVENT_DEPT_ID
           FROM ed_iev_PAT_info epi
           JOIN ed_iev_event_info eei ON eei.event_id=epi.event_id
           WHERE eei.event_type IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062','160225','1600000060', 
                   '236','16023101','222','160000777','49000')
           AND eei.event_status_c IS NULL
           AND EPI.UPDATE_DATE >= @start_dt
           ) eei
         JOIN pat_enc_hsp peh ON peh.pat_enc_csn_id = eei.pat_enc_csn_id
         LEFT JOIN (
           SELECT PSH.*,
             ROW_NUMBER() OVER (PARTITION BY PSH.PAT_ENC_CSN_ID ORDER BY PSH.UPDATE_TIME DESC) AS PSH_RNK
           FROM (
             SELECT DISTINCT PESH.PAT_ENC_CSN_ID,PESH.UPDATE_TIME,PESH.UPDATED_CONF_STAT_C 
             FROM PAT_ENC_STAT_HX PESH
           ) PSH
         ) PESH ON PESH.PAT_ENC_CSN_ID=EEI.PAT_ENC_CSN_ID AND PESH.PSH_RNK=1
         LEFT OUTER JOIN clarity_adt adt ON eei.adt_event_id = adt.event_id
         LEFT OUTER JOIN clarity_emp emp ON eei.event_user_id = emp.user_id
         LEFT OUTER JOIN clarity_ser ser ON emp.prov_id = ser.prov_id  
         LEFT OUTER JOIN cl_dep_id dep ON adt.department_id = dep.department_id AND dep.mpi_id_type_id = 36
         WHERE rn=1
      ) 
      WHERE UPDATE_DATE >= @start_dt
      GROUP BY pat_enc_csn_id,update_date,hsp_account_id
    ) 
    WHERE PATIENT_ARRIVED_IN_ED IS NOT NULL;
    COMMIT;
    END
    ELSE
    BEGIN
        INSERT INTO NYUGT_ED_TMP WITH (TABLOCK)
        WITH ed_updates AS (
        SELECT DISTINCT 
           PAT_ENC.PAT_ID, PAT_ENC.PAT_ENC_CSN_ID, 
           PAT_ENC_HSP.ED_EPISODE_ID, PAT_ENC_HSP.ADMIT_CONF_STAT_C,
           PAT_ENC.CONTACT_DATE, PAT_ENC.Effective_Date_Dt, 
           CSA._UPDATE_DT AS CSA_UPDATE_DATE
        FROM EPIC_UTIL.CSA_PAT_ENC CSA
        INNER JOIN PAT_ENC ON CSA.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
        INNER JOIN PAT_ENC_HSP ON PAT_ENC_HSP.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
                             AND PAT_ENC_HSP.ED_EPISODE_ID IS NOT NULL
                             AND (PAT_ENC_HSP.ADMIT_CONF_STAT_C IS NULL OR PAT_ENC_HSP.ADMIT_CONF_STAT_C NOT IN (2,3))  
        WHERE CSA._UPDATE_DT >= @start_dt
            AND CSA._SOURCE = 0
        )
        SELECT * FROM (
         SELECT pat_enc_csn_id,update_date,hsp_account_id,
             MAX(TRIAGE_STARTED) AS TRIAGE_STARTED ,
             MAX(IP_BED_REQUESTED) AS IP_BED_REQUESTED,
             MAX(PATIENT_DEPARTED_FROM_ED) AS PATIENT_DEPARTED_FROM_ED,
             MAX(PATIENT_ARRIVED_IN_ED) AS PATIENT_ARRIVED_IN_ED,
             MAX(PATIENT_ADMITTED) AS PATIENT_ADMITTED,
             MAX(PATIENT_ADMITTED_BY) AS PATIENT_ADMITTED_BY,
             MAX(PATIENT_ADMITTED_TITLE) AS PATIENT_ADMITTED_TITLE,
             MAX(PATIENT_ADMITTED_TO) AS PATIENT_ADMITTED_TO, 
             MAX(TRIAGE_COMPLETED) AS TRIAGE_COMPLETED,
             MAX(TRIAGE_COMPLETED_BY) AS TRIAGE_COMPLETED_BY,
             MAX(ASSIGN_PHYSICIAN) AS ASSIGN_PHYSICIAN,
             MAX(ED_NOTE_FILED) AS ED_NOTE_FILED,
             MAX(FIRST_PROVIDER_CONTACT) AS FIRST_PROVIDER_CONTACT,
             MAX(DECISION_TO_ED_OBSER) AS DECISION_TO_ED_OBSER,
             MAX(SHORT_TERM_STAY) AS SHORT_TERM_STAY,
             MAX(SHORT_TERM_STAY_TIMESTAMP) AS SHORT_TERM_STAY_TIMESTAMP,
             MAX(TRANS_TO_OBSER_TIMESTAMP) AS TRANS_TO_OBSER_TIMESTAMP,
             GETDATE() AS RUN_DATE,
             MAX(ED_IP_BED_ASSIGNED) AS ED_IP_BED_ASSIGNED,
             MAX(ARRIVAL_department_id) AS ARRIVAL_department_id,
             MAX(ED_DISPOSITION_SELECTED) AS ED_DISPOSITION_SELECTED,
             MAX(PATIENT_LEFT_ED) AS PATIENT_LEFT_ED, 
             MAX(CANCELED_ADM) AS CANCELED_ADM,
             MAX(ED_PATIENT_ERROR) AS ED_PATIENT_ERROR 
         FROM (
             SELECT eei.pat_enc_csn_id,peh.hsp_account_id,
                 MAX(eei.update_date) OVER (PARTITION BY eei.pat_enc_csn_id ) AS update_date,
                 CASE WHEN EEI.EVENT_TYPE = '205' THEN eei.event_time END AS TRIAGE_STARTED,
                 CASE WHEN EEI.EVENT_TYPE = '16022281' THEN eei.event_time END AS IP_BED_REQUESTED,
                 CASE WHEN EEI.EVENT_TYPE = '95' THEN eei.event_time END AS PATIENT_DEPARTED_FROM_ED,
                 CASE WHEN EEI.EVENT_TYPE = '50' THEN eei.event_time END AS PATIENT_ARRIVED_IN_ED,
                 CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN eei.event_time END AS PATIENT_ADMITTED,
                 CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN emp.name END AS PATIENT_ADMITTED_BY,
                 CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN ser.clinician_title END AS PATIENT_ADMITTED_TITLE,
                 CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN dep.mpi_id END AS PATIENT_ADMITTED_TO,
                 CASE WHEN EEI.EVENT_TYPE = '210' THEN eei.event_time END AS TRIAGE_COMPLETED,
                 CASE WHEN EEI.EVENT_TYPE = '210' THEN EMP.NAME END AS TRIAGE_COMPLETED_BY,
                 CASE WHEN eei.event_type = '16011103' THEN eei.event_time END AS ASSIGN_PHYSICIAN, 
                 CASE WHEN eei.event_type = '500' THEN eei.event_time END AS ED_NOTE                CASE WHEN eei.event_type = '16011103' THEN eei.event_time END AS FIRST_PROVIDER_CONTACT,
                MIN(CASE WHEN eei.event_type IN('160224', '1600000062') THEN eei.event_time END) 
                     OVER (PARTITION BY eei.pat_enc_csn_id) AS DECISION_TO_ED_OBSER,
                CASE WHEN eei.event_type = '160225' THEN 'Y' END AS SHORT_TERM_STAY,
                CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time END AS SHORT_TERM_STAY_TIMESTAMP,
                CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time END AS TRANS_TO_OBSER_TIMESTAMP,
                CASE WHEN EEI.EVENT_TYPE = '222' THEN eei.event_time END AS ED_DISPOSITION_SELECTED,
                CASE WHEN EEI.EVENT_TYPE = '160000777' THEN eei.event_time END AS PATIENT_LEFT_ED,
                CASE WHEN EEI.EVENT_TYPE = '49000' THEN eei.event_time END AS ED_PATIENT_ERROR,
                CASE WHEN PESH.UPDATED_CONF_STAT_C = 3 THEN PESH.UPDATE_TIME END AS CANCELED_ADM,
                MIN(CASE WHEN eei.event_type IN('236', '16023101') THEN eei.event_time END)
                     OVER (PARTITION BY eei.pat_enc_csn_id) AS ED_IP_BED_ASSIGNED,
                CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID END AS ARRIVAL_department_id  
            FROM (
              SELECT epi.pat_enc_csn_id,
                ed_updates.CSA_UPDATE_DATE AS update_date,
                epi.items_edited_time,epi.pat_id,
                ROW_NUMBER() OVER (PARTITION BY epi.pat_enc_csn_id,event_type ORDER BY eei.event_time,eei.adt_event_id) rn,
                EEI.ADT_EVENT_ID,EEI.EVENT_TIME,EEI.EVENT_TYPE,EEI.EVENT_USER_ID,EEI.EVENT_DEPT_ID
              FROM ed_iev_PAT_info epi
              JOIN ed_iev_event_info eei ON eei.event_id=epi.event_id
              JOIN ed_updates ON ed_updates.pat_enc_csn_id=epi.pat_enc_csn_id  
              WHERE eei.event_type IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062','160225','1600000060',
                                       '236','16023101','222','160000777','49000')
                AND eei.event_status_c IS NULL
            ) eei
            JOIN pat_enc_hsp peh ON peh.pat_enc_csn_id = eei.pat_enc_csn_id
            LEFT JOIN (
                SELECT PSH.*,
                    ROW_NUMBER() OVER (PARTITION BY PSH.PAT_ENC_CSN_ID ORDER BY PSH.UPDATE_TIME DESC) AS PSH_RNK
                FROM (
                    SELECT DISTINCT PESH.PAT_ENC_CSN_ID,PESH.UPDATE_TIME,PESH.UPDATED_CONF_STAT_C
                    FROM PAT_ENC_STAT_HX PESH  
                ) PSH
            ) PESH ON PESH.PAT_ENC_CSN_ID=EEI.PAT_ENC_CSN_ID AND PESH.PSH_RNK=1
            LEFT OUTER JOIN clarity_adt adt ON eei.adt_event_id = adt.event_id
            LEFT OUTER JOIN clarity_emp emp ON eei.event_user_id = emp.user_id
            LEFT OUTER JOIN clarity_ser ser ON emp.prov_id = ser.prov_id
            LEFT OUTER JOIN cl_dep_id dep ON adt.department_id = dep.department_id AND dep.mpi_id_type_id = 36  
           WHERE rn=1
        ) 
        WHERE PATIENT_ARRIVED_IN_ED IS NOT NULL
        GROUP BY pat_enc_csn_id,update_date,hsp_account_id  
        ); 
        COMMIT;
    END;
    
    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'ED_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ';

    INSERT INTO NYUGT_ED_ORD_TMP WITH (TABLOCK)
    SELECT pp.pat_enc_csn_id,
           pp.order_proc_id, 
           pp.proc_id,
           pp.description,
           pp.order_time,
           pp.order_type_c
    FROM ORDER_METRICS m
    JOIN order_proc pp ON pp.order_proc_id = m.order_id  
    JOIN NYUGT_ED_TMP t ON pp.pat_enc_csn_id=t.pat_enc_csn_id
    WHERE (pp.order_status_c IS NULL OR pp.order_status_c<>4) 
      AND (pp.proc_id IN (233062,252588,60311,377206) OR pp.order_type_c = 49);
    COMMIT; 
    
    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'ED_ORD_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ';
    
    SELECT @cnt = COUNT(*) FROM sys.indexes WHERE name = 'IDX_ED_ADT';
    IF @cnt = 1 
       DROP INDEX IDX_ED_ADT ON NYUGT_ED_ADT_TMP;
    
    SELECT @cnt = COUNT(*)  FROM sys.indexes WHERE name = 'IDX_ED_ADT_U';
    IF @cnt = 1
       DROP INDEX IDX_ED_ADT_U ON NYUGT_ED_ADT_TMP;
       
    INSERT INTO NYUGT_ED_ADT_TMP WITH (TABLOCK)  
    SELECT adt.EVENT_ID,adt.pat_enc_csn_id,adt.pat_id,adt.effective_time,
           adt.event_type_c,adt.event_subtype_c,
           adt.FROM_BASE_CLASS_C,adt.TO_BASE_CLASS_C,
           adt.DEPARTMENT_ID,
           adt.room_id,
           adt.bed_csn_id, 
           adt.room_csn_id,
           adt.pat_class_c,
           adt.PAT_SERVICE_C,
           adt.BASE_PAT_CLASS_C,
           adt.FIRST_IP_IN_IP_YN, 
           adt.SEQ_NUM_IN_ENC
    FROM clarity_adt adt
    JOIN NYUGT_ED_TMP t ON t.pat_enc_csn_id=ADT.PAT_ENC_CSN_ID
    WHERE adt.EVENT_SUBTYPE_C <> 2;
    COMMIT;
    
    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'ED_ADT_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ';
    
    TRUNCATE TABLE SCPM_ED;

    WITH FLO AS (
      SELECT * FROM (
        SELECT m.meas_value,m.recorded_time,t.pat_enc_csn_id,
               ROW_NUMBER() OVER (PARTITION BY rec.pat_id,rec.inpatient_data_id ORDER BY m.recorded_time ASC) rn  
        FROM NYUGT_ED_TMP t
        JOIN pat_enc pe ON pe.pat_enc_csn_id = t.pat_enc_csn_id
        JOIN IP_FLWSHT_REC rec ON pe.pat_id=rec.pat_id AND pe.inpatient_data_id=rec.inpatient_data_id
        JOIN IP_FLWSHT_MEAS m ON m.fsd_id=rec.fsd_id AND m.flo_meas_id='1600005401'
      ) WHERE rn=1
    )
    INSERT INTO SCPM_ED WITH (TABLOCK)
    SELECT DISTINCT
        P.PAT_MRN_ID AS "MRN",
        P.BIRTH_DATE AS "PATIENT_DOB",
        CASE 
            WHEN DATEDIFF(month, P.BIRTH_DATE, COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time))/12 < 0 THEN 0
            WHEN FLOOR(DATEDIFF(month, P.BIRTH_DATE, COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time))/12) = 0 
                THEN ROUND(DATEDIFF(month, P.BIRTH_DATE, COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time))/12.0,2)  
            ELSE FLOOR(DATEDIFF(month, P.BIRTH_DATE, COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time))/12)
        END AS "PATIENT_AGE",
        DEP3.MPI_ID AS "DEPARTMENT",
        DEP4.MPI_ID AS "DEPARTMENT_ADM",
        COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time) AS "VISIT_DATE_TIME",
        HAR3.IP_ADMIT_DATE_TIME AS "ADMIT_DATE_TIME",
        HAR.HSP_ACCOUNT_NAME AS "PATIENT_NAME",
        CASE 
            WHEN HAR.COVERAGE_ID IS NULL THEN ZCFC2.NAME
            WHEN HAR.COVERAGE_ID IS NOT NULL THEN 
                CASE
                    WHEN EPM.FINANCIAL_CLASS IS NULL THEN ZCFC2.NAME
                    ELSE ZCFC.NAME  
                END
        END AS "FIN_CLASS",
        EPM.PAYOR_NAME AS "PAYOR_NAME",
        EPP.BENEFIT_PLAN_NAME AS "PLAN_NAME",
        zpt.name AS "INSURANCE_PRODUCT",
        EPP.RPT_GRP_ONE AS "PLAN_RPT_GRP_ONE", 
        HLB2.XR_HX_XPCTD_AMT AS "EXPECTED_REIMBUSEMENT",
        HAR.HSP_ACCOUNT_ID AS "ACCOUNT_NUMBER",
        ZCHAR.NAME AS "ENCOUNTER_STATUS",
        ZCEPT.NAME AS "DISCH_DISPOSITION",
        ZCEPT.ABBR AS "DISC_DISP_ABBR",
        ZCED.NAME AS "ED_DISCH_DISPOSITION",
        ZCED.ABBR AS "ED_DISC_DISP_ABBR",
        CE.REF_BILL_CODE AS "ICD9", 
        CE.DX_NAME AS "ICD9_DESCRIPTION",
        ZCHAR1.NAME AS "ACCOUNT_STATUS",
        HAR.TOT_CHGS AS "TOTAL_CHARGES",
        PEH.PAT_ENC_CSN_ID AS "CSN",
        ZCHAR2.NAME AS "PATIENT_CLASS",
        COALESCE(ZCPATCLS.NAME,zpc.name) AS "ENC_FINAL_PAT_CLASS",
        haru.inst_of_update_dttm AS "UPDATE_DATE",
        CASE
            WHEN ADT2.TO_BASE_CLASS_C IS NULL THEN 'N/A'  
            WHEN (ADT2.TO_BASE_CLASS_C = 0 AND ADT2.EVENT_TYPE_C = 2) THEN 'Discharged'
            ELSE ZCRBC.NAME
        END AS "PATIENT_AFTER_ED",
        PEH.ADMISSION_PROV_ID AS "ADMITTING_PROV_ID",
        HAR.TOT_PMTS AS "TOTAL_PAYMENTS",
        HAR.TOT_ACCT_BAL AS "TOTAL_ACCT_BAL",
        TRIAGE_STARTED,
        IP_BED_REQUESTED,
        CASE 
            WHEN PATIENT_DEPARTED_FROM_ED IS NOT NULL THEN PATIENT_DEPARTED_FROM_ED
            WHEN PATIENT_DEPARTED_FROM_ED IS NULL AND ED_PATIENT_ERROR>=PATIENT_ARRIVED_IN_ED THEN ED_PATIENT_ERROR  
        END AS PATIENT_DEPARTED_FROM_ED,
        adt6.event_time AS CONVERT_TO_OBSERV,
        PATIENT_ARRIVED_IN_ED,
        PATIENT_ADMITTED,
        PATIENT_ADMITTED_BY,
        PATIENT_ADMITTED_TITLE, 
        PATIENT_ADMITTED_TO,
        TRIAGE_COMPLETED,
        TRIAGE_COMPLETED_BY,
        ASSIGN_PHYSICIAN,  
        ED_NOTE_FILED,
        flo.meas_value AS ACUITY,
        zam.name AS method_of_arrv,
        cea.ref_bill_code AS ADMIT_DX_CODE,
        cea.dx_name AS ADMIT_DX_NAME,
        icd10.code AS "ICD10",
        CE.DX_NAME AS "ICD10_DESCRIPTION", 
        P.ZIP,
        zps.ABBR AS ADM_SERVICE,  
        CEe.ref_bill_code AS IMPRESSION_DX_CODE,
        CEe.dx_name AS IMPRESSION_DX_NAME,
        ARVDEP.DEPARTMENT_NAME AS ARRIVAL_DEPT,
        serl.prov_id AS first_ed_prov_id,
        serl.prov_name AS first_ed_prov_name,
        EPP.BENEFIT_PLAN_ID AS PLAN_ID,
        MIN(CASE WHEN ord.proc_id IN (233062,252588) THEN ord.order_time END) OVER (PARTITION BY peh.pat_enc_csn_id) AS order_date,
        MAX(CASE WHEN ord.proc_id IN (233062,252588) THEN ord.description END) OVER (PARTITION BY peh.pat_enc_csn_id) AS Place_in_ed_observation,  
        FIRST_PROVIDER_CONTACT,
        race.name AS patient_race,
        gr.name AS ethnicity,
        MIN(CASE WHEN ord.proc_id IN (60311, 377206) THEN ord.order_time END) OVER (PARTITION BY peh.pat_enc_csn_id) AS ERS_ADM_order_date,
        MAX(CASE WHEN ord.proc_id IN (60311, 377206) THEN ord.description END) OVER (PARTITION BY peh.pat_enc_csn_id) AS ERS_ADMIT_ORDER,
        adt0.effective_time AS TRANSFER_TO_THGOF,
        
        MAX(CASE WHEN ord.order_type_c = 49 THEN ord.order_time END) OVER (PARTITION BY peh.pat_enc_csn_id) AS DISCH_order_date,
        ztr.name AS HOSPITAL_TRANSFERRED_FROM,
        xtr.LOC_ID,
        CASE
            WHEN xtr.LOC_ID = 10530 THEN 'HJD-P'
            WHEN (xtr.LOC_ID NOT IN (10530, 10500, 10510,10800,1084001,1086001,1086) OR xtr.LOC_ID IS NULL) THEN EAF.LOCATION_ABBR
            ELSE UPPER(xtr.LOC_ABBR)
        END AS "FACILITY",
        DECISION_TO_ED_OBSER,
        room.room_name AS first_ip_room,
        bed.bed_label AS first_ip_bed,
        adt3.effective_time AS first_ip_time,
        ecc.er_complaint AS chief_complaint,
        ZCAS.NAME AS admit_source,
        HAR3.Related_Har_Id,
        SHORT_TERM_STAY,
        ARVDEP.DEPARTMENT_ID AS ARRIVAL_DEPT_ID,
        PEH.DISCH_DISP_C AS DISCH_DISP_ID,
        HAR.PRIM_SVC_HA_C AS HSP_SVC_ID,
        zps.HOSP_SERV_C AS SVC_ID,
        zPATs.Hosp_Serv_c AS PAT_SERV_ID,
        zPATs.Name AS PATIENT_SERVICE,
        har.DISCH_DESTIN_HA_C,
        short_term_stay_timestamp,
        trans_to_obser_timestamp,
        xtr.parent_loc_id,
        xtr.parent_loc_name,
        xtr.parent_loc_abbr,
        ED_IP_BED_ASSIGNED,
        g35.name AS REPORT_GROUP_35,
        ARVDEP.rpt_grp_trtyfive_c,
        trg.meas_value AS TRIAGE_DEST,
        ZCED.ED_DISPOSITION_C,
        COALESCE(peh.adt_pat_class_c,har.acct_class_ha_c) AS adt_pat_class_c,
        PEH.MEANS_OF_ARRV_C AS METHOD_OF_ARRV_ID,
        EPM2.PAYOR_NAME AS SECONDARY_PAYOR,
        EPP2_2.BENEFIT_PLAN_NAME AS SECONDARY_PLAN_NAME,
        ZCFC_2.NAME AS SECONDARY_FIN_CLASS,
        EPP2_2.BENEFIT_PLAN_ID AS SECONDARY_PLAN_ID,
        EPP2_2.RPT_GRP_ONE AS SECONDARY_PLAN_GRP,
        ZPT2.NAME AS SECONDARY_INS_PRODUCT,
        ED_DISPOSITION_SELECTED,
        PATIENT_LEFT_ED,
        CANCELED_ADM
    FROM NYUGT_ED_TMP ED_TMP
    JOIN PAT_ENC_HSP PEH ON ED_TMP.PAT_ENC_CSN_ID=peh.pat_enc_csn_id
    INNER JOIN PATIENT P ON PEH.PAT_ID = P.PAT_ID AND p.pat_name NOT LIKE 'ZZZ%'
    AND P.PAT_ID NOT IN (SELECT PAT_ID FROM CLARITY.NYU_TEST_PATIENT)
    JOIN HSP_ACCOUNT HAR ON PEH.HSP_ACCOUNT_ID = HAR.HSP_ACCOUNT_ID
    JOIN HSP_ACCOUNT_3 HAR3 ON HAR.HSP_ACCOUNT_ID = HAR3.HSP_ACCOUNT_ID
    LEFT OUTER JOIN ZC_PAT_SERVICE zPATs ON ZPATs.Hosp_Serv_c=peh.Hosp_Serv_c
    LEFT JOIN FLO ON flo.pat_enc_csn_id=peh.pat_enc_csn_id
    LEFT OUTER JOIN (
        SELECT hap.prov_id,hap.pat_enc_csn_id,hap.attend_from_date,
               ROW_NUMBER() OVER (PARTITION BY hap.pat_enc_csn_id ORDER BY hap.attend_from_date ASC) rn
        FROM HSP_ATND_PROV hap
        JOIN NYUGT_ED_TMP t ON t.pat_enc_csn_id=hap.pat_enc_csn_id
        WHERE hap.ed_attend_yn='Y'
    ) hap ON peh.pat_enc_csn_id=hap.pat_enc_csn_id AND hap.rn=1
    LEFT OUTER JOIN CLARITY_SER serl ON serl.prov_id=hap.prov_id
    LEFT OUTER JOIN NYUGT_ED_ADT_TMP ADTADMIT ON peh.pat_enc_csn_id=ADTADMIT.PAT_ENC_CSN_ID 
        AND PEH.ADM_EVENT_ID = ADTADMIT.EVENT_ID
        AND ADTADMIT.EVENT_SUBTYPE_C <> 2
        AND ADTADMIT.EVENT_TYPE_C = 1
    LEFT OUTER JOIN CLARITY_DEP ADMDEP ON ADTADMIT.DEPARTMENT_ID = ADMDEP.DEPARTMENT_ID
    LEFT OUTER JOIN CLARITY_DEP ARVDEP ON ARVDEP.DEPARTMENT_ID = COALESCE(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)  
    LEFT OUTER JOIN ZC_DEP_RPT_GRP_35 g35 ON COALESCE(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)=g35.dep_rpt_grp_35_c
    LEFT OUTER JOIN ZC_DISCH_DESTIN_HA zdd ON zdd.disch_destin_ha_c=har.DISCH_DESTIN_HA_C
    LEFT OUTER JOIN HSP_ACCT_LAST_UPDATE haru ON haru.hsp_account_id= har.HSP_ACCOUNT_ID
    LEFT OUTER JOIN ZC_TRANSFER_SRC_HA ztr ON ztr.TRANSFER_SRC_HA_C =HAR.TRANSFER_SRC_HA_C
    LEFT OUTER JOIN NYU_V_FAC_STRUCT_X xtr ON COALESCE(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID) = xtr.DEP_ID
    LEFT OUTER JOIN CLARITY_LOC EAF ON HAR.LOC_ID = EAF.LOC_ID  
    LEFT OUTER JOIN ZC_ADM_SOURCE ZCAS ON PEH.ADMIT_SOURCE_C = ZCAS.ADMIT_SOURCE_C
    LEFT JOIN (
        SELECT FR.INPATIENT_DATA_ID,fm.meas_value,
               ROW_NUMBER() OVER (PARTITION BY FR.INPATIENT_DATA_ID ORDER BY fm.recorded_time DESC) rn
        FROM IP_FLWSHT_MEAS FM
        INNER JOIN IP_FLWSHT_REC FR ON FM.FSD_ID = FR.FSD_ID
        INNER JOIN IP_FLO_GP_DATA GP ON FM.FLO_MEAS_ID = GP.FLO_MEAS_ID  
        WHERE fm.flo_meas_id = 16029
          AND ENTRY_TIME >= (DATEADD(DAY,-30,@start_dt))
    ) trg ON trg.INPATIENT_DATA_ID = peh.INPATIENT_DATA_ID AND trg.rn=1
    LEFT OUTER JOIN CLARITY_DEP DEP ON PEH.DEPARTMENT_ID = DEP.DEPARTMENT_ID
    LEFT JOIN COVERAGE CVG ON HAR.COVERAGE_ID = CVG.COVERAGE_ID
    LEFT OUTER JOIN clarity_epm EPM ON cvg.payor_id = EPM.PAYOR_ID
    LEFT OUTER JOIN CLARITY_EPP EPP ON CVG.PLAN_ID=EPP.BENEFIT_PLAN_ID
    LEFT OUTER JOIN ZC_FINANCIAL_CLASS ZCFC ON EPM.FINANCIAL_CLASS = ZCFC.FINANCIAL_CLASS  
    LEFT OUTER JOIN ZC_FIN_CLASS ZCFC2 ON HAR.ACCT_FIN_CLASS_C = ZCFC2.FIN_CLASS_C
    LEFT OUTER JOIN CLARITY_EPP_2 EPP2 ON epp2.benefit_plan_id= EPP.BENEFIT_PLAN_ID
    LEFT OUTER JOIN zc_prod_type zpt ON zpt.prod_type_c=epp2.prod_type_c
    LEFT OUTER JOIN ZC_ARRIV_MEANS zam ON peh.MEANS_OF_ARRV_C =zam.means_of_arrv_c
    LEFT OUTER JOIN (
        SELECT HAR1.HSP_ACCOUNT_ID, HLB2.BUCKET_ID, HLB2.XR_HX_XPCTD_AMT
        FROM (
                SELECT INSURANCE_BUCKET_ID, HSP_ACCOUNT_ID
                FROM (
                    SELECT INSURANCE_BUCKET_ID, HAR1.HSP_ACCOUNT_ID,
                           ROW_NUMBER() OVER(PARTITION BY HAR1.HSP_ACCOUNT_ID ORDER BY LINE) AS RN  
                    FROM HSP_ACCT_INS_BKTS HAR1
                    JOIN NYUGT_ED_TMP ED_TMP ON ED_TMP.HSP_ACCOUNT_ID=HAR1.HSP_ACCOUNT_ID
                ) WHERE RN = 1
        ) HAR1
        JOIN (
                SELECT BUCKET_ID,XR_HX_XPCTD_AMT 
                FROM (
                    SELECT BUCKET_ID, XR_HX_XPCTD_AMT, 
                           ROW_NUMBER() OVER(PARTITION BY HLB2.BUCKET_ID ORDER BY LINE) AS RN
                    FROM HSP_BKT_XPTRBMT_HX HLB2
                    JOIN NYUGT_ED_TMP ED_TMP ON ED_TMP.HSP_ACCOUNT_ID = HLB2.HSP_ACCOUNT_ID  
                ) WHERE RN = 1
        ) HLB2 ON HAR1.INSURANCE_BUCKET_ID = HLB2.BUCKET_ID
    ) HLB2 ON HAR.HSP_ACCOUNT_ID = HLB2.HSP_ACCOUNT_ID
    LEFT OUTER JOIN (
        SELECT ADT2.PAT_ENC_CSN_ID,adt2.TO_BASE_CLASS_C,adt2.EVENT_TYPE_C
        FROM NYUGT_ED_ADT_TMP ADT2
        WHERE (ADT2.FROM_BASE_CLASS_C = 3 AND ADT2.TO_BASE_CLASS_C <> 3)
          AND ADT2.EVENT_SUBTYPE_C <> 2
          AND ADT2.SEQ_NUM_IN_ENC = (
            SELECT MIN(ADT2X.SEQ_NUM_IN_ENC)  
            FROM NYUGT_ED_ADT_TMP ADT2X
            WHERE ADT2.PAT_ENC_CSN_ID = ADT2X.PAT_ENC_CSN_ID
              AND (ADT2X.FROM_BASE_CLASS_C = 3 AND ADT2X.TO_BASE_CLASS_C <> 3)
              AND ADT2X.EVENT_SUBTYPE_C <> 2
          )
    ) ADT2 ON PEH.PAT_ENC_CSN_ID = ADT2.PAT_ENC_CSN_ID
    LEFT OUTER JOIN NYUGT_ED_ADT_TMP ADT3 ON peh.PAT_ENC_CSN_ID = ADT3.PAT_ENC_CSN_ID
        AND ADT3.FIRST_IP_IN_IP_YN = 'Y'  
        AND ADT3.BASE_PAT_CLASS_C = 1
    LEFT OUTER JOIN ZC_PAT_SERVICE zps ON zps.hosp_serv_c = ADT3.PAT_SERVICE_C
    LEFT OUTER JOIN clarity_bed bed ON adt3.bed_csn_id=bed.bed_csn_id
    LEFT OUTER JOIN clarity_rom room ON adt3.room_csn_id=room.room_csn_id
    LEFT OUTER JOIN (
        SELECT MIN(EFFECTIVE_TIME) AS event_time,adt6.pat_enc_csn_id
        FROM NYUGT_ED_ADT_TMP adt6  
        WHERE adt6.EVENT_SUBTYPE_C <> 2
          AND adt6.pat_class_c ='104'
        GROUP BY adt6.pat_enc_csn_id
    ) adt6 ON PEH.PAT_ENC_CSN_ID = ADT6.PAT_ENC_CSN_ID
    LEFT OUTER JOIN HSP_ACCT_DX_LIST HARDX ON HAR.HSP_ACCOUNT_ID = HARDX.HSP_ACCOUNT_ID AND HARDX.LINE = 1
    LEFT OUTER JOIN CLARITY_EDG CE ON HARDX.DX_ID = CE.DX_ID
    LEFT OUTER JOIN EDG_CURRENT_ICD10 ICD10 ON hardx.dx_id=icd10.dx_id AND hardx.line=1 AND icd10.line=1
    LEFT OUTER JOIN HSP_ADMIT_DIAG HAD ON PEH.PAT_ENC_CSN_ID = HAD.PAT_ENC_CSN_ID AND HAD.LINE = 1 
    LEFT OUTER JOIN CLARITY_EDG CEa ON HAD.DX_ID = CEa.DX_ID
    LEFT OUTER JOIN PAT_ENC_ER_COMPLNT ecc ON ecc.pat_enc_csn_id = peh.pat_enc_csn_id AND ecc.line = 1
    LEFT OUTER JOIN (
        SELECT pedx.DX_ID,pedx.PAT_ENC_CSN_ID
        FROM PAT_ENC_DX pedx
        JOIN NYUGT_ED_TMP t ON t.pat_enc_csn_id=pedx.PAT_ENC_CSN_ID
        WHERE pedx.dx_ed_yn='Y'
          AND pedx.LINE = (
            SELECT MIN(line) 
            FROM PAT_ENC_DX pedx2
            WHERE pedx2.dx_ed_yn ='Y'
              AND pedx2.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
            GROUP BY PAT_ENC_CSN_ID
          ) 
    ) pedx ON peh.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
    LEFT OUTER JOIN CLARITY_EDG CEe ON pedx.DX_ID = CEe.DX_ID
    LEFT OUTER JOIN ZC_MC_PAT_STATUS
    ZCHAR ON HAR.PATIENT_STATUS_C = ZCHAR.PAT_STATUS_C  
    LEFT OUTER JOIN ZC_ACCT_BILLSTS_HA ZCHAR1 ON HAR.ACCT_BILLSTS_HA_C = ZCHAR1.ACCT_BILLSTS_HA_C
    LEFT OUTER JOIN ZC_ACCT_BASECLS_HA ZCHAR2 ON HAR.ACCT_BASECLS_HA_C = ZCHAR2.ACCT_BASECLS_HA_C
    LEFT OUTER JOIN ZC_DISCH_DISP ZCEPT ON PEH.DISCH_DISP_C = ZCEPT.DISCH_DISP_C
    LEFT OUTER JOIN ZC_REP_BASE_CLASS ZCRBC ON ADT2.TO_BASE_CLASS_C = ZCRBC.INT_REP_BASE_CLS_C  
    LEFT OUTER JOIN ZC_ED_DISPOSITION ZCED ON PEH.ED_DISPOSITION_C = ZCED.ED_DISPOSITION_C
    LEFT OUTER JOIN CL_DEP_ID DEP3 ON DEP.DEPARTMENT_ID = DEP3.DEPARTMENT_ID AND DEP3.MPI_ID_TYPE_ID = 36
    LEFT OUTER JOIN CL_DEP_ID DEP4 ON ADT3.DEPARTMENT_ID = DEP4.DEPARTMENT_ID AND DEP4.MPI_ID_TYPE_ID = 36  
    LEFT OUTER JOIN ZC_PAT_CLASS ZCPATCLS ON PEH.ADT_PAT_CLASS_C = ZCPATCLS.ADT_PAT_CLASS_C
    LEFT JOIN ZC_PAT_CLASS zpc ON zpc.adt_pat_class_c=har.ACCT_CLASS_HA_C
    LEFT OUTER JOIN ZC_ACUITY_LEVEL za ON peh.ACUITY_LEVEL_C=za.acuity_level_c
    LEFT OUTER JOIN patient_race aa ON p.pat_id=aa.pat_id AND aa.line=1
    LEFT OUTER JOIN zc_patient_race race ON aa.patient_race_c=race.patient_race_c  
    LEFT OUTER JOIN zc_ethnic_group gr ON p.ethnic_group_c=gr.ethnic_group_c
    LEFT JOIN NYUGT_ED_ORD_TMP ord ON peh.pat_enc_csn_id = ord.pat_enc_csn_id
    LEFT OUTER JOIN (
        SELECT * 
        FROM NYUGT_ED_ADT_TMP adt0
        WHERE adt0.effective_time IN (
          SELECT MIN(adt5.effective_time)
          FROM NYUGT_ED_ADT_TMP adt5  
          WHERE adt0.pat_enc_csn_id = adt5.pat_enc_csn_id
            AND adt5.room_id = 10500016241
            AND adt5.event_type_c = 3
            AND adt5.event_subtype_c = 1
          GROUP BY adt5.pat_enc_csn_id  
        )
    ) adt0 ON peh.pat_enc_csn_id = adt0.pat_enc_csn_id
    LEFT OUTER JOIN HSP_ACCT_CVG_LIST CVG_LIST ON HAR.HSP_ACCOUNT_ID=CVG_LIST.HSP_ACCOUNT_ID AND CVG_LIST.LINE=2
    LEFT OUTER JOIN COVERAGE COV2 ON CVG_LIST.COVERAGE_ID=COV2.COVERAGE_ID
    LEFT OUTER JOIN CLARITY_EPM EPM2 ON COV2.PAYOR_ID = EPM2.PAYOR_ID
    LEFT OUTER JOIN CLARITY_EPP EPP2_2 ON COV2.PLAN_ID = EPP2_2.BENEFIT_PLAN_ID  
    LEFT OUTER JOIN ZC_FINANCIAL_CLASS ZCFC_2 ON EPM2.FINANCIAL_CLASS = ZCFC_2.FINANCIAL_CLASS
    LEFT OUTER JOIN CLARITY_EPP_2 EPP22 ON EPP22.BENEFIT_PLAN_ID= COV2.PLAN_ID
    LEFT OUTER JOIN ZC_PROD_TYPE ZPT2 ON ZPT2.PROD_TYPE_C=EPP22.PROD_TYPE_C
    WHERE PEH.ED_EPISODE_ID IS NOT NULL  
      AND HAR3.Related_Har_Id IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM PATIENT_TYPE ptt
        WHERE ptt.patient_type_c IN ('100','101','102','104')  
          AND peh.pat_id=ptt.pat_id
      )
      AND PATIENT_ARRIVED_IN_ED IS NOT NULL  
      AND (
        (xtr.parent_loc_id NOT IN (1086001,1086) AND EAF.LOC_ID NOT IN (1086001,1086))
        OR ((xtr.parent_loc_id IN (1086001,1086) OR EAF.LOC_ID IN (1086001,1086)) 
            AND CAST(COALESCE(HAR.ADM_DATE_TIME, peh.hosp_admsn_time) AS DATE) >= '2022-11-06')  
      ) 
      AND CANCELED_ADM IS NULL;
      
    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'SCPM_ED', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ';
    
    EXEC clarity.NYU_CLARITY_LOG_PKG.logMsg 'NYU_V_ED_SCPM', 'NYU_V_ED_SCPM_J', 'INFO', 'COMPLETED', 'STORED PROCEDURE COMPLETED';
END;
