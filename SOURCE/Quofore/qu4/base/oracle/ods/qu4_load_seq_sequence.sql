
set define off;

  /*****************************************************************************
  ** Sequence Definition
  ******************************************************************************

    System   : qu4
    Owner    : ods
    Sequence : qu4_load_seq
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Load Sequence

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2012-10-26  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Sequence DDL
drop sequence ods.qu4_load_seq;

create sequence ods.qu4_load_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

-- Synonyms
create or replace public synonym qu4_load_seq for ods.qu4_load_seq;

-- Grants
grant select on ods.qu4_load_seq to ods_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
