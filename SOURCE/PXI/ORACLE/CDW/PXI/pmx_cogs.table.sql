/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : pxi
  Package   : pmx_cogs
  Author    : Chris Horn          

  Description
  ------------------------------------------------------------------------------
  Promax - COGS Interface  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2013-09-11  Chris Horn            [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table pxi.pmx_cogs cascade constraints;
  
  -- Create Table
  create table pxi.pmx_cogs (
    cmpny_code varchar2(3 char) not null,
    div_code varchar2(3 char) not null,
    mars_period number(6,0) not null,
    zrep_matl_code varchar2(18 byte) not null,
    cost number(7,2) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table pxi.pmx_cogs add constraint pmx_cogs_pk primary key (cmpny_code,div_code,mars_period,zrep_matl_code)
    using index (create unique index pxi.pmx_cogs_pk on pxi.pmx_cogs (cmpny_code,div_code,mars_period,zrep_matl_code));


  -- Comments
  comment on table pmx_cogs is 'Promax - COGS Interface';
  comment on column pmx_cogs.cmpny_code is 'Promax Company Code';
  comment on column pmx_cogs.div_code is 'Promax Division Code';
  comment on column pmx_cogs.mars_period is 'Mars Period';
  comment on column pmx_cogs.zrep_matl_code is 'ZREP Matl Code - Short';
  comment on column pmx_cogs.cost is 'Cost of Goods Sold';
  comment on column pmx_cogs.last_update_date is 'Last Update Date/Time';
  comment on column pmx_cogs.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on pxi.pmx_cogs to pxi_app, lics_app with grant option;
  grant select on pxi.pmx_cogs to pxi_app;

/*******************************************************************************
  END
*******************************************************************************/
