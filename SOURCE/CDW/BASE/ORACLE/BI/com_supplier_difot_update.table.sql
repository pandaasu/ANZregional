/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : com_supplier_difot_update
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Commercial - Petcare - DIFOT Overwrite  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2013-09-10  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table bi.com_supplier_difot_update cascade constraints;
  
  -- Create Table
  create table bi.com_supplier_difot_update (
    mars_period number(6,0) not null,
    supplier varchar2(32 char) not null,
    difot_value number(5,2) not null,
    bus_sgmnt varchar2(4 char) not null,
    update_user varchar2(30 char) not null,
    user_comment varchar2(4000 char) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.com_supplier_difot_update add constraint com_supplier_difot_update_pk primary key (mars_period,supplier,bus_sgmnt)
    using index (create unique index bi.com_supplier_difot_update_pk on bi.com_supplier_difot_update (mars_period,supplier,bus_sgmnt));

  create index bi.com_supplier_difot_update_i0 on bi.com_supplier_difot_update (mars_period);  

  -- Comments
  comment on table com_supplier_difot_update is 'Commercial - Petcare - DIFOT Overwrite';
  comment on column com_supplier_difot_update.mars_period is 'Mars Period';
  comment on column com_supplier_difot_update.supplier is 'Supplier';
  comment on column com_supplier_difot_update.difot_value is 'DIFOT overwrite value';
  comment on column com_supplier_difot_update.bus_sgmnt is 'Business Segment';
  comment on column com_supplier_difot_update.update_user is 'User who entered the overwrite';
  comment on column com_supplier_difot_update.user_comment is 'Comments on why the overwrite was entered';
  comment on column com_supplier_difot_update.last_update_date is 'Last Update Date/Time';
  comment on column com_supplier_difot_update.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.com_supplier_difot_update to bi_app, lics_app with grant option;
  grant select on bi.com_supplier_difot_update to qv_user, bo_user, ods_app, lics_app;

/*******************************************************************************
  END
*******************************************************************************/
