
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu3_assort_pkg as
  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu3
    Owner    : ods
    Package  : qu3_assort_pkg
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Interface / Entity / Table List

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-12  Mal Chambeyron        Created
    2013-03-20  Mal Chambeyron        Correct the way we Determine Core Products
    2013-07-11  Mal Chambeyron        Cloned for Wrigley NZ
    2013-07-11  Mal Chambeyron        Remove need to provide Source Id
    2013-07-11  Mal Chambeyron        Remove Lookup (as no longer provided)
    2014-05-18  Mal Chambeyron        Make into a Template
    2014-05-28  Mal Chambeyron        Cleanup Source Id
    2014-07-02  Mal Chambeyron        Added Store Size Hierarchy to [cust_hier_view_at_date]
    2015-03-17  Mal Chambeyron        Add code to Automatically Generate Hierarchies for each
                                      *_hier_id column found in Customer and Produce
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-06  Mal Chambeyron        Add Direct Assignments back to Customer / Product Hierarchies
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Type : Shared Customer / Product Hierarchy -----------------------
  type qu3_hier_rec is record (
    report_date date,
    --
    node_hier_priority number(3),
    node_hier_type varchar2(50 char),
    --
    root_node varchar2(50 char),
    root_node_type varchar2(50 char),
    root_node_id number(10,0),
    root_node_batch_id number(15,0),
    root_node_code varchar2(50 char),
    root_node_desc varchar2(50 char),
    root_node_level number(3,0),
    --
    node varchar2(50 char),
    node_type varchar2(50 char),
    node_id number(10,0),
    node_batch_id number(15,0),
    node_code varchar2(50 char),
    node_desc varchar2(50 char),
    node_level number(3,0),
    --
    node_direct_flag number(1,0),
    --
    node_path varchar2(256 char)
  );

  type qu3_hier_type is table of qu3_hier_rec;

  -- Public : Type : Assortment Detail -----------------------------------------
  type qu3_assort_dtl_rec is record (
    report_date date,
    --
    assort_id number(10,0),
    assort_desc varchar2(50 char),
    --
    root_node_type varchar2(100 char),
    root_node_id number(10,0),
    root_node_batch_id number(15,0),
    root_node_desc varchar2(50 char),
    root_node_level number(3,0),
    --
    node_type varchar2(100 char),
    node_id number(10,0),
    node_batch_id number(15,0),
    node_desc varchar2(50 char),
    node_level number(3,0),
    --
    node_direct_flag number(1,0),
    --
    node_path varchar2(256 char)
  );

  type qu3_assort_dtl_type is table of qu3_assort_dtl_rec;

  -- Public : Type : Customer Assortment ---------------------------------------
  type qu3_cust_assort_rec is record (
    report_date date,
    --
    assort_id number(10,0),
    assort_desc varchar2(50 char),
    --
    root_assort_dtl_type varchar2(50 char),
    root_assort_dtl_id number(10,0),
    root_assort_dtl_batch_id number(15,0),
    root_assort_dtl_desc varchar2(50 char),
    root_assort_dtl_level number(3,0),
    --
    assort_dtl_type varchar2(50 char),
    assort_dtl_id number(10,0),
    assort_dtl_batch_id number(15,0),
    assort_dtl_desc varchar2(50 char),
    assort_dtl_level number(3,0),
    --
    assort_dtl_direct_flag number(1,0),
    --
    cust_assort_dtl_id number(10,0),
    cust_assort_dtl_batch_id number(15,0),
    --
    cust_hier_priority number(3),
    cust_hier_type varchar2(50 char),
    --
    root_cust_node varchar2(50 char),
    root_cust_type varchar2(50 char),
    root_cust_id number(10,0),
    root_cust_batch_id number(15,0),
    root_cust_code varchar2(50 char),
    root_cust_desc varchar2(50 char),
    root_cust_level number(3,0),
    --
    cust_type varchar2(50 char),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    cust_code varchar2(50 char),
    cust_desc varchar2(50 char),
    cust_level number(3,0),
    --
    cust_direct_flag number(1,0),
    --
    cust_hier_path varchar2(256 char),
    segment_hier_path varchar2(256 char)
  );

  type qu3_cust_assort_type is table of qu3_cust_assort_rec;

  -- Public : Type : Product Assortment ---------------------------------------
  type qu3_prod_assort_rec is record (
    report_date date,
    --
    assort_id number(10,0),
    assort_desc varchar2(50 char),
    --
    root_assort_dtl_type varchar2(100 char),
    root_assort_dtl_id number(10,0),
    root_assort_dtl_batch_id number(15,0),
    root_assort_dtl_desc varchar2(50 char),
    root_assort_dtl_level number(3,0),
    --
    assort_dtl_type varchar2(100 char),
    assort_dtl_id number(10,0),
    assort_dtl_batch_id number(15,0),
    assort_dtl_desc varchar2(50 char),
    assort_dtl_level number(3,0),
    --
    assort_dtl_direct_flag number(1,0),
    --
    prod_assort_dtl_id number(10,0),
    prod_assort_dtl_batch_id number(15,0),
    --
    prod_assort_dtl_effective_from date,
    prod_assort_dtl_effective_to date,
    --
    prod_hier_priority number(3),
    prod_hier_type varchar2(50 char),
    --
    root_prod_node varchar2(50 char),
    root_prod_type varchar2(50 char),
    root_prod_id number(10,0),
    root_prod_batch_id number(15,0),
    root_prod_code varchar2(50 char),
    root_prod_desc varchar2(50 char),
    root_prod_level number(3,0),
    --
    prod_type varchar2(50 char),
    prod_id number(10,0),
    prod_batch_id number(15,0),
    prod_code varchar2(50 char),
    prod_desc varchar2(50 char),
    prod_level number(3,0),
    --
    prod_direct_flag number(1,0),
    --
    prod_hier_path varchar2(256 char),
    segment_hier_path varchar2(256 char)
  );

  type qu3_prod_assort_type is table of qu3_prod_assort_rec;

-- Public : Type : Customer / Procuct Assortment -------------------------------
  type qu3_cust_prod_assort_rec is record (
    report_date date,
    --
    cust_id number(10,0),
    prod_id number(10,0),
    assort_id number(10,0),
    assort_dtl_id number(10,0)
  );

  type qu3_cust_prod_assort_type is table of qu3_cust_prod_assort_rec;

  -- Public : Type : Master Assortment -----------------------------------------
  type qu3_master_assort_rec is record (
    report_date date,
    --
    cust_id number(10,0),
    prod_id number(10,0),
    prod_assort_id number(10,0),
    prod_assort_dtl_id number(10,0),
    core_assort_id number(10,0),
    core_assort_dtl_id number(10,0),
    --
    core_flag number(1,0)
  );

  type qu3_master_assort_type is table of qu3_master_assort_rec;

  -- Public : Functions --------------------------------------------------------
  function cust_hier_view_at_date(p_at_date in date) return qu3_hier_type pipelined;
  function prod_hier_view_at_date(p_at_date in date) return qu3_hier_type pipelined;

  function segment_hier_view_at_date(p_at_date in date) return qu3_assort_dtl_type pipelined;
  function segment_up_hier_view_at_date(p_at_date in date) return qu3_assort_dtl_type pipelined;

  function cust_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_assort_type pipelined;
  function prod_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_prod_assort_type pipelined;
  function core_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_prod_assort_type pipelined;
  function cust_prod_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_prod_assort_type pipelined;
  function cust_core_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_prod_assort_type pipelined;

  function master_assort_view_at_date(p_at_date in date) return qu3_master_assort_type pipelined;

end qu3_assort_pkg;
/

create or replace package body qu3_assort_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu3_assort_pkg';

  /*****************************************************************************
  ** Function : Customer Hierarchy, as at Date
  *****************************************************************************/
  function cust_hier_view_at_date(p_at_date in date) return qu3_hier_type pipelined is

  begin

    for l_entity in (

      select *
      from (
        select p_at_date report_date,
          --
          node_hier_priority,
          node_hier_type,
          --
          connect_by_root node root_node,
          connect_by_root node_type root_node_type,
          connect_by_root node_id root_node_id,
          connect_by_root batch_id root_node_batch_id,
          connect_by_root node_code root_node_code,
          connect_by_root node_desc root_node_desc,
          connect_by_root node_level root_node_level,
          --
          node,
          node_type,
          node_id,
          batch_id node_batch_id,
          node_code,
          node_desc,
          node_level,
          --
          decode(connect_by_root node,node,1,0) node_direct_flag,
          --
          'Customer ['||connect_by_root node_type||':'||connect_by_root node_desc||'] '||sys_connect_by_path(node_desc,'\\') node_path
        from (
          --
          -- Hierarchy
          select q4x_batch_id batch_id,
            999 node_hier_priority,
            'Hierarchy:Hierarchy' node_hier_type,
            'Hierarchy:'||id node,
            'Hierarchy' node_type,
            id node_id,
            null node_code,
            id_desc node_desc,
            decode(parent_id,null,null,'Hierarchy:')||parent_id parent_node,
            decode(parent_id,null,null,'Hierarchy') parent_node_type,
            hier_level node_level
          from table(qu3_hier_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- Direct Customer
          select q4x_batch_id batch_id,
            0 node_hier_priority,
            'Customer:Customer' node_hier_type,
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            cust_ref_id node_code,
            cust_name node_desc,
            'Customer:'||id parent_node,
            'Customer' parent_node_type,
            999 node_level
          from table(qu3_cust_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- [CUST:cust_hier_id] Customer > Hierarchy
          select q4x_batch_id batch_id,
            0 node_hier_priority,
            'Customer:CUST' node_hier_type,
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            cust_ref_id node_code,
            cust_name node_desc,
            'Hierarchy:'||cust_hier_id parent_node,
            'Hierarchy' parent_node_type,
            998 node_level
          from table(qu3_cust_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          and cust_hier_id is not null
          --
          union all
          --
          -- [GRADE:grade_hier_id] Customer > Hierarchy
          select q4x_batch_id batch_id,
            0 node_hier_priority,
            'Customer:GRADE' node_hier_type,
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            cust_ref_id node_code,
            cust_name node_desc,
            'Hierarchy:'||grade_hier_id parent_node,
            'Hierarchy' parent_node_type,
            998 node_level
          from table(qu3_cust_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          and grade_hier_id is not null
          --
        ) a
        connect by nocycle prior node = parent_node -- nocycle, insurance against loops
      )
      where node_level > 997 -- restrict to customer level leaves

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_hier_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_hier_view_at_date;

  /*****************************************************************************
  ** Function : Product Hierarchy, as at Date
  *****************************************************************************/
  function prod_hier_view_at_date(p_at_date in date) return qu3_hier_type pipelined is

  begin

    for l_entity in (

      select *
      from (
        select p_at_date report_date,
          --
          node_hier_priority,
          node_hier_type,
          --
          connect_by_root node root_node,
          connect_by_root node_type root_node_type,
          connect_by_root node_id root_node_id,
          connect_by_root batch_id root_node_batch_id,
          connect_by_root node_code root_node_code,
          connect_by_root node_desc root_node_desc,
          connect_by_root node_level root_node_level,
          --
          node,
          node_type,
          node_id,
          batch_id node_batch_id,
          node_code,
          node_desc,
          node_level,
          --
          decode(connect_by_root node,node,1,0) node_direct_flag,
          --
          'Product ['||connect_by_root node_type||':'||connect_by_root node_desc||'] '||sys_connect_by_path(node_desc,'\\') node_path
        from (
          --
          -- Hierarchy
          select q4x_batch_id batch_id,
            999 node_hier_priority,
            'Hierarchy:Hierarchy' node_hier_type,
            'Hierarchy:'||id node,
            'Hierarchy' node_type,
            id node_id,
            null node_code,
            id_desc node_desc,
            decode(parent_id,null,null,'Hierarchy:')||parent_id parent_node,
            decode(parent_id,null,null,'Hierarchy') parent_node_type,
            hier_level node_level
          from table(qu3_hier_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- Product Direct
          select q4x_batch_id batch_id,
            0 node_hier_priority,
            'Product:Product' node_hier_type,
            'Product:'||id node,
            'Product' node_type,
            id node_id,
            sku_code node_code,
            name node_desc,
            'Product:'||id parent_node,
            'Product' parent_node_type,
            999 node_level
          from table(qu3_prod_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- [PROD:prod_hier_id] Product > Hierarchy
          select q4x_batch_id batch_id,
            0 node_hier_priority,
            'Product:PROD' node_hier_type,
            'Product:'||id node,
            'Product' node_type,
            id node_id,
            sku_code node_code,
            name node_desc,
            'Hierarchy:'||prod_hier_id parent_node,
            'Hierarchy' parent_node_type,
            998 node_level
          from table(qu3_prod_pkg.view_at_date(p_at_date))
          where is_active = 1 -- active
          and prod_hier_id is not null
          --
        ) a
        connect by nocycle prior node = parent_node -- nocycle, insurance against loops
      )
      where node_level > 997 -- restrict to product level leaves

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.prod_hier_view_at_date] : '||SQLERRM, 1, 4000));

  end prod_hier_view_at_date;

  /*****************************************************************************
  ** Function : Segment Down Hierarchy (Regular), as at Date
  *****************************************************************************/
  function segment_hier_view_at_date(p_at_date in date) return qu3_assort_dtl_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        assort_id,
        name assort_desc,
        --
        connect_by_root assort_dtl_type_id_desc root_node_type,
        connect_by_root id root_node_id,
        connect_by_root q4x_batch_id root_node_batch_id,
        connect_by_root assort_dtl_name root_node_desc,
        connect_by_root to_number(hier_level) root_node_level,
        --
        assort_dtl_type_id_desc node_type,
        id node_id,
        q4x_batch_id node_batch_id,
        assort_dtl_name node_desc,
        to_number(hier_level) node_level,
        --
        decode(connect_by_root id,id,1,0) node_direct_flag,
        --
        'Segment '||name||' ['||connect_by_root assort_dtl_name||'] '||decode(assort_dtl_type_id_desc,'Segment',null,sys_connect_by_path(assort_dtl_name,'\\')) node_path
      from table(qu3_assort_dtl_pkg.view_at_date(p_at_date))
      where assort_dtl_type_id_desc in ('Segment','Strata','Cluster') -- Segment/Strata/Cluster KNOWN Types
      connect by nocycle prior id = parent_id -- nocycle, insurance against loops

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.segment_hier_view_at_date] : '||SQLERRM, 1, 4000));

  end segment_hier_view_at_date;

  /*****************************************************************************
  ** Function : Segment Up Hierarchy (Reverse), as at Date
  *****************************************************************************/
  function segment_up_hier_view_at_date(p_at_date in date) return qu3_assort_dtl_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        assort_id,
        name assort_desc,
        --
        connect_by_root assort_dtl_type_id_desc root_node_type,
        connect_by_root id root_node_id,
        connect_by_root q4x_batch_id root_node_batch_id,
        connect_by_root assort_dtl_name root_node_desc,
        connect_by_root to_number(hier_level) root_node_level,
        --
        assort_dtl_type_id_desc node_type,
        id node_id,
        q4x_batch_id node_batch_id,
        assort_dtl_name node_desc,
        to_number(hier_level) node_level,
        --
        decode(connect_by_root id,id,1,0) node_direct_flag,
        --
        'Segment* '||name||' ['||connect_by_root assort_dtl_name||'] '||decode(assort_dtl_type_id_desc,'Segment',null,sys_connect_by_path(assort_dtl_name,'\\')) node_path
      from table(qu3_assort_dtl_pkg.view_at_date(p_at_date))
      where assort_dtl_type_id_desc in ('Segment','Strata','Cluster') -- Segment/Strata/Cluster KNOWN Types
      --where assort_dtl_type_id_desc in ('Segment','Strata') -- Cluster NOT Valid for Core Hierarchy
      connect by nocycle prior parent_id = id -- nocycle, insurance against loops -- Reverse Order of Other Hierarchies

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.segment_up_hier_view_at_date] : '||SQLERRM, 1, 4000));

  end segment_up_hier_view_at_date;

  /*****************************************************************************
  ** Function : Customer Assortment, as at Date
  *****************************************************************************/
  function cust_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_assort_type pipelined is

    l_cust_id number(10,0);
    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);

  begin

    l_cust_id := -1;
    l_assort_id := -1;
    l_assort_dtl_id := -1;

    for l_entity in (

      select p_at_date report_date,
        --
        segment_hier.assort_id,
        segment_hier.assort_desc,
        --
        segment_hier.root_node_type root_assort_dtl_type,
        segment_hier.root_node_id root_assort_dtl_id,
        segment_hier.root_node_batch_id root_assort_dtl_batch_id,
        segment_hier.root_node_desc root_assort_dtl_desc,
        segment_hier.root_node_level root_assort_dtl_level,
        --
        segment_hier.node_type assort_dtl_type,
        segment_hier.node_id assort_dtl_id,
        segment_hier.node_batch_id assort_dtl_batch_id,
        segment_hier.node_desc assort_dtl_desc,
        segment_hier.node_level assort_dtl_level,
        --
        segment_hier.node_direct_flag assort_dtl_direct_flag,
        --
        cust_assort_dtl.id cust_assort_dtl_id,
        cust_assort_dtl.q4x_batch_id cust_assort_dtl_batch_id,
        --
        cust_hier.node_hier_priority cust_hier_priority,
        cust_hier.node_hier_type cust_hier_type,
        --
        cust_hier.root_node root_cust_node,
        cust_hier.root_node_type root_cust_type,
        cust_hier.root_node_id root_cust_id,
        cust_hier.root_node_batch_id root_cust_batch_id,
        cust_hier.root_node_code root_cust_code,
        cust_hier.root_node_desc root_cust_desc,
        cust_hier.root_node_level root_cust_level,
        --
        cust_hier.node_type cust_type,
        cust_hier.node_id cust_id,
        cust_hier.node_batch_id cust_batch_id,
        cust_hier.node_code cust_code,
        cust_hier.node_desc cust_desc,
        cust_hier.node_level cust_level,
        --
        cust_hier.node_direct_flag cust_direct_flag,

        cust_hier.node_path cust_hier_path,
        segment_hier.node_path segment_hier_path
        --
      from table(qu3_assort_pkg.cust_hier_view_at_date(p_at_date)) cust_hier,
        table(qu3_cust_assort_dtl_pkg.view_at_date(p_at_date)) cust_assort_dtl,
        table(qu3_assort_pkg.segment_hier_view_at_date(p_at_date)) segment_hier
      where cust_hier.node_type = 'Customer'
      and cust_hier.root_node = decode(cust_assort_dtl.cust_id,null,'Hierarchy:'||cust_assort_dtl.cust_hier_node_id,'Customer:'||cust_assort_dtl.cust_id)
      and cust_assort_dtl.assort_dtl_id = segment_hier.root_node_id
      order by cust_hier.node_id, -- cust_id
        segment_hier.assort_id, -- assort_id
        segment_hier.node_direct_flag desc, -- assort_dtl_direct_flag
        segment_hier.node_level desc, -- assort_dtl_level,
        cust_hier.node_direct_flag desc, -- cust_direct_flag
        cust_hier.root_node_level desc -- root_cust_level

    )
    loop

      if p_filtered != 0 then -- Apply Filter Logic
        -- Return Lowest Assigned Strata for a given Customer / Strata
        if l_entity.assort_dtl_type = 'Strata' then
          if l_cust_id != l_entity.cust_id or l_assort_id != l_entity.assort_id or l_assort_dtl_id != l_entity.assort_dtl_id then
            l_cust_id := l_entity.cust_id;
            l_assort_id := l_entity.assort_id;
            l_assort_dtl_id := l_entity.assort_dtl_id;
            pipe row(l_entity);
          end if;
        elsif l_entity.assort_dtl_type = 'Cluster' then -- Return ALL Clusters
          pipe row(l_entity);
        end if;
      else -- Return ALL
        pipe row(l_entity);
      end if;

    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_assort_view_at_date;

  /*****************************************************************************
  ** Function : Product Assortment, as at Date
  *****************************************************************************/
  function prod_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_prod_assort_type pipelined is

    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_assort_id := -1;
    l_assort_dtl_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_at_date report_date,
        --
        segment_hier.assort_id,
        segment_hier.assort_desc,
        --
        segment_hier.root_node_type root_assort_dtl_type,
        segment_hier.root_node_id root_assort_dtl_id,
        segment_hier.root_node_batch_id root_assort_dtl_batch_id,
        segment_hier.root_node_desc root_assort_dtl_desc,
        segment_hier.root_node_level root_assort_dtl_level,
        --
        segment_hier.node_type assort_dtl_type,
        segment_hier.node_id assort_dtl_id,
        segment_hier.node_batch_id assort_dtl_batch_id,
        segment_hier.node_desc assort_dtl_desc,
        segment_hier.node_level assort_dtl_level,
        --
        segment_hier.node_direct_flag assort_dtl_direct_flag,
        --
        prod_assort_dtl.id prod_assort_dtl_id,
        prod_assort_dtl.q4x_batch_id prod_assort_dtl_batch_id,
        --
        prod_assort_dtl.effective_from prod_assort_dtl_effective_from,
        prod_assort_dtl.effective_to prod_assort_dtl_effective_to,
        --
        prod_hier.node_hier_priority prod_hier_priority,
        prod_hier.node_hier_type prod_hier_type,
        --
        prod_hier.root_node root_prod_node,
        prod_hier.root_node_type root_prod_type,
        prod_hier.root_node_id root_prod_id,
        prod_hier.root_node_batch_id root_prod_batch_id,
        prod_hier.root_node_code root_prod_code,
        prod_hier.root_node_desc root_prod_desc,
        prod_hier.root_node_level root_prod_level,
        --
        prod_hier.node_type prod_type,
        prod_hier.node_id prod_id,
        prod_hier.node_batch_id prod_batch_id,
        prod_hier.node_code prod_code,
        prod_hier.node_desc prod_desc,
        prod_hier.node_level prod_level,
        --
        prod_hier.node_direct_flag prod_direct_flag,
        --
        prod_hier.node_path prod_hier_path,
        segment_hier.node_path segment_hier_path
        --
      from table(qu3_assort_pkg.prod_hier_view_at_date(p_at_date)) prod_hier,
        table(qu3_prod_assort_dtl_pkg.view_at_date(p_at_date)) prod_assort_dtl,
        table(qu3_assort_pkg.segment_hier_view_at_date(p_at_date)) segment_hier
      where prod_hier.node_type = 'Product'
      and prod_hier.root_node = decode(prod_assort_dtl.prod_id,null,'Hierarchy:'||prod_assort_dtl.prod_hier_node_id,'Product:'||prod_assort_dtl.prod_id)
      and p_at_date between nvl(prod_assort_dtl.effective_from,to_date('00010101','YYYYMMDD')) and nvl(prod_assort_dtl.effective_to,to_date('99991231','YYYYMMDD'))
      and prod_assort_dtl.assort_dtl_id = segment_hier.root_node_id
      order by prod_hier.node_id, -- prod_id
        segment_hier.assort_id, -- assort_id
        segment_hier.node_direct_flag desc, -- assort_dtl_direct_flag
        segment_hier.node_level, -- assort_dtl_level,
        prod_hier.node_direct_flag desc, -- prod_direct_flag
        prod_hier.root_node_level desc -- root_prod_level

    )
    loop

      if p_filtered != 0 then -- Apply Filter Logic
        -- Return Lowest Assigned Strata for a given Product / Strata
        if l_entity.assort_dtl_type = 'Strata' then
          if l_prod_id != l_entity.prod_id or l_assort_id != l_entity.assort_id or l_assort_dtl_id != l_entity.assort_dtl_id then
            l_prod_id := l_entity.prod_id;
            l_assort_id := l_entity.assort_id;
            l_assort_dtl_id := l_entity.assort_dtl_id;
            pipe row(l_entity);
          end if;
        elsif l_entity.assort_dtl_type = 'Cluster' then -- Return ALL Clusters
          pipe row(l_entity);
        end if;
      else -- Return ALL
        pipe row(l_entity);
      end if;

    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.prod_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end prod_assort_view_at_date;

  /*****************************************************************************
  ** Function : Core Assortment, as at Date
  *****************************************************************************/
  function core_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_prod_assort_type pipelined is

    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_assort_id := -1;
    l_assort_dtl_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_at_date report_date,
        --
        core_hier.assort_id,
        core_hier.assort_desc,
        --
        core_hier.root_node_type root_assort_dtl_type,
        core_hier.root_node_id root_assort_dtl_id,
        core_hier.root_node_batch_id root_assort_dtl_batch_id,
        core_hier.root_node_desc root_assort_dtl_desc,
        core_hier.root_node_level root_assort_dtl_level,
        --
        core_hier.node_type assort_dtl_type,
        core_hier.node_id assort_dtl_id,
        core_hier.node_batch_id assort_dtl_batch_id,
        core_hier.node_desc assort_dtl_desc,
        core_hier.node_level assort_dtl_level,
        --
        core_hier.node_direct_flag assort_dtl_direct_flag,
        --
        prod_assort_dtl.id prod_assort_dtl_id,
        prod_assort_dtl.q4x_batch_id prod_assort_dtl_batch_id,
        --
        prod_assort_dtl.effective_from prod_assort_dtl_effective_from,
        prod_assort_dtl.effective_to prod_assort_dtl_effective_to,
        --
        prod_hier.node_hier_priority prod_hier_priority,
        prod_hier.node_hier_type prod_hier_type,
        --
        prod_hier.root_node root_prod_node,
        prod_hier.root_node_type root_prod_type,
        prod_hier.root_node_id root_prod_id,
        prod_hier.root_node_batch_id root_prod_batch_id,
        prod_hier.root_node_code root_prod_code,
        prod_hier.root_node_desc root_prod_desc,
        prod_hier.root_node_level root_prod_level,
        --
        prod_hier.node_type prod_type,
        prod_hier.node_id prod_id,
        prod_hier.node_batch_id prod_batch_id,
        prod_hier.node_code prod_code,
        prod_hier.node_desc prod_desc,
        prod_hier.node_level prod_level,
        --
        prod_hier.node_direct_flag prod_direct_flag,
        --
        prod_hier.node_path prod_hier_path,
        core_hier.node_path segment_hier_path
        --
      from table(qu3_assort_pkg.prod_hier_view_at_date(p_at_date)) prod_hier,
        table(qu3_prod_assort_dtl_pkg.view_at_date(p_at_date)) prod_assort_dtl,
        table(qu3_assort_pkg.segment_up_hier_view_at_date(p_at_date)) core_hier
      where prod_hier.node_type = 'Product'
      and prod_hier.root_node = decode(prod_assort_dtl.prod_id,null,'Hierarchy:'||prod_assort_dtl.prod_hier_node_id,'Product:'||prod_assort_dtl.prod_id)
      and p_at_date between nvl(prod_assort_dtl.effective_from,to_date('00010101','YYYYMMDD')) and nvl(prod_assort_dtl.effective_to,to_date('99991231','YYYYMMDD'))
      and prod_assort_dtl.priority_assort_dtl_id = core_hier.root_node_id
      order by prod_hier.node_id, -- prod_id
        core_hier.assort_id, -- assort_id
        core_hier.node_direct_flag desc, -- assort_dtl_direct_flag
        core_hier.node_level, -- assort_dtl_level,
        prod_hier.node_direct_flag desc, -- prod_direct_flag
        prod_hier.root_node_level -- root_prod_level

    )
    loop

      if p_filtered != 0 then -- Apply Filter Logic
        -- Return Lowest Assigned Strata for a given Product / Strata
        if l_entity.assort_dtl_type = 'Strata' then
          if l_prod_id != l_entity.prod_id or l_assort_id != l_entity.assort_id or l_assort_dtl_id != l_entity.assort_dtl_id then
            l_prod_id := l_entity.prod_id;
            l_assort_id := l_entity.assort_id;
            l_assort_dtl_id := l_entity.assort_dtl_id;
            pipe row(l_entity);
          end if;
        elsif l_entity.assort_dtl_type = 'Cluster' then -- Return ALL Clusters
          pipe row(l_entity);
        end if;
      else -- Return ALL
        pipe row(l_entity);
      end if;

    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.core_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end core_assort_view_at_date;

  /*****************************************************************************
  ** Function : Customer/Product Assortment, as at Date
  *****************************************************************************/
  function cust_prod_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_prod_assort_type pipelined is

    l_cust_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_cust_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_at_date report_date,
        --
        cust.cust_id,
        prod.prod_id,
        cust.assort_id,
        prod.assort_dtl_id
      from table(qu3_assort_pkg.cust_assort_view_at_date(p_at_date,p_filtered)) cust,
        table(qu3_assort_pkg.prod_assort_view_at_date(p_at_date,p_filtered)) prod
      where cust.assort_id = prod.assort_id
      and cust.assort_dtl_id = prod.assort_dtl_id
      --
      order by cust.cust_id,
        prod.prod_id,
        cust.assort_dtl_level,
        cust.assort_id,
        prod.assort_dtl_level

    )
    loop

      if p_filtered != 0 then -- Apply Filter Logic
        -- Return First Customer / Product Row
        if l_cust_id != l_entity.cust_id or l_prod_id != l_entity.prod_id then
          l_cust_id := l_entity.cust_id;
          l_prod_id := l_entity.prod_id;
          pipe row(l_entity);
        end if;
      else -- Return ALL
        pipe row(l_entity);
      end if;

    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_prod_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_prod_assort_view_at_date;

  /*****************************************************************************
  ** Function : Customer/Core Assortment, as at Date
  *****************************************************************************/
  function cust_core_assort_view_at_date(p_at_date in date, p_filtered in number) return qu3_cust_prod_assort_type pipelined is

    l_cust_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_cust_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_at_date report_date,
        --
        cust.cust_id,
        core.prod_id,
        cust.assort_id,
        core.assort_dtl_id
      from table(qu3_assort_pkg.cust_assort_view_at_date(p_at_date,p_filtered)) cust,
        table(qu3_assort_pkg.core_assort_view_at_date(p_at_date,p_filtered)) core
      where cust.assort_id = core.assort_id
      and cust.assort_dtl_id = core.assort_dtl_id
      --
      order by cust.cust_id,
        core.prod_id,
        cust.assort_dtl_level desc,
        cust.assort_id,
        core.assort_dtl_level desc

    )
    loop

      if p_filtered != 0 then -- Apply Filter Logic
        -- Return First Customer / Core Row
        if l_cust_id != l_entity.cust_id or l_prod_id != l_entity.prod_id then
          l_cust_id := l_entity.cust_id;
          l_prod_id := l_entity.prod_id;
          pipe row(l_entity);
        end if;
      else -- Return ALL
        pipe row(l_entity);
      end if;

    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_core_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_core_assort_view_at_date;

  /*****************************************************************************
  ** Function : Master Assortment, as at Date
  *****************************************************************************/
  function master_assort_view_at_date(p_at_date in date) return qu3_master_assort_type pipelined is

    l_filtered number(1) := 1; -- Always Filtered

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        prod.cust_id,
        prod.prod_id,
        prod.assort_id prod_assort_id,
        prod.assort_dtl_id prod_assort_dtl_id,
        core.assort_id core_assort_id,
        core.assort_dtl_id core_assort_dtl_id,
        decode(core.assort_dtl_id,null,0,1) core_flag
      from table(qu3_assort_pkg.cust_prod_assort_view_at_date(p_at_date,l_filtered)) prod,
        table(qu3_assort_pkg.cust_core_assort_view_at_date(p_at_date,l_filtered)) core
      where prod.cust_id = core.cust_id(+)
      and prod.prod_id = core.prod_id(+)
      order by prod.cust_id,
        prod.prod_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.master_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end master_assort_view_at_date;

end qu3_assort_pkg;
/

-- Synonyms
create or replace public synonym qu3_assort_pkg for dds_app.qu3_assort_pkg;

-- Grants
grant execute on dds_app.qu3_assort_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
