set serveroutput on size 100000
set linesize 512
set echo on
spool dds_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_rep_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_visit_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_task_assign_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_hotspot_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_gpa_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_ranging_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_off_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_hwaudit_gr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_hwaudit_ro_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_storeop_gr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_storeop_ro_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_top_sku_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_pcking_chg_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_assort_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu3_act_dtl_pkg.sql;


spool off
