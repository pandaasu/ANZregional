/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_interface_ready_list_tab;
drop type qvi_interface_ready_list_obj;

create or replace type qvi_interface_ready_list_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Interface Code"                varchar2(64),
    "SQL Statement"                 varchar2(1024),
    "Interface Type"                varchar2(16), 
    "Polling Type"                  varchar2(16), 
    "Year"                          number(4),
    "Period"                        number(2),
    "Last Update"                   date,
    "Update Sequence"               number(15));
/

create or replace type qvi_interface_ready_list_tab as table of qvi_interface_ready_list_obj;
/
