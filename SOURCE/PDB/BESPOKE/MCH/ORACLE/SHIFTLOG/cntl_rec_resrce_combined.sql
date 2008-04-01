/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace view shiftlog.cntl_rec_resrce_combined as
   select a.*,
          b.cntl_rec_resrce_id,
          b.opertn as resrce_opertn,
          b.resrce_code,
          b.batch_qty as resrce_batch_qty,
          b.batch_uom as resrce_batch_uom,
          b.phantom as resrce_phantom,
          b.phantom_desc as resrce_phantom_desc,
          b.phantom_qty as resrce_phantom_qty,
          b.phantom_uom as resrce_phantom_uom,
          b.plant as resrce_plant
   from cntl_rec a,
        cntl_rec_resrce b
   where a.proc_order = b.proc_order(+);

/*-*/
/* Authority
/*-*/
grant select on shiftlog.cntl_rec_resrce_combined to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym cntl_rec_resrce_combined for shiftlog.cntl_rec_resrce_combined;
