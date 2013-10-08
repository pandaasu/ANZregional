/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : com_pet_supplier_settings
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Commercial - Petcare - Supplier Settings  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2013-09-10  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
--  drop table bi.com_supplier_settings cascade constraints;
  
  -- Create Table
  create table bi.com_supplier_settings (
    supplier varchar2(32 char) not null,
    is_push varchar2(10 char),
    bus_sgmnt varchar2(4 char) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  -- no indexes defined

  -- Comments
  comment on table com_supplier_settings is 'Commercial - Petcare - Supplier Settings';
  comment on column com_supplier_settings.supplier is 'Supplier Code';
  comment on column com_supplier_settings.is_push is 'Push Supplier Indicator';
  comment on column com_supplier_settings.bus_sgmnt is 'Business Segment';
  comment on column com_supplier_settings.last_update_date is 'Last Update Date/Time';
  comment on column com_supplier_settings.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.com_supplier_settings to bi_app, lics_app with grant option;
  grant select on bi.com_supplier_settings to qv_user, bo_user, ods_app, lics_app;

/*******************************************************************************
  END
*******************************************************************************/
