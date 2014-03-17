prompt :: Create Table [jdbc_connect_config] ::::::::::::::::::::::::::::::::::::::::::

/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : df
 Table  : jdbc_connect_config
 Owner  : df
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Repository of JDBC Connection Configuration

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-05   Mal Chambeyron         Created

*******************************************************************************/

-- Table 
drop table df.jdbc_connect_config cascade constraints;

create table df.jdbc_connect_config (
  connection_name                 varchar2(32 char)               not null,
  driver_class                    varchar2(256 char)              not null,
  connection_string               varchar2(256 char)              not null,
  username                        varchar2(64 char)               not null,
  password                        varchar2(64 char)               not null
)
;

-- Keys

alter table df.jdbc_connect_config add constraint jdbc_connect_config_pk primary key (connection_name)
  using index (create unique index df.jdbc_connect_config_pk on df.jdbc_connect_config(connection_name));

-- Comments

comment on table jdbc_connect_config is 'Repository of JDBC Connection Configuration';
comment on column jdbc_connect_config.connection_name is 'Unique Connection Name';
comment on column jdbc_connect_config.driver_class is 'JDBC Driver Class Name, Case Sensitive';
comment on column jdbc_connect_config.connection_string is 'Database Connection String, Case Sensitive';
comment on column jdbc_connect_config.username is 'Username, Case Sensitive';
comment on column jdbc_connect_config.password is 'Password, Case Sensitive';

-- Synonyms

create or replace public synonym jdbc_connect_config for df.jdbc_connect_config;

-- Grants

grant select on df.jdbc_connect_config to df_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

