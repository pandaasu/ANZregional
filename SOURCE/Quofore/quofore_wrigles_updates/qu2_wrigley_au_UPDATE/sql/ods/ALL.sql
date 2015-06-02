set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_load_seq_sequence.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_interface_hdr_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_interface_list_table.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_digest_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_hier_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_general_list_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_role_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_pos_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_rep_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_rep_addrs_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_prod_barcode_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_addrs_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_contact_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_visit_day_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_prod_assort_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_auth_list_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_appoint_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_callcard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_callcard_note_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_ord_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_ord_dtl_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_cust_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_pos_terr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_survey_question_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_response_opt_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_task_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_task_assign_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_task_cust_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_task_prod_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_task_survey_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_hdr_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_a_loc_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_sell_in_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_off_loc_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_facing_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_checkout_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_express_q_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_express_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_selfscan_q_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_selfscan_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_loc_oos_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_perm_disp_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_survey_answer_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_graveyard_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_face_aisle_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_face_expre_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_face_selfs_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_face_stand_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_comp_act_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_comp_face_tables.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods/qu2_act_dtl_exec_compl_tables.sql;


spool off
