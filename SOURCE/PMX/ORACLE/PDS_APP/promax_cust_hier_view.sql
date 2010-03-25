CREATE OR REPLACE VIEW LADS.PROMAX_CUST_HIER_VIEW AS SELECT
/*+ORDERED*/
--*******************************************************************************
--  NAME:      lads.promax_cust_hier_view
--  PURPOSE:   This view is used by the Customer interfaces within Promax.
--             
--  REVISIONS:
--  Ver   Date       Author               Description
--  ----- ---------- -------------------- ----------------------------------------
--  1.0   01/01/2005 Unknown              Created this view.
--  2.0   07/02/2006 Anna Every           /*+ORDERED*/ added Hint for optimisation
--  3.0   28/02/2006 Craig Ford           Update the DECODE to default the Region
--                                         to 'NZ' for New Zealand customers.
--  4.0   03/03/2006 Craig Ford           Filter on effective dates (datab and datbi)
--                                         to return current hierarchy rows only.
--  5.0   05/08/2009 Steve Gregan         Added chncode and divcode
--  6.0   10/12/2009 Rob Bishop           Change financial flag criteria so they are
--                                          ORs rather than ANDs, to include more customers.
--  6.1   04/03/2010 Rob Bishop           Removed redundant ORDER BY clause in view.
--
--  NOTES:
--********************************************************************************
    a.hdrseq,
    b.vkorg cocode,
    DECODE(b.vkorg,'149','NZ','147',c.region) region,
    b.vtweg chncode,
    b.spart divcode,
    b.hielv CustLevel,
    b.kunnr custno,
    d.atwrt PosFormat,
    c.name chain,
    a.datab eff_from,
    a.hdrdat
FROM   LADS_HIE_CUS_HDR a,
       LADS_HIE_CUS_DET b,
       LADS_ADR_DET c,
    LADS_CLA_CHR d,
    LADS_CUS_HDR e
WHERE  b.hdrdat   = a.hdrdat
AND    b.hdrseq   = a.hdrseq
AND    d.objek    = b.kunnr
AND    LTRIM(b.kunnr,0)    = LTRIM(e.kunnr,0)
AND   to_char(sysdate, 'YYYYMMDD') BETWEEN a.datab AND a.datbi
AND    c.OBJ_TYPE (+) = 'KNA1'
AND    c.obj_id   (+) = b.KUNNR
AND     KLART = '011'
AND    d.obtab = 'KNA1'
AND    d.atnam = 'CLFFERT41'
AND (
         e.AUFSD IS NULL -- Any value in AUFSD means this customer can no longer order.
      OR e.FAKSD IS NULL -- Any value in FAKSD means we can't bill this customer at all.
      OR e.LIFSD IS NULL -- Any value LIFSD means we can't deliver to this customer any more.
      OR e.SPERR IS NULL -- Any value in SPERR means we can't post any financial transactions against this customer
    )
AND    a.hdrdat = (SELECT MAX(hdrdat) FROM LADS_HIE_CUS_HDR);
