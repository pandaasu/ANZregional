CREATE VIEW LADS.PROMAX_PRICE_EXT_VIEW AS
--*******************************************************************************
--  NAME:      lads.promax_price_ext_view
--  PURPOSE:   This view is used by the Price List interfaces within Promax.
--             .
--  REVISIONS:
--  Ver   Date       Author               Description
--  ----- ---------- -------------------- ----------------------------------------
--  1.0   01/01/2005 Unknown              Created this view.
--  2.0   30/11/2005 Paul Berude          Added an additional filter to only retrieve
--                                        Price Lists for the Sales Organisation / Material
--                                        Access Sequence (i.e. a.kotabnr = 812).
--  3.0   15/09/2006 Craig Ford           Add filter (trdd_unit = 'X') to exclude zreps
--                                         that are exclusively based on the RSU.
--  4.0   27/09/2006 Anna Every		  Add the filter to only bring in prices that start before sysdate
--						and end after sysdate.
--  5.0   20/06/2009 Steve Gregan         Modified to bring the price for sysdate or the future.
--                                        **note** only the first price start date for each product is returned
--  6.0   25/06/2009 Steve Gregan         Modified for future pricing
--  7.0   21/09/2009 Steve Gregan         Modified to bring current and first two future prices
--                                        Removed RRP - no longer required
--
--  NOTES:
--********************************************************************************
select t01.cocode,
       t01.divcode,
       t01.channel,
       t01.prodcode,
       t01.startdate,
       t01.price1,
       t01.mnfcost,
       t01.rrp
  from (select t01.*,
               rank() over (partition by t01.cocode, t01.divcode, t01.channel, t01.prodcode
                                order by t01.startdate asc) as rnkseq
          from (select ltrim(a.vkorg,1) as cocode,
                       f.dvsn as divcode,
                       decode(a.vkorg,'147',h.dstrbtn_chnl,'149','11') as channel,
                       ltrim(a.matnr,0) as prodcode,
                       a.datab as startdate,
                       decode(a.vkorg,'147',case when h.dstrbtn_chnl = '12' and g.trade_sctr_code = '01' then c.kbetr * 1.03 else c.kbetr end,'149',c.kbetr) as price1,
                       0 as mnfcost,
                       0 as rrp
                  from lads_prc_lst_hdr a,
                       lads_prc_lst_det c,
                       mfanz_matl f,
                       mfanz_fg_matl_clssfctn g,
                       mfanz_matl_by_sales_area h
                 where a.vakey = c.vakey
                   and a.datab = c.datab
                   and a.kschl = c.kschl
                   and a.matnr is not null
                   and a.kotabnr = 812 -- 812 refers to the Access Sequence Sales Organisation / Material
                   and a.matnr = g.matl_code
                   and a.matnr = h.matl_code
                   and a.matnr = f.matl_code
                   and f.matl_type = 'ZREP'
                   and f.trdd_unit = 'X'
                   and a.vkorg = h.sales_org
                   and (a.vkorg,h.dstrbtn_chnl) in (('147','11'),('147','12'),('149','10')) -- AUS Distribution Channels set up are 11 and 12, NZ is 10
                   and c.kbetr is not null
                   and c.knumh = a.knumh
                   and c.kschl in ('ZR05','ZN00')
                   and c.kmein = 'EA'
                   and c.loevm_ko is null -- If this is marked 'X' it means the condition is no longer active
                   and a.datbi >= to_char(sysdate, 'yyyymmdd')) t01) t01
 where t01.rnkseq <= 3;