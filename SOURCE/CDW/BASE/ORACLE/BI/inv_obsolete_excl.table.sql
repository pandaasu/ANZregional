/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : inv_obsolete_excl
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Inventory - Obsolete Stock Exclusion  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-08-29  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
--  drop table bi.inv_obsolete_excl cascade constraints;
  
  -- Create Table
  create table bi.inv_obsolete_excl (
    matl_code varchar2(32 char) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.inv_obsolete_excl add constraint inv_obsolete_excl_pk primary key (matl_code)
    using index (create unique index bi.inv_obsolete_excl_pk on bi.inv_obsolete_excl (matl_code));


  -- Comments
  comment on table inv_obsolete_excl is 'Inventory - Obsolete Stock Exclusion';
  comment on column inv_obsolete_excl.matl_code is 'Material Code';
  comment on column inv_obsolete_excl.last_update_date is 'Last Update Date/Time';
  comment on column inv_obsolete_excl.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.inv_obsolete_excl to bi_app, lics_app with grant option;
  grant select on bi.inv_obsolete_excl to qv_user;

/*******************************************************************************
  END
*******************************************************************************/
