/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : mqm_material_risk
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  MQM Scorecard - Food - Material Risk  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-02-05  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table bi.mqm_material_risk cascade constraints;
  
  -- Create Table
  create table bi.mqm_material_risk (
    material varchar2(50 char) not null,
    material_family varchar2(100 char) null,
    risk varchar2(10 char) null,
    vendor number(16,0) not null,
    supplier_status varchar2(100 char) not null,
    last_purchase_date varchar2(100 char) null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  -- no indexes defined

  -- Comments
  comment on table mqm_material_risk is 'MQM Scorecard - Food - Material Risk';
  comment on column mqm_material_risk.material is 'Material';
  comment on column mqm_material_risk.material_family is 'Material Family';
  comment on column mqm_material_risk.risk is 'Ingredient Risk Rating';
  comment on column mqm_material_risk.vendor is 'Vendor Code';
  comment on column mqm_material_risk.supplier_status is 'Supplier Status for Raw';
  comment on column mqm_material_risk.last_purchase_date is 'Last Purchase Date';
  comment on column mqm_material_risk.last_update_date is 'Last Update Date/Time';
  comment on column mqm_material_risk.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.mqm_material_risk to bi_app, lics_app with grant option;
  grant select on bi.mqm_material_risk to qv_user, bo_user, dds_app, bi_app;

  -- Synonyms 
  create or replace public synonym mqm_material_risk for bi.mqm_material_risk;
  
/*******************************************************************************
  END
*******************************************************************************/
