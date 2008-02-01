/**/
/* Foreign Key Constraints
/**/
alter table lics_data
   add constraint lics_data_fk01 foreign key (dat_header)
      references lics_header (hea_header);
alter table lics_dta_message
   add constraint lics_dta_message_fk01 foreign key (dam_header, dam_dta_seq)
      references lics_data (dat_header, dat_dta_seq);
alter table lics_dta_message
   add constraint lics_dta_message_fk02 foreign key (dam_header, dam_hdr_trace)
      references lics_hdr_trace (het_header, het_hdr_trace);
alter table lics_grp_interface
   add constraint lics_grp_interface_fk01 foreign key (gri_group)
      references lics_group (gro_group);
alter table lics_hdr_message
   add constraint lics_hdr_message_fk01 foreign key (hem_header, hem_hdr_trace)
      references lics_hdr_trace (het_header, het_hdr_trace);
alter table lics_hdr_search
   add constraint lics_hdr_search_fk01 foreign key (hes_header)
      references lics_header (hea_header);
alter table lics_hdr_trace
   add constraint lics_hdr_trace_fk01 foreign key (het_header)
      references lics_header (hea_header);
alter table lics_hdr_trace
   add constraint lics_hdr_trace_fk02 foreign key (het_execution)
      references lics_job_trace (jot_execution);
alter table lics_header
   add constraint lics_header_fk01 foreign key (hea_interface)
      references lics_interface (int_interface);
alter table lics_int_reference
   add constraint lics_int_reference_fk01 foreign key (inr_interface)
      references lics_interface (int_interface);
alter table lics_int_sequence
   add constraint lics_int_sequence_fk01 foreign key (ins_interface)
      references lics_interface (int_interface);
alter table lics_job_trace
   add constraint lics_job_trace_fk01 foreign key (jot_job)
      references lics_job (job_job);
alter table lics_rtg_detail
   add constraint lics_rtg_detail_fk01 foreign key (rde_source)
      references lics_routing (rou_source);
alter table lics_rtg_detail
   add constraint lics_rtg_detail_fk02 foreign key (rde_interface)
      references lics_interface (int_interface);