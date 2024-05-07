
CREATE PROCEDURE NYU_PRENATAL 
  @START_DATE VARCHAR(20),
  @END_DATE VARCHAR(20)
AS
BEGIN

  DECLARE @RUNDATE DATE = GETDATE();
  DECLARE @I_START_DATE DATE = CAST(@START_DATE AS DATE);
  DECLARE @I_END_DATE DATE = CAST(@END_DATE AS DATE);
  DECLARE @FLU_ORD_DATE DATE = '2017-08-01'; 
  DECLARE @FLU_ADM_DATE DATE = '2017-09-01';

  BEGIN
    PRINT 'Start Time: ' + CONVERT(VARCHAR, @RUNDATE, 121);

    BEGIN TRY
      TRUNCATE TABLE tmpActivePregnancyEpisodes;
    END TRY
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701
      BEGIN
        CREATE TABLE tmpActivePregnancyEpisodes 
        (
          Episode_ID numeric(18,0) NULL,
          Patient_ID varchar(20) NULL,
          Patient_MRN varchar(20) NULL,
          Patient_Name varchar(200) NULL,
          Patient_DOB date NULL,
          Start_Date date NULL,
          First_Preg_Enc date NULL,
          First_Prenatal_Loc varchar(200) NULL,
          First_Prenatal_Prov varchar(200) NULL,
          First_Prenatal_Date date NULL,     
          First_Prenatal_Trimester varchar(20) NULL,
          LMP date NULL,
          WORKING_ESD date NULL,
          Working_EDD date NULL,
          Diabetic varchar(1) NULL,
          Hypertensive varchar(1) NULL
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpActivePregnancyVisits; 
    END TRY
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701
      BEGIN
        CREATE TABLE tmpActivePregnancyVisits
        (
          Episode_ID numeric(18,0) NULL,
          Patient_ID varchar(20) NULL,
          Encounter_ID varchar(20) NULL,
          Encounter_Date date NULL,
          LMP date NULL,
          Encounter_Visit_Type varchar(100) NULL,
          Encounter_Department varchar(200) NULL,
          Encounter_Location varchar(200) NULL,
          Encounter_Provider varchar(200) NULL,
          Encounter_Prov_Type varchar(200) NULL,
          Supervising_Provider varchar(200) NULL                
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpPrenatalFluImmunizations;
    END TRY 
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701
      BEGIN
        CREATE TABLE tmpPrenatalFluImmunizations
        (
          Immune_ID varchar(20) NULL,
          Patient_ID varchar(20) NULL,
          Immunization_ID varchar(20) NULL,
          Order_ID varchar(20) NULL,
          Order_description varchar(200) NULL,
          Adminitration_Date date NULL,
          Immunization_Enc_ID varchar(20) NULL,
          Immunization_Entry date NULL,
          Status varchar(20) NULL,
          Defer_Reason varchar(200) NULL
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpRecPrenatalFluImmunizations;
    END TRY
    BEGIN CATCH  
      IF ERROR_NUMBER() = 3701
      BEGIN
        CREATE TABLE tmpRecPrenatalFluImmunizations
        (
          Immune_ID varchar(20) NULL,
          Immune_Type varchar(20) NULL,
          Patient_ID varchar(20) NULL,
          Immunization_ID varchar(20) NULL,
          Order_ID varchar(20) NULL,
          Order_description varchar(200) NULL,
          Adminitration_Date date NULL,
          Immunization_Enc_ID varchar(20) NULL,
          Immunization_Entry date NULL,
          Status varchar(20) NULL,
          Defer_Reason varchar(200) NULL,
          Scanned_Doc_Date date NULL,
          Scanned_Reason varchar(100) NULL
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpPrenatalFluOrders;
    END TRY
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701 
      BEGIN
        CREATE TABLE tmpPrenatalFluOrders
        (
          Order_ID varchar(20) NULL, 
          Medication_ID varchar(20) NULL,
          Order_Code varchar(20) NULL,
          Proc_Code varchar(20) NULL,
          Patient_ID varchar(20) NULL,
          Order_Date date NULL,
          Order_Status varchar(20) NULL,
          Order_Provider varchar(200) NULL,
          Order_Description varchar(200) NULL  
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpPatNextAppt;
    END TRY
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701
      BEGIN  
        CREATE TABLE tmpPatNextAppt
        (
          Patient_ID varchar(20) NULL,
          Encounter_ID varchar(20) NULL,
          Encounter_Date date NULL,
          Encounter_Location varchar(200) NULL,
          Encounter_Provider varchar(200) NULL
        );
      END;
    END CATCH;

    BEGIN TRY
      TRUNCATE TABLE tmpPatLabTestResults;
    END TRY
    BEGIN CATCH
      IF ERROR_NUMBER() = 3701
      BEGIN
        CREATE TABLE tmpPatLabTestResults
        (
          Patient_ID varchar(20) NULL,
          Order_ID varchar(20) NULL,  
          Proc_Code varchar(20) NULL,
          Proc_Desription varchar(200) NULL,
          Order_Status varchar(20) NULL,
          Order_Date date NULL,
          Result_Date date NULL,
          Result_Value varchar(200) NULL,
          Result_Value_Desc varchar(300) NULL,
          Result_Status varchar(50) NULL
        );
      END;  
    END CATCH;

    PRINT 'CREATE TABLES: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS';
    SET @RUNDATE = GETDATE();
    
    -- Populate tmpActivePregnancyEpisodes
    INSERT INTO tmpActivePregnancyEpisodes
    SELECT EPISODE_FILTER.EPISODE_ID
    ,PATIENT.PAT_ID
    ,PATIENT.PAT_MRN_ID
    ,PATIENT.PAT_NAME
    ,PATIENT.BIRTH_DATE
    ,EPISODE.START_DATE
    ,EPISODE.FIRST_PNC_DT
    ,ZC_FIRST_PNT_LOC.Name
    ,''  
    ,FIRST_PNC_DT
    ,CASE
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 280 AND FIRST_PNC_DT < OB_WRK_EDD_DT - 183 
      THEN 'FIRST'
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 182 AND FIRST_PNC_DT < OB_WRK_EDD_DT - 99
      THEN 'SECOND'  
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 98 AND FIRST_PNC_DT <= OB_WRK_EDD_DT
      THEN 'THIRD'
      ELSE NULL
    END AS FIRST_PNC_TRIMESTER
    ,NULL
    ,OB_WRK_EDD_DT - 280 AS OB_WRK_ST_DT
    ,OB_WRK_EDD_DT
    ,''
    ,''  
    FROM (
      SELECT EPISODE.EPISODE_ID
      FROM EPISODE
      LEFT JOIN EPISODE_LINK ON EPISODE.EPISODE_ID = EPISODE_LINK.EPISODE_ID 
      LEFT JOIN PAT_ENC ON EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
      LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
      LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
      WHERE EPISODE.SUM_BLK_TYPE_ID = '2'
        AND EPISODE.STATUS_C <> 3
        AND PAT_ENC.CONTACT_DATE >= @I_START_DATE
        AND PAT_ENC.CONTACT_DATE < @I_END_DATE + 1
        AND CLARITY_LOC.RPT_GRP_ELEVEN_C = '10787'  
      GROUP BY EPISODE.EPISODE_ID  
    ) EPISODE_FILTER
    LEFT JOIN EPISODE ON EPISODE_FILTER.EPISODE_ID = EPISODE.EPISODE_ID
    LEFT JOIN PATIENT ON EPISODE.PAT_LINK_ID = PATIENT.PAT_ID
    LEFT JOIN ZC_FIRST_PNT_LOC ON EPISODE.FIRST_PNT_LOC_C = ZC_FIRST_PNT_LOC.FIRST_PNT_LOC_C;

    -- Append tmpActivePregnancyEpisodes with partial matches  
    INSERT INTO tmpActivePregnancyEpisodes
    SELECT DISTINCT EPISODE.EPISODE_ID
    ,PATIENT.PAT_ID
    ,PATIENT.PAT_MRN_ID
    ,PATIENT.PAT_NAME
    ,PATIENT.BIRTH_DATE
    ,EPISODE.START_DATE
    ,EPISODE.FIRST_PNC_DT AS FIRST_PREG_ENC
    ,ZC_FIRST_PNT_LOC.NAME AS FIRST_PRENATAL_LOC
    ,NULL AS FIRST_PRENATAL_PROV
    ,EPISODE.FIRST_PNC_DT AS FIRST_PRENATAL_DATE
    ,CASE
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 280 AND FIRST_PNC_DT < OB_WRK_EDD_DT - 183
      THEN 'FIRST'
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 182 AND FIRST_PNC_DT < OB_WRK_EDD_DT - 99  
      THEN 'SECOND'
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - 98 AND FIRST_PNC_DT <= OB_WRK_EDD_DT
      THEN 'THIRD' 
      ELSE NULL
    END AS FIRST_PNC_TRIMESTER
    ,NULL AS LMP
    ,EPISODE.OB_WRK_EDD_DT - 280 AS WORKING_ESD
    ,EPISODE.OB_WRK_EDD_DT AS Working_EDD
    ,NULL AS Diabetic
    ,NULL AS Hypertensive
    FROM EPISODE 
    LEFT JOIN (
      SELECT DISTINCT
        EPISODE_LINK.EPISODE_ID,
        PAT_ENC.PAT_ID
      FROM EPISODE_LINK
      LEFT JOIN PAT_ENC ON EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
    ) EPISODE_PAT ON EPISODE.EPISODE_ID = EPISODE_PAT.EPISODE_ID

    LEFT JOIN PAT_ENC ON EPISODE_PAT.PAT_ID = PAT_ENC.PAT_ID
      AND EPISODE.OB_WRK_EDD_DT - 280 < PAT_ENC.CONTACT_DATE 
      AND PAT_ENC.CONTACT_DATE < EPISODE.OB_WRK_EDD_DT
      AND PAT_ENC.ENC_TYPE_C IN (1200,1201) 
      AND PAT_ENC.CHECKIN_TIME IS NOT NULL
 
    LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
    LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
    LEFT JOIN PATIENT ON EPISODE_PAT.PAT_ID = PATIENT.PAT_ID
    LEFT JOIN ZC_FIRST_PNT_LOC ON EPISODE.FIRST_PNT_LOC_C = ZC_FIRST_PNT_LOC.FIRST_PNT_LOC_C

    WHERE EPISODE.OB_WRK_EDD_DT IS NOT NULL
      AND EPISODE.SUM_BLK_TYPE_ID = '2' 
      AND EPISODE.STATUS_C <> 3
      AND EPISODE.EPISODE_ID NOT IN (SELECT EPISODE_ID FROM tmpActivePregnancyEpisodes)
      AND PAT_ENC.CONTACT_DATE >= @I_START_DATE
      AND PAT_ENC.CONTACT_DATE < @I_END_DATE + 1  
      AND CLARITY_LOC.RPT_GRP_ELEVEN_C = '10787';

    PRINT 'EPISODES: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS'; 
    SET @RUNDATE = GETDATE();

    -- Populate tmpActivePregnancyVisits
    INSERT INTO tmpActivePregnancyVisits
    SELECT
      tmpActivePregnancyEpisodes.Episode_ID,
      tmpActivePregnancyEpisodes.Patient_ID, 
      PAT_ENC.Pat_Enc_CSN_ID,
      Pat_Enc.Contact_Date,
      Pat_Enc.LMP_Date,
      ZC_DISP_ENC_TYPE.NAME,
      CLARITY_DEP.DEPARTMENT_NAME,
      CLARITY_LOC.Loc_Name,
      SER_VISIT.Prov_Name,
      SER_VISIT.PROV_TYPE,
      SER_SUPERVISING.Prov_Name
    FROM tmpActivePregnancyEpisodes
    LEFT JOIN EPISODE_LINK ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_LINK.EPISODE_ID 
    LEFT JOIN PAT_ENC ON tmpActivePregnancyEpisodes.PATIENT_ID = PAT_ENC.PAT_ID
      AND (
        EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
        OR 
          (EPISODE_LINK.PAT_ENC_CSN_ID IS NULL
          AND (tmpActivePregnancyEpisodes.WORKING_ESD < PAT_ENC.CONTACT_DATE 
          AND PAT_ENC.CONTACT_DATE < tmpActivePregnancyEpisodes.Working_EDD))  
       )
       AND PAT_ENC.ENC_TYPE_C IN (101,1200,1201,1214)
       AND PAT_ENC.CHECKIN_TIME IS NOT NULL
 
    LEFT JOIN PAT_ENC_2 ON PAT_ENC.PAT_ENC_CSN_ID = PAT_ENC_2.PAT_ENC_CSN_ID
    LEFT JOIN CLARITY_SER SER_VISIT ON PAT_ENC.VISIT_PROV_ID = SER_VISIT.PROV_ID
    LEFT JOIN CLARITY_SER SER_SUPERVISING ON PAT_ENC_2.SUP_PROV_ID = SER_SUPERVISING.PROV_ID
    LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
    LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
    LEFT JOIN ZC_DISP_ENC_TYPE ON Pat_Enc.ENC_TYPE_C = ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C;

    PRINT 'EPISODES VISITS: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS'; 
    SET @RUNDATE = GETDATE();

    -- Update tmpActivePregnancyVisits with diagnosis
    UPDATE tmpActivePregnancyEpisodes
    SET 
      Diabetic = (SELECT MAX(CASE WHEN PAT_ENC_DX.DX_ID IN (SELECT DX_ID FROM EDG_CURRENT_ICD10 WHERE CODE IN ('O13', 'O13.9')) THEN 'Y' ELSE NULL END) 
                  FROM tmpActivePregnancyVisits
                  INNER JOIN PAT_ENC_DX ON tmpActivePregnancyVisits.Encounter_ID = PAT_ENC_DX.PAT_ENC_CSN_ID
                  WHERE tmpActivePregnancyVisits.episode_id = tmpActivePregnancyEpisodes.episode_id),
      Hypertensive = (SELECT MAX(CASE WHEN PAT_ENC_DX.DX_ID IN (SELECT DX_ID FROM EDG_CURRENT_ICD10 WHERE CODE IN (SELECT ICD_CODES_LIST FROM VCG_ICD_CODES WHERE GROUPER_ID = 5100000145 AND CODE_SET_C = 2)) THEN 'Y' ELSE NULL END)
                      FROM tmpActivePregnancyVisits  
                      INNER JOIN PAT_ENC_DX ON tmpActivePregnancyVisits.Encounter_ID = PAT_ENC_DX.PAT_ENC_CSN_ID
                      WHERE tmpActivePregnancyVisits.episode_id = tmpActivePregnancyEpisodes.episode_id);
    
    PRINT 'EPISODES DIAGNOSIS: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS';
    SET @RUNDATE = GETDATE();

    -- Update tmpActivePregnancyEpisodeswith first prenatal provider  
    UPDATE tmpActivePregnancyEpisodes
    SET First_Prenatal_Prov = (
        SELECT TOP 1 v_Patient_Encs_1.Encounter_Provider
        FROM (
          SELECT 
            Episode_ID,
            Patient_ID,
            Encounter_ID,
            Encounter_Provider,
            ROW_NUMBER() OVER (PARTITION BY Patient_ID, Episode_ID ORDER BY Encounter_Date) AS rank  
          FROM tmpActivePregnancyVisits
          WHERE tmpActivePregnancyVisits.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
            AND tmpActivePregnancyVisits.Episode_ID = tmpActivePregnancyEpisodes.Episode_ID  
        ) v_Patient_Encs_1
        WHERE rank = 1
    );
      
    PRINT 'EPISODES FIRST PROVIDER: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS';
    SET @RUNDATE = GETDATE();
  
    -- Update tmpActivePregnancyEpisodes with LMP (last menstral period) from first pregnancy encounter
    UPDATE tmpActivePregnancyEpisodes  
    SET LMP = (
        SELECT TOP 1 v_Patient_Encs.LMP
        FROM (
          SELECT
            Episode_ID, 
            Patient_ID,
            Encounter_ID,
            Encounter_Date, 
            LMP,
            Encounter_Visit_Type,
            ROW_NUMBER() OVER (PARTITION BY Patient_ID ORDER BY Encounter_Date) AS rank
          FROM tmpActivePregnancyVisits
          WHERE tmpActivePregnancyVisits.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID  
            AND tmpActivePregnancyVisits.Episode_ID = tmpActivePregnancyEpisodes.Episode_ID
            AND tmpActivePregnancyVisits.LMP IS NOT NULL
        ) v_Patient_Encs
        WHERE rank = 1       
    );
      
    PRINT 'EPISODES LMP: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS'; 
    SET @RUNDATE = GETDATE();
  
    -- Lets get the next appointment details.
    INSERT INTO tmpPatNextAppt  
    SELECT DISTINCT
      Patient_ID,
      '', 
      NULL,
      '',
      '' 
    FROM tmpActivePregnancyEpisodes;

    -- Now lets get the next appointment for this patient  
    UPDATE tmpPatNextAppt
    SET
      tmpPatNextAppt.Encounter_ID = V_Appts.Pat_ENC_CSN_ID,  
      tmpPatNextAppt.Encounter_Date = V_Appts.Appt_Dttm,
      tmpPatNextAppt.Encounter_Location = V_Appts.LOC_NAME,
      tmpPatNextAppt.Encounter_Provider = V_Appts.PROV_NAME_WID  
    FROM (
        SELECT
          Pat_ID,
          Pat_ENC_CSN_ID,
          appt_dttm,
          Appt_Status_Name,
          LOC_NAME,
          PROV_NAME_WID,  
          ROW_NUMBER() OVER (PARTITION BY Pat_ID ORDER BY appt_dttm) AS rank
        FROM v_sched_appt
        WHERE v_sched_appt.Pat_ID = tmpPatNextAppt.Patient_ID
          AND v_sched_appt.appt_dttm >= GETDATE() - 1 
          AND v_sched_appt.Appt_Status_Name = 'Scheduled'
          AND v_sched_appt.Dept_Specialty_Name = 'Obstetrics and Gynecology'
          AND v_sched_appt.loc_Name LIKE 'NYU LUTHERAN - %'  
      ) V_Appts
    WHERE rank = 1;

    PRINT 'EPISODES NEXT APPT: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS';
    SET @RUNDATE = GETDATE();
  
    -- OK, now that we have our Episodes, lets get to see what the status is of all flu shots for the patients.
    INSERT INTO tmpPrenatalFluImmunizations
    SELECT
      Immune_1.Immune_ID,
      tmpActivePregnancyEpisodes.Patient_ID,
      Immune_1.Immunzatn_ID, 
      Immune_1.Order_ID,
      CLARITY_IMMUNZATN.Name,
      Immune_1.Immune_Date,
      Immune_1.Imm_CSN,
      Immune_1.Entry_DTTM,
      ZC_IMMNZTN_STATUS.Name,
      ZC_DEFER_REASON.Name  
    FROM tmpActivePregnancyEpisodes
    
    INNER JOIN immune Immune_1 ON Immune_1.Pat_Id = tmpActivePregnancyEpisodes.Patient_ID
        
    INNER JOIN CLARITY_IMMUNZATN ON CLARITY_IMMUNZATN.IMMUNZATN_ID = Immune_1.IMMUNZATN_ID
        
    LEFT JOIN ZC_DEFER_REASON ON ZC_DEFER_REASON.DEFER_REASON_C = Immune_1.DEFER_REASON_C
        
    INNER JOIN ZC_IMMNZTN_STATUS ON ZC_IMMNZTN_STATUS.IMMNZTN_STATUS_C = Immune_1.IMMNZTN_STATUS_C
        
    WHERE (CLARITY_IMMUNZATN.Name LIKE '%FLU%' OR CLARITY_IMMUNZATN.Name LIKE '%INFLUENZA%' OR CLARITY_IMMUNZATN.Immunzatn_ID = '61')
      AND ZC_IMMNZTN_STATUS.Name != 'Deleted';
       
    -- Most recent flu vaccine.
    INSERT INTO tmpRecPrenatalFluImmunizations  
    SELECT DISTINCT 
      '',
      CASE WHEN tmpPrenatalFluImmunizations.Immunization_ID != 61 THEN 'Influenza' 
           WHEN tmpPrenatalFluImmunizations.Immunization_ID = 61 THEN 'Tdap'
      END,
      tmpActivePregnancyEpisodes.Patient_ID,
      '',
      '',
      '',
      NULL,
      '',
      '',
      '',
      '',
      NULL,
      ''  
    FROM tmpActivePregnancyEpisodes
        
    LEFT JOIN tmpPrenatalFluImmunizations ON tmpPrenatalFluImmunizations.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID;
        
    -- Now we get the most recent vaccine admin given and any other status that may have occured after the given.
    UPDATE tmpRecPrenatalFluImmunizations
    SET tmpRecPrenatalFluImmunizations.Immune_ID = (
        SELECT MIN(tmpPrenatalFluImmunizations.Immune_ID) 
        FROM tmpPrenatalFluImmunizations
            
        INNER JOIN tmpActivePregnancyEpisodes ON tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID
            
        WHERE tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
          AND tmpPrenatalFluImmunizations.Status = 'Given'
          AND tmpPrenatalFluImmunizations.Immunization_ID != 61
          AND (tmpPrenatalFluImmunizations.Adminitration_Date >= '2017-09-01')  
    )
    WHERE tmpRecPrenatalFluImmunizations.Immune_Type = 'Influenza';
    
    UPDATE tmpRecPrenatalFluImmunizations  
    SET tmpRecPrenatalFluImmunizations.Immune_ID = (
        SELECT MIN(tmpPrenatalFluImmunizations.Immune_ID)
        FROM tmpPrenatalFluImmunizations
            
        INNER JOIN tmpActivePregnancyEpisodes ON tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID
            
        WHERE tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
          AND tmpPrenatalFluImmunizations.Status = 'Given' 
          AND tmpPrenatalFluImmunizations.Immunization_ID = 61
          AND (tmpPrenatalFluImmunizations.Adminitration_Date >= '2017-09-01')
    )  
    WHERE tmpRecPrenatalFluImmunizations.Immune_Type = 'Tdap';
        
    -- For the vaccine admins not given , lets get the IDs.
    UPDATE tmpRecPrenatalFluImmunizations
    SET tmpRecPrenatalFluImmunizations.Immune_ID = (  
        SELECT MIN(tmpPrenatalFluImmunizations.Immune_ID)
        FROM tmpPrenatalFluImmunizations
            
        INNER JOIN tmpActivePregnancyEpisodes ON tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID
            
        WHERE tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
          AND tmpPrenatalFluImmunizations.Status != 'Given'  
          AND tmpPrenatalFluImmunizations.Immunization_ID != 61
          AND (tmpPrenatalFluImmunizations.Adminitration_Date >= '2017-09-01') 
    )
    WHERE tmpRecPrenatalFluImmunizations.Immune_ID IS NULL
      AND tmpRecPrenatalFluImmunizations.Immune_Type = 'Influenza';
        
    -- TDAPFor the vaccine admins not given , lets get the IDs.
    UPDATE tmpRecPrenatalFluImmunizations
    SET tmpRecPrenatalFluImmunizations.Immune_ID = (
        SELECT MIN(tmpPrenatalFluImmunizations.Immune_ID)  
        FROM tmpPrenatalFluImmunizations
            
        INNER JOIN tmpActivePregnancyEpisodes ON tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID
           
        WHERE tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
          AND tmpPrenatalFluImmunizations.Status != 'Given'
          AND tmpPrenatalFluImmunizations.Immunization_ID = 61  
          AND (tmpPrenatalFluImmunizations.Adminitration_Date >= '2017-09-01')
    ) 
    WHERE tmpRecPrenatalFluImmunizations.Immune_ID IS NULL
      AND tmpRecPrenatalFluImmunizations.Immune_Type = 'Tdap';
        
    -- Now that we have the Immune ID, lets get the rest of the data.      
    UPDATE tmpRecPrenatalFluImmunizations
    SET 
      tmpRecPrenatalFluImmunizations.Immunization_ID    = Prenatal_Flu_Imm.Immunization_ID,  
      tmpRecPrenatalFluImmunizations.Order_ID           = Prenatal_Flu_Imm.Order_ID,
      tmpRecPrenatalFluImmunizations.Order_description  = Prenatal_Flu_Imm.Order_description,
      tmpRecPrenatalFluImmunizations.Adminitration_Date = Prenatal_Flu_Imm.Adminitration_Date,  
      tmpRecPrenatalFluImmunizations.Immunization_Enc_ID = Prenatal_Flu_Imm.Immunization_Enc_ID,
      tmpRecPrenatalFluImmunizations.Immunization_Entry = Prenatal_Flu_Imm.Immunization_Entry,
      tmpRecPrenatalFluImmunizations.Status             = Prenatal_Flu_Imm.Status,  
      tmpRecPrenatalFluImmunizations.Defer_Reason       = Prenatal_Flu_Imm.Defer_Reason
    FROM (
        SELECT 
          Immunization_ID,
          Order_ID,  
          Order_description,
          Adminitration_Date,
          Immunization_Enc_ID,
          Immunization_Entry,
          Status,
          Defer_Reason,  
          ROW_NUMBER() OVER (PARTITION BY Patient_ID, Immune_ID ORDER BY
          Adminitration_Date DESC) AS RANK
        FROM tmpPrenatalFluImmunizations
        WHERE tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
          AND tmpPrenatalFluImmunizations.Immune_ID  = tmpRecPrenatalFluImmunizations.Immune_ID  
    ) Prenatal_Flu_Imm
    WHERE RANK = 1;

    -- We need to check if the patient has signed a delcination of the immunizations.  
    UPDATE tmpRecPrenatalFluImmunizations
    SET Scanned_Reason = doc_info.doc_descr,
        Scanned_Doc_Date = doc_info.doc_Recv_Time
    FROM (
        SELECT
          doc_pt_ID, 
          doc_descr,
          doc_Recv_Time,
          ROW_NUMBER() OVER (PARTITION BY doc_pt_ID ORDER BY doc_Recv_Time DESC) AS rank  
        FROM tmpActivePregnancyEpisodes

        INNER JOIN doc_information ON doc_information.doc_pt_ID = tmpActivePregnancyEpisodes.Patient_ID
          AND doc_information.doc_descr LIKE 'REFUSAL OF IMMUNIZATION%'  
            
        WHERE tmpActivePregnancyEpisodes.PATIENT_ID = tmpRecPrenatalFluImmunizations.Patient_ID
          AND (
            (tmpRecPrenatalFluImmunizations.Adminitration_Date IS NOT NULL 
             AND CONVERT(DATE, doc_information.Doc_recv_Time) = CONVERT(DATE, tmpRecPrenatalFluImmunizations.Adminitration_Date))
            OR  
            (tmpRecPrenatalFluImmunizations.Adminitration_Date IS NULL
             AND CONVERT(DATE, doc_information.Doc_recv_Time) >= CONVERT(DATE, tmpActivePregnancyEpisodes.Start_Date))
          )  
    ) Doc_Info
    WHERE rank = 1
      AND (tmpRecPrenatalFluImmunizations.Status != 'Given' OR tmpRecPrenatalFluImmunizations.Status IS NULL) 
      AND (tmpRecPrenatalFluImmunizations.Defer_Reason IS NULL OR tmpRecPrenatalFluImmunizations.Defer_Reason = '');
    
    -- Lets get the orders Proc Table
    INSERT INTO tmpPrenatalFluOrders  
    SELECT
      Order_Proc.Order_Proc_ID,
      '',
      Order_Proc.Proc_ID,  
      EAP_S.Proc_Code,
      tmpActivePregnancyEpisodes.Patient_ID,
      Order_Proc.Ordering_Date,
      ZC_ORDER_STATUS.Name,
      Clarity_Ser.Prov_Name,
      Order_Proc.Description
    FROM tmpActivePregnancyEpisodes
        
    INNER JOIN Order_Proc ON Order_Proc.Pat_ID = tmpActivePregnancyEpisodes.Patient_ID  
    
    INNER JOIN clarity_eap EAP_S ON ORDER_PROC.PROC_ID = EAP_S.PROC_ID
        
    LEFT JOIN ZC_ORDER_STATUS ON ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Proc.ORDER_STATUS_C
        
    LEFT JOIN Clarity_SER ON Clarity_SER.Prov_ID = Order_Proc.Authrzing_Prov_ID
        
    WHERE (Order_Proc.Ordering_Date >= '2017-08-01' 
           AND (Order_Proc.Description LIKE '%INFLUENZA VACCINE%' OR Order_Proc.Description LIKE '%FLU VACCINE%'))  
      OR (Order_Proc.Description LIKE '%TDAP%' OR Order_Proc.Description LIKE '%Tdap%');
        
    -- And now to the order med table -- and now we get teh orders for the meds issued
    INSERT INTO tmpPrenatalFluOrders
    SELECT
      Order_Med.ORDER_MED_ID,
      Order_Med.Medication_ID, 
      '',
      '',
      tmpRecPrenatalFluImmunizations.Patient_ID,
      Order_Med.ORDER_INST,
      ZC_ORDER_STATUS.Name,
      Clarity_Ser.Prov_Name,
      Order_Med.Description
    FROM tmpRecPrenatalFluImmunizations
         
    INNER JOIN Order_Med ON Order_Med.PAT_ID = tmpRecPrenatalFluImmunizations.Patient_ID  
      AND Order_Med.Order_Med_ID  = tmpRecPrenatalFluImmunizations.ORDER_ID
        
    LEFT JOIN ZC_ORDER_STATUS ON ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Med.ORDER_STATUS_C
        
    LEFT JOIN Clarity_SER ON Clarity_SER.Prov_ID = Order_Med.Authrzing_Prov_ID
        
    WHERE Order_Med.ORDER_INST >= '2017-08-01';
        
    -- To do - Get the order ID
    INSERT INTO tmpPrenatalFluOrders
    SELECT  
      Order_Proc.Order_Proc_ID,
      '',
      Order_Proc.Proc_ID,
      eap_t.Proc_Code,
      tmpRecPrenatalFluImmunizations.Patient_ID,
      Order_Proc.Ordering_Date, 
      ZC_ORDER_STATUS.Name,
      Clarity_Ser.Prov_Name,
      Order_Proc.Description
    FROM tmpRecPrenatalFluImmunizations
             
    INNER JOIN Order_Proc ON Order_Proc.Pat_ID = tmpRecPrenatalFluImmunizations.Patient_ID
      AND Order_Proc.ORDER_PROC_ID = tmpRecPrenatalFluImmunizations.ORDER_ID
             
    INNER JOIN clarity_eap EAP_T ON order_proc.proc_id = EAP_T.proc_id
        
    LEFT JOIN ZC_ORDER_STATUS ON ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Proc.ORDER_STATUS_C
        
    LEFT JOIN Clarity_SER ON Clarity_SER.Prov_ID = Order_Proc.Authrzing_Prov_ID;
         
    -- Now lets get the GBC lab values.  
    INSERT INTO tmpPatLabTestResults
    SELECT
      tmpActivePregnancyEpisodes.Patient_ID,
      order_results.order_proc_ID,
      eap_y.Proc_Code,          
      order_proc.description,
      ZC_ORDER_STATUS.Name,
      order_proc.Ordering_Date,
      order_results.Result_Date,
      order_results.Ord_Value, 
      order_results.Ord_Num_Value,
      ZC_LAB_STATUS.Name
    FROM tmpActivePregnancyEpisodes
            
    INNER JOIN order_proc ON order_proc.Pat_ID = tmpActivePregnancyEpisodes.Patient_ID
               
    INNER JOIN clarity_eap EAP_Y ON order_proc.proc_id = EAP_Y.PROC_ID AND EAP_Y.proc_code = 'LAB1377'
        
    LEFT JOIN order_results ON order_results.order_proc_ID = order_proc.Order_Proc_ID
        
    LEFT JOIN ZC_ORDER_STATUS ON ZC_ORDER_STATUS.ORDER_STATUS_C = order_proc.ORDER_STATUS_C
        
    LEFT JOIN ZC_LAB_STATUS ON ZC_LAB_STATUS.LAB_STATUS_C = order_proc.LAB_STATUS_C
        
    WHERE Order_proc.ordering_Date >= '2017-08-01';
        
    PRINT 'EPISODES IMMUNIZATIONS: ' + CONVERT(VARCHAR, DATEDIFF(ss, @RUNDATE, GETDATE())) + ' SECONDS';
    SET @RUNDATE = GETDATE();
    
  END;

  -- CURSOR OUTPUT  
  SELECT DISTINCT
    tmpActivePregnancyEpisodes.Episode_ID,
    tmpActivePregnancyEpisodes.Patient_ID, 
    tmpActivePregnancyEpisodes.Patient_MRN,
    tmpActivePregnancyEpisodes.Patient_Name,
    tmpActivePregnancyEpisodes.Patient_DOB,
    tmpActivePregnancyEpisodes.Diabetic,
    tmpActivePregnancyEpisodes.Hypertensive,
    tmpActivePregnancyEpisodes.Start_Date AS Episode_Start_Date,
    tmpActivePregnancyEpisodes.First_Prenatal_Loc, 
    tmpActivePregnancyEpisodes.First_Prenatal_Date,
    tmpActivePregnancyEpisodes.First_Prenatal_Trimester,
    First_Visit.Encounter_Department AS First_Prenatal_Department,
    tmpActivePregnancyEpisodes.First_Prenatal_Prov,
    First_Visit.Encounter_Date AS First_Preg_Enc,
    Working_EDD,
    CAST(280 - DATEDIFF(DD,First_Visit.Encounter_Date,working_EDD) AS VARCHAR) +  
      'w ' + CAST(((280 - DATEDIFF(DD,First_Visit.Encounter_Date,working_EDD)) - (280 - DATEDIFF(DD,First_Visit.Encounter_Date,working_EDD)))*10 AS VARCHAR) + 'd' AS First_Visit_GA,
    CASE
      WHEN DATEDIFF(DD,working_EDD,GETDATE()) >= 15 THEN NULL 
      WHEN DATEDIFF(DD,working_EDD,GETDATE()) < 14 THEN
        CAST(280 - DATEDIFF(DD,GETDATE(),working_EDD) AS VARCHAR) + 
        'w ' + CAST(((280 - DATEDIFF(DD,GETDATE(),working_EDD))-(280-DATEDIFF(DD,GETDATE(),working_EDD)))*10 AS VARCHAR) + 'd'
    END AS Current_GA,  
    ENCTOEPI_SDE.FHCOBRISKINITIAL,
    ENCTOEPI_SDE.FHCOBRISKINITIAL_VAL,
    ENCTOEPI_SDE.FHCOBRISKFOLLOWUP,
    ENCTOEPI_SDE.FHCOBRISKFOLLOWUP_VAL,
    EPISODE_SMARTPHRASE.FHCVBAC,
    EPISODE_SDE.EDU_BREASTFEEDING,
    EPISODE_SDE.EDU_MOVEMENT, 
    EPISODE_SDE.EDU_EARLYDELIVERY,
    EPISODE_ORD.LAB_HIV_FIRST_TRI,
    EPISODE_ORD.LAB_HIV_THIRD_TRI,
    EPISODE_ORD.LAB_CYSTIC_FIBROSIS,
    EPISODE_ORD.LAB_SMA,
    EPISODE_FLW_LAST.OB_FUNDAL_HEIGHT_DTTM,
    EPISODE_FLW_LAST.OB_FUNDAL_HEIGHT_VAL,
    EPISODE_FLW_LAST.OB_FHR_BASELINE_DTTM,
    EPISODE_FLW_LAST.OB_FHR_BASELINE_VAL,
    EPISODE_FLW_LAST.FETAL_MOVEMENT_DTTM,
    EPISODE_FLW_LAST.FETAL_MOVEMENT_VAL,
    EPISODE_FLW_LAST.OB_PRESENTATION_DTTM,
    EPISODE_FLW_LAST.OB_PRESENTATION_VAL,
    EPISODE_FLW_LAST.DOM_ABUSE_SCRN_DTTM,
    FluOrders.Order_ID AS Flu_Order_ID,
    FluOrders.Order_Date AS Flu_Order_Date,
    FluOrders.Order_Description AS Flu_Order_Description,  
    FluOrders.Order_Status AS Flu_Order_Status,
    tmpFlu.Immune_ID AS Flu_Immune_ID,
    tmpFlu.Order_Description AS Flu_Admin_Description,
    tmpFlu.Adminitration_Date AS Flu_Admin_Date,
    tmpFlu.Status AS Flu_Admin_Staus,  
    tmpFlu.Scanned_Doc_Date AS Flu_Defer_Scan_Date,
    tmpFlu.Scanned_Reason AS Flu_Scan_Date,
    TdapOrders.Order_ID AS Tdap_Order_ID,
    TdapOrders.Medication_ID AS Tdap_Medication_ID,
    TdapOrders.Order_Description AS Tdap_Order_Description,  
    TdapOrders.Order_Date AS Tdap_Order_Date,
    TdapOrders.Order_Status AS Tdap_Order_Status,
    tmpTdap.Immune_ID AS Tdap_Immune_ID,
    tmpTdap.Order_Description AS Tdap_Admin_Description,
    tmpTdap.Adminitration_Date AS Tdap_Admin_Date,  
    tmpTdap.Status AS Tdap_Admin_Status,
    tmpTdap.Scanned_Doc_Date AS Tdap_Defer_Scan_Date,
    tmpTdap.Scanned_Reason AS Tdap_Defer_Reason,
    Lab_Results.Order_ID AS GBS_Order_ID,
    Lab_Results.Proc_Desription AS GBS_Description,  
    Lab_Results.Order_Status AS GBS_Status,
    Lab_Results.Order_Date AS GBS_Ordered,
    Lab_Results.Result_Date AS GBS_Resulted,
    Lab_Results.Result_Value AS GBS_Result,
    Lab_Results.Result_Status AS GBS_Result_Status,  
    Last_Visit.Encounter_Date AS Last_Enc_Date,
    Last_Visit.Encounter_Location AS Last_Enc_Location,
    Last_Visit.Encounter_Provider AS Last_Enc_Provider,
    Last_Visit.Encounter_Prov_Type,
    Last_Visit.Supervising_Provider,
    Last_Visit.Encounter_ID,
    Last_Visit.Encounter_Visit_Type AS Last_Visit_Type,
    tmpPatNextAppt.Encounter_ID AS Next_Appt_CSN,
    tmpPatNextAppt.Encounter_Date AS Next_Appt_Date,  
    tmpPatNextAppt.Encounter_Location AS Next_Appt_Location,
    tmpPatNextAppt.Encounter_Provider AS Next_Appt_Provider
  FROM tmpActivePregnancyEpisodes  

  LEFT JOIN (
    SELECT
      Patient_ID,
      Episode_ID,
      Encounter_Date,
      Encounter_Location, 
      Encounter_Provider,
      Encounter_Visit_Type,
      Encounter_Prov_Type,
      Supervising_Provider,
      Encounter_ID,
      ROW_NUMBER() OVER (PARTITION BY Patient_ID, Episode_ID ORDER BY Encounter_Date DESC) AS RANK
    FROM tmpActivePregnancyVisits
  ) Last_Visit ON Last_Visit.RANK = 1
    AND Last_visit.EPISODE_ID = tmpActivePregnancyEpisodes.Episode_ID
    AND Last_visit.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID

  LEFT JOIN (
    SELECT  
      Patient_ID,
      Episode_ID,
      Encounter_Date,
      Encounter_Department,
      Encounter_Location,  
      Encounter_Provider,
      Encounter_Visit_Type,
      ROW_NUMBER() OVER (PARTITION BY Patient_ID, EPISODE_ID ORDER BY Encounter_Date) AS RANK  
    FROM tmpActivePregnancyVisits
  ) First_Visit ON First_Visit.RANK = 1
    AND First_Visit.Episode_ID = tmpActivePregnancyEpisodes.Episode_ID
    AND First_Visit.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
    
  LEFT JOIN (
    SELECT  
      Order_ID,
      Medication_ID,
      Order_Date,
      Order_Description,
      Patient_ID,  
      Order_Status,
      Proc_Code,
      ROW_NUMBER () OVER (PARTITION BY Patient_ID ORDER BY Order_Date) AS Rank
    FROM tmpPrenatalFluOrders
    WHERE (Proc_Code != 'IMM61' OR
           Medication_ID IN ('239351','238711','238714','238717','238719'))
  ) FluOrders ON FluOrders.Rank = 1 
    AND FluOrders.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
        
  LEFT JOIN (
    SELECT
      Order_ID,
      Medication_ID,
      Order_Date,
      Order_Description,
      Patient_ID,
      Order_Status,  
      Proc_Code,
      ROW_NUMBER() OVER (PARTITION BY Patient_ID ORDER BY Order_Date) AS Rank
    FROM tmpPrenatalFluOrders
    WHERE Proc_Code = 'IMM61' OR Medication_ID IN ('5000089','201574','201575','135818','147414','147465','147467','227724') 
  ) TdapOrders ON TdapOrders.Rank = 1
    AND TdapOrders.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
        
  LEFT JOIN tmpRecPrenatalFluImmunizations tmpFlu ON tmpFlu.PATIENT_ID = tmpActivePregnancyEpisodes.Patient_ID
    AND tmpFlu.Immunization_ID != 61
        
  LEFT JOIN tmpRecPrenatalFluImmunizations tmpTdap ON tmpTdap.PATIENT_ID = tmpActivePregnancyEpisodes.Patient_ID  
    AND tmpTdap.Immunization_ID = 61
        
  LEFT JOIN (
    SELECT  
      Patient_ID,
      Order_ID,
      Proc_Code,
      Proc_Desription,
      Order_Status,
      Order_Date,
      Result_Date,  
      Result_Value,
      Result_Value_Desc,
      Result_Status,  
      ROW_NUMBER() OVER (PARTITION BY Patient_ID ORDER BY Order_Date DESC) AS RANK
    FROM tmpPatLabTestResults
  ) Lab_Results ON Lab_Results.RANK = 1
    AND Lab_Results.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
        
  LEFT JOIN (
    SELECT EPISODE_ORP.EPISODE_ID
      ,MAX(CASE WHEN EPISODE_ORP.ORD_TRIMESTER = 'FIRST' AND EPISODE_ORP.CASE_HIV IS NOT NULL THEN EPISODE_ORP.ORDER_INST ELSE NULL END) AS LAB_HIV_FIRST_TRI
      ,MAX(CASE WHEN EPISODE_ORP.ORD_TRIMESTER = 'THIRD' AND EPISODE_ORP.CASE_HIV IS NOT NULL THEN EPISODE_ORP.ORDER_INST ELSE NULL END) AS LAB_HIV_THIRD_TRI 
      ,MAX(CASE WHEN EPISODE_ORP.PROC_CODE IN ('LAB737','LAB21363') THEN EPISODE_ORP.ORDER_INST ELSE NULL END) AS LAB_CYSTIC_FIBROSIS
      ,MAX(CASE WHEN EPISODE_ORP.PROC_CODE IN ('LAB21058') THEN EPISODE_ORP.ORDER_INST ELSE NULL END) AS LAB_SMA
    FROM (  
      SELECT
        tmpActivePregnancyEpisodes.Episode_ID  
        ,ORDER_PROC.ORDER_PROC_ID
        ,ORDER_PROC.PAT_ENC_CSN_ID
        ,ORDER_PROC.PAT_ID
        ,ORDER_PROC.ORDER_INST
        ,ORDER_PROC.RESULT_TIME
        ,CLARITY_EAP.PROC_ID
        ,CLARITY_EAP.PROC_CODE
        ,CLARITY_EAP.PROC_NAME
        ,CASE
          WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - 280 AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD - 183  
          THEN 'FIRST'
          WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - 182 AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD - 99
          THEN 'SECOND'  
          WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - 98 AND ORDER_PROC.ORDER_INST <= tmpActivePregnancyEpisodes.WORKING_EDD
          THEN 'THIRD'
          ELSE NULL
        END AS ORD_TRIMESTER
        ,CASE WHEN CLARITY_EAP.PROC_NAME LIKE '%HIV%' THEN 'HIV' ELSE NULL END AS CASE_HIV
      FROM ORDER_PROC  
      INNER JOIN tmpActivePregnancyEpisodes ON ORDER_PROC.PAT_ID = tmpActivePregnancyEpisodes.Patient_ID
        AND ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_ESD AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD
      LEFT JOIN CLARITY_EAP ON ORDER_PROC.PROC_ID = CLARITY_EAP.PROC_ID  
      WHERE ORDER_PROC.ORDER_STATUS_C = 5
        AND ORDER_PROC.RESULT_TIME IS NOT NULL
        AND (CLARITY_EAP.PROC_CODE IN ('LAB3277','LAB3532','LAB10790','LAB2209','LAB2360','LAB103341','LAB10327','LAB1808','LAB2306')  
             OR CLARITY_EAP.PROC_CODE IN ('LAB737','LAB21363')
             OR CLARITY_EAP.PROC_CODE IN ('LAB21058')) 
    ) EPISODE_ORP
    GROUP BY EPISODE_ORP.EPISODE_ID
  ) EPISODE_ORD ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_ORD.EPISODE_ID
   
  LEFT JOIN (
    SELECT  
      EPISODE_LINK.EPISODE_ID
      ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NULL THEN PAT_ENC.CONTACT_DATE ELSE NULL END) AS FHCOBRISKINITIAL
      ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NULL THEN SDE_PIVOT.NYU434_VAL ELSE NULL END) AS FHCOBRISKINITIAL_VAL  
      ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NOT NULL THEN PAT_ENC.CONTACT_DATE ELSE NULL END) AS FHCOBRISKFOLLOWUP
      ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NOT NULL THEN SDE_PIVOT.NYU434_VAL ELSE NULL END) AS FHCOBRISKFOLLOWUP_VAL
    FROM PAT_ENC  
    LEFT JOIN EPISODE_LINK ON PAT_ENC.PAT_ENC_CSN_ID = EPISODE_LINK.PAT_ENC_CSN_ID
    LEFT JOIN (
      SELECT SMRTDTA_ELEM_DATA.RECORD_ID_VARCHAR AS PAT_ID  
        ,SMRTDTA_ELEM_DATA.CONTACT_SERIAL_NUM AS PAT_ENC_CSN_ID
        ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#434' THEN 1 ELSE NULL END) AS NYU434 
        ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#434' THEN SMRTDTA_ELEM_VALUE ELSE NULL END) AS NYU434_VAL
        ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#970' THEN 1 ELSE NULL END) AS NYU970
      FROM SMRTDTA_ELEM_DATA
      LEFT JOIN SMRTDTA_ELEM_VALUE ON SMRTDTA_ELEM_DATA.HLV_ID = SMRTDTA_ELEM_VALUE.HLV_ID  
      WHERE SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#434','NYU#970')
      GROUP BY SMRTDTA_ELEM_DATA.RECORD_ID_VARCHAR, SMRTDTA_ELEM_DATA.CONTACT_SERIAL_NUM
    ) SDE_PIVOT ON PAT_ENC.PAT_ID = SDE_PIVOT.PAT_ID  
      AND PAT_ENC.PAT_ENC_CSN_ID = SDE_PIVOT.PAT_ENC_CSN_ID
    GROUP BY EPISODE_LINK.EPISODE_ID  
  ) ENCTOEPI_SDE ON tmpActivePregnancyEpisodes.EPISODE_ID = ENCTOEPI_SDE.EPISODE_ID
    
  LEFT JOIN (
    SELECT SMRTDTA_ELEM_DATA.RECORD_ID_NUMERIC AS EPISODE_ID
      ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('EPIC#OBC230', 'EPIC#OBC831', 'EPIC#OBC832') THEN CONVERT(DATE,SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) AS EDU_BREASTFEEDING  
      ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#558', 'NYU#586', 'NYU#587') THEN CONVERT(DATE,SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) AS EDU_MOVEMENT
      ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#552', 'NYU#631', 'NYU#632') THEN CONVERT(DATE,SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) AS EDU_EARLYDELIVERY 
    FROM SMRTDTA_ELEM_DATA  
    WHERE (CONTEXT_NAME = 'EPISODE'  
      AND SMRTDTA_ELEM_DATA.CUR_SOURCE_LQF_ID IN (92,93,94)
      AND SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('EPIC#OBC230', 'EPIC#OBC831', 'EPIC#OBC832', 'NYU#558', 'NYU#586', 'NYU#587', 'NYU#552', 'NYU#631', 'NYU#632'))  
    GROUP BY SMRTDTA_ELEM_DATA.RECORD_ID_NUMERIC
  ) EPISODE_SDE ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_SDE.EPISODE_ID
    
  LEFT JOIN (
    SELECT EPI_FLW_LAST.EPISODE_ID  
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12401' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) AS OB_FUNDAL_HEIGHT_DTTM
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12401' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) AS OB_FUNDAL_HEIGHT_VAL
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12086' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) AS OB_FHR_BASELINE_DTTM  
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12086' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) AS OB_FHR_BASELINE_VAL
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12403' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) AS FETAL_MOVEMENT_DTTM
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12403' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) AS FETAL_MOVEMENT_VAL  
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12404' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) AS OB_PRESENTATION_DTTM
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12404' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) AS OB_PRESENTATION_VAL
      ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_GRP_ID = '669658' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) AS DOM_ABUSE_SCRN_DTTM
    FROM (  
      SELECT EPISODE_LINK.EPISODE_ID
        ,IP_FLWSHT_REC.INPATIENT_DATA_ID  
        ,IP_FLWSHT_MEAS.FSD_ID
        ,IP_FLO_GP_DATA.FLO_MEAS_ID
        ,IP_FLO_GP_DATA.FLO_MEAS_NAME
        ,IP_FLO_MEASUREMNTS.ID AS FLO_MEAS_GRP_ID
        ,IP_FLWSHT_MEAS.RECORDED_TIME
        ,IP_FLWSHT_MEAS.ENTRY_TIME
        ,IP_FLWSHT_MEAS.MEAS_VALUE  
        ,ROW_NUMBER() OVER (PARTITION BY EPISODE_LINK.EPISODE_ID, IP_FLWSHT_MEAS.FLO_MEAS_ID ORDER BY IP_FLWSHT_MEAS.RECORDED_TIME DESC) AS FLO_CNT
      FROM PAT_ENC  
      LEFT JOIN EPISODE_LINK ON PAT_ENC.PAT_ENC_CSN_ID = EPISODE_LINK.PAT_ENC_CSN_ID
      LEFT JOIN IP_FLWSHT_REC ON PAT_ENC.INPATIENT_DATA_ID = IP_FLWSHT_REC.INPATIENT_DATA_ID
      LEFT JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID  
      LEFT JOIN IP_FLO_GP_DATA ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_GP_DATA.FLO_MEAS_ID
      LEFT JOIN IP_FLO_MEASUREMNTS ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_MEASUREMNTS.MEASUREMENT_ID
        AND IP_FLO_MEASUREMNTS.ID = '669658'  
      WHERE IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('12401','12086','12403','12404')
        OR IP_FLO_MEASUREMNTS.ID IS NOT NULL
    ) EPI_FLW_LAST
    WHERE EPI_FLW_LAST.FLO_CNT = 1  
    GROUP BY EPI_FLW_LAST.EPISODE_ID
  ) EPISODE_FLW_LAST ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_FLW_LAST.EPISODE_ID
    
  LEFT JOIN (
    SELECT  
      tmpActivePregnancyVisits.EPISODE_ID
      ,MAX(CASE WHEN CL_SPHR.SMARTPHRASE_NAME = 'FHCVBAC' THEN PAT_ENC.CONTACT_DATE ELSE NULL END) AS FHCVBAC  
    FROM PAT_ENC
    INNER JOIN tmpActivePregnancyVisits ON PAT_ENC.PAT_ENC_CSN_ID = tmpActivePregnancyVisits.ENCOUNTER_ID  
    LEFT JOIN HNO_INFO ON PAT_ENC.PAT_ENC_CSN_ID = HNO_INFO.PAT_ENC_CSN_ID
    LEFT JOIN NOTE_ENC_INFO ON HNO_INFO.NOTE_ID = NOTE_ENC_INFO.NOTE_ID  
    LEFT JOIN NOTE_SMARTPHRASE_IDS ON NOTE_ENC_INFO.CONTACT_SERIAL_NUM = NOTE_SMARTPHRASE_IDS.NOTE_CSN_ID
    LEFT JOIN CL_SPHR ON NOTE_SMARTPHRASE_IDS.SMARTPHRASES_ID = CL_SPHR.SMARTPHRASE_ID
    WHERE CL_SPHR.SMARTPHRASE_NAME = 'FHCVBAC'  
    GROUP BY tmpActivePregnancyVisits.EPISODE_ID
  ) EPISODE_SMARTPHRASE ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_SMARTPHRASE.EPISODE_ID

  LEFT JOIN tmpPatNextAppt ON tmpPatNextAppt.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID;

END
