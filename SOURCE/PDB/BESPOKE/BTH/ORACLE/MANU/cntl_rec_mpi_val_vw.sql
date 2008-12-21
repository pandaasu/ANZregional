DROP VIEW MANU.CNTL_REC_MPI_VAL_VW;

/* Formatted on 2008/12/22 10:52 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_val_vw (cntl_rec_mpi_val_id,
                                                       proc_order,
                                                       opertn,
                                                       phase,
                                                       seq,
                                                       mpi_tag,
                                                       mpi_desc,
                                                       mpi_val,
                                                       mpi_uom,
                                                       mc_code,
                                                       dtl_desc
                                                      )
AS
  SELECT "CNTL_REC_MPI_VAL_ID", LTRIM (proc_order, 0) proc_order, "OPERTN",
         "PHASE", "SEQ", "MPI_TAG", "MPI_DESC", "MPI_VAL", "MPI_UOM",
         "MC_CODE", "DTL_DESC"
    FROM cntl_rec_mpi_val;


DROP PUBLIC SYNONYM CNTL_REC_MPI_VAL_VW;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_VAL_VW FOR MANU.CNTL_REC_MPI_VAL_VW;


GRANT SELECT ON MANU.CNTL_REC_MPI_VAL_VW TO MANU_APP;

