/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : jdbc_connect_config
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table is used to manage the connection information to the various 
 promax databases.

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-16   Chris Horn             Created script.

*******************************************************************************/

-- Drop the Table
drop table jdbc_connect_config cascade constraints;

-- Table
create table jdbc_connect_config (	
  connection_name     varchar2(32 byte) not null enable, 
  driver_class        varchar2(256 byte) not null enable, 
  connection_string   varchar2(256 byte) not null enable, 
  username            varchar2(64 byte) not null enable,
  password            varchar2(64 byte) not null enable
);

-- Primary Key
alter table jdbc_connect_config add constraint jdbc_connect_config_pk primary key (connection_name)
  using index (create unique index jdbc_connect_config_pk on jdbc_connect_config(connection_name));
  
-- Comments
COMMENT ON TABLE jdbc_connect_config  IS 'JDBC Connection Configuration Information for Promax Connections.';
COMMENT ON COLUMN jdbc_connect_config.connection_name IS 'The name of the Connection.';
COMMENT ON COLUMN jdbc_connect_config.driver_class IS 'Drive class to use for the connections.';
COMMENT ON COLUMN jdbc_connect_config.connection_string IS 'The JDBC Connection string.';
COMMENT ON COLUMN jdbc_connect_config.username IS 'User Name';
COMMENT ON COLUMN jdbc_connect_config.password IS 'Pass word';

-- Grants
grant select, insert, update, delete on jdbc_connect_config to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
