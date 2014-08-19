set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log


@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_load_seq_sequence.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_interface_hdr_table.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_interface_list_table.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_digest_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_hier_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_general_list_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_role_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_pos_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_rep_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_rep_address_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_prod_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_prod_barcode_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_address_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_note_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_contact_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_visitor_day_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_prod_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_auth_list_prod_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_appoint_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_call_card_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_call_card_note_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_ord_hdr_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_ord_dtl_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_terr_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_cust_terr_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_pos_terr_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_survey_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_survey_question_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_response_opt_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_task_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_task_assignment_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_task_cust_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_task_prod_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_task_survey_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_act_hdr_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_act_dtl_dist_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_act_dtl_permancy_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_act_dtl_disply_std_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_survey_answer_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_graveyard_tables.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods/qu4_act_dtl_planogram_tables.sql;


spool off
