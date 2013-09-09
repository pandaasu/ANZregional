          select distinct
            t4.promax_company as cmpny_code,
            t4.promax_division as div_code,
            pxi_common.full_matl_code(t3.rep_item) as zrep_matl_code,
            '20' as dstrbtn_chain_status,
            trunc(sysdate) as change_date,
            trunc(sysdate) as last_extracted
          from
            dw_sales_base@db1270p_promax_testing t1,  -- 
            matl_dim@db1270p_promax_testing t3, --
            table(pxi_common.promax_config(:i_pmx_company,:i_pmx_division)) t4
          where
            -- Join to promax configuration table.
            t1.company_code = t4.promax_company 
            and ((t1.company_code = :pxi_common_gc_australia and t1.hdr_division_code = t4.promax_division) or (t1.company_code = :pxi_common_gc_new_zealand))
            and t1.creatn_date >= to_date('01/01/2012','DD/MM/YYYY')
            -- Now join to the material zrep detail
            and t1.matl_code = t3.matl_code
            -- Not null check added to accommodate new restrictions on output format
            and t1.matl_entd is not null 
            and t1.hdr_distbn_chnl_code not in ('99','98')
            
            
            
            