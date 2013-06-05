-- This is the grant script required to be run on LICS schema for the 
-- purpose of the Flat File Loating Utility.
grant select on lics_sec_user to fflu_app;
grant select on lics_interface to fflu_app;
grant select on lics_group to fflu_app;
grant select on lics_grp_interface to fflu_app;
grant select on lics_sec_option to fflu_app;
grant select on lics_header to fflu_app;
grant select on lics_sec_link to fflu_app;
grant select on lics_sec_interface to fflu_app;
grant select on lics_hdr_message to fflu_app;
grant select on lics_dta_message to fflu_app;
grant select on lics_hdr_trace to fflu_app;
grant select on lics_data to fflu_app;
grant select on lics_interface to fflu_app;