set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_load_seq_sequence.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_interface_hdr_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_interface_list_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_digest_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_hier_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_general_list_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_role_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_pos_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_rep_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_rep_addrs_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_prod_barcode_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_addrs_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_contact_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_visit_day_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_prod_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_auth_list_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_appoint_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_callcard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_callcard_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_ord_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_ord_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_cust_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_pos_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_survey_question_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_response_opt_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_task_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_task_assign_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_task_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_task_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_task_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_hotspot_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_gpa_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_ranging_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_pos_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_off_loc_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_survey_answer_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_graveyard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_hwaudit_gr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_hwaudit_ro_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_storeop_gr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_storeop_ro_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_top_sku_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu3_act_dtl_pcking_chg_tables.sql;


spool off
