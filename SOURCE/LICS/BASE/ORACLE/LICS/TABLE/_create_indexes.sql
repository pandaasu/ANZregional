/*-*/
/* Create indexes
/*-*/
create index lics_job_trace_ix01 on lics_job_trace
   (jot_status, jot_execution);

create index lics_header_ix01 on lics_header
   (hea_interface, hea_status, hea_header);

create index lics_header_ix02 on lics_header
   (hea_status, hea_crt_time, hea_header);

create index lics_hdr_trace_ix01 on lics_hdr_trace
   (het_execution, het_header, het_hdr_trace);

create index lics_dta_message_ix01 on lics_dta_message
   (dam_header, dam_dta_seq, dam_msg_seq);