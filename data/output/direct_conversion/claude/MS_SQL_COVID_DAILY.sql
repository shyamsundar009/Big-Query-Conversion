
CREATE PROCEDURE COVID_DAILY
AS
BEGIN
 DECLARE
 @start_dt date;
 @end_dt date;
 @cur_dt date;

 SET @START_DATE = EPIC_UTIL.EFN_DIN('2/1/2020');
 SET @END_DATE = CAST(GETDATE() AS DATE);  

 SET @start_dt = @START_DATE;
 SET @end_dt = @END_DATE;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_COHORT_ALL_SOURCES', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_COHORT_ALL_SOURCES DISABLE;  
 EXEC sp_refreshview N'COVID_COHORT_ALL_SOURCES';
 ALTER INDEX ALL ON COVID_COHORT_ALL_SOURCES REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_COHORT_ALL_SOURCES', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_COHORT', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_COHORT DISABLE;
 EXEC sp_refreshview N'COVID_COHORT';
 ALTER INDEX ALL ON COVID_COHORT REBUILD; 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_COHORT', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ED_IMPRESSION', GETDATE(), NULL); 
 COMMIT;
 ALTER INDEX ALL ON COVID_ED_IMPRESSION DISABLE;
 EXEC sp_refreshview N'COVID_ED_IMPRESSION';
 ALTER INDEX ALL ON COVID_ED_IMPRESSION REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ED_IMPRESSION', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_LABS', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_LABS DISABLE;
 EXEC sp_refreshview N'COVID_LABS';
 ALTER INDEX ALL ON COVID_LABS REBUILD; 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_LABS', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_DIALYSIS_PROC', GETDATE(), NULL);
 COMMIT; 
 ALTER INDEX ALL ON COVID_DIALYSIS_PROC DISABLE;
 EXEC sp_refreshview N'COVID_DIALYSIS_PROC';
 ALTER INDEX ALL ON COVID_DIALYSIS_PROC REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_DIALYSIS_PROC', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_DIALYSIS_FLOW', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_DIALYSIS_FLOW DISABLE; 
 EXEC sp_refreshview N'COVID_DIALYSIS_FLOW';
 ALTER INDEX ALL ON COVID_DIALYSIS_FLOW REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_DIALYSIS_FLOW', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_FLOWSHEET', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_VENT_FLOWSHEET DISABLE;
 EXEC sp_refreshview N'COVID_VENT_FLOWSHEET';
 ALTER INDEX ALL ON COVID_VENT_FLOWSHEET REBUILD; 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_FLOWSHEET', NULL, GETDATE());
 COMMIT;
   
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_COMMENTS', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_VENT_COMMENTS DISABLE;  
 EXEC sp_refreshview N'COVID_VENT_COMMENTS';
 ALTER INDEX ALL ON COVID_VENT_COMMENTS REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_COMMENTS', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_ORDERS', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_VENT_ORDERS DISABLE;
 EXEC sp_refreshview N'COVID_VENT_ORDERS';
 ALTER INDEX ALL ON COVID_VENT_ORDERS REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENT_ORDERS', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_SOC_HX', GETDATE(), NULL); 
 COMMIT;
 ALTER INDEX ALL ON COVID_SOC_HX DISABLE;
 EXEC sp_refreshview N'COVID_SOC_HX'; 
 ALTER INDEX ALL ON COVID_SOC_HX REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_SOC_HX', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VAPING', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_VAPING DISABLE;
 EXEC sp_refreshview N'COVID_VAPING';
 ALTER INDEX ALL ON COVID_VAPING REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VAPING', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ECMO', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_ECMO DISABLE;  
 EXEC sp_refreshview N'COVID_ECMO';
 ALTER INDEX ALL ON COVID_ECMO REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ECMO', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TRACHEOSTOMY_COHORT', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_TRACHEOSTOMY_COHORT DISABLE;
 EXEC sp_refreshview N'COVID_TRACHEOSTOMY_COHORT';
 ALTER INDEX ALL ON COVID_TRACHEOSTOMY_COHORT REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TRACHEOSTOMY_COHORT', NULL, GETDATE());
 COMMIT;
   
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_AIRWAY_MEASURES', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_AIRWAY_MEASURES DISABLE;
 EXEC sp_refreshview N'COVID_AIRWAY_MEASURES';
 ALTER INDEX ALL ON COVID_AIRWAY_MEASURES REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_AIRWAY_MEASURES', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_PL_DX', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_PL_DX DISABLE;
 EXEC sp_refreshview N'COVID_PL_DX';
 ALTER INDEX ALL ON COVID_PL_DX REBUILD;  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_PL_DX', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_MEDHX_DX', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_MEDHX_DX DISABLE;
 EXEC sp_refreshview N'COVID_MEDHX_DX';
 ALTER INDEX ALL ON COVID_MEDHX_DX REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_MEDHX_DX', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ENC_DX', GETDATE(), NULL);
 COMMIT; 
 ALTER INDEX ALL ON COVID_ENC_DX DISABLE; 
 EXEC sp_refreshview N'COVID_ENC_DX';
 ALTER INDEX ALL ON COVID_ENC_DX REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ENC_DX', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TRACH_LABS', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_TRACH_LABS DISABLE;
 EXEC sp_refreshview N'COVID_TRACH_LABS';
 ALTER INDEX ALL ON COVID_TRACH_LABS REBUILD; 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TRACH_LABS', NULL, GETDATE());
 COMMIT; 
   
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VITALS', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_VITALS DISABLE;  
 EXEC sp_refreshview N'COVID_VITALS';
 ALTER INDEX ALL ON COVID_VITALS REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VITALS', NULL, GETDATE()); 
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_O2_DEVICE_FLOWSHEET', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_O2_DEVICE_FLOWSHEET DISABLE;
 EXEC sp_refreshview N'COVID_O2_DEVICE_FLOWSHEET';
 ALTER INDEX ALL ON COVID_O2_DEVICE_FLOWSHEET REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_O2_DEVICE_FLOWSHEET', NULL, GETDATE());
 COMMIT;
   
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_ICU DISABLE;
 EXEC sp_refreshview N'COVID_ICU';
 ALTER INDEX ALL ON COVID_ICU REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU', NULL, GETDATE()); 
 COMMIT;
   
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU_BY_ACCOMODATION', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_ICU_BY_ACCOMODATION DISABLE;
 EXEC sp_refreshview N'COVID_ICU_BY_ACCOMODATION'; 
 ALTER INDEX ALL ON COVID_ICU_BY_ACCOMODATION REBUILD;  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU_BY_ACCOMODATION', NULL, GETDATE());
 COMMIT;
 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENTFLOW_REINTUB', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_VENTFLOW_REINTUB DISABLE;
 EXEC sp_refreshview N'COVID_VENTFLOW_REINTUB';
 ALTER INDEX ALL ON COVID_VENTFLOW_REINTUB REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_VENTFLOW_REINTUB', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_O2_VENT_REINTUB', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_O2_VENT_REINTUB DISABLE;
 EXEC sp_refreshview N'COVID_O2_VENT_REINTUB';
 ALTER INDEX ALL ON COVID_O2_VENT_REINTUB REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_O2_VENT_REINTUB', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU_CURRENT', GETDATE(), NULL);
 COMMIT;
 SELECT @cur_dt = MAX(t.update_date) FROM COVID_ICU_CURRENT t;
 IF @cur_dt NOT BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
 BEGIN
    ALTER INDEX ALL ON COVID_ICU_CURRENT DISABLE;
    EXEC sp_refreshview N'COVID_ICU_CURRENT';
    ALTER INDEX ALL ON COVID_ICU_CURRENT REBUILD;
 END;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ICU_CURRENT', NULL, GETDATE());
 COMMIT;

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ALL_TESTS_FINAL_RESULT', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_ALL_TESTS_FINAL_RESULT DISABLE;
 EXEC sp_refreshview N'COVID_ALL_TESTS_FINAL_RESULT';  
 ALTER INDEX ALL ON COVID_ALL_TESTS_FINAL_RESULT REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ALL_TESTS_FINAL_RESULT', NULL, GETDATE());
 COMMIT;
 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_POS_SYMPTOMS_COHORT', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_POS_SYMPTOMS_COHORT DISABLE;
 EXEC sp_refreshview N'COVID_POS_SYMPTOMS_COHORT';
 ALTER INDEX ALL ON COVID_POS_SYMPTOMS_COHORT REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_POS_SYMPTOMS_COHORT', NULL, GETDATE());
 COMMIT;
 
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_CT_CHEST', GETDATE(), NULL);
 COMMIT;
 ALTER INDEX ALL ON COVID_CT_CHEST DISABLE;
 EXEC sp_refreshview N'COVID_CT_CHEST';
 ALTER INDEX ALL ON COVID_CT_CHEST REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_CT_CHEST', NULL, GETDATE());
 COMMIT;
  
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ANTIBODY_TEST', GETDATE(), NULL);
 COMMIT;  
 ALTER INDEX ALL ON COVID_ANTIBODY_TEST DISABLE;
 EXEC sp_refreshview N'COVID_ANTIBODY_TEST';
 ALTER INDEX ALL ON COVID_ANTIBODY_TEST REBUILD;
 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_ANTIBODY_TEST', NULL, GETDATE());
 COMMIT;
  
 EXEC sp_addsrvrolemember N'DSSVI_TAB_USER', N'db_datareader'
 EXEC sp_addsrvrolemember N'PAU_USER', N'db_datareader'

 INSERT INTO COVID_DAILY_LOG VALUES ('COVID_REPORT_FULL', GETDATE(), NULL);
 COMMIT;
  
 EXEC sp_executesql N'TRUNCATE TABLE COVID_REPORT_I';
 
 WITH ecmo AS (
  SELECT IP_FLWSHT_REC.PAT_ID, pat_enc_hsp.pat_enc_csn_id,
   MIN(RECORDED_TIME) AS from_date, 
   MAX(RECORDED_TIME) AS to_date,
   MAX(CASE WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('304010099809','3040100998') THEN CAST(IP_FLWSHT_MEAS.MEAS_VALUE AS int) END) AS ecmo_hours,
   MAX(CASE WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3041530236') THEN IP_FLWSHT_MEAS.MEAS_VALUE END) AS ecmo_type
  FROM IP_FLWSHT_REC
  JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID
  JOIN COVID_COHORT ON COVID_COHORT.pat_id = pat_enc_hsp.pat_id  
  JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
  JOIN IP_FLO_GP_DATA gd ON gd.flo_meas_id = IP_FLWSHT_MEAS.flo_meas_id
  WHERE IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('304010099809','3040100998','304101003','3041530236')
    AND IP_FLWSHT_MEAS.RECORDED_TIME BETWEEN EPIC_UTIL.EFN_DIN('2/1/2020') AND CAST(GETDATE() AS DATE)  
  GROUP BY IP_FLWSHT_REC.PAT_ID, pat_enc_hsp.pat_enc_csn_id
 ), 
 Covid_vent_flo AS (
  SELECT PAT_ID, pat_enc_csn_id,
   MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE END) AS MECH_VENT_TYPE_DATE,
   MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE END) AS MECH_VENT_TYPE,
   MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE END) AS MECH_VENT_TYPE_LAST_DATE,
   MAX(CASE WHEN MECH_VENT_CATG='INVASIVE' AND RN_DESC = 1 THEN VENT_DAYS END) AS VENT_DAYS, 
   MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE_NI END) AS MECH_VENT_TYPE_DATE_NI,
   MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_NI END) AS MECH_VENT_TYPE_NI,
   MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE_NI END) AS MECH_VENT_TYPE_LAST_DATE_NI,  
   MAX(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' AND RN_DESC = 1 THEN VENT_DAYS END) AS VENT_DAYS_NI
  FROM (
    SELECT flo.pat_id, flo.pat_enc_csn_id, flo.hsp_account_id, 
     asc_rn AS RN_ASC,
     desc_rn AS RN_DESC,
     SUM(vent_days) OVER (PARTITION BY flo.pat_id, flo.pat_enc_csn_id, flo.hsp_account_id, MECH_VENT_CATG) AS vent_days,
     MECH_VENT_CATG,
     CASE WHEN MECH_VENT_CATG='INVASIVE' THEN vent_first_date END AS MECH_VENT_TYPE_DATE,
     CASE WHEN MECH_VENT_CATG='INVASIVE' THEN vent_type END AS MECH_VENT_TYPE,   
     CASE WHEN MECH_VENT_CATG='INVASIVE' THEN vent_last_date END AS MECH_VENT_TYPE_LAST_DATE,
     CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_first_date END AS MECH_VENT_TYPE_DATE_NI, 
     CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_type END AS MECH_VENT_TYPE_NI,
     CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_last_date END AS MECH_VENT_TYPE_LAST_DATE_NI  
    FROM COVID_VENT_FLOWSHEET flo
    JOIN COVID_COHORT ON flo.PAT_ID = COVID_COHORT.pat_id
   ) t
  GROUP BY PAT_ID, pat_enc_csn_id
 ), 
 vitals_flo AS (
  SELECT PAT_ID, pat_enc_csn_id,
   MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN MEAS_VALUE END) AS SVO2,
   MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN RECORDED_TIME END) AS SVO2_TIME,
   
   ROUND(MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_DESC = 1 THEN MEAS_VALUE END), 2) AS WEIGHT_KG_LAST_DOC, 
   ROUND(MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END), 2) AS WEIGHT_KG_FIRST_DOC,
   ROUND(MIN(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' THEN MEAS_VALUE END), 2) AS WEIGHT_KG_MIN,
   MAX(CASE WHEN FLO_MEAS_CAT = 'HEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END) AS HEIGHT,
     
   MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN MEAS_VALUE END) AS RESP,   
   MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN MEAS_VALUE END) AS TEMP,
   MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) AS BP_SYSTOLIC, 
   MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) AS BP_DIASTOLIC,
   MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN MEAS_VALUE END) AS BP,  
   MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN MEAS_VALUE END) AS BMI,
   
   MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN RECORDED_TIME END) AS RESP_TIME,
   MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN RECORDED_TIME END) AS TEMP_TIME,  
   MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) AS BP_SYSTOLIC_TIME,
   MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) AS BP_DIASTOLIC_TIME,   
   MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN RECORDED_TIME END) AS BP_TIME,
   MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN RECORDED_TIME END) AS BMI_TIME,
   
   MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN MEAS_VALUE END) AS PULSE,
   MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN RECORDED_TIME END) AS PULSE_TIME  
  FROM (
    SELECT vi.pat_id, vi.pat_enc_csn_id, vi.hsp_account_id,
     RN_ASC, 
     RN_DESC,
     FLO_MEAS_ID, FSD_ID,  
     RECORDED_TIME,
     MEAS_VALUE,
     FLO_MEAS_CAT 
    FROM COVID_VITALS vi  
   ) t
  GROUP BY PAT_ID, pat_enc_csn_id
 ),
 icu AS (
  SELECT pat_id, pat_enc_csn_id,
   from_time, 
   COALESCE(to_time, CAST(GETDATE() AS DATE)) AS to_time,
   ROUND(COALESCE(to_time, hosp_disch_time, CAST(GETDATE() AS DATE)) - from_time, 2) AS in_days   
  FROM (
    SELECT DISTINCT adt.pat_id, adt.pat_enc_csn_id,
     MIN(adt.effective_time) AS from_time,
     MAX(adt.effective_time) AS max_ICU_to_time,  
     CASE 
      WHEN MAX(adt.effective_time) > MAX(adt2.effective_time) THEN NULL
      ELSE MAX(CASE WHEN adt1.event_type_c = 2 THEN adt1.effective_time ELSE adt2.effective_time END) 
     END AS to_time,
     MAX(hosp_disch_time) AS hosp_disch_time
    FROM CLARITY_ADT ADT 
    JOIN pat_enc_hsp peh ON adt.pat_enc_csn_id = peh.pat_enc_csn_id
    JOIN COVID_COHORT ON adt.pat_id = COVID_COHORT.pat_id 
     AND adt.accommodation_c IN ('10003','10010')
     AND adt.effective_time BETWEEN EPIC_UTIL.EFN_DIN('2/1/2020') AND CAST(COALESCE(peh.hosp_disch_time, GETDATE()) AS DATE)
    JOIN ZC_PAT_SERVICE zs ON zs.hosp_serv_c = adt.pat_service_c
    LEFT JOIN CLARITY_ADT ADT1 ON adt1.pat_id = COVID_COHORT.pat_id 
     AND adt.next_out_event_id = adt1.event_id 
     AND adt1.event_subtype_c <> 2
    LEFT JOIN CLARITY_ADT ADT2 ON adt2.pat_id = COVID_COHORT.pat_id      
     AND adt1.xfer_in_event_id = adt2.event_id 
     AND adt2.event_subtype_c <> 2
     AND (adt1.event_type_c = 2 OR adt2.accommodation_c NOT IN ('10003','10010'))
    WHERE adt.event_subtype_c <> 2 
    GROUP BY adt.pat_id, adt.pat_enc_csn_id
   ) t  
 ),
 icu_by_service AS (
  SELECT pat_id, pat_enc_csn_id, hsp_account_id,
   from_time,
   first_service, 
   COALESCE(to_time, hosp_disch_time, CAST(GETDATE() AS DATE)) AS to_time,
   ROUND(COALESCE(to_time, hosp_disch_time, CAST(GETDATE() AS DATE)) - from_time, 2) AS in_days
  FROM (  
    SELECT DISTINCT adt.pat_id, adt.pat_enc_csn_id, peh.hsp_account_id, 
     MIN(adt.effective_time) AS from_time,
     MAX(adt.effective_time) AS max_ICU_to_time,
     MAX(zs.name) AS first_service,  
     CASE 
      WHEN MAX(adt.effective_time) > MAX(adt2.effective_time) THEN NULL  
      ELSE MAX(CASE WHEN adt1.event_type_c = 2 THEN adt1.effective_time ELSE adt2.effective_time END)
     END AS to_time,
     MAX(hosp_disch_time) AS hosp_disch_time
      
    FROM CLARITY_ADT ADT
    JOIN pat_enc_hsp peh ON adt.pat_enc_csn_id = peh.pat_enc_csn_id 
    JOIN patient p ON adt.pat_id = p.pat_id
    JOIN zc_accommodation za ON za.accommodation_c = adt.accommodation_c
    JOIN clarity_dep d ON d.department_id = adt.department_id
    JOIN clarity_rom r ON r.room_id = adt.room_id
    JOIN ZC_EVENT_TYPE zet ON zet.event_type_c = adt.event_type_c
    JOIN ZC_PAT_SERVICE zs ON zs.hosp_serv_c = adt.pat_service_c
      
    JOIN COVID_COHORT ON adt.pat_id = COVID_COHORT.pat_id
      
    LEFT JOIN CLARITY_ADT ADT1 ON adt1.pat_id = p.pat_id 
     AND adt.next_out_event_id = adt1.event_id
     AND adt1.event_subtype_c <> 2
    LEFT JOIN CLARITY_ADT ADT2 ON adt2.pat_id = p.pat_id 
     AND adt1.xfer_in_event_id = adt2.event_id  
     AND adt2.event_subtype_c <> 2 
     AND (
      adt1.event_type_c = 2
      OR adt2.pat_service_c NOT IN (
       '212', --  Pediatric Critical Care  
       '219', --  Surgical Critical Care
       '111', --  Medicine, Critical Care 
       '310008', --  Medicine, Pulmonary (Medicine, Critical Care)
       '310015', --  Surgery, Critical Care (Anesthesiology, Pain Management) 
       '310023', --  Neurology, Critical Care (Neurology)
       '310060', --  Pediatrics, Critical Care
       '310062' --  Medicine, Cardiology Critical Care  
      )
     )
      
    WHERE adt.event_subtype_c <> 2
     AND adt.effective_time BETWEEN EPIC_UTIL.EFN_DIN('3/1/2020') AND CAST(COALESCE(peh.hosp_disch_time, GETDATE()) AS DATE) 
     AND adt.pat_service_c IN
 (  
   '212', --  Pediatric Critical Care
   '219', --  Surgical Critical Care 
   '111', --  Medicine, Critical Care
   '310008', --  Medicine, Pulmonary (Medicine, Critical Care)  
   '310015', --  Surgery, Critical Care (Anesthesiology, Pain Management)
   '310023', --  Neurology, Critical Care (Neurology) 
   '310060', --  Pediatrics, Critical Care
   '310062' --  Medicine, Cardiology Critical Care
  )
    GROUP BY adt.pat_id, adt.pat_enc_csn_id, peh.hsp_account_id
   ) t
 ),
 homeless AS (
  SELECT DISTINCT enc4.pat_id, enc4.pat_homeless_typ_c, hom.name, enc4.contact_date, enc4.pat_homeless_yn  
  FROM COVID_COHORT
  JOIN pat_enc_4 enc4 ON enc4.pat_id = COVID_COHORT.pat_id
  JOIN pat_enc pe ON pe.pat_enc_csn_id = enc4.pat_enc_csn_id 
  LEFT JOIN zc_pat_homeless_ty hom ON enc4.pat_homeless_typ_c = hom.pat_homeless_ty_c
  WHERE enc4.pat_enc_csn_id IN (
    SELECT MAX(pat_enc_csn_id)  
    FROM pat_enc_4 pe4
    WHERE pe4.pat_id = enc4.pat_id
     AND pe4.contact_date BETWEEN EPIC_UTIL.EFN_DIN('yb-1') AND GETDATE()  
     AND pat_homeless_yn IS NOT NULL
   )
 ),
 symp_visit AS (
  SELECT DISTINCT rsn.pat_enc_csn_id, 
   CAST(STRING_AGG(reason_visit_name + CASE WHEN rsn.comments IS NOT NULL THEN '-' + rsn.comments END, ';') AS varchar(2000)) AS symptoms 
  FROM COVID_COHORT cc
  JOIN PAT_ENC_RSN_VISIT rsn ON cc.pat_id = rsn.pat_id
  JOIN CL_RSN_FOR_VISIT clr ON clr.reason_visit_id = rsn.enc_reason_id
  GROUP BY rsn.pat_enc_csn_id
 ),  
 symp_adm AS (
  SELECT DISTINCT adx.pat_enc_csn_id,
   CAST(STRING_AGG(edg.dx_name + CASE WHEN adx.admit_diag_text IS NOT NULL THEN '-' + adx.admit_diag_text END, ';') AS varchar(2000)) AS symptoms
  FROM COVID_COHORT cc 
  JOIN HSP_ADMIT_DIAG adx ON cc.pat_id = adx.pat_id
  JOIN clarity_edg edg ON edg.dx_id = adx.dx_id
  GROUP BY adx.pat_enc_csn_id
 ),
 o2_therapy_flo AS (
  SELECT INPATIENT_DATA_ID, PAT_ID, pat_enc_csn_id,
   MAX(CASE WHEN RN_ASC = 1 THEN OXYGEN_DEVICE END) AS OXYGEN_DEVICE_INIT,
   MAX(CASE WHEN RN_ASC = 1 THEN RECORDED_TIME END) AS O2_TIME_INIT,
   MAX(CASE WHEN RN_ASC = 1 THEN O2_FLOW_RATE END) AS O2_FLOW_RATE_INIT, 
   MAX(O2_FLOW_RATE_MAX) KEEP (DENSE_RANK FIRST ORDER BY RECORDED_TIME) AS O2_FLOW_RATE_MAX,
   MAX(O2_FLOW_RATE_AVG) KEEP (DENSE_RANK FIRST ORDER BY RECORDED_TIME) AS O2_FLOW_RATE_AVG,
   MAX(CASE WHEN t.O2_FLOW_RATE = t.O2_FLOW_RATE_MAX THEN t.OXYGEN_DEVICE END) AS OXYGEN_DEVICE_MAX,   
   MAX(CASE WHEN RN_ASC = 1 THEN FiO2 END) AS FiO2_INIT,
   MAX(FiO2_MAX) KEEP (DENSE_RANK FIRST ORDER BY RECORDED_TIME) AS FiO2_MAX,
   MAX(FiO2_AVG) KEEP (DENSE_RANK FIRST ORDER BY RECORDED_TIME) AS FiO2_AVG,
   MAX(CASE WHEN t.FiO2 = t.FiO2_MAX THEN t.OXYGEN_DEVICE END) AS OXYGEN_DEVICE_FiO2_MAX
  FROM (
    SELECT IP_FLWSHT_REC.INPATIENT_DATA_ID, IP_FLWSHT_REC.PAT_ID, pat_enc_hsp.pat_enc_csn_id,
     ROW_NUMBER() OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID ORDER BY m1.RECORDED_TIME ASC) AS RN_ASC,
     ROW_NUMBER() OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID ORDER BY m1.RECORDED_TIME DESC) AS RN_DESC,
     m1.RECORDED_TIME, 
     m1.MEAS_VALUE AS OXYGEN_DEVICE,
     m2.MEAS_VALUE AS O2_FLOW_RATE,
     m3.MEAS_VALUE AS FiO2,
     MAX(CAST(m2.MEAS_VALUE AS decimal)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) AS O2_FLOW_RATE_MAX,  
     MAX(CAST(m3.MEAS_VALUE AS decimal)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) AS FiO2_MAX,
     AVG(CAST(m2.MEAS_VALUE AS decimal)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) AS O2_FLOW_RATE_AVG, 
     AVG(CAST(m3.MEAS_VALUE AS decimal)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) AS FiO2_AVG     
    FROM IP_FLWSHT_REC
    JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID
    JOIN COVID_COHORT ON pat_enc_hsp.PAT_ID = COVID_COHORT.pat_id    
    LEFT JOIN Covid_vent_flo vent_flo ON pat_enc_hsp.pat_enc_csn_id = vent_flo.pat_enc_csn_id
    JOIN IP_FLWSHT_MEAS m1 ON IP_FLWSHT_REC.FSD_ID = m1.FSD_ID 
     AND m1.MEAS_VALUE IS NOT NULL
     AND m1.FLO_MEAS_ID IN (
       '301030', --R OXYGEN DEVICE
       '16055', --R ED OXYGEN DEVICE  
       '3041530321', --NYU R TC PED O2 DEVICE
       '30430103001', --NYU R TC OXYGEN DEVICE
       '4212' --R OXYGEN DEVICE [COMPILED RECORD] [FLT ID 1603100001]  
      ) 
    LEFT JOIN IP_FLWSHT_MEAS m2 ON IP_FLWSHT_REC.FSD_ID = m2.FSD_ID
     AND m1.recorded_time = m2.recorded_time 
     AND m2.MEAS_VALUE IS NOT NULL
     AND m2.FLO_MEAS_ID IN (  
       '250026', --  R OXYGEN FLOW RATE
       '500690' --R IP O2 FLOW RATE
      )
    LEFT JOIN IP_FLWSHT_MEAS m3 ON IP_FLWSHT_REC.FSD_ID = m3.FSD_ID
     AND m1.recorded_time = m3.recorded_time  
     AND m3.MEAS_VALUE IS NOT NULL 
     AND m3.FLO_MEAS_ID IN (
      '3042001465', --FiO2  
      '3041562020', --FiO2
      '301550' --FiO2  
     )
    WHERE m1.RECORDED_TIME BETWEEN EPIC_UTIL.EFN_DIN('2/1/2020') AND COALESCE(vent_flo.mech_vent_type_date, CAST(GETDATE() AS DATE))
     AND (m2.MEAS_VALUE IS NOT NULL OR m3.MEAS_VALUE IS NOT NULL) 
   ) t
  GROUP BY INPATIENT_DATA_ID, PAT_ID, pat_enc_csn_id
 ), 
 prone_on_floor AS (
  SELECT peh.pat_id, peh.pat_enc_csn_id, peh.hsp_account_id,
   MAX(IP_FLWSHT_MEAS.MEAS_VALUE) AS MEAS_VALUE,
   MIN(IP_FLWSHT_MEAS.RECORDED_TIME) AS first_prone_date,
   MAX(IP_FLWSHT_MEAS.RECORDED_TIME) AS last_prone_date
  FROM IP_FLWSHT_REC  
  JOIN pat_enc_hsp peh ON IP_FLWSHT_REC.INPATIENT_DATA_ID = peh.INPATIENT_DATA_ID
  JOIN covid_cohort cc ON cc.pat_id = peh.pat_id
  JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
  WHERE RECORDED_TIME BETWEEN '2020-02-01' AND CAST(GETDATE() AS DATE)
   AND IP_FLWSHT_MEAS.FLO_MEAS_ID = '803340' 
   AND LOWER(IP_FLWSHT_MEAS.MEAS_VALUE) = 'prone'
  GROUP BY peh.pat_id, peh.pat_enc_csn_id, peh.hsp_account_id  
 ),
 airway_measures AS (
  SELECT *
  FROM (
    SELECT pat_enc_csn_id, flo_meas_cat,
     recorded_time,
     meas_value, 
     max_recorded_time,
     max_meas_value
    FROM (  
      SELECT t.*,
       MIN(CASE WHEN meas_value = max_meas_value THEN recorded_time END) OVER (PARTITION BY pat_enc_csn_id, flo_meas_cat) AS max_recorded_time,
       ROW_NUMBER() OVER (PARTITION BY pat_enc_csn_id, flo_meas_cat ORDER BY RECORDED_TIME) AS ASC_RN
      FROM (  
        SELECT air.pat_enc_csn_id, flo_meas_cat,
         CASE WHEN ISNUMERIC(air.meas_value) = 1 THEN CAST(air.meas_value AS decimal) END AS meas_value,
         MAX(CASE WHEN ISNUMERIC(air.meas_value) = 1 THEN CAST(air.meas_value AS decimal) END) OVER (PARTITION BY air.pat_enc_csn_id, flo_meas_cat) AS max_meas_value, 
         air.recorded_time
        FROM COVID_AIRWAY_MEASURES air
        WHERE air.flo_meas_cat IN ('PEEP','MSOFA_SCORE','HIGH_TV')  
       ) t
     ) t
    WHERE asc_rn = 1
   ) t 
  PIVOT (
    MAX(recorded_time) AS first_recorded_time,
    MAX(meas_value) AS first_value, 
    MAX(max_recorded_time) AS max_recorded_time,
    MAX(max_meas_value) AS max_value
    FOR flo_meas_cat IN ('PEEP' AS PEEP, 'MSOFA_SCORE' AS MSOFA, 'HIGH_TV' AS TV)
  ) AS pivoted
 )
 INSERT INTO COVID_REPORT_I
 SELECT zd.name AS enc_type, 
  t.*
 FROM (
  SELECT DISTINCT 
   p.pat_mrn_id AS "MRN",
   COALESCE(har.prim_enc_csn_id, pe.pat_enc_csn_id) AS "CSN",
   har.hsp_account_id AS "HAR",  
   p.pat_name AS "Patient Name",
   COVID_COHORT.specimn_taken_date AS "Date Tested",
   COVID_COHORT.ORD_VALUE AS "Result (Positive / Negative)", 
   CASE 
     WHEN har.hsp_account_id IS NOT NULL THEN har.adm_date_time
     ELSE pe.effective_date_dt  
   END AS "Admission/Arrival Date",
   zarr.name AS "Arrival Info (home, ambulance, transfer)",
   COALESCE(zpcA.name, zpcH.name) AS "Admission Status",
   zpc.name AS "Current Patient Class", 
   bed.bed_label AS "Bed",
   room.room_name AS "Room", 
   v.department_name AS "Department",
   v.catg AS "Facility",
   zdc.name AS "Discharge Status (or if still admitted leave blank)*",
   ZC_PAT_LIVING_STAT.name + CASE WHEN ZC_PAT_LIVING_STAT.PAT_LIVING_STAT_C = 2 THEN ' as of ' + FORMAT(p.death_date,'MM/dd/yy') END AS "Patient Status",
   CASE WHEN har.hsp_account_id IS NOT NULL THEN har.disch_date_time END AS "Discharge Date*",
   CASE WHEN har.disch_date_time IS NOT NULL THEN zdd.name END AS "Discharge destination / disposition*",
   rr.race AS "Race", 
   gr2.name AS "Ethnic Group (Hispanic/Non-Hispanic)",
   zss.name AS "Gender", 
   p.birth_date AS "Age/DOB",
   CASE WHEN pe.lmp_other_c = 4 THEN 'Y' END AS "Pregnant?",  
   homeless.pat_homeless_yn AS "Homeless?",
   MAX(pe.bmi) OVER (PARTITION BY pe.pat_id) AS BMI,
   soc_hx.ZC_TOBACCO_USER AS "Smoking",
   soc_hx.tobacco_pak_per_dy AS "Pack per day", 
   soc_hx.tobacco_used_years AS "Years used",
   vaping.Vaping AS "Vaping",
   REPLACE(
    (CASE WHEN soc_hx.alcohol_oz_per_wk IS NOT NULL THEN 'oz per wk:' + CAST(soc_hx.alcohol_oz_per_wk AS varchar) END +
     CASE WHEN soc_hx.alcohol_comment IS NOT NULL THEN 'alcohol comment:' + soc_hx.alcohol_comment END), 
    '"', ''
   ) AS "Alcohol History",
   icu.in_icu_time AS "Was patient ever ICU status (date of transfer to ICU)",
   ROUND(icu.total_days_per_stay, 2) AS "Duration of ICU stay",
   CASE WHEN vent_flo.MECH_VENT_TYPE IS NOT NULL 
     THEN FORMAT(vent_flo.MECH_VENT_TYPE_DATE,'MM/dd/yyyy') + ' - ' + vent_flo.MECH_VENT_TYPE 
   END AS "Was patient ever on ventilator",
   CAST(vent_flo.VENT_DAYS AS varchar) AS "Duration of mechancial ventilation", 
   ecmo.ecmo_hours AS "ECMO duration(hours)", 
   ecmo.from_date AS "ECMO Date",
   labs."Lymphocytes abs",
   labs."Neutrophils abs",    
   
   CASE 
    WHEN vitals_flo.temp IS NOT NULL THEN vitals_flo.temp_time
    WHEN peA.temperature IS NOT NULL THEN peA2.VITALS_TAKEN_TM 
   END AS "temp_time",  
   CASE
    WHEN vitals_flo.temp IS NOT NULL THEN vitals_flo.temp  
    WHEN peA.temperature IS NOT NULL THEN CAST(peA.temperature AS varchar) 
   END AS "Temperature",

   CASE  
    WHEN vitals_flo.BP_SYSTOLIC IS NOT NULL THEN vitals_flo.BP_SYSTOLIC_TIME
    WHEN vitals_flo.bp IS NOT NULL THEN vitals_flo.bp_time
    WHEN peA.bp_systolic IS NOT NULL THEN peA2.VITALS_TAKEN_TM
   END AS "bp_time",
   CASE 
    WHEN vitals_flo.BP_SYSTOLIC IS NOT NULL THEN vitals_flo.BP_SYSTOLIC 
    WHEN vitals_flo.bp IS NOT NULL THEN SUBSTRING(vitals_flo.bp, 1, CHARINDEX('/', vitals_flo.bp)-1)  
    WHEN peA.bp_systolic IS NOT NULL THEN CAST(peA.bp_systolic AS varchar)
   END AS "bp_systolic", 
   CASE
    WHEN vitals_flo.BP_diastolic IS NOT NULL THEN vitals_flo.BP_diastolic  
    WHEN vitals_flo.bp IS NOT NULL THEN SUBSTRING(vitals_flo.bp, CHARINDEX('/', vitals_flo.bp)+1, LEN(vitals_flo.bp))
    WHEN peA.bp_diastolic IS NOT NULL THEN CAST(peA.bp_diastolic AS varchar)  
   END AS "bp_diastolic",

   CASE
    WHEN vitals_flo.resp IS NOT NULL THEN vitals_flo.resp_time 
    WHEN peA.Respirations IS NULL THEN peA2.VITALS_TAKEN_TM
   END AS "Resp_time",
   CASE 
    WHEN vitals_flo.resp IS NOT NULL THEN vitals_flo.resp
    WHEN peA.Respirations IS NULL THEN CAST(peA.Respirations AS varchar)  
   END AS "Resp.Rate",
   
   CASE
    WHEN vitals_flo.SVO2 IS NOT NULL THEN vitals_flo.SVO2_time
    WHEN peA2.PHYS_SPO2 IS NULL THEN peA2.VITALS_TAKEN_TM  
   END AS "SVO2_time",
   CASE
    WHEN vitals_flo.SVO2 IS NOT NULL THEN vitals_flo.SVO2  
    WHEN peA2.PHYS_SPO2 IS NULL THEN CAST(peA2.PHYS_SPO2 AS varchar)
   END AS "SVO2",
    
   COALESCE(symp_adm.symptoms, symp_visit.symptoms) AS "Symptoms",
   tt.stage AS "Transplant",
   zs.name AS "Infection Status", 
   CASE 
    WHEN har.hsp_account_id IS NULL THEN 'y'
    WHEN har.hsp_account_id IS NOT NULL AND har.prim_enc_csn_id = pe.pat_enc_csn_id THEN 'y'
   END AS is_include,
   pe.enc_type_c, 
   GETDATE() AS update_date,
   
   CASE WHEN vent_flo.MECH_VENT_TYPE_NI IS NOT NULL  
    THEN FORMAT(vent_flo.MECH_VENT_TYPE_DATE_NI,'MM/dd/yyyy') + ' - ' + vent_flo.MECH_VENT_TYPE_NI   
   END AS "Non-invasive ventilator",
   CAST(vent_flo.VENT_DAYS_NI AS varchar) AS "Duration of non-invasive ventilation",
  
   o2_therapy_flo.OXYGEN_DEVICE_INIT AS "Oxygen_device Init", 
   o2_therapy_flo.O2_TIME_INIT AS "O2 Device Time Init",
   o2_therapy_flo.O2_FLOW_RATE_INIT AS "O2_Flow_Rate Init", 
   o2_therapy_flo.FIO2_INIT AS "Fio2 Init", 
   o2_therapy_flo.OXYGEN_DEVICE_MAX AS "Oxygen_device at O2 MAX",
   o2_therapy_flo.O2_FLOW_RATE_MAX AS "O2_Flow_Rate MAX",
   o2_therapy_flo.OXYGEN_DEVICE_FIO2_MAX AS "Oxygen_device at Fio2 MAX",
   o2_therapy_flo.FIO2_MAX AS "Fio2 MAX",
   o2_therapy_flo.O2_FLOW_RATE_AVG AS "O2_Flow_Rate AVG", 
   o2_therapy_flo.FIO2_AVG AS "Fio2 AVG",
   
   icu_by_service.from_time AS "ICU by Service",
   CAST(ROUND(icu_by_service.in_days, 2) AS varchar) + ' ' + icu_by_service.first_service AS "Duration of ICU stay (by service)",  
   ZC_RELIGION.NAME AS Religion,
   COVID_CPR.EVENT_TIME AS CPR_date,
   
   CASE 
    WHEN vitals_flo.pulse IS NOT NULL THEN vitals_flo.pulse_time
    WHEN peA.Pulse IS NULL THEN peA2.VITALS_TAKEN_TM
   END AS "pulse_time",
   CASE  
    WHEN vitals_flo.pulse IS NOT NULL THEN vitals_flo.pulse
    WHEN peA.pulse IS NULL THEN CAST(peA.Respirations AS varchar) 
   END AS "pulse",
   
   p.INTRPTR_NEEDED_YN,
   zc_language.name AS language, 
   REPLACE(epp.benefit_plan_name, '&', 'and') AS Primary_Insurance,
   ocu.occupation,
   soc_hx.years_education, 
   p.zip,
   prone_on_floor.first_prone_date,
   prone_on_floor.last_prone_date,
   COVID_TRACHEOSTOMY_COHORT.PROCEDURE_DATE AS tracheostomy_date,
   first_Inf_onset_date,
   COVID_VENT_COMMENTS.MEAS_COMMENT_VENT AS vent_comment,
   COVID_VENT_COMMENTS.FIRST_VENT_COMMENT_DATE,
   COVID_VENT_COMMENTS.MEAS_COMMENT_ANY AS other_comment, 
   COVID_VENT_COMMENTS.FIRST_ANY_COMMENT_DATE AS first_other_comment_date,
   rsv.reason_visit_name AS chief_complaint,
   air.PEEP_FIRST_RECORDED_TIME, 
   air.PEEP_FIRST_VALUE,
   air.PEEP_MAX_RECORDED_TIME,
   air.PEEP_MAX_VALUE,
   air.MSOFA_FIRST_RECORDED_TIME,
   air.MSOFA_FIRST_VALUE,
   air.MSOFA_MAX_RECORDED_TIME, 
   air.MSOFA_MAX_VALUE,
   air.TV_FIRST_RECORDED_TIME,
   air.TV_FIRST_VALUE, 
   air.TV_MAX_RECORDED_TIME,
   air.TV_MAX_VALUE,
   COVID_COHORT.covid_source 
   
  FROM COVID_COHORT
  JOIN patient p ON COVID_COHORT.pat_id = p.pat_id
  JOIN pat_enc pe ON pe.pat_id = p.pat_id 
   AND (
    pe.effective_date_dt BETWEEN EPIC_UTIL.EFN_DIN('2/1/2020') AND CAST(GETDATE() AS DATE)  
    OR pe.contact_date BETWEEN EPIC_UTIL.EFN_DIN('2/1/2020') AND CAST(GETDATE() AS DATE)
   )
   AND (
    (pe.enc_type_c <> 3 AND pe.appt_status_c = 2) 
    OR (pe.enc_type_c = 3 AND pe.hsp_account_id IS NOT NULL 
     AND pe.cancel_reason_c IS NULL 
     AND (pe.appt_status_c IS NULL OR appt_status_c <> 3) 
     AND pe.CALCULATED_ENC_STAT_C <> 3)
   )
    
  LEFT JOIN hsp_account har ON har.hsp_account_id = pe.hsp_account_id
  LEFT JOIN pat_enc_hsp peh ON peh.pat_enc_csn_id = pe.pat_enc_csn_id
  LEFT JOIN (
   SELECT adt.*,
     ROW_NUMBER() OVER (PARTITION BY adt.pat_enc_csn_id ORDER BY adt.effective_time DESC) AS rn 
   FROM clarity_adt adt
   WHERE EVENT_SUBTYPE_C <> 2 
    AND (adt.bed_id IS NOT NULL OR adt.event_type_c = 2)  
  ) adt ON adt.pat_enc_csn_id = peh.pat_enc_csn_id AND adt.rn = 1
  LEFT JOIN (
   SELECT adtA.*,
    ROW_NUMBER() OVER (PARTITION BY adtA.pat_enc_csn_id ORDER BY adtA.effective_time ASC) AS rn 
   FROM clarity_adt adtA
   WHERE adtA.event_type_c IN (7, 1) 
    AND adtA.EVENT_SUBTYPE_C <> 2
  ) adtA ON adtA.pat_enc_csn_id = peh.pat_enc_csn_id AND adtA.rn = 1 
  LEFT JOIN pat_enc peA ON peA.Pat_Enc_Csn_Id = COALESCE(adtA.pat_enc_csn_id, COVID_COHORT.csn_onadmission)
  LEFT JOIN pat_enc_2 peA2 ON peA.Pat_Enc_Csn_Id = peA2.Pat_Enc_Csn_Id
  LEFT JOIN department_info_v v ON v.department_id = COALESCE(adt.department_id, pe.effective_dept_id) 
  LEFT JOIN ZC_PAT_CLASS zpcA ON zpcA.adt_pat_class_c = adtA.pat_class_c
  LEFT JOIN ZC_PAT_CLASS zpcH ON zpcH.adt_pat_class_c = peh.adt_pat_class_c
  LEFT JOIN clarity_bed bed ON bed.bed_csn_id = adt.bed_csn_id
  LEFT JOIN clarity_rom room ON room.room_csn_id = adt.room_csn_id
  LEFT JOIN ZC_PAT_CLASS zpc ON zpc.adt_pat_class_c = peh.adt_pat_class_c
  LEFT JOIN ZC_ARRIV_MEANS zarr ON peh.MEANS_OF_ARRV_C = zarr.MEANS_OF_ARRV_C
  LEFT JOIN ZC_DISCH_DISP zdd ON zdd.DISCH_DISP_C = peh.DISCH_DISP_C
  LEFT JOIN ZC_DISCHARGE_CAT zdc ON zdc.DISCHARGE_CAT_C = peh.DISCHARGE_CAT_C
  LEFT JOIN ZC_DISCH_DEST zddh ON har.DISCH_DESTIN_HA_C = zddh.disch_dest_c
  LEFT JOIN COVID_Vaping Vaping ON Vaping.pat_id = COVID_COHORT.pat_id
  LEFT JOIN covid_labs labs ON adtA.pat_enc_csn_id = labs.pat_enc_csn_id
  LEFT JOIN vitals_flo ON vitals_flo.pat_id = COVID_COHORT.pat_id AND peh.pat_enc_csn_id = vitals_flo.pat_enc_csn_id
  LEFT JOIN COVID_ECMO ecmo ON ecmo.pat_id = COVID_COHORT.pat_id AND peh.pat_enc_csn_id = ecmo.pat_enc_csn_id
  LEFT JOIN Covid_vent_flo vent_flo ON peh.pat_enc_csn_id = vent_flo.pat_enc_csn_id
  LEFT JOIN o2_therapy_flo ON peh.pat_enc_csn_id = o2_therapy_flo.pat_enc_csn_id
  LEFT JOIN symp_visit ON symp_visit.pat_enc_csn_id = peh.pat_enc_csn_id
  LEFT JOIN symp_adm ON symp_adm.pat_enc_csn_id = peh.pat_enc_csn_id
  LEFT JOIN COVID_soc_hx soc_hx ON COVID_COHORT.pat_id = soc_hx.pat_id
  LEFT JOIN COVID_ICU_BY_ACCOMODATION icu ON COVID_COHORT.pat_id = icu.pat_id AND peh.pat_enc_csn_id = icu.pat_enc_csn_id
  LEFT JOIN icu_by_service ON peh.pat_enc_csn_id = icu_by_service.pat_enc_csn_id
  LEFT JOIN homeless ON COVID_COHORT.pat_id = homeless.pat_id  
  LEFT JOIN (
    SELECT rr.pat_id, STRING_AGG(rr2.name, ';') AS race
    FROM patient_race rr  
    JOIN zc_patient_race rr2 ON rr.patient_race_c = rr2.patient_race_c
    GROUP BY rr.pat_id
  ) rr ON p.pat_id = rr.pat_id
  LEFT JOIN zc_ethnic_group gr ON p.ethnic_group_c = gr.ethnic_group_c
  LEFT JOIN (
    SELECT eb.pat_id, gr2.name
    FROM ETHNIC_BACKGROUND eb
    JOIN ZC_ETHNIC_BKGRND gr2 ON gr2.ethnic_bkgrnd_c = eb.ethnic_bkgrnd_c
    WHERE eb.line = 1
  ) gr2 ON gr2.pat_id = p.pat_id
  JOIN patient_4 pp4 ON p.pat_id = pp4.pat_id  
  LEFT JOIN ZC_PAT_LIVING_STAT ON pp4.pat_living_stat_c = ZC_PAT_LIVING_STAT.PAT_LIVING_STAT_C
  LEFT JOIN zc_gender_identity zg ON zg.gender_identity_c = pp4.gender_identity_c
  LEFT JOIN zc_sex_asgn_at_birth zsb ON zsb.sex_asgn_at_birth_c = pp4.SEX_ASGN_AT_BIRTH_C
  LEFT JOIN zc_sex zss ON zss.rcpt_mem_sex_c = p.sex_c
  LEFT JOIN (
    SELECT tt.pat_id,
     STRING_AGG(FORMAT(tt.txp_surg_dttm,'MM/dd/yy') + ' ' + ZC_TX_CURRENT_STAG.NAME, ';') WITHIN GROUP (ORDER BY tt.tx_current_stage_dt ASC) AS stage
    FROM TRANSPLANT_INFO tt
    LEFT JOIN ZC_TX_EPSD_TYPE ON ZC_TX_EPSD_TYPE.TX_EPSD_TYPE_C = tt.tx_epsd_type_c
    LEFT JOIN ZC_TX_CURRENT_STAG ON ZC_TX_CURRENT_STAG.TX_CURRENT_STAG_C = tt.tx_current_stage_c
    GROUP BY tt.pat_id
  ) tt ON tt.pat_id = COVID_COHORT.pat_id
  LEFT JOIN (
    SELECT ii.*, 
     MIN(COALESCE(ii.ONSET_DATE, EPIC_UTIL.EFN_UTC_TO_LOCAL(ii.add_utc_dttm))) OVER (PARTITION BY pat_id) AS first_Inf_onset_date,
     ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY ii.add_utc_dttm DESC) AS rn
    FROM INFECTIONS ii
    WHERE ii.infection_type_c = 30813  
  ) ii ON ii.pat_id = p.pat_id AND ii.rn = 1  
  LEFT JOIN ZC_INF_STATUS zs ON zs.inf_status_c = ii.inf_status_c
  LEFT JOIN COVID_CPR ON COVID_CPR.HSP_ACCOUNT_ID = har.hsp_account_id AND COVID_CPR.RN_ASC = 1
  LEFT JOIN (
    SELECT ocu.pat_id, ocu.hx_occupn + ' ' + eep.employer_name AS occupation,
     ROW_NUMBER() OVER (PARTITION BY ocu.pat_id ORDER BY ocu.contact_date DESC) AS rn  
    FROM PAT_OCCUPN_HX ocu
    LEFT JOIN CLARITY_EEP eep ON eep.employer_id = ocu.hx_employer_id
  ) ocu ON covid_cohort.pat_id = ocu.pat_id AND ocu.rn = 1
  LEFT JOIN pat_acct_cvg ac ON har.coverage_id = ac.coverage_id
  LEFT JOIN clarity_epp epp ON ac.plan_id = epp.benefit_plan_id
  LEFT JOIN prone_on_floor ON peh.pat_enc_csn_id = prone_on_floor.pat_enc_csn_id
  LEFT JOIN COVID_TRACHEOSTOMY_COHORT ON COVID_TRACHEOSTOMY_COHORT.pat_enc_csn_id = peh.pat_enc_csn_id
  LEFT JOIN COVID_VENT_COMMENTS ON COVID_VENT_COMMENTS.pat_enc_csn_id = peh.pat_enc_csn_id
  LEFT JOIN f_ed_encounters ed ON ed.pat_enc_csn_id = peh.pat_enc_csn_id
  LEFT JOIN CL_RSN_FOR_VISIT rsv ON ed.first_chief_complaint_id = rsv.reason_visit_id  
  LEFT JOIN airway_measures air ON air.pat_enc_csn_id = peh.pat_enc_csn_id
   
  WHERE (peh.adt_pat_class_c IS NULL OR peh.adt_pat_class_c <> '111')
    
 ) t
 JOIN zc_disp_enc_type zd ON zd.disp_enc_type_c = t.enc_type_c
 WHERE is_include = 'y' AND "Admission/Arrival Date" IS NOT NULL
;

COMMIT;
  
EXEC sp_executesql N'TRUNCATE TABLE COVID_REPORT_II'; 
 
WITH DIAB_EDG AS (
 SELECT DISTINCT icd10.code AS icd_code, edg.*
 FROM CLARITY_EDG edg
 JOIN edg_current_icd10 icd10 ON edg.dx_id = icd10.dx_id
 WHERE EXISTS (SELECT 1 FROM DIAB_DX dx WHERE dx.icd_code = icd10.code)    
),
pl_dx AS (
 SELECT * 
 FROM (
  SELECT pat_id, STRING_AGG(ICD_CODE, ';') WITHIN GROUP (ORDER BY ICD_CODE) AS ICD_CODE, 
   DX_CATG
  FROM (
    SELECT pat_id, icd_code, DX_CATG
    FROM COVID_PL_DX pl
    UNION  
    SELECT pat_id, icd_code, DX_CATG
    FROM COVID_MEDHX_DX m
    UNION
    SELECT pat_id, icd_code, DX_CATG  
    FROM COVID_ENC_DX m
  ) t
  GROUP BY pat_id, DX_CATG 
 ) src
 PIVOT (
  MAX(ICD_CODE) 
  FOR DX_CATG IN (
   'Hyperlipidemia' AS "Hyperlipidemia", 
   'Hypertension' AS "Hypertension", 
   'COPD' AS "COPD",
   'HF' AS "Heart Failure",
   'CAD' AS "Coronary artery disease",
   'PVD' AS "Peripheral vascular disease",
   'diabetes' AS "Diabetes",  
   'Asthma' AS "Asthma",
   'Dialysis' AS "Dialysis", 
   'CKD' AS "CKD",
   'Cancer' AS "Cancer",
   'Cirrhosis' AS "Cirrhosis",
   'OBESITY' AS "OBESITY",
   'Autoimmune Disorders' AS "Autoimmune Disorders", 
   'Interstitial Lung Disease' AS Interstitial_Lung_Disease,
   'Emphysema' AS Emphysema, 
   'Pulmonary Fibrosis' AS Pulmonary_Fibrosis,
   'Cystic Fibrosis' AS Cystic_Fibrosis,
   'Sleep Apnea' AS Sleep_Apnea,
   'Bronchiectasis' AS Bronchiectasis
  )
 ) pvt
), 
MEDS AS (
 SELECT DISTINCT cm.MEDICATION_ID, cm.name AS rx_name,
  CASE 
   WHEN gmr.GROUPER_ID IN ('104155', '105758') AND LOWER(cm.name) LIKE '%pril%' THEN 'ACE'
   WHEN gmr.GROUPER_ID IN ('104155', '105758') AND LOWER(cm.name) LIKE '%artan%' THEN 'ARB' 
   WHEN gmr.GROUPER_ID IN ('104155', '105758') THEN 'ACE/ARB'
   WHEN gmr.GROUPER_ID IN ('2100000128') THEN 'NSAID'
   WHEN gmr.GROUPER_ID IN ('1137305') THEN 'Aspirin'
   WHEN gmr.GROUPER_ID IN ('1139692', '2100009193') THEN 'Statin' 
   WHEN gmr.GROUPER_ID IN ('115353') THEN 'Anti-hypertensive'
   WHEN cm.thera_class_c = 27 THEN 'Diabetes'
   WHEN cm.thera_class_c = 28 THEN 'Immunosuppressants'
   WHEN cm.pharm_class_c IN (631, 1156) THEN 'Biologic'
  END AS RX_CATG 
 FROM CLARITY_MEDICATION cm
 JOIN GROUPER_MED_RECS gmr ON gmr.EXP_MEDS_LIST_ID = cm.medication_id 
 JOIN GROUPER_ITEMS gi ON gi.grouper_id = gmr.GROUPER_ID
 WHERE gmr.GROUPER_ID IN ('104155', '105758', '2100000128', '1137305', '1139692', '2100009193', '115353')  
  OR cm.thera_class_c IN (27, 28)
  OR cm.pharm_class_c IN (631, 1156)
),
medications AS (
 SELECT *
 FROM (  
  SELECT DISTINCT COVID_COHORT.pat_id, MEDS.rx_name, RX_CATG,
   om.HV_DISCRETE_DOSE AS dose 
  FROM COVID_COHORT  
  JOIN PAT_ENC_CURR_MEDS mm ON COVID_COHORT.pat_id = mm.pat_id AND IS_ACTIVE_YN = 'Y'
  JOIN order_med om ON om.order_med_id = mm.current_med_id
  JOIN MEDS ON MEDS.MEDICATION_ID = om.medication_id
 ) src 
 PIVOT (
  MAX(rx_name),
  MAX(dose) AS dose  
  FOR RX_CATG IN (
   'ACE/ARB' AS "ACE/ARB", 
   'ACE' AS "ACE",
   'ARB' AS "ARB",
   'NSAID' AS "NSAID",
   'Aspirin' AS "Aspirin",
   'Statin' AS "Statin",
   'Diabetes' AS "Diabetes RX",
   'Anti-hypertensive' AS "Anti-hypertensive",  
   'Immunosuppressants' AS "Immunosuppressants",
   'Biologic' AS "Biologic"
  )  
 ) pvt
),
DIALYSIS_HISTORY AS (
 SELECT t.PAT_ID, MIN(t.DIALYSIS_START_DATE) AS DIALYSIS_START_DATE, MAX(t.DIALYSIS_END_DATE) AS DIALYSIS_END_DATE   
 FROM V_PAT_DIALYSIS_HISTORY t
 GROUP BY t.PAT_ID
),
DNR AS (
 SELECT COV.CSN,
  CODA.CODE_STATUS_ADM AS Admission_Code_Status,
  CODA.ACTIVATED_INST AS First_Code_Status_Time,
  CODD.CODE_STATUS_DSC AS Discharge_Code_Status,
  CODD.ACTIVATED_INST AS Last_Code_Status_Time
 FROM COVID_REPORT_I COV  
 LEFT JOIN (
   SELECT 
    OCS.PATIENT_CSN,
    OCS.PATIENT_ID,
    OCS.ORDER_ID,
    OCS.ACTIVATED_INST,
    ZC_STAT.NAME AS CODE_STATUS_ADM,
    ROW_NUMBER() OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST ASC) AS RANK
   FROM COVID_REPORT_I COV
   JOIN OCS_CODE_STATUS OCS ON COV.CSN = OCS.PATIENT_CSN  
   JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
   WHERE OCS.ACTIVATED_INST > '2020-02-01'  
 ) CODA ON CODA.PATIENT_CSN = COV.CSN AND CODA.RANK = 1
 LEFT JOIN ( 
   SELECT
    OCS.PATIENT_CSN, 
    OCS.PATIENT_ID,
    OCS.ORDER_ID,
    OCS.ACTIVATED_INST, 
    ZC_STAT.NAME AS CODE_STATUS_DSC,
    ROW_NUMBER() OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST DESC) AS RANK  
   FROM COVID_REPORT_I COV
   JOIN OCS_CODE_STATUS OCS ON COV.CSN = OCS.PATIENT_CSN
   JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C 
   WHERE OCS.ACTIVATED_INST > '2020-02-01'
 ) CODD ON CODD.PATIENT_CSN = COV.CSN AND CODD.RANK = 1
) 

SELECT DISTINCT cc.pat_mrn_id, cc.pat_id,  
 pl_dx."Hyperlipidemia", pl_dx."Hypertension", pl_dx."COPD", pl_dx."Heart Failure", pl_dx."Coronary artery disease",  
 pl_dx."Peripheral vascular disease", pl_dx."Diabetes", pl_dx."Asthma", pl_dx."Dialysis", pl_dx."CKD",
 medications."ACE/ARB", "ACE/ARB_DOSE", "ACE", "ACE_DOSE", "ARB", "ARB_DOSE", "NSAID", "Aspirin", "Statin", "Diabetes RX", "Anti-hypertensive", "Immunosuppressants",
 "Immunosuppressants_DOSE", "Biologic", "Biologic_DOSE", "Cancer", "NSAID_DOSE", "Cirrhosis", "OBESITY",  
 "Autoimmune Disorders", Interstitial_Lung_Disease,
 Emphysema, Pulmonary_Fibrosis, Cystic_Fibrosis, Sleep_Apnea, Bronchiectasis,
 dialysis_start_date, dialysis_end_date  
FROM COVID_COHORT cc
JOIN patient p ON p.pat_id = cc.pat_id
LEFT JOIN pl_dx ON pl_dx.pat_id = cc.pat_id
LEFT JOIN medications ON medications.pat_id = cc.pat_id  
LEFT JOIN DIALYSIS_HISTORY ON DIALYSIS_HISTORY.pat_id = cc.pat_id
;

COMMIT; 
  
DECLARE @objExists int;
SELECT @objExists = COUNT(*) FROM sys.objects WHERE type = 'U' AND name = 'COVID_REPORT_FULL';
IF @objExists > 0 
BEGIN
 EXEC sp_executesql N'DROP TABLE COVID_REPORT_FULL';  
END;
  
EXEC sp_executesql N'
 CREATE TABLE COVID_REPORT_FULL AS
 SELECT DISTINCT COVID_REPORT_I.*, 
  COVID_REPORT_II.*,
  
  Admission_Code_Status,
  First_Code_Status_Time,
  Discharge_Code_Status, 
  Last_Code_Status_Time
 FROM COVID_REPORT_I
 JOIN COVID_REPORT_II ON COVID_REPORT_I.MRN = COVID_REPORT_II.pat_mrn_id  
 LEFT JOIN (
   SELECT COV.CSN,
    CODA.CODE_STATUS_ADM AS Admission_Code_Status,
    CODA.ACTIVATED_INST AS First_Code_Status_Time,  
    CODD.CODE_STATUS_DSC AS Discharge_Code_Status,
    CODD.ACTIVATED_INST AS Last_Code_Status_Time 
   FROM COVID_REPORT_I COV
   LEFT JOIN (
     SELECT 
      OCS.PATIENT_CSN,
      OCS.PATIENT_ID, 
      OCS.ORDER_ID,
      OCS.ACTIVATED_INST,
      ZC_STAT.NAME AS CODE_STATUS_ADM,
      ROW_NUMBER() OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST ASC) AS RANK  
     FROM COVID_REPORT_I COV
     JOIN OCS_CODE_STATUS OCS ON COV.CSN = OCS.PATIENT_CSN
     JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
     WHERE OCS.ACTIVATED_INST > ''2020-02-01''
    ) CODA ON CODA.PATIENT_CSN = COV.CSN AND CODA.RANK = 1
   LEFT JOIN (
     SELECT  
      OCS.PATIENT_CSN,
      OCS.PATIENT_ID,
      OCS.ORDER_ID, 
      OCS.ACTIVATED_INST,
      ZC_STAT.NAME AS CODE_STATUS_DSC,
      ROW_NUMBER() OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST DESC) AS RANK
     FROM COVID_REPORT_I COV 
     JOIN OCS_CODE_STATUS OCS ON COV.CSN = OCS.PATIENT_CSN
     JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
     WHERE OCS.ACTIVATED_INST > ''2020-02-01'' 
    ) CODD ON CODD.PATIENT_CSN = COV.CSN AND CODD.RANK = 1
  ) DNR ON DNR.CSN = COVID_REPORT_I.CSN
';

COMMIT;

CREATE INDEX COV_FUL_IDX ON COVID_REPORT_FULL (CSN);
GRANT SELECT ON COVID_REPORT_FULL TO DSSVI_TAB_USER;  
GRANT SELECT ON COVID_REPORT_FULL TO PAU_USER;

INSERT INTO COVID_DAILY_LOG VALUES ('COVID_REPORT_FULL', NULL, GETDATE());
COMMIT;
  
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_CURRENT_INV_VENT_DASHB', GETDATE(), NULL);
COMMIT;  
ALTER INDEX ALL ON COVID_CURRENT_INV_VENT_DASHB DISABLE;
EXEC sp_refreshview N'COVID_CURRENT_INV_VENT_DASHB'; 
ALTER INDEX ALL ON COVID_CURRENT_INV_VENT_DASHB REBUILD;
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_CURRENT_INV_VENT_DASHB', NULL, GETDATE()); 
COMMIT;
 
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TOTALS_MV', GETDATE(), NULL);
COMMIT;
ALTER INDEX ALL ON COVID_TOTALS_MV DISABLE; 
EXEC sp_refreshview N'COVID_TOTALS_MV';  
ALTER INDEX ALL ON COVID_TOTALS_MV REBUILD;
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TOTALS_MV', NULL, GETDATE());
COMMIT;
 
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TOTALS_DASHBOARD', GETDATE(), NULL);
COMMIT; 
EXEC COVID_TOTALS_DASHBOARD 99999;
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_TOTALS_DASHBOARD', NULL, GETDATE());
COMMIT;
  
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_IMAGING', GETDATE(), NULL);
COMMIT;
ALTER INDEX ALL ON COVID_IMAGING DISABLE;
EXEC sp_refreshview N'COVID_IMAGING';
ALTER INDEX ALL ON COVID_IMAGING REBUILD; 
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_IMAGING', NULL, GETDATE());
COMMIT;
 
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_LABS_RESULTS', GETDATE(), NULL);
COMMIT; 
ALTER INDEX ALL ON COVID_LABS_RESULTS DISABLE;
EXEC sp_refreshview N'COVID_LABS_RESULTS';
ALTER INDEX ALL ON COVID_LABS_RESULTS REBUILD;
INSERT INTO COVID_DAILY_LOG VALUES ('COVID_LABS_RESULTS', NULL, GETDATE()); 
COMMIT;

END;
GO
