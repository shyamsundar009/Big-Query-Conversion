CREATE OR REPLACE PROCEDURE COVID_DAILY


AS

  -- Author  : Yelena Chernyak
  -- Created : 3/26/2020

Begin
 Declare

start_dt date;--varchar2(30);
end_dt date;--varchar2(30) ;
cur_dt date; -- YC 2/12/2021

START_DATE date:= EPIC_UTIL.EFN_DIN('2/1/2020') ;
END_DATE date:= TRUNC(sysdate);

Begin

--If (iSTARTDATE is Null OR iENDDATE is NULL)  then      -- If iSTARTDATE and iENDDATE are null, and FileType is Combined, then use previous Sunday thru Saturday dates
  start_dt := START_DATE;
  end_dt := END_DATE;
/*Else                                                                                -- Else use the date parameters passed by crystal reports.
  start_dt:=EPIC_UTIL.EFN_DIN(iSTARTDATE);
  end_dt:=EPIC_UTIL.EFN_DIN(iENDDATE)+1;
End If;
*/
insert into COVID_DAILY_LOG values('COVID_COHORT_ALL_SOURCES',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_COHORT_ALL_SOURCES', method=>'cf', atomic_refresh=>false  );-- 8/25/21 YC added per Jackey's advice
insert into COVID_DAILY_LOG values('COVID_COHORT_ALL_SOURCES',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_COHORT',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_COHORT' , method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_COHORT',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ED_IMPRESSION',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ED_IMPRESSION', method=>'cf', atomic_refresh=>false );-- for TRACH labs  and may be for Chris
insert into COVID_DAILY_LOG values('COVID_ED_IMPRESSION',null,sysdate);commit;

---YC 7/17/2020 don't need it anymore DBMS_MVIEW.REFRESH( 'COVID_LDA_FOR_TOTALS');-- for totals - should be replaced later
insert into COVID_DAILY_LOG values('COVID_LABS',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_LABS', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_LABS',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_DIALYSIS_PROC',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_DIALYSIS_PROC', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_DIALYSIS_PROC',null,sysdate);commit;

 ---DBMS_MVIEW.REFRESH( 'COVID_DIALYSIS_PROC_ALL' );
insert into COVID_DAILY_LOG values('COVID_DIALYSIS_FLOW',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_DIALYSIS_FLOW', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_DIALYSIS_FLOW',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_VENT_FLOWSHEET',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_VENT_FLOWSHEET', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_VENT_FLOWSHEET',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_VENT_COMMENTS',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_VENT_COMMENTS', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_VENT_COMMENTS',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_vent_orders',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_vent_orders', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_vent_orders',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_soc_hx',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_soc_hx', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_soc_hx',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_Vaping',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_Vaping', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_Vaping',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ECMO',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ECMO', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_ECMO',null,sysdate);commit;

--insert into COVID_DAILY_LOG values('COVID_LDA',sysdate,null);commit;
--- DBMS_MVIEW.REFRESH( 'COVID_LDA'); -- for TRACH
--insert into COVID_DAILY_LOG values('COVID_LDA',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_TRACHEOSTOMY_COHORT',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_TRACHEOSTOMY_COHORT', method=>'cf', atomic_refresh=>false ); -- 4/28/2020
insert into COVID_DAILY_LOG values('COVID_TRACHEOSTOMY_COHORT',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_AIRWAY_MEASURES',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_AIRWAY_MEASURES', method=>'cf', atomic_refresh=>false  ); -- for TRACH
insert into COVID_DAILY_LOG values('COVID_AIRWAY_MEASURES',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_PL_DX',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_PL_DX', method=>'cf', atomic_refresh=>false  );
insert into COVID_DAILY_LOG values('COVID_PL_DX',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_MEDHX_DX',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_MEDHX_DX', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_MEDHX_DX',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ENC_DX',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ENC_DX', method=>'cf', atomic_refresh=>false );--
insert into COVID_DAILY_LOG values('COVID_ENC_DX',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_TRACH_LABS',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_TRACH_LABS', method=>'cf', atomic_refresh=>false );-- for TRACH
insert into COVID_DAILY_LOG values('COVID_TRACH_LABS',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_VITALS',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_VITALS', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_VITALS',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_O2_DEVICE_FLOWSHEET',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_O2_DEVICE_FLOWSHEET', method=>'cf', atomic_refresh=>false );-- for TRACH
insert into COVID_DAILY_LOG values('COVID_O2_DEVICE_FLOWSHEET',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ICU',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ICU', method=>'cf', atomic_refresh=>false ); -- just in case
insert into COVID_DAILY_LOG values('COVID_ICU',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ICU_BY_ACCOMODATION',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ICU_BY_ACCOMODATION', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_ICU_BY_ACCOMODATION',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_VENTFLOW_REINTUB',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_VENTFLOW_REINTUB', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_VENTFLOW_REINTUB',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_O2_VENT_REINTUB',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_O2_VENT_REINTUB', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_O2_VENT_REINTUB',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ICU_CURRENT',sysdate,null);commit;
  select max(t.update_date) into cur_dt from COVID_ICU_CURRENT t;
  if cur_dt not between trunc(sysdate) and sysdate then --2/12/2021 check if MV was refreshed today , if not then run refresh.
      DBMS_MVIEW.REFRESH( 'COVID_ICU_CURRENT', method=>'cf', atomic_refresh=>false ); -- for Dashbord - the current ICU state 10/19/2020 moved this refresh to Jackey's Dashboard job list
  end if;    
insert into COVID_DAILY_LOG values('COVID_ICU_CURRENT',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ALL_TESTS_FINAL_RESULT',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ALL_TESTS_FINAL_RESULT', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_ALL_TESTS_FINAL_RESULT',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_POS_SYMPTOMS_COHORT',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_POS_SYMPTOMS_COHORT', method=>'cf', atomic_refresh=>false ); -- Ryan's for reasearch
insert into COVID_DAILY_LOG values('COVID_POS_SYMPTOMS_COHORT',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_CT_CHEST',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_CT_CHEST', method=>'cf', atomic_refresh=>false ); -- YC 7/29 added per Angel's request
insert into COVID_DAILY_LOG values('COVID_CT_CHEST',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_ANTIBODY_TEST',sysdate,null);commit;
 DBMS_MVIEW.REFRESH( 'COVID_ANTIBODY_TEST', method=>'cf', atomic_refresh=>false ); -- YC 12/1/21 added per Chris's request
insert into COVID_DAILY_LOG values('COVID_ANTIBODY_TEST',null,sysdate);commit;


--- DBMS_MVIEW.REFRESH( 'COVID_CXR');-- for TRACH
------------
execute immediate 'grant select on COVID_DIALYSIS_PROC  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_DIALYSIS_PROC  to PAU_USER';
execute immediate 'grant select on COVID_COHORT  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_COHORT  to PAU_USER';
--execute immediate 'grant select on COVID_DIALYSIS_PROC_ALL  to DSSVI_TAB_USER';
--execute immediate 'grant select on COVID_DIALYSIS_PROC_ALL  to PAU_USER';
execute immediate 'grant select on COVID_PL_DX  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_PL_DX  to PAU_USER';
execute immediate 'grant select on COVID_DIALYSIS_FLOW  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_DIALYSIS_FLOW  to PAU_USER';
execute immediate 'grant select on COVID_vent_orders  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_vent_orders  to PAU_USER';
execute immediate 'grant select on COVID_ANTIBODY_TEST  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_ANTIBODY_TEST  to PAU_USER';

---------------------------
/*  moved to MV execute immediate 'Truncate table COVID_ALL_TESTS_FINAL_RESULT';
insert into COVID_ALL_TESTS_FINAL_RESULT
  select DISTINCT p.pat_mrn_id,op.pat_id,OP.PAT_ENC_CSN_ID,pe.hsp_account_id---,orr.ORD_VALUE
    ,op.order_proc_id
    ,case when (op.abnormal_yn='Y' or   RESULT_FLAG_C=2) and orr.ORD_VALUE is null then nvl(orr.ORD_VALUE,'PRESUMPTIVE POSITIVE') else orr.ORD_VALUE end ORD_VALUE
    ,nvl(op2.specimn_taken_date,op.result_time) specimn_taken_date--,op.ordering_date -- replace by result_date - for scanned results
    --4/6/2020 YC:
    ,pe.effective_date_dt contact_date
    ,zst.name LAB_STATUS,op.order_status_c,nvl(cc.name,op.description) name,op.result_time
    --, v.Revenue_Loc_Name
    ,case when op.order_class_c=45 then 'HISTORICAL' else v.catg end facility
    ---,op.order_type_c,op.PROC_ID
    from ORDER_PROC op
    join pat_enc pe on pe.pat_enc_csn_id=OP.PAT_ENC_CSN_ID
    left join hsp_account har on har.hsp_account_id=pe.hsp_account_id
    left join department_info_v v on v.department_id=pe.effective_dept_id
    join patient p on p.pat_id=op.pat_id
        --  and p.pat_id in ('Z8250904','Z7617279')
    join order_proc_2 op2 on op.order_proc_id=op2.order_proc_id ----and op.order_proc_id=364875872
    left join  ORDER_RESULTS orr on op.ORDER_PROC_ID = orr.ORDER_PROC_ID
    left join clarity_component cc on cc.component_id=orr.component_id
    join ZC_LAB_STATUS zst on zst.lab_status_c=op.lab_status_c
    --join ZC_ORDER_TYPE on ZC_ORDER_TYPE.ORDER_TYPE_C=op.order_type_c
    WHERE ---orr.ORD_VALUE in ( 'DETECTED', 'Detected', 'Positive', 'Presumptive Positive' ) and-- abnormal
      ORDER_INST > '01-feb-20' and
           op.PROC_ID in ( '688141','688142','688143','688327','688388','688087','688480' )-- YC 4/7/2020 added 688388
           and op.order_status_c in ( 5) -- completed
           and op.lab_status_c in (3,5) -- final
           and (
           (orr.ref_normal_vals is not null or upper(orr.ORD_VALUE) in ('PENDING','NOT-DETECTED')
           or upper(orr.ORD_VALUE) in ('DETECTED',  'POSITIVE', 'PRESUMPTIVE POSITIVE', 'NOT-DETECTED', 'NOT DETECTED' )) -- include valid results
           or op.abnormal_yn='Y'
           )
;
commit;
*/
execute immediate 'grant select on COVID_ALL_TESTS_FINAL_RESULT  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_ALL_TESTS_FINAL_RESULT  to PAU_USER';

/*
execute immediate 'Truncate table vitals_flo';

insert into vitals_flo
SELECT PAT_ID,pat_enc_csn_id
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN MEAS_VALUE END) SVO2
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN RECORDED_TIME END) SVO2_TIME

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_DESC = 1 THEN MEAS_VALUE END) * 0.0283495231 WEIGHT_KG_LAST_DOC
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END) * 0.0283495231 WEIGHT_KG_FIRST_DOC
  ,MIN(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' THEN MEAS_VALUE END) * 0.0283495231 WEIGHT_KG_MIN
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'HEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END) HEIGHT

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN MEAS_VALUE END) RESP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN MEAS_VALUE END) TEMP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP_SYSTOLIC
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP_DIASTOLIC
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN MEAS_VALUE END) BMI

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN RECORDED_TIME END) RESP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN RECORDED_TIME END) TEMP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_SYSTOLIC_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_DIASTOLIC_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN RECORDED_TIME END) BMI_TIME

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN MEAS_VALUE END) PULSE
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN RECORDED_TIME END) PULSE_TIME

from (
    SELECT FLO_MEAS_CATEGORIES.*
    ,ROW_NUMBER() OVER (PARTITION BY INPATIENT_DATA_ID, FLO_MEAS_CAT ORDER BY RECORDED_TIME ASC) RN_ASC
    ,ROW_NUMBER() OVER (PARTITION BY INPATIENT_DATA_ID, FLO_MEAS_CAT ORDER BY RECORDED_TIME DESC) RN_DESC

       FROM (
          SELECT IP_FLWSHT_REC.INPATIENT_DATA_ID,IP_FLWSHT_REC.PAT_ID,pat_enc_hsp.pat_enc_csn_id
          ,IP_FLWSHT_MEAS.FLO_MEAS_ID,IP_FLWSHT_MEAS.FSD_ID
          ,IP_FLWSHT_MEAS.RECORDED_TIME
          ,IP_FLWSHT_MEAS.MEAS_VALUE
          --,IP_FLO_GP_DATA.Disp_Name
          ,CASE
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('10','301390','301400','7096401','3041000687','2184','2185') THEN 'SVO2'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('14') THEN 'WEIGHT'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('301370','112000205') THEN 'CVP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('683030','1570490004','1572140203','1572140205') THEN 'SYSTOLIC_BP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('683022','1021000401','1572140204','1572140206') THEN 'DIASTOLIC_BP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('9') THEN 'RESP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('6','3040100959') THEN 'TEMP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('5') THEN 'BP'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('804863','10182','301070','4033')  THEN 'BMI'
            WHEN  IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('11','15206') THEN   'HEIGHT'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID in ('8') THEN 'PULSE'
          END FLO_MEAS_CAT
          FROM IP_FLWSHT_REC
          JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID ---and pat_enc_hsp.pat_enc_csn_id=786684519
             ---  and pat_enc_hsp.pat_id in ('Z1298348','Z1298581')

          JOIN COVID_COHORT ON pat_enc_hsp.PAT_ID = COVID_COHORT.pat_id  -----and pat_enc_hsp.pat_enc_csn_id=COVID_COHORT.CSN_ONADMISSION-- and SEP_POPUL.INPATIENT_DATA_ID=46185631
              ---- AND COVID_COHORT.PAT_MRN_ID='12603245'
          JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
         -- join IP_FLO_GP_DATA on IP_FLO_GP_DATA.FLO_MEAS_ID=IP_FLWSHT_MEAS.FLO_MEAS_ID
          WHERE RECORDED_TIME between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate) ----and IP_FLWSHT_REC.PAT_ID='Z1557833' and IP_FLWSHT_MEAS.FLO_MEAS_ID='10'
                and (IP_FLWSHT_MEAS.FLO_MEAS_ID in ('10','301390','301400','7096401','3041000687','2184','2185') -- SVO2
                OR IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('14') --WEIGHT
                OR IP_FLWSHT_MEAS.FLO_MEAS_ID in ('8') -- pulse 4/14/2020
               -- OR IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('301370','112000205') --CVP
                OR   IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042000602','1600100167') --MECH VENT --'3042001458',

                OR  IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('683030',--  CPM S18 R AS SYSTOLIC BP (MMHG)
                                            '1570490004',--  R ED CLINICAL CALCULATOR - SYSTOLIC BP < 90 MMHG AT TRIAGE
                                            '1572140203',--  R PED GIRLS SYSTOLIC BP PERCENTILE
                                            '1572140205'--  R PED BOYS SYSTOLIC BP PERCENTILE
                                            )
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('9') -- Resp
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('6','3040100959') -- temp
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('5') -- BP
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('683022',--  CPM S18 R AS DIASTOLIC BP (MMHG)
                                                 '1021000401',--  NYU R DIASTOLIC BLOOD PRESSURE
                                                '1572140204',--  R PED GIRLS DIASTOLIC BP PERCENTILE
                                                '1572140206'--  R PED BOYS DIASTOLIC BP PERCENTILE
                                                )
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('804863','10182','301070','4033','667418')  -- BMI
               or IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('11','15206')--   HEIGHT
               )
          and IP_FLWSHT_MEAS.MEAS_VALUE IS NOT NULL


        ) FLO_MEAS_CATEGORIES
) GROUP BY PAT_ID,pat_enc_csn_id ;
commit;


execute immediate 'truncate table Covid_vent_flo';

insert into Covid_vent_flo
SELECT PAT_ID,pat_enc_csn_id
 -- ,MAX(CASE WHEN FLO_MEAS_CAT = 'CVP' AND RN_ASC = 1 THEN RECORDED_TIME END) CVP_DTTM
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_MODE END) MECH_VENT_MODE
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE END) MECH_VENT_TYPE_DATE
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE END) MECH_VENT_TYPE
  ,MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE END) MECH_VENT_TYPE_LAST_DATE
  ,MAX(CASE WHEN MECH_VENT_CATG='INVASIVE' and RN_DESC = 1 THEN VENT_DAYS END) VENT_DAYS
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_MODE_NI END) MECH_VENT_MODE_NI
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE_NI END) MECH_VENT_TYPE_DATE_NI
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_NI END) MECH_VENT_TYPE_NI
  ,MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE_NI END) MECH_VENT_TYPE_LAST_DATE_NI
  ,MAX(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and RN_DESC = 1 THEN VENT_DAYS END) VENT_DAYS_NI

from (
    SELECT FLO_MEAS_CATEGORIES.*
    ,ROW_NUMBER() OVER (PARTITION BY INPATIENT_DATA_ID, FLO_MEAS_CAT,MECH_VENT_CATG ORDER BY RECORDED_TIME ASC) RN_ASC
    ,ROW_NUMBER() OVER (PARTITION BY INPATIENT_DATA_ID, FLO_MEAS_CAT,MECH_VENT_CATG ORDER BY RECORDED_TIME DESC) RN_DESC
    ,count( distinct vent_day )OVER (PARTITION BY INPATIENT_DATA_ID, MECH_VENT_CATG,FLO_MEAS_CAT )  VENT_DAYS
    ,(CASE WHEN MECH_VENT_CATG='INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_MODE' THEN MEAS_VALUE END)  MECH_VENT_MODE
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN RECORDED_TIME END)  MECH_VENT_TYPE_DATE
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN MEAS_VALUE END)  MECH_VENT_TYPE
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN RECORDED_TIME END)  MECH_VENT_TYPE_LAST_DATE
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_MODE' THEN MEAS_VALUE END)  MECH_VENT_MODE_NI
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN RECORDED_TIME END)  MECH_VENT_TYPE_DATE_NI
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN MEAS_VALUE END) MECH_VENT_TYPE_NI
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and FLO_MEAS_CAT = 'MECH_VENT_TYPE' THEN RECORDED_TIME END)  MECH_VENT_TYPE_LAST_DATE_NI

       FROM (
          SELECT IP_FLWSHT_REC.INPATIENT_DATA_ID,IP_FLWSHT_REC.PAT_ID,pat_enc_hsp.pat_enc_csn_id
          ,IP_FLWSHT_MEAS.FLO_MEAS_ID,IP_FLWSHT_MEAS.FSD_ID
          ,IP_FLWSHT_MEAS.RECORDED_TIME
          ,IP_FLWSHT_MEAS.MEAS_VALUE
          --,IP_FLO_GP_DATA.Disp_Name
          ,CASE WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042000602','1600100167') then
                 case when IP_FLWSHT_MEAS.MEAS_VALUE in ('V60','Bag-Valve-Mask','Philips Bi-Flex','Babi Plus') or IP_FLWSHT_MEAS.MEAS_VALUE like '%Other%' THEN 'NON-INVASIVE'
                   else 'INVASIVE' end end MECH_VENT_CATG
          ,CASE
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042001458') THEN 'MECH_VENT_MODE'
            WHEN IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042000602','1600100167','301030')  THEN 'MECH_VENT_TYPE'
           END FLO_MEAS_CAT
          ,case when IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042000602','1600100167') THEN trunc(IP_FLWSHT_MEAS.RECORDED_TIME) end vent_day
          FROM IP_FLWSHT_REC
          JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID ---and pat_enc_hsp.pat_enc_csn_id=786684519
          JOIN COVID_COHORT ON pat_enc_hsp.PAT_ID = COVID_COHORT.pat_id  ---and pat_enc_hsp.pat_enc_csn_id=COVID_COHORT.CSN_ONADMISSION-- and SEP_POPUL.INPATIENT_DATA_ID=46185631
              ---- AND COVID_COHORT.PAT_MRN_ID='12603245'
                         --    and pat_enc_hsp.pat_enc_csn_id in (787229122) --786747342,787215472,
          JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
          join IP_FLO_GP_DATA on IP_FLO_GP_DATA.FLO_MEAS_ID=IP_FLWSHT_MEAS.FLO_MEAS_ID
          WHERE RECORDED_TIME between start_dt and end_dt and ----and IP_FLWSHT_REC.PAT_ID='Z1557833' and IP_FLWSHT_MEAS.FLO_MEAS_ID='10'
                (IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('3042000602','1600100167')
                ---- or upper(IP_FLWSHT_MEAS.MEAS_VALUE) in ( 'VENTILATOR') and IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('301030' )
                 )  --O2 Device per Leora
                                                                                     --MECH VENT --'3042001458',
           and IP_FLWSHT_MEAS.MEAS_VALUE IS NOT NULL

        ) FLO_MEAS_CATEGORIES
) GROUP BY PAT_ID,pat_enc_csn_id
  ;
commit;
*/


execute immediate 'Truncate table COVID_CPR';

insert into COVID_CPR
select p.pat_mrn_id,p.pat_name,epi.pat_id,epi.pat_enc_csn_id,peh.hsp_account_id
, eei.event_time,ED_EVENT_TMPL_INFO.RECORD_NAME event_type
,row_number() over (partition by epi.pat_id,peh.hsp_account_id order by eei.event_time ASC ) RN_ASC
,row_number() over (partition by epi.pat_id,peh.hsp_account_id order by eei.event_time DESC ) RN_DESC
from ed_iev_PAT_info epi
join ed_iev_event_info eei  ON eei.event_id=epi.event_id
join pat_enc_hsp peh on peh.pat_enc_csn_id=epi.pat_enc_csn_id
join patient p on p.pat_id=peh.pat_id
join ED_EVENT_TMPL_INFO on ED_EVENT_TMPL_INFO.RECORD_ID=eei.event_type
join COVID_COHORT on COVID_COHORT.pat_id=epi.pat_id
where  eei.event_type in ('34380',--  CODE START
                          '34378',--  CODE RAPID RESPONSE START
                          '34370'---  RAPID RESPONSE START
                          )
AND (eei.event_status_c IS NULL OR eei.event_status_c NOT IN (2,3,6,7))
 and   eei.event_time between start_dt and end_dt  ;

commit;



/*execute immediate 'Truncate table COVID_vent_orders';

insert into  COVID_vent_orders  (
       select t.*
          ,row_number() over (partition by pat_id,hsp_account_id order by procedure_start,ORDER_TYPE ASC) ASC_RN
          ,row_number() over (partition by pat_id,hsp_account_id order by procedure_start,ORDER_TYPE DESC) DESC_RN
      from (
          select distinct op.pat_id,har.hsp_account_id
          ,nvl(op.proc_start_time,op.instantiated_time) procedure_start
          ,case when op.PROC_ID = 423920 then 'INV_VENT'
               when op.PROC_ID in ( 72364, 38849, 69233, 68661,336574 ) then 'INTUB'
               when op.PROC_ID = 423921 then 'NONINV_VENT'
               when op.PROC_ID in ( 38847 ) then 'EXTUB'
                 end ORDER_TYPE
          ,op.description  procedure
          from order_proc op
          join COVID_COHORT cc on cc.pat_id=op.pat_id ----and cc.pat_id='Z5215330'
          join patient p on cc.pat_id=p.pat_id ----and p.pat_mrn_id in ('12436715')
          join clarity_eap eap on eap.proc_id=op.proc_id
          join pat_enc pe on pe.pat_enc_csn_id=op.pat_enc_csn_id -- link to pat_enc -- not to loose anesth. encounters
          join hsp_account har on har.hsp_account_id=pe.hsp_account_id
          where OP.ORDER_STATUS_C=5--(OP.ORDER_STATUS_C <> 4 OR OP.ORDER_STATUS_C IS NULL)
                and (op.PROC_ID = 423920 -- INVASIVE MECHANICAL VENTILATION
                or op.PROC_ID = 423921 -- NONINVASIVE MECHANICAL VENTILATION
                or op.PROC_ID in ( 72364, 38849, 69233, 68661, 336574 ) -- INTUBATION ORDERS (336574 this is the anesthesia orders)
                or op.PROC_ID = 38847 -- extubation
                )
           and op.instantiated_time >= to_date('2/1/2020','mm/dd/yyyy')
         ----  and har.hsp_account_id=14917164
     ) t
     );

     commit;

*/



----------------------
insert into COVID_DAILY_LOG values('COVID_REPORT_FULL',sysdate,null);commit;

execute immediate 'Truncate table COVID_REPORT_I';

insert into COVID_REPORT_I
with ecmo as (
SELECT IP_FLWSHT_REC.PAT_ID,pat_enc_hsp.pat_enc_csn_id,
  min(RECORDED_TIME) from_date
 ,max(RECORDED_TIME)  to_date
 ,max(case when IP_FLWSHT_MEAS.FLO_MEAS_ID in ('304010099809','3040100998') then to_number(IP_FLWSHT_MEAS.MEAS_VALUE) end)  ecmo_hours
 ,max(case when IP_FLWSHT_MEAS.FLO_MEAS_ID in ('3041530236') then IP_FLWSHT_MEAS.MEAS_VALUE end ) ecmo_type
  FROM IP_FLWSHT_REC
  JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID  ----and pat_enc_hsp.INPATIENT_DATA_ID=70737774
  join COVID_COHORT on COVID_COHORT.pat_id=pat_enc_hsp.pat_id
  JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
  join IP_FLO_GP_DATA  gd on gd.flo_meas_id= IP_FLWSHT_MEAS.flo_meas_id
  WHERE IP_FLWSHT_MEAS.FLO_MEAS_ID  IN ('304010099809','3040100998','304101003','3041530236') --
        and IP_FLWSHT_MEAS.RECORDED_TIME between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate)
    ---    and IP_FLWSHT_REC.INPATIENT_DATA_ID=69777074
 group by   IP_FLWSHT_REC.PAT_ID,pat_enc_hsp.pat_enc_csn_id

)
, Covid_vent_flo as(
SELECT PAT_ID,pat_enc_csn_id
 -- ,MAX(CASE WHEN FLO_MEAS_CAT = 'CVP' AND RN_ASC = 1 THEN RECORDED_TIME END) CVP_DTTM
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE END) MECH_VENT_TYPE_DATE
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE END) MECH_VENT_TYPE
  ,MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE END) MECH_VENT_TYPE_LAST_DATE
  ,MAX(CASE WHEN MECH_VENT_CATG='INVASIVE' and RN_DESC = 1 THEN VENT_DAYS END) VENT_DAYS
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_DATE_NI END) MECH_VENT_TYPE_DATE_NI
  ,MAX(CASE WHEN RN_ASC = 1 THEN MECH_VENT_TYPE_NI END) MECH_VENT_TYPE_NI
  ,MAX(CASE WHEN RN_DESC = 1 THEN MECH_VENT_TYPE_LAST_DATE_NI END) MECH_VENT_TYPE_LAST_DATE_NI
  ,MAX(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' and RN_DESC = 1 THEN VENT_DAYS END) VENT_DAYS_NI

from (
    SELECT flo.pat_id, flo.pat_enc_csn_id, flo.hsp_account_id
    ,asc_rn  RN_ASC
    ,desc_rn  RN_DESC
    ,sum(vent_days ) over ( partition by flo.pat_id,flo.pat_enc_csn_id, flo.hsp_account_id ,MECH_VENT_CATG) vent_days
    ,MECH_VENT_CATG
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE'  THEN vent_first_date  END)  MECH_VENT_TYPE_DATE
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE' THEN vent_type  END)  MECH_VENT_TYPE
   ,(CASE WHEN MECH_VENT_CATG='INVASIVE' THEN vent_last_date  END)  MECH_VENT_TYPE_LAST_DATE
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_first_date  END)  MECH_VENT_TYPE_DATE_NI
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_type  END) MECH_VENT_TYPE_NI
   ,(CASE WHEN MECH_VENT_CATG='NON-INVASIVE' THEN vent_last_date  END)  MECH_VENT_TYPE_LAST_DATE_NI
           FROM COVID_VENT_FLOWSHEET flo
           JOIN COVID_COHORT ON flo.PAT_ID = COVID_COHORT.pat_id  ---and pat_enc_hsp.pat_enc_csn_id=COVID_COHORT.CSN_ONADMISSION-- and SEP_POPUL.INPATIENT_DATA_ID=46185631
              ---- AND COVID_COHORT.PAT_MRN_ID='12603245'

) GROUP BY PAT_ID,pat_enc_csn_id
)
,vitals_flo as (
SELECT PAT_ID,pat_enc_csn_id
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN MEAS_VALUE END) SVO2
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SVO2' AND RN_ASC = 1 THEN RECORDED_TIME END) SVO2_TIME

  ,round(MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_DESC = 1 THEN MEAS_VALUE END),2)  WEIGHT_KG_LAST_DOC
  ,round(MAX(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END),2)  WEIGHT_KG_FIRST_DOC
  ,round(MIN(CASE WHEN FLO_MEAS_CAT = 'WEIGHT' THEN MEAS_VALUE END),2)  WEIGHT_KG_MIN
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'HEIGHT' AND RN_ASC = 1 THEN MEAS_VALUE END) HEIGHT

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN MEAS_VALUE END) RESP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN MEAS_VALUE END) TEMP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP_SYSTOLIC
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP_DIASTOLIC
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN MEAS_VALUE END) BP
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN MEAS_VALUE END) BMI

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'RESP' AND RN_ASC = 1 THEN RECORDED_TIME END) RESP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'TEMP' AND RN_ASC = 1 THEN RECORDED_TIME END) TEMP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'SYSTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_SYSTOLIC_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'DIASTOLIC_BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_DIASTOLIC_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BP' AND RN_ASC = 1 THEN RECORDED_TIME END) BP_TIME
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'BMI' AND RN_ASC = 1 THEN RECORDED_TIME END) BMI_TIME

  ,MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN MEAS_VALUE END) PULSE
  ,MAX(CASE WHEN FLO_MEAS_CAT = 'PULSE' AND RN_ASC = 1 THEN RECORDED_TIME END) PULSE_TIME

from (
    SELECT vi.pat_id, vi.pat_enc_csn_id, vi.hsp_account_id
    , RN_ASC
    , RN_DESC
          ,FLO_MEAS_ID,FSD_ID
          ,RECORDED_TIME
          ,MEAS_VALUE
          ,FLO_MEAS_CAT
          FROM COVID_VITALS vi
) GROUP BY PAT_ID,pat_enc_csn_id
)
,icu as (
select pat_id,pat_enc_csn_id
,from_time
,nvl(to_time,trunc(sysdate)) to_time
,round(coalesce(to_time,hosp_disch_time,trunc(sysdate))-from_time ,2) in_days
from (
select distinct adt.pat_id,adt.pat_enc_csn_id
     ,min(adt.effective_time)  from_time
     ,max(adt.effective_time)  max_ICU_to_time
     ,case when max(adt.effective_time) > max(adt2.effective_time ) then null
           else max(case when adt1.event_type_c=2 then adt1.effective_time else adt2.effective_time end )  end to_time
     ,max(hosp_disch_time) hosp_disch_time
 /*    select adt.pat_id,adt.pat_enc_csn_id Z4779011
     ,min(adt.effective_time) from_time
     ,nvl(max(adt2.effective_time),trunc(sysdate)) to_time
     ,sum(nvl(max(adt2.effective_time),trunc(sysdate))-min(adt.effective_time)) over (partition by adt.pat_id,adt.pat_enc_csn_id) in_days -- YC 4/6/2020
 */
    from CLARITY_ADT ADT
    join pat_enc_hsp peh on adt.pat_enc_csn_id=peh.pat_enc_csn_id ---and peh.pat_id='Z4779011'
     JOIN COVID_COHORT on  adt.pat_id =COVID_COHORT.pat_id and adt.accommodation_c in ('10003','10010')
          and adt.effective_time between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(nvl(peh.hosp_disch_time,sysdate))
     join ZC_PAT_SERVICE zs on zs.hosp_serv_c=adt.pat_service_c
     left JOIN CLARITY_ADT ADT1 on  adt1.pat_id =COVID_COHORT.pat_id and adt.next_out_event_id=adt1.event_id and adt1.event_subtype_c<>2
     left JOIN CLARITY_ADT ADT2 on  adt2.pat_id =COVID_COHORT.pat_id and adt1.xfer_in_event_id=adt2.event_id and adt2.event_subtype_c<>2
         and (adt1.event_type_c =2 or adt2.accommodation_c not in ('10003','10010'))
     where adt.event_subtype_c<>2
     group by adt.pat_id,adt.pat_enc_csn_id
     )
)
--4/6/2020 YC
,icu_by_service as (
select pat_id,pat_enc_csn_id,hsp_account_id
,from_time
,first_service
,coalesce(to_time,hosp_disch_time,trunc(sysdate)) to_time
,round(coalesce(to_time,hosp_disch_time,trunc(sysdate))-from_time ,2) in_days
from (
select distinct adt.pat_id,adt.pat_enc_csn_id,peh.hsp_account_id
     ,min(adt.effective_time)  from_time
     ,max(adt.effective_time)  max_ICU_to_time
     ,max(zs.name)  KEEP (DENSE_RANK FIRST ORDER BY adt.effective_time) first_service
     ,case when max(adt.effective_time) > max(adt2.effective_time ) then null
           else max(case when adt1.event_type_c=2 then adt1.effective_time else adt2.effective_time end )  end  to_time
/*  select distinct adt.pat_id,adt.pat_enc_csn_id--,d.department_name,r.room_name,zet.name event ,za.name accom,adt.effective_time
     ,min(adt.effective_time) from_time
     ,max(zs.name)  KEEP (DENSE_RANK FIRST  ORDER BY adt.effective_time) first_service
     ,nvl(max(adt2.effective_time),trunc(sysdate)) to_time
     ,sum(nvl(max(adt2.effective_time),trunc(sysdate))-min(adt.effective_time)) over (partition by adt.pat_id,adt.pat_enc_csn_id) in_days
    */
  --  ,adt1.event_id,adt1.effective_time
    ,max(hosp_disch_time) hosp_disch_time

    from CLARITY_ADT ADT
    join pat_enc_hsp peh on adt.pat_enc_csn_id=peh.pat_enc_csn_id
    join patient p on adt.pat_id = p.pat_id --and      p.pat_id='Z6019706'
    join zc_accommodation za on za.accommodation_c=adt.accommodation_c
    join clarity_dep d on d.department_id=adt.department_id
    join clarity_rom r on r.room_id=adt.room_id
    join ZC_EVENT_TYPE zet on zet.event_type_c=adt.event_type_c
    join ZC_PAT_SERVICE zs on zs.hosp_serv_c=adt.pat_service_c

     JOIN COVID_COHORT on  adt.pat_id =COVID_COHORT.pat_id

     left JOIN CLARITY_ADT ADT1 on  adt1.pat_id =p.pat_id and adt.next_out_event_id=adt1.event_id and adt1.event_subtype_c<>2
     left JOIN CLARITY_ADT ADT2 on  adt2.pat_id =p.pat_id and adt1.xfer_in_event_id=adt2.event_id and adt2.event_subtype_c<>2
                and (adt1.event_type_c=2
                or ( ---adt.accommodation_c not in ('10003','10010')
                 adt2.pat_service_c  not in (  '212',--  Pediatric Critical Care
                  '219',--  Surgical Critical Care
                  '111',--  Medicine, Critical Care
                  '310008',--  Medicine, Pulmonary (Medicine, Critical Care)
                  '310015',--  Surgery, Critical Care (Anesthesiology, Pain Management)
                  '310023',--  Neurology, Critical Care (Neurology)
                  '310060',--  Pediatrics, Critical Care
                  '310062' --  Medicine, Cardiology Critical Care
                  )
                  ) )

    where adt.event_subtype_c<>2
       and adt.effective_time between EPIC_UTIL.EFN_DIN('3/1/2020') and TRUNC(nvl(peh.hosp_disch_time,sysdate))
       --and adt.accommodation_c not in ('10003','10010')
                  and adt.pat_service_c in (  '212',--  Pediatric Critical Care
                  '219',--  Surgical Critical Care
                  '111',--  Medicine, Critical Care
                  '310008',--  Medicine, Pulmonary (Medicine, Critical Care)
                  '310015',--  Surgery, Critical Care (Anesthesiology, Pain Management)
                  '310023',--  Neurology, Critical Care (Neurology)
                  '310060',--  Pediatrics, Critical Care
                  '310062' --  Medicine, Cardiology Critical Care
                  )
   group by adt.pat_id,adt.pat_enc_csn_id ,peh.hsp_account_id
   )
  )
/*,soc_hx as (
 SELECT DISTINCT hx.pat_id,
      max(hx.contact_date) contact_date,
      max(HX.tobacco_pak_per_dy) tobacco_pak_per_dy,
 --     hx.smoking_tob_use_c,
      max(hx.tobacco_used_years) tobacco_used_years,
      max(hx.smoking_quit_date) smoking_quit_date,
      max(ZC_TOBACCO_USER.name) ZC_TOBACCO_USER
      ,max(hx.alcohol_oz_per_wk) alcohol_oz_per_wk
      ,max(hx.alcohol_comment) alcohol_comment
    FROM   social_hx hx
    JOIN   COVID_COHORT  ON COVID_COHORT.pat_id   =hx.pat_id
      --   AND hx.contact_date=(select max(hx1.contact_date) from social_hx hx1
    left join ZC_TOBACCO_USER on ZC_TOBACCO_USER.TOBACCO_USER_C =hx.tobacco_user_c
    group by hx.pat_id
    )*/
/*,Vaping as (
select * from (
select COVID_COHORT.pat_id,sd.SMRTDTA_ELEM_VALUE Vaping
,row_number() over (partition by sd.RECORD_ID_VARCHAR order by sd.VALUE_UPDATE_DTTM desc) rn
from COVID_COHORT
join V_SMRTDTA_ELEM_VAL_ALL sd on sd.RECORD_ID_VARCHAR=COVID_COHORT.pat_id
where sd.ELEMENT_ID='EPIC#50170'    ) where rn=1
)*/
,homeless as(
select distinct enc4.pat_id, enc4.pat_homeless_typ_c,hom.name,enc4.contact_date,enc4.pat_homeless_yn
      from COVID_COHORT
      join pat_enc_4 enc4 on enc4.pat_id=COVID_COHORT.pat_id
      join pat_enc pe on pe.pat_enc_csn_id=enc4.pat_enc_csn_id
      left outer join zc_pat_homeless_ty hom on enc4.pat_homeless_typ_c=hom.pat_homeless_ty_c
      where enc4.pat_enc_csn_id in (select max(pat_enc_csn_id) from pat_enc_4 pe4 -- YC 12/2/2016 - changed for the first enc in the year
                where pe4.pat_id=enc4.pat_id and pe4.contact_date between EPIC_UTIL.EFN_DIN('yb-1') and sysdate
                and pat_homeless_yn  is not null
                    )
      )

,symp_visit as (
 select distinct rsn.pat_enc_csn_id, cast(LISTAGG(reason_visit_name||case when rsn.comments is not null then '-'||rsn.comments end, ';' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY reason_visit_name) as varchar2(2000)) AS symptoms
from COVID_COHORT cc
join PAT_ENC_RSN_VISIT rsn on cc.pat_id=rsn.pat_id
join   CL_RSN_FOR_VISIT clr on clr.reason_visit_id=rsn.enc_reason_id
---where cc.csn_onadmission=767920114
---CROSS JOIN (SELECT level FROM dual CONNECT BY level <= 1000)
group by rsn.pat_enc_csn_id
)

,symp_adm as (
select distinct adx.pat_enc_csn_id, cast(LISTAGG(edg.dx_name||case when adx.admit_diag_text is not null then '-'||adx.admit_diag_text end, ';' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY adx.line) as varchar2(2000)) AS symptoms
from COVID_COHORT cc
join HSP_ADMIT_DIAG adx on cc.pat_id=adx.pat_id --HSP_ADMIT_DIAG
join clarity_edg edg on edg.dx_id=adx.dx_id
---where cc.csn_onadmission=767920114
---CROSS JOIN (SELECT level FROM dual CONNECT BY level <= 1000)
group by adx.pat_enc_csn_id
)
---YC 4/6/2020 YC:
,o2_therapy_flo as (
  SELECT INPATIENT_DATA_ID,PAT_ID,pat_enc_csn_id
   ,MAX(case when RN_ASC=1 then OXYGEN_DEVICE end) OXYGEN_DEVICE_INIT
   ,MAX(case when RN_ASC=1 then RECORDED_TIME end) O2_TIME_INIT
   ,MAX(case when RN_ASC=1 then O2_FLOW_RATE end) O2_FLOW_RATE_INIT
   ,MAX(O2_FLOW_RATE_MAX)   KEEP (DENSE_RANK FIRST  ORDER BY RECORDED_TIME  ) AS O2_FLOW_RATE_MAX
   ,MAX(O2_FLOW_RATE_AVG)   KEEP (DENSE_RANK FIRST  ORDER BY RECORDED_TIME  ) AS O2_FLOW_RATE_AVG
   ,MAX(CASE WHEN t.O2_FLOW_RATE = t.O2_FLOW_RATE_MAX then t.OXYGEN_DEVICE end) OXYGEN_DEVICE_MAX
   ,MAX(case when RN_ASC=1 then FiO2 end) FiO2_INIT
   ,MAX(FiO2_MAX)   KEEP (DENSE_RANK FIRST  ORDER BY RECORDED_TIME  ) AS FiO2_MAX
   ,MAX(FiO2_AVG)   KEEP (DENSE_RANK FIRST  ORDER BY RECORDED_TIME  ) AS FiO2_AVG
   ,MAX(CASE WHEN t.FiO2 = t.FiO2_MAX then t.OXYGEN_DEVICE end) OXYGEN_DEVICE_FiO2_MAX
  from (
          SELECT IP_FLWSHT_REC.INPATIENT_DATA_ID,IP_FLWSHT_REC.PAT_ID,pat_enc_hsp.pat_enc_csn_id
    ,ROW_NUMBER() OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID ORDER BY m1.RECORDED_TIME ASC) RN_ASC
    ,ROW_NUMBER() OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID ORDER BY m1.RECORDED_TIME DESC) RN_DESC
          ,m1.RECORDED_TIME
          ,m1.MEAS_VALUE OXYGEN_DEVICE
          ,m2.MEAS_VALUE O2_FLOW_RATE
          ,m3.MEAS_VALUE FiO2
          ,max(to_number(m2.MEAS_VALUE)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) O2_FLOW_RATE_MAX
          ,max(to_number(m3.MEAS_VALUE)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) FiO2_MAX
          ,AVG(to_number(m2.MEAS_VALUE)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) O2_FLOW_RATE_AVG
          ,AVG(to_number(m3.MEAS_VALUE)) OVER (PARTITION BY IP_FLWSHT_REC.INPATIENT_DATA_ID) FiO2_AVG
          FROM IP_FLWSHT_REC
          JOIN pat_enc_hsp ON IP_FLWSHT_REC.INPATIENT_DATA_ID = pat_enc_hsp.INPATIENT_DATA_ID ---and pat_enc_hsp.pat_enc_csn_id=786684519
          JOIN COVID_COHORT ON pat_enc_hsp.PAT_ID = COVID_COHORT.pat_id  ---and pat_enc_hsp.pat_enc_csn_id=COVID_COHORT.CSN_ONADMISSION-- and SEP_POPUL.INPATIENT_DATA_ID=46185631
            --   AND COVID_COHORT.PAT_MRN_ID='13904481'
          left join Covid_vent_flo vent_flo on pat_enc_hsp.pat_enc_csn_id =vent_flo.pat_enc_csn_id
          JOIN IP_FLWSHT_MEAS m1 ON IP_FLWSHT_REC.FSD_ID = m1.FSD_ID -- device
               and m1.MEAS_VALUE IS NOT NULL
               and m1.FLO_MEAS_ID IN (
                                         '301030',--R OXYGEN DEVICE
                                         '16055'  ,--R ED OXYGEN DEVICE
                                         '3041530321'  ,--NYU R TC PED O2 DEVICE
                                         '30430103001'  ,--NYU R TC OXYGEN DEVICE
                                         '4212'  --R OXYGEN DEVICE [COMPILED RECORD] [FLT ID 1603100001]
                                          )
          left JOIN IP_FLWSHT_MEAS m2 ON IP_FLWSHT_REC.FSD_ID = m2.FSD_ID -- O2 flow rate
               and m1.recorded_time=m2.recorded_time and   m2.MEAS_VALUE IS NOT NULL
               and m2.FLO_MEAS_ID IN (--'3041562004'
                                         '250026',--  R OXYGEN FLOW RATE
                                         '500690'--R IP O2 FLOW RATE
                                          )
          left JOIN IP_FLWSHT_MEAS m3 ON IP_FLWSHT_REC.FSD_ID = m3.FSD_ID -- FiO2 flow rate
               and m1.recorded_time=m3.recorded_time and   m3.MEAS_VALUE IS NOT NULL
               and m3.FLO_MEAS_ID IN ( '3042001465',--FiO2
                                      '3041562020',--FiO2
                                      '301550' --FiO2
                 )

                 --  join IP_FLO_GP_DATA on IP_FLO_GP_DATA.FLO_MEAS_ID=IP_FLWSHT_MEAS.FLO_MEAS_ID
        --  join IP_FLT_DATA on IP_FLT_DATA.TEMPLATE_ID=IP_FLWSHT_MEAS.FLT_ID
          WHERE m1.RECORDED_TIME between EPIC_UTIL.EFN_DIN('2/1/2020') and nvl(vent_flo.mech_vent_type_date,TRUNC(sysdate)) and----and IP_FLWSHT_REC.PAT_ID='Z1557833'
           (   m2.MEAS_VALUE IS NOT NULL or  m3.MEAS_VALUE IS NOT NULL)
          --IP_FLWSHT_MEAS.FLO_MEAS_ID='660452' and IP_FLWSHT_MEAS.MEAS_VALUE='tracheostomy' FLT '680621' - LDA
         -- and pat_enc_hsp.pat_enc_csn_id=787072727-- or pat_enc_hsp.pat_id='Z7676003')

 ) t group by INPATIENT_DATA_ID,PAT_ID,pat_enc_csn_id
)
,prone_on_floor as (
--select * from (
select peh.pat_id,peh.pat_enc_csn_id,peh.hsp_account_id
 ,max(IP_FLWSHT_MEAS.MEAS_VALUE) MEAS_VALUE
 ,min(IP_FLWSHT_MEAS.RECORDED_TIME) first_prone_date
 ,max(IP_FLWSHT_MEAS.RECORDED_TIME) last_prone_date
-- ,row_number() over (partition by  peh.pat_id,peh.pat_enc_csn_id,peh.hsp_account_id order by IP_FLWSHT_MEAS.RECORDED_TIME) rn

       FROM IP_FLWSHT_REC
          JOIN pat_enc_hsp peh ON IP_FLWSHT_REC.INPATIENT_DATA_ID = peh.INPATIENT_DATA_ID
             ---  and pat_enc_hsp.pat_enc_csn_id=786668718
          join covid_cohort cc on cc.pat_id=peh.pat_id ---and cc.pat_id='Z1004244'
          --left  join COVID_ICU on COVID_ICU.PAT_ID=cc.pat_id
          JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
       --   join IP_FLO_GP_DATA on IP_FLO_GP_DATA.FLO_MEAS_ID=IP_FLWSHT_MEAS.FLO_MEAS_ID
          WHERE RECORDED_TIME between to_date('2/1/2020','mm/dd/yyyy') and TRUNC(sysdate) and
            /*    1= (case when COVID_ICU.ICU_TO_TIME is not null and RECORDED_TIME>COVID_ICU.ICU_FROM_TIME then 1
                         when COVID_ICU.ICU_TO_TIME is null then 1
                       else 0 end ) and*/
                IP_FLWSHT_MEAS.FLO_MEAS_ID='803340' and
                lower(IP_FLWSHT_MEAS.MEAS_VALUE) in ('prone')
 group by peh.pat_id,peh.pat_enc_csn_id,peh.hsp_account_id
                       --   ) t where t.rn=1
)
,airway_measures as (
select * from (select pat_enc_csn_id,flo_meas_cat
,recorded_time
,meas_value
,max_recorded_time
,max_meas_value
from (
select t.*
,min(case when meas_value=max_meas_value then recorded_time end) over (partition by pat_enc_csn_id,flo_meas_cat) max_recorded_time
,row_number() over (partition by pat_enc_csn_id,flo_meas_cat order by RECORDED_TIME ) ASC_RN
from (
select air.pat_enc_csn_id,flo_meas_cat
,case when is_number(air.meas_value)=1 then to_number(air.meas_value) end meas_value
,max(case when is_number(air.meas_value)=1 then to_number(air.meas_value) end) over (partition by air.pat_enc_csn_id,flo_meas_cat ) max_meas_value
,air.recorded_time
from COVID_AIRWAY_MEASURES air
where air.flo_meas_cat in ('PEEP','MSOFA_SCORE','HIGH_TV')
) t
) where asc_rn=1
)
PIVOT (
max(recorded_time) first_recorded_time
,max(meas_value) first_value
,max(max_recorded_time) max_recorded_time
,max(max_meas_value) max_value
    FOR flo_meas_cat IN ('PEEP' as PEEP,'MSOFA_SCORE' as MSOFA,'HIGH_TV' as TV)
)

)

--------------main-------
-- 4/7/2020 added a lot of columns:
select zd.name enc_type
,t.* from (
select distinct
p.pat_mrn_id "MRN"
,nvl(har.prim_enc_csn_id , pe.pat_enc_csn_id) "CSN" --,COVID_COHORT.pat_enc_csn_id
,har.hsp_account_id "HAR" --,COVID_COHORT.hsp_account_id
,p.pat_name "Patient Name"
,COVID_COHORT.specimn_taken_date "Date Tested"
,COVID_COHORT.ORD_VALUE "Result (Positive / Negative)"
,case when har.hsp_account_id is not null then har.adm_date_time else pe.effective_date_dt end "Admission/Arrival Date"
,zarr.name "Arrival Info (home, ambulance, transfer)"
,nvl(zpcA.name,zpcH.name) "Admission Status"
,zpc.name "Current Patient Class"
,bed.bed_label "Bed"
,room.room_name "Room"
,v.department_name "Department"
,v.catg "Facility"
,zdc.name "Discharge Status (or if still admitted leave blank)*"
,ZC_PAT_LIVING_STAT.name||case when ZC_PAT_LIVING_STAT.PAT_LIVING_STAT_C=2 then ' as of '||to_char(p.death_date,'mm/dd/yy') end "Patient Status"
,case when har.hsp_account_id is not null then har.disch_date_time end "Discharge Date*"
,case when har.disch_date_time  is not null then zdd.name  end "Discharge destination / disposition*" --zddh.name
,rr.race "Race"
,gr2.name "Ethnic Group (Hispanic/Non-Hispanic)"
,zss.name "Gender"
,p.birth_date "Age/DOB"
,case when pe.lmp_other_c=4 then 'Y' end "Pregnant?"
,homeless.pat_homeless_yn "Homeless?"
,max(pe.bmi) over (partition by pe.pat_id) BMI
,soc_hx.ZC_TOBACCO_USER "Smoking"
,soc_hx.tobacco_pak_per_dy "Pack per day"
,soc_hx.tobacco_used_years "Years used"
,vaping.Vaping "Vaping"
,replace ((case when soc_hx.alcohol_oz_per_wk is not null then 'oz per wk:'||soc_hx.alcohol_oz_per_wk end ||
      case when soc_hx.alcohol_comment is not null then 'alcohol comment:'||soc_hx.alcohol_comment end ),'"','')
      as "Alcohol History"
,icu.in_icu_time  "Was patient ever ICU status (date of transfer to ICU)"
,round(icu.total_days_per_stay ,2) "Duration of ICU stay"
,case when vent_flo.MECH_VENT_TYPE is not null then to_char(vent_flo.MECH_VENT_TYPE_DATE,'mm/dd/yyyy')||' - '||vent_flo.MECH_VENT_TYPE end "Was patient ever on ventilator" --(Mechanical invasive or Noninvasive, need to specify)
,to_char(vent_flo.VENT_DAYS) "Duration of mechancial ventilation"
,ecmo.ecmo_hours "ECMO duration(hours)"
,ecmo.from_date "ECMO Date"
,labs."Lymphocytes abs"
,labs."Neutrophils abs"
/*,case when peA.temperature is not null then to_char(peA.temperature) else vitals_flo.temp end "Temperature"
,case when peA.bp_systolic is not null then to_char(peA.bp_systolic) else
      case when vitals_flo.bp is not null then substr(vitals_flo.bp,1,instr(vitals_flo.bp,'/')-1)
        else vitals_flo.BP_SYSTOLIC   end end "bp_systolic"

,case when peA.bp_diastolic is not null then to_char(peA.bp_diastolic) else
       case when vitals_flo.bp is not null then substr(vivitals_flotals_flo.bp,instr(vitals_flo.bp,'/')+1)
         else vitals_flo.BP_diastolic  end end "bp_diastolic"
,case when peA.Respirations is  null then vitals_flo.resp else to_char(peA.Respirations) end "Resp.Rate"
,case when peA2.PHYS_SPO2 is null then vitals_flo.SVO2 else to_char(peA2.PHYS_SPO2) end "SVO2"
*/
,case when vitals_flo.temp is not null then vitals_flo.temp_time
      when peA.temperature is not null then peA2.VITALS_TAKEN_TM end "temp_time"
,case when vitals_flo.temp is not null then vitals_flo.temp
      when peA.temperature is not null then to_char(peA.temperature) end "Temperature"

,case when vitals_flo.BP_SYSTOLIC is not null then vitals_flo.BP_SYSTOLIC_TIME
      when vitals_flo.bp is not null then vitals_flo.bp_time
      when peA.bp_systolic is not null then peA2.VITALS_TAKEN_TM end  "bp_time"
,case when vitals_flo.BP_SYSTOLIC is not null then vitals_flo.BP_SYSTOLIC
      when vitals_flo.bp is not null then substr(vitals_flo.bp,1,instr(vitals_flo.bp,'/')-1)
      when peA.bp_systolic is not null then to_char(peA.bp_systolic) end  "bp_systolic"
,case when vitals_flo.BP_diastolic is not null then vitals_flo.BP_diastolic
      when vitals_flo.bp is not null then substr(vitals_flo.bp,instr(vitals_flo.bp,'/')+1)
      when peA.bp_diastolic is not null then to_char(peA.bp_diastolic) end "bp_diastolic"

,case when vitals_flo.resp is not null then vitals_flo.resp_time
      when peA.Respirations is  null then peA2.VITALS_TAKEN_TM end "Resp_time"
,case when vitals_flo.resp is not null then vitals_flo.resp
      when peA.Respirations is  null then to_char(peA.Respirations) end "Resp.Rate"

,case when vitals_flo.SVO2 is not null then vitals_flo.SVO2_time
      when peA2.PHYS_SPO2 is null then peA2.VITALS_TAKEN_TM end "SVO2_time"
,case when vitals_flo.SVO2 is not null then vitals_flo.SVO2
      when peA2.PHYS_SPO2 is null then to_char(peA2.PHYS_SPO2) end "SVO2"

,nvl(symp_adm.symptoms,symp_visit.symptoms) "Symptoms"
--,ZC_TX_CURRENT_STAG.NAME "Transplant"
,tt.stage "Transplant"
,zs.name "Infection Status"
---,row_number() over (partition by p.pat_id,icu.in_days,vent.VENT_TYPE,vent.VENT_DAYS,har.hsp_account_id order by pe.pat_enc_csn_id desc) rn
,case when har.hsp_account_id is null then 'y' --- COVID_COHORT 2/10/2021
      when har.hsp_account_id is not null and har.prim_enc_csn_id= pe.pat_enc_csn_id then 'y'
        end is_include
,pe.enc_type_c
,(sysdate) update_date
,case when vent_flo.MECH_VENT_TYPE_NI is not null then to_char(vent_flo.MECH_VENT_TYPE_DATE_NI,'mm/dd/yyyy')||' - '||vent_flo.MECH_VENT_TYPE_NI end "Non-invasive ventilator" --(Mechanical invasive or Noninvasive, need to specify)
,to_char(vent_flo.VENT_DAYS_NI) "Duration of non-invasive ventilation"

,o2_therapy_flo.OXYGEN_DEVICE_INIT "Oxygen_device Init"
,o2_therapy_flo.O2_TIME_INIT "O2 Device Time Init"
,o2_therapy_flo.O2_FLOW_RATE_INIT "O2_Flow_Rate Init"
,o2_therapy_flo.FIO2_INIT "Fio2 Init"
,o2_therapy_flo.OXYGEN_DEVICE_MAX "Oxygen_device at O2 MAX"
,o2_therapy_flo.O2_FLOW_RATE_MAX "O2_Flow_Rate MAX"
,o2_therapy_flo.OXYGEN_DEVICE_FIO2_MAX "Oxygen_device at Fio2 MAX"
,o2_therapy_flo.FIO2_MAX "Fio2 MAX"
,o2_therapy_flo.O2_FLOW_RATE_AVG "O2_Flow_Rate AVG"
,o2_therapy_flo.FIO2_AVG "Fio2 AVG"
,icu_by_service.from_time "ICU by Service"
,to_char(round(icu_by_service.in_days,2))||' '||icu_by_service.first_service "Duration of ICU stay (by service)"
,ZC_RELIGION.NAME Religion
,COVID_CPR.EVENT_TIME CPR_date
,case when vitals_flo.pulse is not null then vitals_flo.pulse_time
      when peA.Pulse is  null then peA2.VITALS_TAKEN_TM end "pulse_time"
,case when vitals_flo.pulse is not null then vitals_flo.pulse
      when peA.pulse is  null then to_char(peA.Respirations) end "pulse"
,p.INTRPTR_NEEDED_YN
,zc_language.name language
,replace(epp.benefit_plan_name,'&','and') Primary_Insurance
,ocu.occupation
,soc_hx.years_education
,p.zip
,prone_on_floor.first_prone_date
,prone_on_floor.last_prone_date
,COVID_TRACHEOSTOMY_COHORT.PROCEDURE_DATE tracheostomy_date
,first_Inf_onset_date
,COVID_VENT_COMMENTS.MEAS_COMMENT_VENT vent_comment
,COVID_VENT_COMMENTS.FIRST_VENT_COMMENT_DATE
,COVID_VENT_COMMENTS.MEAS_COMMENT_ANY other_comment
,COVID_VENT_COMMENTS.FIRST_ANY_COMMENT_DATE first_other_comment_date
,rsv.reason_visit_name chief_complaint
,air.PEEP_FIRST_RECORDED_TIME
,air.PEEP_FIRST_VALUE
,air.PEEP_MAX_RECORDED_TIME
,air.PEEP_MAX_VALUE
,air.MSOFA_FIRST_RECORDED_TIME
,air.MSOFA_FIRST_VALUE
,air.MSOFA_MAX_RECORDED_TIME
,air.MSOFA_MAX_VALUE
,air.TV_FIRST_RECORDED_TIME
,air.TV_FIRST_VALUE
,air.TV_MAX_RECORDED_TIME
,air.TV_MAX_VALUE
,COVID_COHORT.covid_source
from COVID_COHORT
join patient p on COVID_COHORT.pat_id=p.pat_id
 ---                                                     and p.pat_id in ('Z675823','Z2699814','Z5390338')

join pat_enc pe on pe.pat_id=p.pat_id and
--6/1/2020:
   ( (pe.effective_date_dt) between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate)---ii.record_creation_date-14 --- and pe.pat_enc_csn_id=785498625
   or (pe.contact_date) between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate) )
    --- and ORD_VALUE in ( 'DETECTED', 'Detected', 'Positive', 'Presumptive Positive' )
       and ((pe.enc_type_c <> 3 and pe.appt_status_c=2) or (pe.enc_type_c=3 and pe.hsp_account_id is not null --2/23/2021 YC made it (pe.enc_type_c <> 3 and pe.appt_status_c=2) to avoid extra hospital encounters without HAR
                           and pe.cancel_reason_c is null and (pe.appt_status_c is null or appt_status_c<>3) and pe.CALCULATED_ENC_STAT_C <> 3))--YC 7/16

--join pat_enc peA on peA.Pat_Enc_Csn_Id=COVID_COHORT.csn_onadmission -- pe.bmi,pe.temperature,pe.bp_systolic,pe.bp_diastolic,
--join pat_enc_2 peA2 on peA.Pat_Enc_Csn_Id=peA2.Pat_Enc_Csn_Id
left join hsp_account har on har.hsp_account_id=pe.hsp_account_id
left join pat_enc_hsp peh on peh.pat_enc_csn_id=pe.pat_enc_csn_id----8/21/2020 to pick up ADT event for Hospital OUtpatient har.prim_enc_csn_id
--left join ZC_PAT_STATUS zps on zps.adt_patient_stat_c=peh.ADT_PATIENT_STAT_C
left join ZC_RELIGION on ZC_RELIGION.RELIGION_C=p.religion_c
left join zc_language on zc_language.language_c=p.language_c
left join (select adt.*
              ,row_number() over (partition by adt.pat_enc_csn_id order by adt.effective_time desc) rn
              from clarity_adt adt
                   where EVENT_SUBTYPE_C <>2  and (adt.bed_id is not null or adt.event_type_c=2) ) adt on  adt.pat_enc_csn_id=peh.pat_enc_csn_id and adt.rn=1
left join (select adtA.*
              ,row_number() over (partition by adtA.pat_enc_csn_id order by adtA.effective_time asc) rn
          from  clarity_adt  adtA
          where adtA.event_type_c in (7,1) -- admission, Hospital OP
          and adtA.EVENT_SUBTYPE_C <>2 ) adtA on  adtA.pat_enc_csn_id=peh.pat_enc_csn_id and adtA.rn=1
left join pat_enc peA on peA.Pat_Enc_Csn_Id= nvl(adtA.pat_enc_csn_id,COVID_COHORT.csn_onadmission)
left join pat_enc_2 peA2 on peA.Pat_Enc_Csn_Id=peA2.Pat_Enc_Csn_Id
left join department_info_v v on v.department_id=nvl(adt.department_id,pe.effective_dept_id) -- current department/facility on adt
left join ZC_PAT_CLASS  zpcA on zpcA.adt_pat_class_c=adtA.pat_class_c
left join ZC_PAT_CLASS  zpcH on zpcH.adt_pat_class_c=peh.adt_pat_class_c
left join clarity_bed bed on bed.bed_csn_id= adt.bed_csn_id
left join clarity_rom room on room.room_csn_id=adt.room_csn_id
--- YC 8/25/2020 left join ZC_PAT_CLASS  zpc on zpc.adt_pat_class_c=adt.pat_class_c
left join ZC_PAT_CLASS  zpc on zpc.adt_pat_class_c=peh.adt_pat_class_c
left join ZC_ARRIV_MEANS zarr on peh.MEANS_OF_ARRV_C=zarr.MEANS_OF_ARRV_C
left join ZC_DISCH_DISP zdd on zdd.DISCH_DISP_C=peh.DISCH_DISP_C
left join ZC_DISCHARGE_CAT zdc on zdc.DISCHARGE_CAT_C  =peh.DISCHARGE_CAT_C
left join ZC_DISCH_DEST zddh on har.DISCH_DESTIN_HA_C  =zddh.disch_dest_c

left join COVID_Vaping Vaping on Vaping.pat_id=COVID_COHORT.pat_id
left join covid_labs labs on adtA.pat_enc_csn_id=labs.pat_enc_csn_id
--left join flow_BMI on flow_BMI.pat_id=COVID_COHORT.pat_id
--left join vent  on vent.pat_id=COVID_COHORT.pat_id and peh.pat_enc_csn_id=vent.pat_enc_csn_id
left join vitals_flo on vitals_flo.pat_id=COVID_COHORT.pat_id and peh.pat_enc_csn_id=vitals_flo.pat_enc_csn_id -- pick from flowsheet
left join COVID_ECMO ecmo on ecmo.pat_id=COVID_COHORT.pat_id and peh.pat_enc_csn_id=ecmo.pat_enc_csn_id

left join Covid_vent_flo vent_flo on peh.pat_enc_csn_id=vent_flo.pat_enc_csn_id -- 4/4/2020 YC
left join o2_therapy_flo on peh.pat_enc_csn_id=o2_therapy_flo.pat_enc_csn_id -- 4/6/2020 YC

left join symp_visit on symp_visit.pat_enc_csn_id=peh.pat_enc_csn_id
left join symp_adm  on symp_adm.pat_enc_csn_id=peh.pat_enc_csn_id

left join COVID_soc_hx soc_hx on COVID_COHORT.pat_id=soc_hx.pat_id
---left join icu on COVID_COHORT.pat_id=icu.pat_id and peh.pat_enc_csn_id=icu.pat_enc_csn_id-- 6/25/2020 YC
left join COVID_ICU_BY_ACCOMODATION icu on COVID_COHORT.pat_id=icu.pat_id and peh.pat_enc_csn_id=icu.pat_enc_csn_id-- 6/25/2020 YC
left join icu_by_service on peh.pat_enc_csn_id=icu_by_service.pat_enc_csn_id

left join homeless on COVID_COHORT.pat_id=homeless.pat_id

left outer join (select rr.pat_id,listagg(rr2.name,';') WITHIN GROUP(order by rr.line) race
     from   patient_race rr ---on pp.pat_id=rr.pat_id and rr.line=1
     join zc_patient_race  rr2 on rr.patient_race_c=rr2.patient_race_c
     group by rr.pat_id
     ) rr on p.pat_id=rr.pat_id
--- YC according to Cathy we should use ETHNIC_BACKGROUND - we'll use both
left outer join zc_ethnic_group gr on p.ethnic_group_c=gr.ethnic_group_c
--left outer join ETHNIC_BACKGROUND eb on eb.pat_id=pp.pat_id and eb.line=1
--left outer join ZC_ETHNIC_BKGRND gr2 on gr2.ethnic_bkgrnd_c=eb.ethnic_bkgrnd_c
left outer join (select eb.pat_id ,gr2.name --listagg(gr2.name,';') WITHIN GROUP(order by eb.line) name
     from ETHNIC_BACKGROUND eb  --on eb.pat_id=pp.pat_id and eb.line=1
     join ZC_ETHNIC_BKGRND gr2 on gr2.ethnic_bkgrnd_c=eb.ethnic_bkgrnd_c
     where eb.line=1 ---group by eb.pat_id
     )gr2 on gr2.pat_id=p.pat_id
join patient_4 pp4 on p.pat_id=pp4.pat_id
left join ZC_PAT_LIVING_STAT on pp4.pat_living_stat_c=ZC_PAT_LIVING_STAT.PAT_LIVING_STAT_C
left outer join zc_gender_identity zg on zg.gender_identity_c=pp4.gender_identity_c
left outer join zc_sex_asgn_at_birth zsb on zsb.sex_asgn_at_birth_c=pp4.SEX_ASGN_AT_BIRTH_C
left outer join zc_sex zss on zss.rcpt_mem_sex_c=p.sex_c
left join (select tt.pat_id--,ZC_TX_CURRENT_STAG.NAME--,row_number() over(partition by tt.pat_id order by tt.tx_current_stage_dt desc) rn
            ,listagg(to_char(tt.txp_surg_dttm,'mm/dd/yy') ||' '||ZC_TX_CURRENT_STAG.NAME,';') WITHIN GROUP(order by tt.tx_current_stage_dt asc) stage
            from TRANSPLANT_INFO tt --on tt.pat_id=COVID_COHORT.pat_id--  TX_EPSD_TYPE_C
            left join ZC_TX_EPSD_TYPE on ZC_TX_EPSD_TYPE.TX_EPSD_TYPE_C=tt.tx_epsd_type_c
            left join ZC_TX_CURRENT_STAG on ZC_TX_CURRENT_STAG.TX_CURRENT_STAG_C=tt.tx_current_stage_c
            --where tt.pat_id='Z5882050'
            group by tt.pat_id ) tt on tt.pat_id=COVID_COHORT.pat_id
/*left join TRANSPLANT_INFO tt on tt.pat_id=COVID_COHORT.pat_id--  TX_EPSD_TYPE_C
left join ZC_TX_EPSD_TYPE on ZC_TX_EPSD_TYPE.TX_EPSD_TYPE_C=tt.tx_epsd_type_c
left join ZC_TX_CURRENT_STAG on ZC_TX_CURRENT_STAG.TX_CURRENT_STAG_C=tt.tx_current_stage_c
*/
left join (select ii.*
          ,min(nvl(ii.ONSET_DATE,EPIC_UTIL.EFN_UTC_TO_LOCAL(ii.add_utc_dttm))) over (partition by pat_id)  first_Inf_onset_date
          ,row_number() over (partition by pat_id order by ii.add_utc_dttm desc) rn
     from INFECTIONS ii  ---p.pat_id='Z1372873' and
          where ii.infection_type_c=30813 ---and ii.inf_status_c=1 -- active
    )ii on ii.pat_id=p.pat_id and ii.rn=1
left join ZC_INF_STATUS zs on zs.inf_status_c=ii.inf_status_c
left join COVID_CPR on COVID_CPR.HSP_ACCOUNT_ID=har.hsp_account_id and COVID_CPR.RN_ASC=1
left join (select ocu.pat_id,ocu.hx_occupn||' '||eep.employer_name occupation
          ,row_number() over (partition by ocu.pat_id order by ocu.contact_date desc) rn
           from PAT_OCCUPN_HX ocu
          left join CLARITY_EEP eep on eep.employer_id=ocu.hx_employer_id
            )ocu on covid_cohort.pat_id=ocu.pat_id and ocu.rn=1
left join  pat_acct_cvg ac on har.coverage_id=ac.coverage_id
left join clarity_epp epp on ac.plan_id=epp.benefit_plan_id
left join prone_on_floor on peh.pat_enc_csn_id=prone_on_floor.pat_enc_csn_id
left join COVID_TRACHEOSTOMY_COHORT on COVID_TRACHEOSTOMY_COHORT.pat_enc_csn_id=peh.pat_enc_csn_id
left join COVID_VENT_COMMENTS on COVID_VENT_COMMENTS.pat_enc_csn_id=peh.pat_enc_csn_id
left join f_ed_encounters ed on ed.pat_enc_csn_id=peh.pat_enc_csn_id
left join CL_RSN_FOR_VISIT rsv on   ed.first_chief_complaint_id=rsv.reason_visit_id
left join airway_measures air on air.pat_enc_csn_id=peh.pat_enc_csn_id
/*where
-- ---9/16/2020 moved here and added disch date:
   ( (pe.effective_date_dt) between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate)---ii.record_creation_date-14 --- and pe.pat_enc_csn_id=785498625
   or (pe.contact_date) between EPIC_UTIL.EFN_DIN('2/1/2020') and TRUNC(sysdate)
   or (har.disch_date_time is null or har.disch_date_time >=EPIC_UTIL.EFN_DIN('2/1/2020'))
   )
    --- and ORD_VALUE in ( 'DETECTED', 'Detected', 'Positive', 'Presumptive Positive' )
       and (pe.appt_status_c=2 or (pe.enc_type_c=3 and pe.hsp_account_id is not null
                           and pe.cancel_reason_c is null and (pe.appt_status_c is null or pe.appt_status_c<>3) and pe.CALCULATED_ENC_STAT_C <> 3))--YC 7/16
*/

where (peh.adt_pat_class_c is null or peh.adt_pat_class_c <> '111') --- Savas ryan updated for Organ Donor exclusion



) t
join  zc_disp_enc_type zd on zd.disp_enc_type_c=t.enc_type_c
where is_include='y' and "Admission/Arrival Date" is not null
;

commit;

commit;

------------------- part II - DX and RX:
execute immediate 'Truncate table COVID_REPORT_II';

insert into  COVID_REPORT_II
with DIAB_EDG as (
select distinct icd10.code icd_code,edg.*
  from
       CLARITY_EDG edg --ON dx.DX_ID = edg.DX_ID and dx.line=1 -- YC check for primary DX
       join edg_current_icd10 icd10     on edg.dx_id = icd10.dx_id
       where exists (select 1 from DIAB_DX dx where dx.icd_code=icd10.code)

)
,pl_dx as (
select * from (
select pat_id,LISTAGG(ICD_CODE,';' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY ICD_CODE )  ICD_CODE
,DX_CATG
from (
    select pat_id,icd_code,DX_CATG
    from COVID_PL_DX pl
    union
    select pat_id,icd_code  ,DX_CATG
    from COVID_MEDHX_DX m
    union
    select pat_id,icd_code  ,DX_CATG
    from COVID_ENC_DX m

)
group by pat_id,DX_CATG
)
PIVOT (
 max(ICD_CODE)
    FOR DX_CATG IN ('Hyperlipidemia' as "Hyperlipidemia", 'Hypertension' as "Hypertension", 'COPD' as "COPD",'HF' as "Heart Failure",'CAD' as "Coronary artery disease"
        ,'PVD' as "Peripheral vascular disease",'diabetes' as "Diabetes",'Asthma' as "Asthma",'Dialysis' as "Dialysis", 'CKD' as "CKD"
        ,'Cancer' as "Cancer",'Cirrhosis' as "Cirrhosis",'OBESITY' as "OBESITY",'Autoimmune Disorders' as "Autoimmune Disorders",'Interstitial Lung Disease' as Interstitial_Lung_Disease
        ,'Emphysema' as Emphysema,'Pulmonary Fibrosis' as Pulmonary_Fibrosis, 'Cystic Fibrosis' as Cystic_Fibrosis,'Sleep Apnea' as Sleep_Apnea,'Bronchiectasis' as Bronchiectasis)

)
)
, MEDS AS
  (
  SELECT DISTINCT cm.MEDICATION_ID,cm.name rx_name
 ,case when gmr.GROUPER_ID in ( '104155', '105758') and lower(cm.name) like '%pril%' then 'ACE'-- (GROUPER_ITEMS.GROUPER_ID)  ACE
      when gmr.GROUPER_ID in ( '104155', '105758') and lower(cm.name) like '%artan%' then 'ARB'-- (GROUPER_ITEMS.GROUPER_ID)  ACE
      when gmr.GROUPER_ID in ( '104155', '105758')  then 'ACE/ARB'-- (GROUPER_ITEMS.GROUPER_ID)  ACE
      when gmr.GROUPER_ID in ('2100000128') then 'NSAID'
      when gmr.GROUPER_ID in ('1137305') then 'Aspirin'
      when gmr.GROUPER_ID in ('1139692','2100009193') then 'Statin'
      when gmr.GROUPER_ID in ('115353') then 'Anti-hypertensive'
          --  Immunocompromised
     ---  when gmr.GROUPER_ID in ('1650000113' ,'1650000129')  then 'Diabetes'

     when cm.thera_class_c=27 then 'Diabetes'
     when cm.thera_class_c=28 then 'Immunosuppressants'
     when cm.pharm_class_c in (631,1156) then 'Biologic'
      end RX_CATG

     FROM CLARITY_MEDICATION cm

  join GROUPER_MED_RECS gmr on gmr.EXP_MEDS_LIST_ID=cm.medication_id
  join GROUPER_ITEMS gi on gi.grouper_id=gmr.GROUPER_ID
  where gmr.GROUPER_ID in ( '104155', '105758',-- ACE and ARB (GROUPER_ITEMS.GROUPER_ID)  ACE
          '2100000128',--  NSAID
          '1137305',--Aspirin
          '1139692','2100009193',--Statin
          '115353' --ERX VCG 115353 ? NYU RX HD ANTI-HYPERTENSIVES  Anti-hypertensive
          --  Immunocompromised
          --  Immunosuppressive
          --'1650000113' ,'1650000129' --(Metformin)  Diabetes
          )
    or cm.thera_class_c in (27,28) --27 (ANTIHYPERGLYCEMICS)  28 (IMMUNOSUPPRESSANTS)
    or cm.pharm_class_c in (631,1156) -- Biologic Rituximab, adalimumab, certolizumab, etanercept, golimumab, infliximab, belimumab, and ustekinumab basically any drugs that end in ?-mab? (stands for monoclonal antibody just as a fun fact)

)
,medications as (
select * from (
SELECT DISTINCT COVID_COHORT.pat_id,MEDS.rx_name,RX_CATG
,om.HV_DISCRETE_DOSE dose
FROM COVID_COHORT
--JOIN pat_enc enc ON population.hsp_account_id=enc.hsp_account_id
JOIN PAT_ENC_CURR_MEDS mm ON COVID_COHORT.pat_id=mm.pat_id and   IS_ACTIVE_YN='Y'
join order_med om on om.order_med_id=mm.current_med_id
join MEDS on MEDS.MEDICATION_ID=om.medication_id
)
PIVOT (
max(rx_name)
,max(dose) dose
    FOR RX_CATG IN ('ACE/ARB' as "ACE/ARB",'ACE' as "ACE", 'ARB' as "ARB",'NSAID' as "NSAID", 'Aspirin' as "Aspirin",'Statin' as "Statin",'Diabetes' as "Diabetes RX"
      ,'Anti-hypertensive' as "Anti-hypertensive",'Immunosuppressants' as "Immunosuppressants",'Biologic' as "Biologic")
)
)
,DIALYSIS_HISTORY as (
select t.PAT_ID,min(t.DIALYSIS_START_DATE) DIALYSIS_START_DATE,max(t.DIALYSIS_END_DATE) DIALYSIS_END_DATE
from V_PAT_DIALYSIS_HISTORY t
--join covid_cohort cc on cc.pat_id=t.PAT_ID
group by t.PAT_ID
)
,DNR as (
      select COV.CSN
     ,CODA.CODE_STATUS_ADM Admission_Code_Status
     ,CODA.ACTIVATED_INST  First_Code_Status_Time --,to_char(HA.ADM_DATE_TIME, 'MM/DD/YYYY HH24:MI')
     ,CODD.CODE_STATUS_DSC Discharge_Code_Status
     ,CODD.ACTIVATED_INST Last_Code_Status_Time

    from
    COVID_REPORT_I COV
    left join (SELECT
    OCS.PATIENT_CSN
    ,OCS.PATIENT_ID
    ,OCS.ORDER_ID
    ,OCS.ACTIVATED_INST
    ,ZC_STAT.NAME          AS CODE_STATUS_ADM
    ,ROW_NUMBER () OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST ASC)  AS RANK
    FROM
    COVID_REPORT_I COV
    INNER JOIN OCS_CODE_STATUS  OCS   ON COV.CSN=OCS.PATIENT_CSN
    INNER JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
    WHERE OCS.ACTIVATED_INST > to_date('01-feb-20','dd-mon-yy'))    CODA on (CODA.PATIENT_CSN = COV.CSN AND CODA.RANK = 1)
     LEFT JOIN
    (SELECT
    OCS.PATIENT_CSN
    ,OCS.PATIENT_ID
    ,OCS.ORDER_ID
    ,OCS.ACTIVATED_INST
    ,ZC_STAT.NAME          AS CODE_STATUS_DSC
    ,ROW_NUMBER () OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST DESC)  AS RANK
    FROM
    COVID_REPORT_I COV
    INNER JOIN OCS_CODE_STATUS  OCS   ON COV.CSN=OCS.PATIENT_CSN
    INNER JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
    WHERE OCS.ACTIVATED_INST > to_date('01-feb-20','dd-mon-yy'))    CODD on (CODD.PATIENT_CSN = COV.CSN AND CODD.RANK = 1)
)
select distinct cc.pat_mrn_id,cc.pat_id
,pl_dx."Hyperlipidemia", pl_dx."Hypertension", pl_dx."COPD",pl_dx."Heart Failure",pl_dx."Coronary artery disease"
,pl_dx."Peripheral vascular disease",pl_dx."Diabetes",pl_dx."Asthma",pl_dx."Dialysis",pl_dx."CKD"
,medications."ACE/ARB","ACE/ARB_DOSE","ACE","ACE_DOSE","ARB","ARB_DOSE","NSAID","Aspirin","Statin","Diabetes RX","Anti-hypertensive","Immunosuppressants"
,"Immunosuppressants_DOSE","Biologic","Biologic_DOSE","Cancer","NSAID_DOSE","Cirrhosis","OBESITY"
,"Autoimmune Disorders",Interstitial_Lung_Disease
,Emphysema,Pulmonary_Fibrosis,Cystic_Fibrosis,Sleep_Apnea,Bronchiectasis
,dialysis_start_date,dialysis_end_date
from COVID_COHORT cc
join patient p on p.pat_id=cc.pat_id
left join pl_dx on pl_dx.pat_id=cc.pat_id
left join medications on medications.pat_id=cc.pat_id
left join DIALYSIS_HISTORY on DIALYSIS_HISTORY.pat_id=cc.pat_id
;
commit;

DECLARE
objExists number := 0;
BEGIN
select count(*) into objExists from ALL_OBJECTS where OBJECT_TYPE = 'TABLE' and OWNER = (SELECT sys_context('USERENV', 'CURRENT_USER') FROM dual) and object_name = 'COVID_REPORT_FULL' ;
if (objExists > 0) THEN
EXECUTE IMMEDIATE 'DROP TABLE COVID_REPORT_FULL';
END IF;
END;

--execute immediate 'drop table COVID_REPORT_FULL';

execute immediate 'create table COVID_REPORT_FULL as
select distinct COVID_REPORT_I.*
,COVID_REPORT_II.*
,Admission_Code_Status
,First_Code_Status_Time
,Discharge_Code_Status
,Last_Code_Status_Time
from COVID_REPORT_I
join COVID_REPORT_II on COVID_REPORT_I.MRN=COVID_REPORT_II.pat_mrn_id
left join  (
      select COV.CSN
     ,CODA.CODE_STATUS_ADM Admission_Code_Status
     ,CODA.ACTIVATED_INST  First_Code_Status_Time
     ,CODD.CODE_STATUS_DSC Discharge_Code_Status
     ,CODD.ACTIVATED_INST Last_Code_Status_Time
    from
    COVID_REPORT_I COV
    left join (SELECT
    OCS.PATIENT_CSN
    ,OCS.PATIENT_ID
    ,OCS.ORDER_ID
    ,OCS.ACTIVATED_INST
    ,ZC_STAT.NAME          AS CODE_STATUS_ADM
    ,ROW_NUMBER () OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST ASC)  AS RANK
    FROM
    COVID_REPORT_I COV
    INNER JOIN OCS_CODE_STATUS  OCS   ON COV.CSN=OCS.PATIENT_CSN
    INNER JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
    WHERE OCS.ACTIVATED_INST > to_date(''01-feb-20'',''dd-mon-yy''))    CODA on (CODA.PATIENT_CSN = COV.CSN AND CODA.RANK = 1)
     LEFT JOIN
    (SELECT
    OCS.PATIENT_CSN
    ,OCS.PATIENT_ID
    ,OCS.ORDER_ID
    ,OCS.ACTIVATED_INST
    ,ZC_STAT.NAME          AS CODE_STATUS_DSC
    ,ROW_NUMBER () OVER (PARTITION BY OCS.PATIENT_CSN ORDER BY OCS.ACTIVATED_INST DESC)  AS RANK
    FROM
    COVID_REPORT_I COV
    INNER JOIN OCS_CODE_STATUS  OCS   ON COV.CSN=OCS.PATIENT_CSN
    INNER JOIN ZC_CODE_STATUS ZC_STAT ON ZC_STAT.CD_STATUS_C = OCS.CODE_STATUS_C
    WHERE OCS.ACTIVATED_INST > to_date(''01-feb-20'',''dd-mon-yy''))    CODD on (CODD.PATIENT_CSN = COV.CSN AND CODD.RANK = 1)
   ) DNR on DNR.CSN=COVID_REPORT_I.CSN';

commit;


execute immediate 'create index COV_FUL_IDX on COVID_REPORT_FULL (CSN)';
execute immediate 'grant select on COVID_REPORT_FULL  to DSSVI_TAB_USER';
execute immediate 'grant select on COVID_REPORT_FULL  to PAU_USER';

insert into COVID_DAILY_LOG values('COVID_REPORT_FULL',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_CURRENT_INV_VENT_DASHB',sysdate,null);commit;
       DBMS_MVIEW.REFRESH( 'COVID_CURRENT_INV_VENT_DASHB', method=>'cf', atomic_refresh=>false );---YC 7/10/2020
insert into COVID_DAILY_LOG values('COVID_CURRENT_INV_VENT_DASHB',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_TOTALS_MV',sysdate,null);commit;
       DBMS_MVIEW.REFRESH( 'COVID_TOTALS_MV', method=>'cf', atomic_refresh=>false );---YC 7/9/2020
insert into COVID_DAILY_LOG values('COVID_TOTALS_MV',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_TOTALS_DASHBOARD',sysdate,null);commit;
       COVID_TOTALS_DASHBOARD(99999);
insert into COVID_DAILY_LOG values('COVID_TOTALS_DASHBOARD',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_IMAGING',sysdate,null);commit;
       DBMS_MVIEW.REFRESH( 'COVID_IMAGING', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_IMAGING',null,sysdate);commit;

insert into COVID_DAILY_LOG values('COVID_LABS_RESULTS',sysdate,null);commit;
       DBMS_MVIEW.REFRESH( 'COVID_LABS_RESULTS', method=>'cf', atomic_refresh=>false );
insert into COVID_DAILY_LOG values('COVID_LABS_RESULTS',null,sysdate);commit;


end;
end COVID_DAILY;
/