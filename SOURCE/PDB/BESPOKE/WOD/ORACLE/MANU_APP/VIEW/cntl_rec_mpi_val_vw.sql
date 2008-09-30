DROP VIEW MANU_APP.CNTL_REC_MPI_VAL_VW;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_mpi_val_vw (cntl_rec_mpi_val_id,
                                                           proc_order,
                                                           opertn,
                                                           phase,
                                                           seq,
                                                           mpi_tag,
                                                           mpi_desc,
                                                           mpi_val,
                                                           mpi_uom,
                                                           mc_code,
                                                           dtl_desc,
                                                           plant
                                                          )
AS
  SELECT "CNTL_REC_MPI_VAL_ID", "PROC_ORDER", "OPERTN", "PHASE", "SEQ",
         "MPI_TAG", "MPI_DESC", "MPI_VAL", "MPI_UOM", "MC_CODE", "DTL_DESC",
         "PLANT"
    FROM manu.cntl_rec_mpi_val
   WHERE proc_order IN (SELECT proc_order
                          FROM cntl_rec
                         WHERE teco_stat = 'NO');


