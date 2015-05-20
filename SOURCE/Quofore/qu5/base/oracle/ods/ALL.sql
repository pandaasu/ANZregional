set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_load_seq_sequence.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_interface_hdr_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_interface_list_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_digest_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_hier_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_general_list_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_role_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_pos_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_rep_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_rep_address_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_prod_barcode_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_address_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_contact_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_visitor_day_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_contact_training_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_prod_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_auth_list_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_appoint_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_callcard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_callcard_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_ord_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_ord_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_pos_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_survey_question_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_response_opt_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_task_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_task_assignment_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_task_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_task_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_task_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_survey_answer_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_graveyard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_cust_wholesaler_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_dist_check_1_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_dist_check_2_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_relay_hours_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_second_site_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_interuption_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_hardware_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_upgrades_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_training_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_shelf_share_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_compliant_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu5_act_dtl_new_prod_dev_tables.sql;


spool off
