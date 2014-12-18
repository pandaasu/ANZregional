/*******************************************************************************
/* Table Data
/*******************************************************************************
 System : pxi
 Table  : jdbc_connect_config
*******************************************************************************/

-- Clear Table
delete from jdbc_connect_config;

-- Populate Table
insert into jdbc_connect_config (connection_name,driver_class,connection_string,username,password) 
values ('PX_AU_PETCARE','com.microsoft.sqlserver.jdbc.SQLServerDriver','jdbc:sqlserver://mfants5.mars-ad.net:1433;instanceName=MI9997T;databaseName=PETCARE_TEST','PromaxPX_Reader','readonly');
insert into jdbc_connect_config (connection_name,driver_class,connection_string,username,password) 
values ('PX_AU_FOOD','com.microsoft.sqlserver.jdbc.SQLServerDriver','jdbc:sqlserver://mfants5.mars-ad.net:1433;instanceName=MI9997T;databaseName=FOOD_TEST','PromaxPX_Reader','readonly');


-- Commit Data
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

