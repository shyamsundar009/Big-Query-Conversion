CREATE OR REPLACE PROCEDURE "NYU_TOBACC0_REPORTS_ALL" ----- to use instead of package tobacco_reports

( 
 
 STARTDATE IN varchar2  
, ENDDATE IN varchar2 
, p_recordset OUT SYS_REFCURSOR
) 

AS

  -- Author  : Ervin Mayorga 
  -- Created : 03/28/2018
  -- Purpose : To show Tobacco Education Patients

Begin
DECLARE

start_dt varchar(30);
end_dt varchar(30);

begin

start_dt :=  epic_util.efn_din(STARTDATE);
end_dt:= epic_util.efn_din(ENDDATE) +1;

begin

EXECUTE IMMEDIATE ' Truncate table NYU_TOBACCO_MAIN_ALL_2';
insert into NYU_TOBACCO_MAIN_ALL_2
WITH HIST AS
  (SELECT *
  FROM
    (SELECT DISTINCT har.pat_id,
      har.hsp_account_id,
      har.adm_date_time,
      hx.contact_date,
      hx.IS_TOBACCO_USER,
      HX.tobacco_pak_per_dy,
      hx.tobacco_comment,
      hx.smoking_tob_use_c,
      hx.tobacco_used_years,
      hx.smoking_quit_date,
      hx.tobacco_user_c ,
      har.prim_enc_csn_id,
      peh.inp_adm_date,
      rank () over (partition BY har.hsp_account_id order by hx.contact_date DESC ) rn
    FROM hsp_account har
    LEFT OUTER JOIN     social_hx hx    ON har.pat_id   =hx.pat_id
    left outer join pat_enc_hsp peh on peh.hsp_account_id = har.hsp_account_id 
         AND TRUNC(har.disch_date_time) >= TRUNC(hx.contact_date)
    WHERE -- har.pat_id in ('Z1167114','Z3195353','Z3167864') and
      har.adm_date_time           IS NOT NULL
    AND har.acct_basecls_ha_c      =1
--    AND TRUNC(har.DISCH_DATE_TIME) > to_date('06/01/2011','mm/dd/yyyy') --- testing without this -- Erv 2/26/2018
and har.disch_date_time > = start_dt and har.disch_date_time  < = end_dt

      ---  ORDER BY har.pat_id,      har.hsp_account_id
    )
  WHERE rn=1
  ),
 PHONE AS
  (SELECT *
  FROM(
     SELECT DISTINCT hh.hsp_account_id,
      hh.disch_date_time,
      vvv.enc_reason_name,
      vvv.contact_date ,
      rank () over (partition BY hh.hsp_account_id order by vvv.contact_date ) rn
    FROM hsp_account hh
    join hist on hist.hsp_account_id = hh.hsp_account_id 
    JOIN PAT_ENC_RSN_VISIT vvv    ON vvv.pat_id = hh.pat_id
    AND vvv.enc_reason_name IN ( 'SUPPLEMENTAL')
    AND vvv.CONTACT_DATE > TRUNC(hh.DISCH_DATE_TIME)
      --  and   trunc(sysdate - (trunc(hh.DISCH_DATE_TIME))) > 30
    WHERE --hh.hsp_account_id=3639622 and
      hh.acct_basecls_ha_c        =1
    AND hh.adm_date_time         IS NOT NULL
--    AND TRUNC(hh.DISCH_DATE_TIME) > to_date('06/01/2011','mm/dd/yyyy')  testing without this -- Erv 2/26/2018
-- and hh.DISCH_DATE_TIME > = epic_util.efn_din('t-1') and hh.DISCH_DATE_TIME  < = epic_util.efn_din('t-1')
    AND vvv.contact_date         IS NOT NULL
      ----   ORDER BY hh.hsp_account_id
    )
  WHERE rn=1
  ),
  COGNIT2 AS --- Modified this on Jan 10, to make it look like Cecilia's code as requested by Ryan  -- Ervin Mayorga 
  (
    SELECT hhh.hsp_account_id,
      max(upper( meas.meas_value))   AS cognit_value --meas_value
    ---  TRUNC (TO_NUMBER (TO_CHAR (rec.record_date, 'YYYYMMDD')) - TO_NUMBER (TO_CHAR (Hhh.hosp_ADMsn_TIME, 'YYYYMMDD'))) AS cogn_day_differ
    FROM pat_enc hhh
    join hist on hist.hsp_account_id  = hhh.hsp_account_id 
    JOIN ip_flwsht_rec rec    ON hhh.INPATIENT_DATA_ID=rec.INPATIENT_DATA_ID
    JOIN ip_flwsht_meas meas    ON rec.fsd_id                =meas.fsd_id
    JOIN IP_FLT_DATA FLT ON FLT.TEMPLATE_ID = meas.FLT_ID --- added this on Jan 10 so it can be like the code from Cecilia -- Ervin Mayorga
    WHERE hhh.INPATIENT_DATA_ID IS NOT NULL
--     AND meas.FLO_MEAS_ID         = 660820 -- modified this on Jan 10 so it can be like the code from Cecilia -- Ervin Mayorga
AND MEAS.FLO_MEAS_ID  IN ('800169','910143') -- CPM F16 R AS COGNITIVE/NEURO/BEHAVIORAL WDL   added this on Jan 10 so it can be like the code from Cecilia -- Ervin Mayorga, Osman K. added 910143 on 10/23/2018
and FLT.TEMPLATE_ID IN ('831380','910384')   -- CPM F16 ADULT PCS BODY SYSTEM  added this on Jan 10 so it can be like the code from Cecilia -- Ervin Mayorga, Osman K. added 910384 - 910384	CPM S18 ADULT PCS BODY SYSTEM on 10/23/2018

     AND meas.meas_value         IS NOT NULL
   -- ) cognit1
  GROUP BY hhh.hsp_account_id
  ),
  COMFORT AS --- modified on jan 10. Ryan asked to use only '308101' -- DNR-Comfort Care Only
  (SELECT *
  FROM
    (SELECT hh.hsp_account_id,
      hh.prim_enc_csn_id,
      comf.code_status_c,
      comf.activated_inst AS COMFORT_DATE,
      comf.comments       AS COMFORT,
      rank () over (partition BY hh.hsp_account_id order by comf.activated_inst ) rn
    FROM hsp_account hh
    join hist on hist.hsp_account_id = hh.hsp_account_id 
    JOIN OCS_CODE_STATUS comf
    ON hh.prim_enc_csn_id         = comf.patient_csn
    WHERE hh.acct_basecls_ha_c    =1
--    AND TRUNC(hh.DISCH_DATE_TIME) > to_date('06/01/2017','mm/dd/yyyy') testing without this -- Erv 2/26/2018
--and hh.disch_date_time > = epic_util.efn_din('t-1') and hh.disch_date_time  < = epic_util.efn_din('t-1')
--    AND comf.CODE_STATUS_C IN ('2', '308101','308102')
     and comf.CODE_STATUS_C  = '308101' -- DNR-Comfort Care Only
    )
  WHERE rn=1
  ),
  CESSATION AS
  (SELECT DISTINCT hh.prim_enc_csn_id,
    proc.proc_code,
    proc.description ,
    ss.name               AS order_status,
    proc.proc_ending_time AS Cessation_date
  FROM hsp_account hh
  join hist on hist.hsp_account_id = hh.hsp_account_id 
  JOIN order_proc PROC  ON hh.prim_enc_csn_id = proc.pat_enc_csn_id
  JOIN zc_order_status ss  ON proc.order_status_c          =ss.order_status_c
  WHERE 
  0 = 0 
--  and TRUNC(hh.DISCH_DATE_TIME) > to_date('06/01/2011','mm/dd/yyyy')  testing without this -- Erv 2/26/2018
--and hh.disch_date_time > = epic_util.efn_din('t-1') and hh.disch_date_time  < = epic_util.efn_din('t-1')

  AND hh.acct_basecls_ha_c        =1
  AND proc.proc_id                =41601
  AND proc.order_status_c         =5
    ---ORDER BY hh.prim_enc_csn_id
  ),
  EDUCATION AS
  (SELECT os.pat_csn,
    os.instant_of_entry,
    tt.ttp_name,
    tit.name AS edu_status
  FROM cl_pat_edu_os os
  join hist on hist.prim_enc_csn_id = os.pat_csn
  JOIN cl_pat_edu_title edu  ON os.ped_id=edu.ped_id
  JOIN ip_edu_data tt  ON edu.pat_title_id=tt.ttp_id
  LEFT OUTER JOIN ZC_PED_P_TIT_STATU tit  ON edu.pat_title_status_c       =tit.PED_P_TIT_STATU_C
  WHERE edu.pat_title_id          ='661504'
--  AND TRUNC(os.instant_of_entry) >= to_date('06/01/2011','mm/dd/yyyy')   testing without this -- Erv 2/26/2018
--and os.instant_of_entry >= epic_util.efn_din('t-1') and os.instant_of_entry < = epic_util.efn_din('t-1')
  ),
  EDUCAT_POINTS AS
  (SELECT main2.hsp_account_id,
    main2.pat_enc_csn_id,
    MAX(main2.Relev_of_quitting_response)    AS Relev_of_quitting_response,
    MAX(main2.Relev_of_quitting_status)      AS Relev_of_quitting_status,
    MAX(main2.Risk_of_health_response)       AS Risk_of_health_response,
    MAX(main2.Risk_of_health_status)         AS Risk_of_health_status,
    MAX(main2.Long_term_risk_response)       AS Long_term_risk_response,
    MAX(main2.Long_term_risk_status)         AS Long_term_risk_status,
    MAX(main2.Risk_for_other_response)       AS Risk_for_other_response,
   MAX(main2.Risk_for_other_status)         AS Risk_for_other_status,
    MAX(main2.Rewards_of_quitting_response)  AS Rewards_of_quitting_response,
    MAX(main2.Rewards_of_quitting_status)    AS Rewards_of_quitting_status,
    MAX(main2.Roadblocks_to_quitting_resp)   AS Roadblocks_to_quitting_resp,
    MAX(main2.Roadblocks_to_quitting_status) AS Roadblocks_to_quitting_status,
    MAX(main2.Repetition_response)           AS Repetition_response,
    MAX(main2.Repetition_status)             AS Repetition_status
  FROM
    (SELECT points.HSP_ACCOUNT_ID ,
      POINTS.PAT_ENC_CSN_ID,
      CASE WHEN POINTS.POINTS_IED_ID IN ('805035', '914096', '661139') THEN POINTS.RESPONSE ELSE '   ' END AS RELEV_OF_QUITTING_RESPONSE, -- Ervin M. added 805035, Osman K added 914096 10/23/2018
      CASE WHEN POINTS.POINTS_IED_ID IN ('805035', '914096', '661139') THEN POINTS.STATUS ELSE '   ' END AS RELEV_OF_QUITTING_STATUS,     -- Ervin M. added 805035, Osman K added 914096 10/23/2018
--      CASE WHEN points.points_ied_id = '661139' THEN points.response ELSE '   ' END AS Relev_of_quitting_response,                      -- Ervin M. added 805035
--      CASE WHEN points.points_ied_id = '661139' THEN points.status ELSE '   ' END AS Relev_of_quitting_status,                          -- Ervin M. added 805035
      CASE WHEN points.points_ied_id='661315' THEN points.response ELSE '   ' END AS Risk_of_health_response,
      CASE WHEN points.points_ied_id='661315' THEN points.status ELSE '   ' END AS Risk_of_health_status,
      CASE WHEN points.points_ied_id='660015' THEN points.response ELSE '   ' END AS Long_term_risk_response,
      CASE WHEN points.points_ied_id='660015' THEN points.status ELSE '   ' END AS Long_term_risk_status,
      CASE WHEN points.points_ied_id='660089' THEN points.response ELSE '   ' END AS Risk_for_other_response,
      CASE WHEN POINTS.POINTS_IED_ID='660089' THEN POINTS.STATUS  ELSE '   ' END AS RISK_FOR_OTHER_STATUS,
      CASE WHEN POINTS.POINTS_IED_ID IN ('801808', '911462', '660292') THEN POINTS.RESPONSE ELSE '   ' END AS REWARDS_OF_QUITTING_RESPONSE,  -- Ervin M. added 801808, Osman K added 911462 10/23/2018
      CASE WHEN POINTS.POINTS_IED_ID IN ('801808', '911462', '660292') THEN POINTS.STATUS ELSE '   ' END AS REWARDS_OF_QUITTING_STATUS,      -- Ervin M. added 801808, Osman K added 911462 10/23/2018
      CASE WHEN POINTS.POINTS_IED_ID IN ('804455', '913599', '660315') THEN POINTS.RESPONSE ELSE '   ' END AS ROADBLOCKS_TO_QUITTING_RESP,   -- Ervin M. added 804455, Osman K added 913599 10/23/2018
      CASE WHEN POINTS.POINTS_IED_ID IN ('804455', '913599', '660315') THEN POINTS.STATUS ELSE '   '   END AS ROADBLOCKS_TO_QUITTING_STATUS, -- Ervin M. added 804455, Osman K added 913599 10/23/2018
      CASE WHEN POINTS.POINTS_IED_ID IN ('800521', '910448', '660709') THEN POINTS.RESPONSE ELSE '   ' END AS REPETITION_RESPONSE,           -- Ervin M. added 800521, Osman K added 910448 10/23/2018
      CASE WHEN points.points_ied_id in ('800521', '910448', '660709') THEN points.status   ELSE '   ' END AS Repetition_status              -- Ervin M. added 800521, Osman K added 910448 10/23/2018

--      CASE WHEN points.points_ied_id = '660292' THEN points.response ELSE '   ' END AS Rewards_of_quitting_response,  -- Ervin M. added 801808
--      CASE WHEN points.points_ied_id = '660292' THEN points.status   ELSE '   ' END AS Rewards_of_quitting_status,    -- Ervin M. added 801808
--      CASE WHEN points.points_ied_id = '660315' THEN points.response ELSE '   ' END AS Roadblocks_to_quitting_resp,   -- Ervin M. added 804455
--      CASE WHEN points.points_ied_id = '660315' THEN points.status   ELSE '   ' END AS Roadblocks_to_quitting_status, -- Ervin M. added 804455
--      CASE WHEN points.points_ied_id = '660709' THEN points.response ELSE '   ' END AS Repetition_response,           -- Ervin M. added 800521
--      CASE WHEN points.points_ied_id = '660709' THEN points.status   ELSE '   ' END AS Repetition_status              -- Ervin M. added 800521
    FROM
      /* YC ( SELECT DISTINCT points.HSP_ACCOUNT_ID,
        points.PAT_ENC_CSN_ID,
        points.points_ied_id,
        points.taught_at_ins,
        points.response,
        points.status
      FROM*/
        (SELECT enc.HSP_ACCOUNT_ID,
          enc.PAT_ENC_CSN_ID,
          enc.ENC_TYPE_C ,
          os.ped_id,
          ns.points_ied_id,
          ns.taught_at_ins,
          ns.response,
          st.name AS status ,
          rank () over (partition BY enc.HSP_ACCOUNT_ID,enc.PAT_ENC_CSN_ID,ns.points_ied_id order by ns.taught_at_ins DESC) rn
        FROM pat_enc enc
        join hist on hist.hsp_account_id = enc.hsp_account_id
        JOIN cl_pat_edu_os os ON enc.PAT_ENC_CSN_ID=os.pat_csn
          --oin cl_patedu_cntct_pt pt --on os.ped_id=pt.ped_id
          --left outer join ZC_PED_CT_STATUS st  --on pt.cnt_point_status_c=st.ped_ct_status_c
        JOIN CL_PAT_EDU_LEARNER ns ON os.ped_id=ns.ped_id
        LEFT OUTER JOIN ZC_PED_CT_STATUS st   ON ns.status_c=st.ped_ct_status_c
        WHERE  -----enc.hsp_account_id in (3645962,3716146,3836613) and
          --  st.name             ='Done' and
          ns.points_ied_id --- Changed on Aug, 23 2017 by Ervin M. Ryan requested to add the f 660292, 660315, 660709, 661139 for their F16 counterparts
          IN ( 
'660015', --	CPM S15 PNT EDI LONG TERM RISKS
'660089', --	CPM S15 PNT EDI RISK FOR OTHERS
'660292', --	CPM S15 PNT EDI REWARDS OF QUITTING -  
'660315', --	CPM F13 PNT EDI ROADBLOCKS TO QUITTING (ADULT,OBSTETRICS,PEDIATRIC) 
'660709', --	CPM F13 PNT EDI REPETITION (MOTIVATION INTERVENTION FOR PATIENTS UNWILLING TO QUIT) (ADULT,OBSTETRICS,PEDIATRIC) 
'661139', --	CPM S15 PNT EDI RELEVANCE OF QUITTING 
'661315', --	CPM S15 PNT EDI RISKS TO HEALTH (WORSENED IMMEDIATE SYMPTOMS)
'800521', --  CPM F16 PNT TOBACCO/SECOND-HAND SMOKE COUNSELING HOW TO QUIT REPETITION -- Ervin  to complement '660709'
'801808', --	CPM F16 PNT TOBACCO/SECOND-HAND SMOKE COUNSELING RELEVANCE OF QUITTING REWARDS OF QUITTING -- Ervin to complement '660292
'804455', --	CPM F16 PNT TOBACCO/SECOND-HAND SMOKE COUNSELING HOW TO QUIT MANAGING ROADBLOCKS -- Ervin to complement  '660315'
'805035', --	CPM F16 TOP EDI RELEVANCE OF QUITTING )--- Ervin to complement 661139
'914096', --  CPM S18 G ASR SUPINATION, LEFT ELBOW (ROM)
'911462', --  CPM S18 R GREH ACTIVITY (DIRECTION FOLLOWING GOAL 1, SLP)
'913599', --  CPM S18 G INVR THERAPEUTIC EXERCISE
'910448'  --	CPM S18 R ASR IRF CARE OF OTHERS, IMPAIRMENTS (IADLS)
)
          -- and enc.contact_date=ns.contact_date
        ) points
      WHERE points.rn =1
   --   ) main1
    ) main2
    -- where    main2.hsp_account_id in (3613459,3590084,3820244)
  GROUP BY main2.HSP_ACCOUNT_ID,
    main2.PAT_ENC_CSN_ID
    ----ORDER BY main2.HSP_ACCOUNT_ID,    main2.PAT_ENC_CSN_ID
  ),
  THERAPY AS
  (SELECT *
  FROM
    (SELECT proc.pat_enc_csn_id,
      proc.description AS therapy_description,
      proc.ordering_date,
      st.name AS therapy_status,
      qq.ord_quest_resp AS ord_quest_resp,
      proc.order_proc_id as order_id,         -- added 5/8/17 by zz to specify other
      rank () over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time ) rrr2
    FROM order_proc PROC
    join hist on hist.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status st
    ON proc.order_status_c=st.order_status_c
    LEFT OUTER JOIN ord_spec_quest qq
    ON proc.order_proc_id=qq.order_id
    AND qq.line          =1
    WHERE proc.proc_id  = 232422
      --and  proc.pat_enc_csn_id=495223477
    AND st.name IS NOT NULL
    )
  WHERE rrr2=1
  ) ,
  THERAPY2 AS
  (SELECT *
  FROM
    (SELECT proc.pat_enc_csn_id,
      proc.description   AS therapy_description2,
      proc.ordering_date AS ordering_date2,
      st.name            AS therapy_status2,
      (
      CASE
        WHEN qq.ord_quest_resp IN ('Allergy to ALL NRT medications','Drug interaction with ALL NRT medications', 'Patient/Caregiver refusal','Pregnant','Recent MI (1-2 weeks', 'Temporary or permanent cognitive impairment')
        THEN qq.ord_quest_resp
        ELSE '                      '
      END) AS ord_quest_resp2,
      --  qq.ord_quest_resp AS ord_quest_resp,
      rank () over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time ) rrr2
    FROM order_proc PROC
    join hist on hist.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status st
    ON proc.order_status_c=st.order_status_c
    LEFT OUTER JOIN ord_spec_quest qq
    ON proc.order_proc_id=qq.order_id
    AND qq.line          =1
    WHERE proc.proc_id  =232422
      --and  proc.pat_enc_csn_id=495223477
    AND st.name IS NOT NULL
    )
  WHERE rrr2=1
  ),
THERAPY3  AS /*-zz added 3/9/17*/
  (SELECT *
  FROM
    (SELECT proc.pat_enc_csn_id,
      proc.description AS therapy_description3,
      proc.ordering_date  AS ordering_date3,
      st.name AS therapy_status3,
      --   (
      --   CASE
      --     WHEN qq.ord_quest_resp IN ('Allergy to ALL NRT medications','Drug interaction with ALL NRT medications', 'Patient/Caregiver refusal','Pregnant','Recent MI (1-2 weeks', 'Temporary or permanent cognitive impairment')
      --    THEN qq.ord_quest_resp
      --    ELSE '                      '
      --  END)
      qq.ord_quest_resp AS ord_quest_resp3,
      proc.order_proc_id as order_id,   -- added 5/8/17 by zz
      rank () over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time ) rrr2
    FROM order_proc PROC
    join hist on hist.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status st
    ON proc.order_status_c=st.order_status_c
    LEFT OUTER JOIN ord_spec_quest qq
    ON proc.order_proc_id=qq.order_id
    AND qq.line          =1
    WHERE proc.proc_id  =430872
      --and  proc.pat_enc_csn_id=495223477
    AND st.name IS NOT NULL
    )
  WHERE rrr2=1
  ),
   NOTHERAPY as  -- added 5/8/17 by zz to specify other on reason
(SELECT proc.pat_enc_csn_id,
      proc.description AS therapy_description,
      proc.ordering_date,
      st.name AS therapy_status,
         qq.ord_quest_resp AS OTHER_REASON,
     PROC.ORDER_PROC_ID as order_id
    FROM order_proc PROC
    join hist on hist.prim_enc_csn_id = proc.pat_enc_csn_id 
    JOIN zc_order_status st
    ON proc.order_status_c=st.order_status_c
    LEFT OUTER JOIN ord_spec_quest qq
    ON proc.order_proc_id=qq.order_id
    WHERE proc.proc_id  = 232422
    and qq.ord_quest_resp<>'Other'),

    NOTHERAPY_DSCH as  -- added 5/8/17 by zz
    (SELECT proc.pat_enc_csn_id,
            qq.ord_quest_resp AS other_on_discharge,
           proc.order_proc_id as order_id
    --  rank () over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time ) rrr2
    FROM order_proc PROC
    join hist on hist.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status st
    ON proc.order_status_c=st.order_status_c
    LEFT OUTER JOIN ord_spec_quest qq
    ON proc.order_proc_id=qq.order_id
   WHERE proc.proc_id  =430872
     -- and  proc.pat_enc_csn_id=703605971
    AND st.name IS NOT NULL
    and qq.ord_quest_resp<>'Other'),

avs as (select distinct hsp_account_id 
from (
select distinct pe.pat_id, pe.pat_enc_csn_id, pe.hsp_account_id,  pe.avs_print_tm, hx.SMOKELESS_TOB_USE_C, hx.smoking_tob_use_c
from pat_enc pe
join social_hx hx   ON pe.pat_id   =hx.pat_id
join hist on hist.hsp_account_id = pe.hsp_account_id 
where 
0 = 0
and pe.avs_print_tm is not null and (hx.SMOKELESS_TOB_USE_C	in (1, --	Current User
      2) -- 	Former User
      or hx.smoking_tob_use_c in (
      1, -- 	Current Every Day Smoker
'2', -- 	Current Some Day Smoker
3, -- 	Smoker, Current Status Unknown
4, -- 	Former Smoker
9, --	Heavy Tobacco Smoker
10 --	Light Tobacco Smoker
))
)
),

tob_screening as (
  select distinct pat_id, most_recent_screening
from (
SELECT tr.pat_id, 
hx_aud_time, 
HX_AUD_ITEM,
max (hx_aud_time) over (partition by tr.pat_id) most_recent_screening 

--TR.PAT_ENC_CSN_ID, MIN(TR.HX_AUD_TIME) AUDIT_DATE
FROM HISTORY_AUDIT_TRL TR
join hist on hist.pat_id = tr.pat_id 
WHERE TR.HX_AUD_ITEM IN (
'19291', --- smoking start date
'19215', -- could not find 
'19213', -- TOBACCO_USED_YEARS	
'19212', --- TOBACCO_PAK_PER_DY
'19211', --- CIGARETTES_YN
'19210', --- 	IS_TOBACCO_USER, 	TOBACCO_USER_C
'19209', --- SMOKING_QUIT_DATE
'19208', --- SMOKING_TOB_USE_C
'19207', -- SMOKELESS_QUIT_DATE	
'19205' --- 	SMOKELESS_TOB_USE_C	
) --TOBACCO FIELDS LOCATED IN THE SOCIAL HISTORY ---- missing tobacco comment 19214
)
)



--- MAIN query:
select * from (
SELECT "PATIENT_MRN",
  "HSP_ACCOUNT_ID",
  "PRIM_ENC_CSN_ID",
  "PAT_LAST_NAME",
  "PAT_FIRST_NAME",
  "SEX",
  "BIRTH_DATE",
  "PATIENT_AGE",
  "PAT_ZIP",
  "ADMISSION_SOURCE",
  "ETHNICITY",
  "RACE",
  "SMOKING_TOB_USE_C",
  "STATUS",
  "TOBACCO_USED_YEARS",
  "TOBACCO_COMMENT",
  "SMOKING_QUIT_DATE",
  "TOBACCO_PAK_PER_DY",
  "DAY_DIFFER",
  "TOBACCO_REVIEWED",
  "COGNIT_VALUE",
  "PHONE_CONTACT_DATE",
  "POST_DISCHARGE_PHONE_CALL",
  "COMFORT_DATE",
  "COMFORT",
  "CESSATION_CODE",
  "CESSATION",
  "ORDER_STATUS",
  "EDUCATION_DATE",
  "EDUCATION_TITLE",
  "RELEV_OF_QUITTING_RESPONSE",
  "RELEV_OF_QUITTING_STATUS",
  "RISK_OF_HEALTH_RESPONSE",
  "RISK_OF_HEALTH_STATUS",
  "LONG_TERM_RISK_RESPONSE",
  "LONG_TERM_RISK_STATUS",
  "RISK_FOR_OTHER_RESPONSE",
  "RISK_FOR_OTHER_STATUS",
  "REWARDS_OF_QUITTING_RESPONSE",
  "REWARDS_OF_QUITTING_STATUS",
  "ROADBLOCKS_TO_QUITTING_RESP",
  "ROADBLOCKS_TO_QUITTING_STATUS",
  "REPETITION_RESPONSE",
  "REPETITION_STATUS",
  "EDUCATION_STATUS",
  "IP_ADMIT_DATE",
  -- "IP_ADM_TIME",
  "ADM_DATE",
  closest_screening_admission,
  time_between_scren_admission,
  --  "ADM_TIME",
  "DISCH_DATE",
  -- "DISCH_TIME",
  "DISCH_DISPOSITION",
  "HOSPITAL_NAME",
  "HOSPITAL_SERVICE_ABBR",
  "HOSPITAL_SERVICE",
  "ADMIT_DEP_ID",
  "ADMIT_DEPARTMENT_NAME",
  "THERAPY_DESCRIPTION",
  "ORDERING_DATE",
  "THERAPY_STATUS",
  "THERAPY_REASON" ,
  "OTHER_REASON",   -- ZZ added 5/8/17
  "THERAPY_DESCRIPTION2",
  "ORDERING_DATE2",
  "THERAPY_STATUS2",
  "THERAPY_REASON2",
  "THERAPY_DESCRIPTION3", --ZZ added  3/9/17
  "ORDERING_DATE3",
  "THERAPY_STATUS3",
  "THERAPY_REASON3",
  "OTHER_ON_DISCHARGE", -- ZZ added 5/8/17
/*  "THERAPY_DESCRIPTION4",
  "ORDERING_DATE4",
  "THERAPY_STATUS4",
  "THERAPY_REASON4",*/
  "PRIM_DIAG",
  "PRIM_DIAG_DESCRIPTION",
  DD_DATE
, row_number () over (partition BY patient_mrn,hsp_account_id order by hsp_account_id,ordering_date,education_date desc ) rrr5
,disch_dept_id
,attending_prov_id
,avs
FROM
  ( SELECT DISTINCT pp.PAT_MRN_ID AS patient_mrn, --2020-09-16 TM - Deprecated column --hh.PATIENT_MRN,
    hh.HSP_ACCOUNT_ID,
    hh.PRIM_ENC_CSN_ID,
    pp.pat_last_name,
    pp.pat_first_name,
    ss.name sex,
    TO_CHAR(pp.birth_date,'MM/DD/YYYY')                                                                                    AS birth_date,
    TRUNC( (TO_NUMBER (TO_CHAR (Hh.ADM_DATE_TIME, 'YYYYMMDD')) - TO_NUMBER (TO_CHAR (pp.BIRTH_DATE, 'YYYYMMDD'))) / 10000) AS "PATIENT_AGE",
    (
    CASE
      WHEN hh.pat_zip IS NOT NULL
      THEN hh.pat_zip
      ELSE pp.zip
    END )     AS pat_zip,
    ad.name   AS Admission_source,
    bk.name   AS Ethnicity,
    race.name AS race,
    hist.smoking_tob_use_c,
    tob.name AS status,
    --hist.is_tobacco_user,
    hist.tobacco_used_years,
    hist.tobacco_comment,
    TO_CHAR(hist.smoking_quit_date,'MM/DD/YYYY') AS smoking_quit_date,
    hist.tobacco_pak_per_dy,
    TRUNC (TO_NUMBER (TO_CHAR (Hh.ADM_DATE_TIME, 'YYYYMMDD')) - TO_NUMBER (TO_CHAR (hist.smoking_quit_date, 'YYYYMMDD'))) day_differ,
    (
    CASE
      WHEN enc4.tobacco_use_vrfy_YN='Y'
      THEN 'YES'
      ELSE 'NO'
    END) AS TOBACCO_REVIEWED,
    --  hist.contact_date as Modification_date,
    cognit2.cognit_value,
    TO_CHAR(PHONE.contact_date,'MM/DD/YYYY') AS PHONE_CONTACT_DATE,
    phone.enc_reason_name                    AS Post_Discharge_Phone_Call,
    TO_CHAR(COMFORT.COMFORT_DATE,'MM/DD/YYYY') COMFORT_DATE,
    COMFORT.COMFORT,
    CESSATION.PROC_CODE   AS CESSATION_CODE,
    CESSATION.DESCRIPTION AS CESSATION ,
    CESSATION.order_status,
    --   CESSATION.cessation_date,
    TO_CHAR(EDUCATION.instant_of_entry,'MM/DD/YYYY') AS EDUCATION_DATE,
    EDUCATION.ttp_name                               AS EDUCATION_TITLE,
    EDUCAT_POINTS.Relev_of_quitting_response,
    EDUCAT_POINTS.Relev_of_quitting_status,
    EDUCAT_POINTS.Risk_of_health_response,
    EDUCAT_POINTS.Risk_of_health_status,
    EDUCAT_POINTS.Long_term_risk_response,
    EDUCAT_POINTS.Long_term_risk_status,
    EDUCAT_POINTS.Risk_for_other_response,
    EDUCAT_POINTS.Risk_for_other_status,
    EDUCAT_POINTS.Rewards_of_quitting_response,
    EDUCAT_POINTS.Rewards_of_quitting_status,
    EDUCAT_POINTS.Roadblocks_to_quitting_resp,
    EDUCAT_POINTS.Roadblocks_to_quitting_status,
    EDUCAT_POINTS.Repetition_response,
    EDUCAT_POINTS.Repetition_status,
    EDUCATION.edu_status AS EDUCATION_STATUS,
    --YC (TO_CHAR (hh3.ip_admit_date_time,'MM/DD/YYYY HH24:MI')) AS IP_ADMIT_DATE,
    hh3.ip_admit_date_time AS IP_ADMIT_DATE,
    -- (TO_CHAR (hh3.ip_admit_date_time, 'HH24:MI')) AS IP_Adm_time,
    --YC (TO_CHAR (Hh.ADM_DATE_TIME, 'MM/DD/YYYY HH24:MI')) AS Adm_date,
    Hh.ADM_DATE_TIME AS Adm_date,
    case when abs (hist.contact_date - hist.inp_adm_date) < abs (tob_screening.most_recent_screening - hist.inp_adm_date) then hist.contact_date else tob_screening.most_recent_screening end as closest_screening_admission,
    case when abs (hist.contact_date - hist.inp_adm_date) < abs (tob_screening.most_recent_screening - hist.inp_adm_date) then hist.contact_date else tob_screening.most_recent_screening end - hist.inp_adm_date  time_between_scren_admission,

    --  (TO_CHAR (Hh.ADM_DATE_TIME, 'HH24:MI'))       AS Adm_time,
    --YC(TO_CHAR (Hh.disch_DATE_TIME, 'MM/DD/YYYY HH24:MI')) AS Disch_date,
    Hh.disch_DATE_TIME AS Disch_date,
    --  (TO_CHAR (Hh.DISCH_DATE_TIME, 'HH24:MI'))     AS Disch_time,
    dd.name             AS Disch_disposition,
    serv.ABBR           AS Hospital_service_ABBR,
    serv.NAME           AS HOSPITAL_SERVICE,
    adt.department_id   AS ADMIT_DEP_ID,
    dep.department_name AS ADMIT_DEPARTMENT_NAME,
    Therapy.therapy_description,
    therapy.ordering_date,
    therapy.therapy_status,
    (
    CASE
      WHEN therapy.ord_quest_resp IS NULL
      THEN '      '
      ELSE therapy.ord_quest_resp
    END) AS therapy_reason,
    CASE when notherapy.OTHER_REASON<>therapy.ord_quest_resp
         then notherapy.OTHER_REASON end as OTHER_REASON, -- ZZ added 5/8/17
    Therapy2.therapy_description2,
    therapy2.ordering_date2,
    therapy2.therapy_status2,
    (
    CASE
      WHEN therapy2.ord_quest_resp2 IS NULL
      THEN '      '
      ELSE therapy2.ord_quest_resp2
    END)               AS therapy_reason2,
    Therapy3.therapy_description3,
    therapy3.ordering_date3,
    therapy3.therapy_status3,
  (
    CASE
      WHEN therapy3.ord_quest_resp3 IS NULL
      THEN '      '
      ELSE therapy3.ord_quest_resp3
    END)               AS therapy_reason3,
    CASE when NOTHERAPY_DSCH.other_on_discharge<>therapy2.ord_quest_resp2
         then NOTHERAPY_DSCH.other_on_discharge end as other_on_discharge, --ZZ added 5/8/17 to specify Other or Reason
/*  Therapy4.therapy_description4,
    therapy4.ordering_date4,
    therapy4.therapy_status4,
  (
    CASE
      WHEN therapy4.ord_quest_resp4 IS NULL
      THEN '      '
      ELSE therapy4.ord_quest_resp4
    END)               AS therapy_reason4,*/
    edg.ref_bill_code  AS prim_diag,
    edg.dx_name        AS prim_diag_description,
    Hh.disch_DATE_TIME AS dd_date,
    hh.disch_dept_id,
    hh.attending_prov_id,
    LOC.loc_name       AS HOSPITAL_NAME,
    case when avs.hsp_account_id is null then 'No' when avs.hsp_account_id is not null then 'Yes' end as AVS


  FROM hsp_account hh
  JOIN patient pp  ON hh.pat_id=pp.pat_id
  JOIN hsp_account_3 hh3  ON hh.hsp_account_id=hh3.hsp_account_id
       and hh.combine_acct_id is null -- YC
  JOIN hist ON hh.hsp_account_id=hist.hsp_account_id
  JOIN pat_enc_4 enc4  ON hh.prim_enc_csn_id=enc4.pat_enc_csn_id
  JOIN clarity_adt adt  ON hh.prim_enc_csn_id    =adt.pat_enc_csn_id
       AND adt.event_type_c     =1
       AND adt.event_subtype_c <>2
  left outer JOIN zc_patient_sex ss  ON pp.sex_c=ss.patient_sex_c
  LEFT JOIN CLARITY_DEP DEP ON hh.disch_dept_id = DEP.DEPARTMENT_ID 
  LEFT JOIN CLARITY_LOC LOC ON LOC.LOC_ID = DEP.REV_LOC_ID
  LEFT JOIN CLARITY_DEP DEPA ON DEPA.DEPARTMENT_ID = ADT.DEPARTMENT_ID
  LEFT JOIN CLARITY_LOC LOCA on LOCA.LOC_ID = DEPA.REV_LOC_ID
  LEFT OUTER JOIN zc_smoking_tob_use tob  ON hist.smoking_tob_use_c=tob.smoking_tob_use_c
  LEFT OUTER JOIN cognit2  ON hh.hsp_account_id=cognit2.hsp_account_id
  LEFT OUTER JOIN zc_pat_service serv  ON hh.PRIM_SVC_HA_C=serv.hosp_serv_c
  LEFT OUTER JOIN PHONE  ON hh.hsp_account_id=PHONE.hsp_account_id
  LEFT OUTER JOIN COMFORT  ON hh.hsp_account_id=COMFORT.hsp_account_id
  LEFT OUTER JOIN clarity_dep dep  ON adt.department_id=dep.department_id
  LEFT OUTER JOIN CESSATION  ON hh.prim_enc_csn_id=cessation.prim_enc_csn_id
  LEFT OUTER JOIN pat_enc_hsp enc  ON hh.prIm_enc_csn_id=enc.pat_enc_csn_id
  LEFT OUTER JOIN zc_disch_disp dd  ON enc.disch_disp_c=dd.disch_disp_c
  LEFT OUTER JOIN education  ON hh.prIm_enc_csn_id=education.pat_csn
  LEFT OUTER JOIN zc_mc_adm_type ad  ON hh.admission_type_c=ad.admission_type_c
  LEFT OUTER JOIN ethnic_background et  ON pp.pat_id = et.pat_id  AND et.line  =1
  LEFT OUTER JOIN zc_ethnic_bkgrnd bk  ON et.ETHNIC_BKGRND_C=bk.ETHNIC_BKGRND_C
  LEFT OUTER JOIN patient_race pr  ON pp.pat_id=pr.pat_id  AND pr.line =1
  LEFT OUTER JOIN zc_patient_race race  ON pr.patient_race_c=race.patient_race_c
  LEFT OUTER JOIN hsp_acct_dx_list dx  ON hh.hsp_account_id=dx.hsp_account_id  AND dx.line  =1
  LEFT OUTER JOIN clarity_edg edg  ON dx.dx_id=edg.dx_id
  LEFT OUTER JOIN EDUCAT_POINTS  ON hh.hsp_account_id= EDUCAT_POINTS.hsp_account_id
  LEFT OUTER JOIN THERAPY ON hh.prim_enc_csn_id=THERAPY.pat_enc_csn_id
  LEFT OUTER JOIN THERAPY2 ON hh.prim_enc_csn_id=THERAPY2.pat_enc_csn_id
  LEFT OUTER JOIN THERAPY3 ON hh.prim_enc_csn_id=THERAPY3.pat_enc_csn_id --zz added 3/9/17
  LEFT OUTER JOIN NOTHERAPY on hh.prim_enc_csn_id=NOTHERAPY.pat_enc_csn_id and therapy.order_id=notherapy.order_id -- ZZ added 5/8/17
  LEFT OUTER JOIN NOTHERAPY_DSCH on hh.prim_enc_csn_id=NOTHERAPY_DSCH.pat_enc_csn_id and therapy3.order_id=notherapy_dsch.order_id -- ZZ added 5/8/17
  LEFT OUTER JOIN avs on avs.hsp_account_id = hist.hsp_account_id
  LEFT OUTER JOIN tob_screening ON tob_screening.pat_id = hist.pat_id

/*  LEFT OUTER JOIN THERAPY4
  ON hh.prim_enc_csn_id=THERAPY4.pat_enc_csn_id*/
    --where hh.HSP_ACCOUNT_ID in (2574917)
  WHERE ---hist.smoking_tob_use_c IN (1,2,3,4,8,9,10)
  0 = 0 
--  and TRUNC(hh.DISCH_DATE_TIME) > to_date('06/01/2011','mm/dd/yyyy') --- testing without this  Erv 2/26/18
  AND hh.acct_basecls_ha_c      = 1
  AND hh.acct_class_ha_c  <>  112 --hospice
    --   and  hh.HSP_ACCOUNT_ID in (3613459,3590084,3820244)
--  and TRUNC(hh.DISCH_DATE_TIME) between epic_util.efn_din('t-1')  and epic_util.efn_din('t-1') --- this is already done in hist 
  --YC:
  and floor(months_between(Hh.ADM_DATE_TIME,pp.BIRTH_DATE) / 12) >=18
 --- and   tob.name <> 'Unknown If Ever Smoked'
  and adt.department_id not in (  10530009, --- HJD 9 NORTH
                                  10530010, --- HJD 9 SOUTH
                                  10800002, --- LM 3B
                                  10500315 --- TH HCC 9
                                  ) ---- On June 20, Ryan E Sullivan asked to take these apartments out--- Ervin M. 
  ) main1


WHERE 

0 = 0 

--and ((main1.day_differ   IS NULL AND main1.smoking_tob_use_c<>4) --- on May 30 Ryan E Sullivan asked us to take all patients 
--      OR main1.day_differ        <=30)
--AND Hospital_service_ABBR  <>'PHG'
) where rrr5=1;
commit;



EXECUTE IMMEDIATE ' Truncate table NYU_TOBACCO_MED_2';
insert into NYU_TOBACCO_MED_2
WITH medication1 AS
  (SELECT *
  FROM
    (SELECT pp.PAT_MRN_ID AS patient_mrn, --2020-09-16 TM - Deprecated column --hh.patient_mrn,
      hh.hsp_account_id,
      hh.adm_date_time,
      hh.disch_date_time,
      ord.medication_id,
      ord.description,
      rec.grouper_id AS Grouper,
      it.grouper_name,
      ormode.title                                  AS ordering_mode,
      orstatus.title                                AS Order_status,
      orroute.title                                 AS Admin_route,
      ord.hv_discrete_dose                          AS Dose,
      unit.title                                    AS UNIT,
      freq.freq_name                                AS frequency,
      TO_CHAR (ii.taken_time ,'MM/DD/YYYY HH24:MI') AS taken_time,
      ii.comments,
      ii.mar_action_c,
      rslt.name AS ord_result,
      rsn.name  AS reason,
      ord.order_med_id,
      TRUNC (ord.start_date) - trunc (hh.ADM_DATE_TIME) med_day_differ,
      row_number() over (partition BY pp.PAT_MRN_ID,hh.hsp_account_id,ord.order_med_id order by taken_time desc) rrr5
    FROM hsp_account hh
    JOIN order_med ord    ON hh.prim_enc_csn_id=ord.pat_enc_csn_id
    JOIN mar_admin_info ii    ON ord.order_med_id   =ii.order_med_id
        AND (ii.mar_action_c IN (1,2,115) )
    JOIN GROUPER_RECORDS rec    ON ord.medication_id=rec.grouper_rec_list
    JOIN PATIENT PP ON hh.PAT_ID = PP.PAT_ID    --2020-09-16 TM - HH.patient_mrn has been deprecated. Updated
    LEFT OUTER JOIN zc_order_class orclass    ON ord.order_class_c=orclass.order_class_c
    LEFT OUTER JOIN zc_ordering_mode ormode    ON ord.ordering_mode_c=ormode.ordering_mode_c
    LEFT OUTER JOIN zc_order_status orstatus    ON ord.order_status_c=orstatus.order_status_c
    LEFT OUTER JOIN zc_admin_route orroute    ON ord.med_route_c=orroute.med_route_c
    LEFT OUTER JOIN zc_med_unit unit    ON ord.dose_unit_c=unit.disp_qtyunit_c
    LEFT OUTER JOIN ip_frequency freq    ON ord.hv_discr_freq_id=freq.freq_id
    LEFT OUTER JOIN zc_mar_rslt rslt    ON ii.mar_action_c=rslt.result_c
    LEFT OUTER JOIN zc_mar_rsn rsn    ON ii.reason_c=rsn.reason_c
    LEFT OUTER JOIN grouper_items it    ON rec.grouper_id  =it.grouper_id
    WHERE hh.acct_basecls_ha_c =1
    AND rec.grouper_id   ='5100000177'
    AND TRUNC (ord.start_date) - trunc (Hh.adm_DATE_TIME) < 3
    AND orstatus.title   <>'SENT'
    AND ord.order_class_c  =1
    AND (ii.comments   <> 'wrong order'
    AND ii.comments <> 'Wrong order'
    AND ii.comments <> 'WRONG ORDER'
    OR ii.comments IS NULL)

    and  hh.DISCH_DATE_TIME > = start_dt  and hh.DISCH_DATE_TIME < end_dt

      --    and hh.hsp_account_id=5205590
       --   and    hh.prim_enc_csn_id= 506846316
--   ORDER BY hh.patient_mrn,
--     hh.hsp_account_id ,
  --    ord.order_med_id,
--     TO_CHAR (ii.taken_time, 'YYYYMMDD HH24:MI')
    )
  WHERE rrr5=1
  ) ,
  medication2 AS
  (SELECT *
  FROM
    (SELECT pp.PAT_MRN_ID AS patient_mrn, --2020-09-16 TM - Deprecated column --hh.patient_mrn,
      hh.hsp_account_id,
      hh.adm_date_time,
      hh.disch_date_time,
      ord.medication_id,
      ord.description,
      rec.grouper_id AS Grouper,
      it.grouper_name,
      ormode.title                                  AS ordering_mode,
      orstatus.title                                AS Order_status,
      orroute.title                                 AS Admin_route,
      ord.hv_discrete_dose                          AS Dose,
      unit.title                                    AS UNIT,
      freq.freq_name                                AS frequency,
      TO_CHAR (ii.taken_time ,'MM/DD/YYYY HH24:MI') AS taken_time,
      ii.comments,
      ii.mar_action_c,
      rslt.name AS ord_result,
      rsn.name  AS reason,
      ord.order_med_id,
      TRUNC (ord.start_date) - trunc (hh.ADM_DATE_TIME) med_day_differ,
      row_number () over (partition BY pp.PAT_MRN_ID,hh.hsp_account_id,ord.order_med_id order by ii.taken_time desc ) rrr6
    FROM hsp_account hh
    JOIN order_med ord    ON hh.prim_enc_csn_id=ord.pat_enc_csn_id
    join medication1 on medication1.order_med_id = ord.order_med_id 
    JOIN GROUPER_RECORDS rec    ON ord.medication_id=rec.grouper_rec_list
   JOIN mar_admin_info ii    ON ord.order_med_id   =ii.order_med_id
                        AND (ii.mar_action_c IN (1,2,115) )
    JOIN PATIENT PP ON hh.PAT_ID = PP.PAT_ID    --2020-09-16 TM - hh.patient_mrn has been deprecated. Updated
    LEFT OUTER JOIN zc_order_class orclass    ON ord.order_class_c=orclass.order_class_c
    LEFT OUTER JOIN zc_ordering_mode ormode    ON ord.ordering_mode_c=ormode.ordering_mode_c
    LEFT OUTER JOIN zc_order_status orstatus    ON ord.order_status_c=orstatus.order_status_c
    LEFT OUTER JOIN zc_admin_route orroute    ON ord.med_route_c=orroute.med_route_c
    LEFT OUTER JOIN zc_med_unit unit    ON ord.dose_unit_c=unit.disp_qtyunit_c
    LEFT OUTER JOIN ip_frequency freq    ON ord.hv_discr_freq_id=freq.freq_id
    LEFT OUTER JOIN zc_mar_rslt rslt    ON ii.mar_action_c=rslt.result_c
    LEFT OUTER JOIN zc_mar_rsn rsn    ON ii.reason_c=rsn.reason_c
    LEFT OUTER JOIN grouper_items it    ON rec.grouper_id                                                                                      =it.grouper_id
    WHERE hh.acct_basecls_ha_c   =1
    AND rec.grouper_id   ='5100000177'
    AND TRUNC (ord.start_date)- trunc (Hh.adm_DATE_TIME) <3
    AND orstatus.title  <>'SENT'
    AND ord.order_class_c   =1
    AND rslt.name IN ('Patch Applied','Given')

--    and  TRUNC(hh.DISCH_DATE_TIME) between start_dt  and end_dt -- this is already done in medication1

      ---   and hh.hsp_account_id=5205590
     ---      and    hh.prim_enc_csn_id= 506846316
  --  ORDER BY hh.patient_mrn,
--     hh.hsp_account_id ,
  --    ord.order_med_id,
  --    TO_CHAR (ii.taken_time, 'YYYYMMDD HH24:MI')
    )
  WHERE rrr6=1
  )
----main_medication_query
SELECT "PATIENT_MRN",
  "HSP_ACCOUNT_ID",
  "ADM_DATE_TIME",
  "DISCH_DATE_TIME",
  "MEDICATION_ID",
  "DESCRIPTION",
  "GROUPER",
  "GROUPER_NAME",
  "ORDERING_MODE",
  "ORDER_STATUS",
  "ADMIN_ROUTE",
  "DOSE",
  "UNIT",
  "FREQUENCY",
  "MED_TAKEN_TIME",
  "MED_COMMENTS",
  "MED_ORD_RESULT",
  "MED_REASON",
  "RRR10"
FROM
  (SELECT medication1.patient_mrn,
    medication1.hsp_account_id,
    TO_CHAR (medication1.adm_date_time ,'MM/DD/YYYY HH24:MI') adm_date_time,
    TO_CHAR (medication1.disch_date_time ,'MM/DD/YYYY HH24:MI') disch_date_time,
    medication1.medication_id,
    medication1.description,
    medication1.Grouper,
    medication1.grouper_name,
    medication1.ordering_mode,
    medication1.Order_status,
    medication1.Admin_route,
    medication1.Dose,
    medication1.UNIT,
    medication1.frequency,
    (
    CASE
      WHEN medication1.mar_action_c<> medication2.mar_action_c
      AND medication1.ord_RESULT   <> medication2.ord_result
      AND medication2.ord_result   IN ('Given','Patch Applied')
      THEN medication2.taken_time
      ELSE medication1.taken_time
    END) AS med_taken_time,
    (
    CASE
      WHEN medication1.mar_action_c<> medication2.mar_action_c
      AND medication1.ord_RESULT   <> medication2.ord_result
      AND medication2.ord_result   IN ('Given','Patch Applied')
      THEN medication2.comments
      ELSE medication1.comments
    END) AS med_comments,
    (
    CASE
      WHEN medication1.mar_action_c<> medication2.mar_action_c
      AND medication1.ord_RESULT   <> medication2.ord_result
      AND medication2.ord_result   IN ('Given','Patch Applied')
      THEN medication2.ord_result
      ELSE medication1.ord_result
    END ) AS med_ord_result,
    (
    CASE
      WHEN medication1.mar_action_c<> medication2.mar_action_c
      AND medication1.ord_RESULT   <> medication2.ord_result
      AND medication2.ord_result   IN ('Given','Patch Applied')
      THEN medication2.reason
      ELSE medication1.reason
    END) AS med_reason ,
    row_number() over (partition BY medication1.hsp_account_id order by medication1.order_med_id) rrr10
  FROM medication1
  LEFT OUTER JOIN medication2  ON medication1.order_med_id=medication2.order_med_id
-- ORDER BY medication1.hsp_account_id,    medication1.order_med_id

  )
WHERE rrr10         =1;

commit;

Open p_recordset FOR

with MAIN0 as
(select
PATIENT_MRN
,HSP_ACCOUNT_ID
,PRIM_ENC_CSN_ID
,PAT_LAST_NAME
,PAT_FIRST_NAME,SEX,BIRTH_DATE,PATIENT_AGE,PAT_ZIP,ADMISSION_SOURCE,ETHNICITY,RACE
,SMOKING_TOB_USE_C,STATUS,TOBACCO_USED_YEARS,TOBACCO_COMMENT,SMOKING_QUIT_DATE
,TOBACCO_PAK_PER_DY,DAY_DIFFER,TOBACCO_REVIEWED,COGNIT_VALUE,PHONE_CONTACT_DATE
,POST_DISCHARGE_PHONE_CALL,COMFORT_DATE,COMFORT,CESSATION_CODE,CESSATION,ORDER_STATUS
,EDUCATION_DATE,EDUCATION_TITLE,Relev_of_quitting_response,Relev_of_quitting_status
,Risk_of_health_response,Risk_of_health_status,Long_term_risk_response,Long_term_risk_status
,Risk_for_other_response,Risk_for_other_status,Rewards_of_quitting_response,Rewards_of_quitting_status
,Roadblocks_to_quitting_resp,Roadblocks_to_quitting_status,Repetition_response,Repetition_status
,EDUCATION_STATUS,IP_ADMIT_DATE,
ADM_DATE,
closest_screening_admission,
time_between_scren_admission,
DISCH_DATE,DISCH_DISPOSITION
,HOSPITAL_NAME
,HOSPITAL_SERVICE_ABBR
,HOSPITAL_SERVICE,ADMIT_DEP_ID,ADMIT_DEPARTMENT_NAME,THERAPY_DESCRIPTION as "First NRT Order"
,ORDERING_DATE as  "First NRT Order Date"
,THERAPY_STATUS as "First Status"
,THERAPY_REASON  as "First Reason"
,OTHER_REASON as "Other Reason"
,(  case when  trim (THERAPY_REASON2) is not null  then THERAPY_DESCRIPTION2 else null end)  as "Valid NRT Order"
, ( case when trim (THERAPY_REASON2) is not null then ORDERING_DATE2 else null end)  as  "Valid NRT Order Date"
, ( case when trim (THERAPY_REASON2) is not null then THERAPY_STATUS2 else null end) as "Valid Status"
, THERAPY_REASON2  as "Valid Reason"
,THERAPY_DESCRIPTION3 as "Discharge Order"
,ORDERING_DATE3  as  "Order Date"
,THERAPY_STATUS3 as "Status"
,THERAPY_REASON3  as "Reason"
,OTHER_ON_DISCHARGE as "Other on Discharge"
,PRIM_DIAG
,PRIM_DIAG_DESCRIPTION
,disch_dept_id
,attending_prov_id
,AVS
from NYU_TOBACCO_MAIN_ALL_2 main00
where ---trunc(main00.disch_date) between {?start_date}  and {?end_date}
patient_age >=18 ---and   status <> 'Unknown If Ever Smoked'
)
,
DISCH_MED
as
(select all3.*
from
(
select all2.*,
row_number() over(partition by all2.hsp_account_id order by all2.LAST_ADMIN_INST desc) rrr
from

  (
  select        hh.hsp_account_id,
                om.pat_enc_csn_id ,
                om.medication_id,
                om.description,
                om.order_inst LAST_ADMIN_INST,
                gr.grouper_id
              --  row_number() over(partition by gr.grouper_id order by om.order_inst desc,om.medication_id) rrr
                        from order_med om
                        join pat_enc pe on pe.pat_enc_csn_id=om.pat_enc_csn_id
                        join NYU_TOBACCO_MAIN_ALL_2 hh on hh.hsp_account_id=pe.hsp_account_id
                        join GROUPER_MED_RECS gr  on gr.exp_meds_list_id = om.medication_id
                         where
                            gr.grouper_id in ('5100000177') ---- tobacco medication                            --  and mi.order_source_c in (3,41,42) -- on discharge
                            and om.ACT_ORDER_C = 1
                            AND om.DISCON_TIME IS NULL
                            and om.order_status_c <> 4 --- not cancelled
                            and (om.order_class_c not in (3, 6, 7, 45, 48) or
                             om.order_class_c is null)
                       --  and hh.acct_basecls_ha_c=1





   ) all2
   )all3
    where all3.rrr=1

),

ref_proc
as
(
/* YC select   proc.hsp_account_id,
proc.description as ref_proced,
proc.ordering_date as Ref_order_date,
proc.reason_for_cancelation,
proc.order_status as ref_order_status
from
( */
  select distinct pp.pat_enc_csn_id,pp.proc_id,pp.description as ref_proced
         ,pp.ordering_date as Ref_order_date
         ,st.name as ref_order_status
         ,can.name as reason_for_cancelation
         ,hh.hsp_account_id
--        ,har.acct_basecls_ha_c
  from order_proc pp
  join pat_enc pe on  pp.pat_enc_csn_id=pe.pat_enc_csn_id
  join NYU_TOBACCO_MAIN_ALL_2 hh on  hh.hsp_account_id=pe.hsp_account_id
  left outer join zc_order_status st on pp.order_status_c=st.order_status_c
  left outer join zc_reason_for_canc can on pp.reason_for_canc_c=can.reason_for_canc_c
  where  pp.proc_id=414701
      and pp.future_or_stand='S'
--     and har.acct_basecls_ha_c=1
-- YC) proc
),


/*  refused as
  ( select distinct  ff.pat_enc_csn_id,ff.alert_action_date,ff.alert_id,ff.bpa_name,ff.specific_override_reason,
     hh.hsp_account_id--,hh.acct_basecls_ha_c
     from v_cube_f_alert    ff
     join pat_enc pe on ff.pat_enc_csn_id=pe.pat_enc_csn_id
     join NYU_TOBACCO_MAIN_TMP hh on pe.hsp_account_id=hh.hsp_account_id
     where --ff.alert_id= 25492632
      ff.bpa_name='NYU IPO OPT TO QUIT BASE'
      and ff.bpa_trigger_action = 'Open Patient Chart'
      and ff.specific_override_reason = 'Patient Refused'
   --   and hh.acct_basecls_ha_c=1

),*/
admit_dep
as
(
select all1.*
from
(
select adt.event_id,hh.hsp_account_id,adt.pat_enc_csn_id,adt.next_out_event_id,adt.event_type_c
,adt.department_id,dd.department_name,
to_char(adt.effective_time,'mmddyyyy hh24:mi') as effect_time,
rank () over (partition BY hh.hsp_account_id order by  adt.effective_time ) ddd
from  NYU_TOBACCO_MAIN_ALL_2 hh
join pat_enc_hsp peh on peh.hsp_account_id=hh.hsp_account_id
join clarity_adt adt on adt.pat_enc_csn_id=peh.pat_enc_csn_id
join clarity_dep dd on adt.department_id=dd.department_id
where adt.event_subtype_c <> 2
and adt.event_time>to_date('1/1/2016','mm/dd/yyyy')
) all1
where ddd=1
),

next_admit_dep as
(
select all1.*
from
(
select adt.event_id,peh.hsp_account_id,adt.pat_enc_csn_id,adt.next_out_event_id,adt.event_type_c,adt.department_id,dd.department_name,
to_char(adt.effective_time,'mmddyyyy hh24:mi') as effect_time,
rank () over (partition BY hh.hsp_account_id order by  adt.effective_time ) ddd
from NYU_TOBACCO_MAIN_ALL_2 hh
join pat_enc_hsp peh on peh.hsp_account_id=hh.hsp_account_id
join clarity_adt adt on peh.pat_enc_csn_id=adt.pat_enc_csn_id
join clarity_dep dd on adt.department_id=dd.department_id
where adt.event_subtype_c<>2
and adt.event_time>to_date('1/1/2016','mm/dd/yyyy')
----and hh.acct_basecls_ha_c=1
and adt.department_id not in (10500016,10500364, 10800021--  LM EMERGENCY DEPT
                      )
--and hh.hsp_account_id=5670843
) all1
where ddd=1
)






-----main query
select fff.*,
case when "Discharge Medication" = 2 then 2 
     when "Valid Reason 2" = 2 then 2
     when "Discharge Medication" = 1 then 1
     when "Valid Reason 2" = 1 then 1 else 0 end as "Total Discharge Numerator",
case when "Numerator for Education" = 2 then 2 
     when "Numerator for Education" = 0 then 0
     when "Medication Numerator" = 0 then 0 else 1 end as "Total Numerator",
case when specific_override_reason is not null and "Patient Excluded" = '0' then 1
     when specific_override_reason is null and "Patient Excluded" = '0' then 0
     else 2
     END as Referral_Refusal,
case when ref_order_date is not null and "Patient Excluded" = '0' then 1
     when ref_order_date is null and "Patient Excluded" = '0' then 0
     else 2
     END as Referral_Agree
from (
select eee.*,
case when "Numerator for Medications" = 2 then 2
     when SMOKING_TOB_USE_C in ( 10, -- Light tobacco Smoker
                                 2) -- Current Some Day Smoker
                                 then 2
--    when "First Reason" =  'Light smoker (less than 5 cigarettes/day)' then 2   Ryan asked to take this out of formula on Jan 10, 2018
      when "Reason" in (
'Light Smoker (less than 5 cigarettes/day)',
'Drug interaction with ALL NRT medications',
'Patient/Caregiver refusal',
'Recent MI (1-2 weeks)',
'Temporary or permanent cognitive impairment',
'Allergy to ALL NRT medications',
'Pregnant',
'Other',
'Patient does not use tobacco') then 1 else 0 end as "Valid Reason 2"

from (
select ddd.*,
case when "Numerator for Medications" = 2 then 2
     when "Valid Reason 1" = 2 then 2
     when "Numerator for Medications" = 1 then 1
     when "Valid Reason 1" = 1 then 1 else 0 end as "Medication Numerator"
from (
select ccc.*, 
case when "Patient Excluded" = 1 then 2
     when Relev_of_quitting_status in ('Done', 'Active') then 1
     when RISK_OF_HEALTH_STATUS in ('Done', 'Active') then 1
     when LONG_TERM_RISK_STATUS in ('Done', 'Active') then 1
     when RISK_FOR_OTHER_STATUS in ('Done', 'Active') then 1
     when REWARDS_OF_QUITTING_STATUS in ('Done', 'Active') then 1
     when ROADBLOCKS_TO_QUITTING_STATUS in ('Done', 'Active') then 1
     when REPETITION_STATUS in ('Done', 'Active') then 1 else 0 end as "Numerator for Education",
case when "Patient Excluded" = 1 then 2
     when SMOKING_TOB_USE_C in (
     10, -- Light Tobacco Smoker
     2 ) --Current Some Day Smoker
     then 2
     when TOBACCO_COMMENT is not null and TOBACCO_PAK_PER_DY < 0.25 then 2
     when MED_ORD_RESULT is null then 0 else 1 end as "Numerator for Medications",
case when "Patient Excluded" = 1 then 2
     when SMOKING_TOB_USE_C in (
     10, -- Light Tobacco Smoker
     2 ) --Current Some Day Smoker
     then 2
     when "First Reason" in (
     'Light smoker (less than 5 cigarettes/day)', 
     'Patient/Caregiver refusal',
     'Recent MI (1-2 weeks)', 
     'Temporary or permanent cognitive impairment',
    'Drug interaction with ALL NRT medications',
    'Pregnant',
    'Other',
    'Patient does not use tobacco') then 1 else 0 end as "Valid Reason 1"

from(
select bbb.*,
case when "LOS <1.5" = 1 then 2
     when "Cognitive Impairment" = 1 then 2
     when "Comfort Measure Exclusions" = 1 then 2
     when SMOKING_TOB_USE_C in (
1, -- Current Every Day Smoker
4, --Former Smoker
'2', -- Current Some Day Smoker
10, --Light Tobacco Smoker
9, --Heavy Tobacco Smoker
5, --	Never Smoker
7, --	Passive Smoke Exposure - Never Smoker
3 --	Smoker, Current Status Unknown
)  then 1 else 0 end as "Screening"
,case when "LOS <1.5" = 1 then 1
     when "Status Exclusion" = 1 then 1
     when "Cognitive Impairment" = 1 then 1
     when "Comfort Measure Exclusions" =1 then 1 else 0 end as "Patient Excluded"

from (
select aaa.* ,
(case when aaa.TTM2c='1' and Rx_or_Reason_for_no='1' then '1' else '0' end) as TTM2,
(case when aaa.TTM2b='1' and TTM2c='1' then '1' else '0' end) as TTM2a,
DISCH_DATE - IP_ADMIT_DATE LOS
,case when aaa.DISCH_DATE - aaa.IP_ADMIT_DATE < 1.5 then 1 else 0 end as "LOS <1.5"
,case when COGNIT_VALUE is null then 0 
      when lower (COGNIT_VALUE) like 'ex' then 1 else 0 end as "Cognitive Impairment"
,case when comfort is null then 0 else 1 end as "Comfort Measure Exclusions"
,case when SMOKING_TOB_USE_C is null then 1
      when SMOKING_TOB_USE_C in (
      4, -- former smoker 
7, -- Passive smoke exposure -- never smoker
5, --never smoker
6, --never assessed 
8) -- Unknown If Ever Smoked
    then 1 else 0 end as "Status Exclusion"
,case when DISCH_DISPOSITION in (
'Discharged to Children''s Hospital',
'Discharged to Other Facility',
'Expired',
'Federal Hospital',
'Hospice/Home',
'Hospice/Medical Facility',
'Left Against Medical Advice',
'Long Term Care',
'Psychiatric Hospital',
'Rehab Facility',
'Short Term Hospital',
'Skilled Nursing Facility',
'Acute Rehab Facility') then 2 
   when DISCHARGE_MEDICATION is null then 0
   when PRIM_ENC_CSN_ID is null then 0 else 1 end as "Discharge Medication"

from

(
select distinct  main0.*,med.medication_id,med.description,med.grouper,med.grouper_name,med.ordering_mode,
       med.order_status med_order_status,med.admin_route,med.dose,med.unit,med.frequency,med.med_taken_time,
       med.med_comments,med.med_ord_result,med.med_reason,
       (case when Relev_of_quitting_status = 'Done'  and
            Risk_of_health_status   = 'Done'  and
            Long_term_risk_status   = 'Done'  and
            Risk_for_other_status   = 'Done'  and
            Rewards_of_quitting_status   = 'Done'  and
            Roadblocks_to_quitting_status= 'Done'  and
            Repetition_status      = 'Done'    then '1' else '0' end) as TTM2c,
        (case when   "Valid NRT Order" is not null or   med.med_ord_result is not null then  '1' else '0' end)
                                                                       as Rx_or_Reason_for_no,
        (case when   med.med_ord_result is not null then  '1' else '0' end)   as TTM2b ,
        (case when   trunc(ADM_DATE)>=to_date('04-dec-2013','dd-mon-yyyy') then '2' else '1' end ) as "Nurse intervention",
        (case when   trunc(ADM_DATE)>=to_date('02-jul-2014','dd-mon-yyyy') then '3'
              when   trunc(ADM_DATE)<to_date('29-may-2013','dd-mon-yyyy') then '1'
              when   trunc(ADM_DATE)<to_date('02-jul-2014','dd-mon-yyyy') and
                     trunc(ADM_DATE)>=to_date('29-may-2013','dd-mon-yyyy') then '2' end ) as "Provider intervention",
          disch_med.description as discharge_medication,
          disch_med.LAST_ADMIN_INST as LAST_ADMIN_INST ,
(case when ref_proc.Ref_order_date is not null then 'Y' else 'N'  end ) as Ref_ORDER_OCCURED,
ref_proc.ref_proced,
ref_proc.Ref_order_date,
ref_proc.reason_for_cancelation,
ref_proc.ref_order_status,
refused.alert_action_date,
refused.bpa_name,
refused.specific_override_reason,
( case when admit_dep.department_id not in (10500364,--         TH CH EMERG DEPT
                                10800021,--         LM EMERGENCY DEPT
                                10500016--          TH EMERGENCY DEPT
                              ) then  admit_dep.department_name
                              else next_admit_dep.department_name end ) as admit_dept,
dep.department_name as Disch_department,
ser.prov_name as Attend_PHY


from  main0
left outer join NYU_TOBACCO_MED_2  med on main0.hsp_account_id=med.hsp_account_id
left outer join disch_med on main0.hsp_account_id=disch_med.hsp_account_id
left outer join ref_proc on main0.hsp_account_id=ref_proc.hsp_account_id
---left outer join refused on main0.hsp_account_id=refused.hsp_account_id
left outer join (select distinct pe.hsp_account_id,ff.*
     from v_cube_f_alert ff
     join pat_enc pe on ff.pat_enc_csn_id=pe.pat_enc_csn_id
     where --ff.alert_id= 25492632
      ff.bpa_name='NYU IPO OPT TO QUIT BASE'
      and ff.bpa_trigger_action = 'Open Patient Chart'
      and ff.specific_override_reason = 'Patient Refused' ) refused on main0.hsp_account_id=refused.hsp_account_id
--left outer join hsp_account hh on main0.hsp_account_id=hh.hsp_account_id
left outer join clarity_dep  dep on main0.disch_dept_id=dep.department_id
left outer join clarity_ser ser on main0.attending_prov_id=ser.prov_id
left outer join admit_dep on main0.hsp_account_id=admit_dep.hsp_account_id
left outer join next_admit_dep on main0.hsp_account_id=next_admit_dep.hsp_account_id

)aaa)bbb)ccc)ddd)eee)fff


;



end;
END;
END ;
/