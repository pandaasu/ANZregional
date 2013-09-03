-- Synonym for the sequence.
create or replace synonym fflu_load_seq for fflu.fflu_load_seq;

-- -------------------------------------------------------------------------------------------
-- Create Table Synonyms
-- -------------------------------------------------------------------------------------------  
create or replace synonym fflu_load_header for fflu.fflu_load_header;
create or replace synonym fflu_load_data for fflu.fflu_load_data;
create or replace synonym fflu_xaction_progress for fflu.fflu_xaction_progress;
create or replace synonym fflu_xaction_writeback for fflu.fflu_xaction_writeback;