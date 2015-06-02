/*******************************************************************************
** Table Definition
********************************************************************************

 System : qu2
 Table  : qu2_interface_list
 Owner  : ods
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Quofore Interface Control : Interface / Entity / Table List

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2015-03-04   Mal Chambeyron         Updated Interface List

*******************************************************************************/

-- NEW Loader: Interface [qu2cdw54] Entity [ActivityDetailCompetitionActivity] Table [qu2_act_dtl_comp_act]
-- NEW Loader: Interface [qu2cdw55] Entity [ActivityDetailCompetitionFacings] Table [qu2_act_dtl_comp_face]
-- NEW Loader: Interface [qu2cdw56] Entity [ActivityDetailExecCompliance] Table [qu2_act_dtl_exec_compl]
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW54','ACTIVITYDETAILCOMPETITIONACTIVITY','QU2_ACT_DTL_COMP_ACT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW55','ACTIVITYDETAILCOMPETITIONFACINGS','QU2_ACT_DTL_COMP_FACE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW56','ACTIVITYDETAILEXECCOMPLIANCE','QU2_ACT_DTL_EXEC_COMPL');
-- RETIRE Loader: Interface [qu2cdw36] Entity [ActivityDetailSecLocFridge] Table [qu2_act_dtl_fridge]
-- RETIRE Loader: Interface [qu2cdw37] Entity [ActivityDetailSecLocCafeUnit] Table [qu2_act_dtl_cafe_unit]
delete from qu2_interface_list where q4x_interface_name in ('QU2CDW36', 'QU2CDW37');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
