/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_qv_load                                         */
/* Author  : Steve Gregan                                         */
/* Date    : March 2012                                           */
/*                                                                */
/******************************************************************/

/*----------------------------------------*/
/* MUST BE CONNECTED AS USER QV or QV_APP */
/*----------------------------------------*/

/*-*/
/* Create the QVI control data
/*-*/
prompt CREATING DASHBOARD DEFINITIONS ...

insert into qv.qvi_das_defn values('Dashboard Code', 'Dashboard Name', '1', user, sysdate);
insert into qv.qvi_fac_defn values('Dashboard Code', 'Fact Code', 'Fact Name', '1', '*NONE', 'Fact_Builder_Package', 'Fact_Table_Function', 'Fact_Data_Type', user, sysdate);
insert into qv.qvi_fac_part values('Dashboard Code', 'Fact Code', 'Part Code', 'Part Name', '1', 'Source_Table_Function', 'Source_Data_Type', user, sysdate);

prompt CREATING DIMENSION DEFINITIONS ...

insert into qv.qvi_dim_defn values('Dimension Code', 'Dimension Name', '1', 'Dimension_Table_Function', 'Dimension_Data_Type', '0', sysdate, sysdate, user, sysdate);

prompt COMMIT THE LOADING ...

commit;