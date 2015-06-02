
set define off;

  /*****************************************************************************
  ** Sequence Definition
  ******************************************************************************

    System   : qu3
    Owner    : ods
    Sequence : qu3_load_seq
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Load Sequence

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2012-10-26  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Sequence DDL
drop sequence ods.qu3_load_seq;

create sequence ods.qu3_load_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

-- Synonyms
create or replace public synonym qu3_load_seq for ods.qu3_load_seq;

-- Grants
grant select on ods.qu3_load_seq to ods_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
