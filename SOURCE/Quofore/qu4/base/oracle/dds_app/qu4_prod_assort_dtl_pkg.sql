
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu4_prod_assort_dtl_pkg as
  /***************************************************************-****************
  ** Package Definition
  ********************************************************************************

    System   : qu4
    Owner    : dds_app
    Package  : qu4_prod_assort_dtl_pkg
    Author   : [Auto-Generate]

    Description
    ------------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    View Package, Entity [ProductAssortmentDetail] Table [qu4_prod_assort_dtl][_load/_hist]

    Package provides standard access methods to the entities

    YYYY-MM-DD  Author                Description
    ----------  --------------------  --------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Convert Template to Latest Spec
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-26  Mal Chambeyron        Fix view primary key
    2014-07-14  [Auto-Generate]       [Auto-Generated] Created

  *******************************************************************************/

  -- Public : Type
  type qu4_prod_assort_dtl_type is table of ods.qu4_prod_assort_dtl_hist%rowtype;

  -- Public : Functions
  function view_at_date(p_date in date) return qu4_prod_assort_dtl_type pipelined;
  function view_history return qu4_prod_assort_dtl_type pipelined;

end qu4_prod_assort_dtl_pkg;
/

create or replace package body dds_app.qu4_prod_assort_dtl_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu4_prod_assort_dtl_pkg';
  g_entity_name constant varchar2(64 char) := 'ProductAssortmentDetail';
  g_source_id constant number(4) := qu4_constants.source_id;

  /*****************************************************************************
  ** Function : Return Entity : As at Date
  *****************************************************************************/
  function view_at_date(p_date in date) return qu4_prod_assort_dtl_type pipelined is

  begin

    for l_entity in (
      select *
      from qu4_prod_assort_dtl_hist
      where (id,q4x_batch_id) in (
        select id,
          max(q4x_batch_id) max_q4x_batch_id
        from qu4_prod_assort_dtl_hist
        where q4x_timestamp <= p_date
        and id not in (
          select id
          from qu4_graveyard_hist
          where entity = g_entity_name
          and q4x_timestamp <= p_date
        )
        group by id
      )
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_at_date] : '||SQLERRM, 1, 4000));

  end view_at_date; 

  /*****************************************************************************
  ** Function : Return Entity : History .. WARNING .. Does NOT Apply Graveyard
  *****************************************************************************/
  function view_history return qu4_prod_assort_dtl_type pipelined is

  begin

    for l_entity in (
      select *
      from qu4_prod_assort_dtl_hist
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

end qu4_prod_assort_dtl_pkg;
/

-- Synonyms
create or replace public synonym qu4_prod_assort_dtl_pkg for dds_app.qu4_prod_assort_dtl_pkg;

-- Grants
grant execute on dds_app.qu4_prod_assort_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
