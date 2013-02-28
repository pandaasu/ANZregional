
set define off;

-- Create Entity Access Package
create or replace package dds_app.quo_assort_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : quo
  Owner   : dds_app
  Package : quo_assort_pkg
  Author  : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Provide a View as at a given Date on the [ActivityDetailDistCheck] Entity

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-12  Mal Chambeyron        Created

*******************************************************************************/

  -- Public : Type : Shared Customer / Product Hierarchy -----------------------
  type quo_hier_rec is record (
    source_id number(4,0),
    report_date date,
    --
    node_hier_priority number(3),
    node_hier_type varchar2(50 char),
    --
    root_node varchar2(50 char),
    root_node_type varchar2(50 char),
    root_node_id number(10,0),
    root_node_batch_id number(15,0),
    root_node_lookup varchar2(50 char),
    root_node_code varchar2(50 char),
    root_node_desc varchar2(50 char),
    root_node_level number(3,0),
    --
    node varchar2(50 char),
    node_type varchar2(50 char),
    node_id number(10,0),
    node_batch_id number(15,0),
    node_lookup varchar2(50 char),
    node_code varchar2(50 char),
    node_desc varchar2(50 char),
    node_level number(3,0),
    --
    node_direct_flag number(1,0),
    --
    node_path varchar2(256 char)
  );

  type quo_hier_type is table of quo_hier_rec;

  -- Public : Type : Assortment Detail -----------------------------------------
  type quo_assort_dtl_rec is record (
    source_id number(4,0),
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

  type quo_assort_dtl_type is table of quo_assort_dtl_rec;

  -- Public : Type : Customer Assortment ---------------------------------------
  type quo_cust_assort_rec is record (
    source_id number(4,0),
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
    root_cust_lookup varchar2(50 char),
    root_cust_code varchar2(50 char),
    root_cust_desc varchar2(50 char),
    root_cust_level number(3,0),
    --
    cust_type varchar2(50 char),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    cust_lookup varchar2(50 char),
    cust_code varchar2(50 char),
    cust_desc varchar2(50 char),
    cust_level number(3,0),
    --
    cust_direct_flag number(1,0),
    --
    cust_hier_path varchar2(256 char),
    segment_hier_path varchar2(256 char)
  );

  type quo_cust_assort_type is table of quo_cust_assort_rec;

  -- Public : Type : Product Assortment ---------------------------------------
  type quo_prod_assort_rec is record (
    source_id number(4,0),
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
    root_prod_lookup varchar2(50 char),
    root_prod_code varchar2(50 char),
    root_prod_desc varchar2(50 char),
    root_prod_level number(3,0),
    --
    prod_type varchar2(50 char),
    prod_id number(10,0),
    prod_batch_id number(15,0),
    prod_lookup varchar2(50 char),
    prod_code varchar2(50 char),
    prod_desc varchar2(50 char),
    prod_level number(3,0),
    --
    prod_direct_flag number(1,0),
    --
    prod_hier_path varchar2(256 char),
    segment_hier_path varchar2(256 char)
  );

  type quo_prod_assort_type is table of quo_prod_assort_rec;

  -- Public : Type : Master Assortment RAW -------------------------------------
  type quo_master_assort_raw_rec is record (
    source_id number(4,0),
    report_date date,
    --
    cust_hier_priority number(3),
    cust_hier_type varchar2(50 char),
    --
    root_cust_node varchar2(50 char),
    root_cust_type varchar2(50 char),
    root_cust_id number(10,0),
    root_cust_batch_id number(15,0),
    root_cust_lookup varchar2(50 char),
    root_cust_code varchar2(50 char),
    root_cust_desc varchar2(50 char),
    root_cust_level number(3,0),
    --
    cust_type varchar2(50 char),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    cust_lookup varchar2(50 char),
    cust_code varchar2(50 char),
    cust_desc varchar2(50 char),
    cust_level number(3,0),
    cust_direct_flag number(1,0),
    --
    assort_id number(10,0),
    assort_desc varchar2(50 char),
    --
    cust_assort_dtl_type varchar2(100 char),
    cust_assort_dtl_id number(10,0),
    cust_assort_dtl_batch_id number(15,0),
    cust_assort_dtl_desc varchar2(50 char),
    cust_assort_dtl_level number(3,0),
    cust_assort_dtl_direct_flag number(1,0),
    --
    prod_assort_dtl_type varchar2(100 char),
    prod_assort_dtl_id number(10,0),
    prod_assort_dtl_batch_id number(15,0),
    prod_assort_dtl_desc varchar2(50 char),
    prod_assort_dtl_level number(3,0),
    prod_assort_dtl_direct_flag number(1,0),
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
    root_prod_lookup varchar2(50 char),
    root_prod_code varchar2(50 char),
    root_prod_desc varchar2(50 char),
    root_prod_level number(3,0),
    --
    prod_type varchar2(50 char),
    prod_id number(10,0),
    prod_batch_id number(15,0),
    prod_lookup varchar2(50 char),
    prod_code varchar2(50 char),
    prod_desc varchar2(50 char),
    prod_level number(3,0),
    prod_direct_flag number(1,0),
    --
    cust_hier_path varchar2(256 char),
    cust_segment_hier_path varchar2(256 char),
    prod_segment_hier_path varchar2(256 char),
    prod_hier_path varchar2(256 char),
    --
    core_flag number(1,0),
    core_assort_dtl_effective_from date,
    core_assort_dtl_effective_to date,
    core_prod_hier_path varchar2(256 char),
    core_segment_hier_path varchar2(256 char)
  );

  type quo_master_assort_raw_type is table of quo_master_assort_raw_rec;

  -- Public : Type : Master Assortment -----------------------------------------
  type quo_master_assort_rec is record (
    source_id number(4,0),
    report_date date,
    --
    cust_id number(10,0),
    cust_batch_id number(15,0),
    --
    prod_id number(10,0),
    prod_batch_id number(15,0),
    --
    core_flag number(1,0)
  );

  type quo_master_assort_type is table of quo_master_assort_rec;

  -- Public : Functions --------------------------------------------------------
  function cust_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_hier_type pipelined;
  function prod_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_hier_type pipelined;

  function segment_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_assort_dtl_type pipelined;
  function segment_up_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_assort_dtl_type pipelined;

  function cust_assort_view_at_date(p_source_id in number, p_at_date date, p_filtered in number) return quo_cust_assort_type pipelined;
  function prod_assort_view_at_date(p_source_id in number, p_at_date date, p_filtered in number) return quo_prod_assort_type pipelined;
  function core_assort_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_prod_assort_type pipelined;

  function master_assort_raw_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_master_assort_raw_type pipelined;
  function master_assort_view_at_date(p_source_id in number, p_at_date in date) return quo_master_assort_type pipelined;

end quo_assort_pkg;
/

create or replace package body dds_app.quo_assort_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'quo_assort_pkg';

  /*****************************************************************************
  ** Function : Customer Hierarchy, as at Date
  *****************************************************************************/
  function cust_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_hier_type pipelined is

  begin

    for l_entity in (
    
      select *
      from (
        select p_source_id source_id,
          p_at_date report_date,
          --
          node_hier_priority,
          node_hier_type,
          --
          connect_by_root node root_node,
          connect_by_root node_type root_node_type,
          connect_by_root node_id root_node_id,
          connect_by_root batch_id root_node_batch_id,
          connect_by_root node_lookup root_node_lookup,
          connect_by_root node_code root_node_code,
          connect_by_root node_desc root_node_desc,
          connect_by_root node_level root_node_level,
          --
          node,
          node_type,
          node_id,
          batch_id node_batch_id,
          node_lookup,
          node_code,
          node_desc,
          node_level,
          --
          decode(connect_by_root node,node,1,0) node_direct_flag,
          --
          'Customer ['||connect_by_root node_type||':'||connect_by_root node_desc||'] '||sys_connect_by_path(node_desc,'\\') node_path
        from (
          --
          -- Customer DIRECT
          select q4x_batch_id batch_id,
            1 node_hier_priority,
            'Customer-Direct' node_hier_type,
            --
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            id_lookup node_lookup,
            cust_ref_id node_code,
            cust_name node_desc,
            'Direct:'||cust_hier_id parent_node,
            'Direct' parent_node_type,
            cust_hier_id parent_node_id,
            999 node_level
          from table(quo_cust_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- Customer > Hierarchy
          select q4x_batch_id batch_id,
            2 node_hier_priority,
            'Customer-Hierarchy' node_hier_type,
            --
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            id_lookup node_lookup,
            cust_ref_id node_code,
            cust_name node_desc,
            'Hierarchy:'||cust_hier_id parent_node,
            'Hierarchy' parent_node_type,
            cust_hier_id parent_node_id,
            998 node_level
          from table(quo_cust_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          and cust_hier_id is not null
          --
          union all
          --
          -- Customer > Grade
          select q4x_batch_id batch_id,
            3 node_hier_priority,
            'Customer-Grade' node_hier_type,
            --
            'Customer:'||id node,
            'Customer' node_type,
            id node_id,
            id_lookup node_lookup,
            cust_ref_id node_code,
            cust_name node_desc,
            'Hierarchy:'||grade_hier_id parent_node,
            'Hierarchy' parent_node_type,
            cust_hier_id parent_node_id,
            998 node_level
          from table(quo_cust_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          and grade_hier_id is not null
          --
          union all
          --
          -- Hierarchy
          select q4x_batch_id batch_id,
            999 node_hier_priority,
            'Hierarchy-Hierarchy' node_hier_type,
            --
            'Hierarchy:'||id node,
            'Hierarchy' node_type,
            id node_id,
            id_lookup node_lookup,
            null node_code,
            id_desc node_desc,
            decode(parent_id,null,null,'Hierarchy:')||parent_id parent_node,
            decode(parent_id,null,null,'Hierarchy') parent_node_type,
            parent_id parent_node_id,
            hier_level node_level
          from table(quo_hier_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          -- and hier_root_id_desc in ('Customer','Grade') -- remove filter to highlight any mis-configurations
        ) a
        connect by nocycle prior node = parent_node -- nocycle, insurance against loops
      )
      where node_level in (998,999) -- restrict to customer level leaves
      and root_node_level != 998 -- filter where non-direct is root
        
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
  function prod_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_hier_type pipelined is

  begin

    for l_entity in (
    
      select * 
      from (
        select p_source_id source_id,
          p_at_date report_date,
          --
          node_hier_priority,
          node_hier_type,
          --
          connect_by_root node root_node,
          connect_by_root node_type root_node_type,
          connect_by_root node_id root_node_id,
          connect_by_root batch_id root_node_batch_id,
          connect_by_root node_lookup root_node_lookup,
          connect_by_root node_code root_node_code,
          connect_by_root node_desc root_node_desc,
          connect_by_root node_level root_node_level,
          --
          node,
          node_type,
          node_id,
          batch_id node_batch_id,
          node_lookup,
          node_code,
          node_desc,
          node_level,
          --
          decode(connect_by_root node,node,1,0) node_direct_flag,
          --
          'Product ['||connect_by_root node_type||':'||connect_by_root node_desc||'] '||sys_connect_by_path(node_desc,'\\') node_path
        from (
          -- Product DIRECT
          select q4x_batch_id batch_id,
            1 node_hier_priority,
            'Product-Direct' node_hier_type,
            --
            'Product:'||id node,
            'Product' node_type,
            id node_id,
            id_lookup node_lookup,
            sku_code node_code,
            name node_desc,
            'Product:Direct:'||prod_hier_id parent_node,
            'Product:Direct' parent_node_type,
            prod_hier_id parent_node_id,
            999 node_level
          from table(quo_prod_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          --
          union all
          --
          -- Product > Hierarchy
          select q4x_batch_id batch_id,
            2 node_hier_priority,
            'Product-Hierarchy' node_hier_type,
            --
            'Product:'||id node,
            'Product' node_type,
            id node_id,
            id_lookup node_lookup,
            sku_code node_code,
            name node_desc,
            'Hierarchy:'||prod_hier_id parent_node,
            'Hierarchy' parent_node_type,
            prod_hier_id parent_node_id,
            998 node_level
          from table(quo_prod_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          and prod_hier_id is not null
          --
          union all
          --
          -- Hierarchy
          select q4x_batch_id batch_id,
            999 node_hier_priority,
            'Hierarchy-Hierarchy' node_hier_type,
            --
            'Hierarchy:'||id node,
            'Hierarchy' node_type,
            id node_id,
            id_lookup node_lookup,
            null node_code,
            id_desc node_desc,
            decode(parent_id,null,null,'Hierarchy:')||parent_id parent_node,
            decode(parent_id,null,null,'Hierarchy') parent_node_type,
            parent_id parent_node_id,
            hier_level node_level
          from table(quo_hier_pkg.view_at_date(p_source_id,p_at_date))
          where is_active = 1 -- active
          -- and hier_root_id_desc = 'Product' -- remove filter to highlight any mis-configurations
        ) a
        connect by nocycle prior node = parent_node -- nocycle, insurance against loops
      )
      where node_level in (998,999) -- restrict to customer level leaves
      and root_node_level != 998 -- filter where non-direct is root

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
  function segment_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_assort_dtl_type pipelined is

  begin

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
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
      from table(quo_assort_dtl_pkg.view_at_date(p_source_id,p_at_date))
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
  function segment_up_hier_view_at_date(p_source_id in number, p_at_date in date) return quo_assort_dtl_type pipelined is

  begin

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
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
      from table(quo_assort_dtl_pkg.view_at_date(p_source_id,p_at_date))
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
  function cust_assort_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_cust_assort_type pipelined is

    l_cust_id number(10,0);
    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);

  begin

    l_cust_id := -1;
    l_assort_id := -1;
    l_assort_dtl_id := -1;

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
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
        cust_hier.root_node_lookup root_cust_lookup,
        cust_hier.root_node_code root_cust_code,
        cust_hier.root_node_desc root_cust_desc,
        cust_hier.root_node_level root_cust_level,
        --
        cust_hier.node_type cust_type,
        cust_hier.node_id cust_id,
        cust_hier.node_batch_id cust_batch_id,
        cust_hier.node_lookup cust_lookup,
        cust_hier.node_code cust_code,
        cust_hier.node_desc cust_desc,
        cust_hier.node_level cust_level,
        --
        cust_hier.node_direct_flag cust_direct_flag,

        cust_hier.node_path cust_hier_path,
        segment_hier.node_path segment_hier_path
        --
      from table(quo_assort_pkg.cust_hier_view_at_date(p_source_id,p_at_date)) cust_hier,
        table(quo_cust_assort_dtl_pkg.view_at_date(p_source_id,p_at_date)) cust_assort_dtl,
        table(quo_assort_pkg.segment_hier_view_at_date(p_source_id,p_at_date)) segment_hier
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
  function prod_assort_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_prod_assort_type pipelined is

    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_assort_id := -1;
    l_assort_dtl_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
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
        prod_hier.root_node_lookup root_prod_lookup,
        prod_hier.root_node_code root_prod_code,
        prod_hier.root_node_desc root_prod_desc,
        prod_hier.root_node_level root_prod_level,
        --
        prod_hier.node_type prod_type,
        prod_hier.node_id prod_id,
        prod_hier.node_batch_id prod_batch_id,
        prod_hier.node_lookup prod_lookup,
        prod_hier.node_code prod_code,
        prod_hier.node_desc prod_desc,
        prod_hier.node_level prod_level,
        --
        prod_hier.node_direct_flag prod_direct_flag,
        --
        prod_hier.node_path prod_hier_path,
        segment_hier.node_path segment_hier_path
        --
      from table(quo_assort_pkg.prod_hier_view_at_date(p_source_id,p_at_date)) prod_hier,
        table(quo_prod_assort_dtl_pkg.view_at_date(p_source_id,p_at_date)) prod_assort_dtl,
        table(quo_assort_pkg.segment_hier_view_at_date(p_source_id,p_at_date)) segment_hier
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
  function core_assort_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_prod_assort_type pipelined is

    l_assort_id number(10,0);
    l_assort_dtl_id number(10,0);
    l_prod_id number(10,0);

  begin

    l_assort_id := -1;
    l_assort_dtl_id := -1;
    l_prod_id := -1;

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
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
        prod_hier.root_node_lookup root_prod_lookup,
        prod_hier.root_node_code root_prod_code,
        prod_hier.root_node_desc root_prod_desc,
        prod_hier.root_node_level root_prod_level,
        --
        prod_hier.node_type prod_type,
        prod_hier.node_id prod_id,
        prod_hier.node_batch_id prod_batch_id,
        prod_hier.node_lookup prod_lookup,
        prod_hier.node_code prod_code,
        prod_hier.node_desc prod_desc,
        prod_hier.node_level prod_level,
        --
        prod_hier.node_direct_flag prod_direct_flag,
        --
        prod_hier.node_path prod_hier_path,
        core_hier.node_path segment_hier_path
        --
      from table(quo_assort_pkg.prod_hier_view_at_date(p_source_id,p_at_date)) prod_hier,
        table(quo_prod_assort_dtl_pkg.view_at_date(p_source_id,p_at_date)) prod_assort_dtl,
        table(quo_assort_pkg.segment_up_hier_view_at_date(p_source_id,p_at_date)) core_hier
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
  ** Function : Master Assortment RAW, as at Date
  *****************************************************************************/
  function master_assort_raw_view_at_date(p_source_id in number, p_at_date in date, p_filtered in number) return quo_master_assort_raw_type pipelined is

  begin

    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
        --
        assort.*,
        --
        decode(core.assort_id,null,0,1) core_flag,
        core.prod_assort_dtl_effective_from core_assort_dtl_effective_from,
        core.prod_assort_dtl_effective_to core_assort_dtl_effective_to,
        core.prod_hier_path core_prod_hier_path,
        core.segment_hier_path core_segment_hier_path
      from (
        --
        select cust.cust_hier_priority,
          cust.cust_hier_type,
          --
          cust.root_cust_node,
          cust.root_cust_type,
          cust.root_cust_id,
          cust.root_cust_batch_id,
          cust.root_cust_lookup,
          cust.root_cust_code,
          cust.root_cust_desc,
          cust.root_cust_level,
          --
          cust.cust_type,
          cust.cust_id,
          cust.cust_batch_id,
          cust.cust_lookup,
          cust.cust_code,
          cust.cust_desc,
          cust.cust_level,
          cust.cust_direct_flag,
          --
          cust.assort_id,
          cust.assort_desc,
          --
          cust.assort_dtl_type cust_assort_dtl_type,
          cust.assort_dtl_id cust_assort_dtl_id,
          cust.assort_dtl_batch_id cust_assort_dtl_batch_id,
          cust.assort_dtl_desc cust_assort_dtl_desc,
          cust.assort_dtl_level cust_assort_dtl_level,
          cust.assort_dtl_direct_flag cust_assort_dtl_direct_flag,
          --
          prod.assort_dtl_type prod_assort_dtl_type,
          prod.assort_dtl_id prod_assort_dtl_id,
          prod.assort_dtl_batch_id prod_assort_dtl_batch_id,
          prod.assort_dtl_desc prod_assort_dtl_desc,
          prod.assort_dtl_level prod_assort_dtl_level,
          prod.assort_dtl_direct_flag prod_assort_dtl_direct_flag,
          prod.prod_assort_dtl_effective_from,
          prod.prod_assort_dtl_effective_to,
          --
          prod.prod_hier_priority,
          prod.prod_hier_type,
          --
          prod.root_prod_node,
          prod.root_prod_type,
          prod.root_prod_id,
          prod.root_prod_batch_id,
          prod.root_prod_lookup,
          prod.root_prod_code,
          prod.root_prod_desc,
          prod.root_prod_level,
          --
          prod.prod_type,
          prod.prod_id,
          prod.prod_batch_id,
          prod.prod_lookup,
          prod.prod_code,
          prod.prod_desc,
          prod.prod_level,
          prod.prod_direct_flag,
          --
          cust.cust_hier_path,
          cust.segment_hier_path cust_segment_hier_path,
          prod.segment_hier_path prod_segment_hier_path,
          prod.prod_hier_path
          --
        from table(quo_assort_pkg.cust_assort_view_at_date(p_source_id,p_at_date,p_filtered)) cust,
          table(quo_assort_pkg.prod_assort_view_at_date(p_source_id,p_at_date,p_filtered)) prod
        where cust.assort_id = prod.assort_id
        and cust.assort_dtl_id = prod.assort_dtl_id
        --and cust.cust_id = p_cust_id .. Will likely need to break down to smaller chunks
      ) assort,
        table(quo_assort_pkg.core_assort_view_at_date(p_source_id,p_at_date,p_filtered)) core
      where assort.assort_id = core.assort_id(+)
      and assort.cust_assort_dtl_id = core.assort_dtl_id(+)
      and assort.prod_id = core.prod_id(+)
      --
      order by assort.cust_id,
        assort.prod_id,
        assort.cust_direct_flag desc,
        assort.prod_direct_flag desc,
        assort.assort_id, 
        assort.cust_assort_dtl_direct_flag desc,
        assort.prod_assort_dtl_direct_flag desc,
        assort.cust_assort_dtl_level desc
        -- assort.cust_hier_priority, 
        -- assort.prod_hier_priority,
        -- assort.root_cust_level desc,
        -- assort.root_prod_level desc
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.master_assort_raw_view_at_date] : '||SQLERRM, 1, 4000));

  end master_assort_raw_view_at_date;

  /*****************************************************************************
  ** Function : Master Assortment, as at Date
  *****************************************************************************/
  function master_assort_view_at_date(p_source_id in number, p_at_date in date) return quo_master_assort_type pipelined is

    l_working_entity quo_master_assort_rec;
    l_filtered number(1) := 1;
  
  begin
  
    for l_entity in (

      select p_source_id source_id,
        p_at_date report_date,
        --
        assort.cust_id,
        assort.cust_batch_id,
        assort.prod_id,
        assort.prod_batch_id,
        --
        decode(core.assort_id,null,0,1) core_flag
      from (
        --
        select 
          cust.cust_id,
          cust.cust_batch_id,
          --
          cust.assort_id,
          cust.assort_dtl_id cust_assort_dtl_id,
          --
          prod.prod_id,
          prod.prod_batch_id
          --
        from table(quo_assort_pkg.cust_assort_view_at_date(p_source_id,p_at_date,l_filtered)) cust,
          table(quo_assort_pkg.prod_assort_view_at_date(p_source_id,p_at_date,l_filtered)) prod
        where cust.assort_id = prod.assort_id
        and cust.assort_dtl_id = prod.assort_dtl_id
        --and cust.cust_id = p_cust_id .. Will likely need to break down to smaller chunks
      ) assort,
        table(quo_assort_pkg.core_assort_view_at_date(p_source_id,p_at_date,l_filtered)) core
      where assort.assort_id = core.assort_id(+)
      and assort.cust_assort_dtl_id = core.assort_dtl_id(+)
      and assort.prod_id = core.prod_id(+)
      --
      order by assort.cust_id,
        assort.prod_id
    )
    loop
    
      if l_working_entity.cust_id is null then -- First Entity, Initialise Working Entity
        l_working_entity.source_id := p_source_id;
        l_working_entity.report_date := p_at_date;
        --
        l_working_entity.cust_id := l_entity.cust_id;
        l_working_entity.cust_batch_id := l_entity.cust_batch_id;
        --
        l_working_entity.prod_id := l_entity.prod_id;
        l_working_entity.prod_batch_id := l_entity.prod_batch_id;
        --
        l_working_entity.core_flag := l_entity.core_flag;
      elsif l_working_entity.cust_id = l_entity.cust_id and l_working_entity.prod_id = l_entity.prod_id then
        if l_entity.core_flag = 1 then
          l_working_entity.core_flag := 1;
        end if;
      else
        pipe row(l_working_entity);
        l_working_entity.cust_id := l_entity.cust_id;
        l_working_entity.cust_batch_id := l_entity.cust_batch_id;
        --
        l_working_entity.prod_id := l_entity.prod_id;
        l_working_entity.prod_batch_id := l_entity.prod_batch_id;
        --
        l_working_entity.core_flag := l_entity.core_flag;
      end if;
    
    end loop;
    
    pipe row(l_working_entity); -- Pile Last Entity ..
      
  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.master_assort_view_at_date] : '||SQLERRM, 1, 4000));

  end master_assort_view_at_date;
  
end quo_assort_pkg;
/

-- Synonyms
create or replace public synonym quo_assort_pkg for dds_app.quo_assort_pkg;

-- Grants
grant execute on dds_app.quo_assort_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
