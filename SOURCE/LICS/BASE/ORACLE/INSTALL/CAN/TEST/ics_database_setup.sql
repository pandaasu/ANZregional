execute dbms_java.grant_permission('DBEC','java.io.FilePermission','/ics/test/-','read,write,execute,delete');
execute dbms_java.grant_permission('DBEC','java.lang.RuntimePermission','*','readFileDescriptor,writeFileDescriptor');
execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/test/-','read,write,execute,delete');
execute dbms_java.grant_permission('LICS_APP','java.lang.RuntimePermission','*','readFileDescriptor,writeFileDescriptor');
commit;

create directory ics_inbound as '/ics/test/inbound';
create directory ics_outbound as '/ics/test/outbound';
create directory ics_view as '/ics/test/webview';
create directory ics_statistics as '/ics/test/statistics';

grant all on directory ics_inbound to lics_app;
grant all on directory ics_outbound to lics_app;
grant all on directory ics_view to lics_app;
grant all on directory ics_statistics to lics_app;

grant execute on dbms_pipe to lics_app;
grant execute on dbms_lock to lics_app;
