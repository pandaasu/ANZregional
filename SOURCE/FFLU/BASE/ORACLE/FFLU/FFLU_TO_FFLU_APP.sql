-- This is the grant script from the base FFLU schema to the application
-- schema.
grant select, update, insert, delete on fflu_load_header to fflu_app;
grant select, update, insert, delete on fflu_load_data to fflu_app;
grant select, update, insert, delete on fflu_xaction_progress to fflu_app;

create or replace public synonym fflu_load_header for fflu.fflu_load_header;
create or replace public synonym fflu_load_data for fflu.fflu_load_data;
create or replace public synonym fflu_xaction_progress for fflu.fflu_xaction_progress;

-- Setup the sequence.
grant select on fflu_load_seq to fflu_app;
create or replace public synonym fflu_load_seq for fflu.fflu_load_seq;
