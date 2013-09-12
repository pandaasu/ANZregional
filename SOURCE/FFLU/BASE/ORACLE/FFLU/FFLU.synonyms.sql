-- If you want to use public synonmys in this system use this script.  If you 
-- want to use private synonyms use the synonyms script in FFLU_APP schema.

-- Synonym for the sequence.
create or replace public synonym fflu_load_header for fflu.fflu_load_header;
create or replace public synonym fflu_load_data for fflu.fflu_load_data;
create or replace public synonym fflu_xaction_progress for fflu.fflu_xaction_progress;
create or replace public synonym fflu_xaction_writeback for fflu.fflu_xaction_writeback;

-- Setup the sequence.
create or replace public synonym fflu_load_seq for fflu.fflu_load_seq;
