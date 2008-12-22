DROP VIEW MANU.CNTL_REC_MPI_VAL_VW;

/* Formatted on 2008/12/22 11:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_val_vw (cntl_rec_mpi_val_id,
                                                       proc_order,
                                                       operation,
                                                       phase,
                                                       seq,
                                                       mpi_tag,
                                                       mpi_desc,
                                                       mpi_val,
                                                       mpi_uom,
                                                       machine_code,
                                                       detail_desc
                                                      )
AS
  SELECT "CNTL_REC_MPI_VAL_ID", LTRIM (proc_order, 0) proc_order, "OPERATION",
         "PHASE", "SEQ", "MPI_TAG", "MPI_DESC", "MPI_VAL", "MPI_UOM",
         "MACHINE_CODE", "DETAIL_DESC"
    FROM cntl_rec_mpi_val;


DROP PUBLIC SYNONYM CNTL_REC_MPI_VAL_VW;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_VAL_VW FOR MANU.CNTL_REC_MPI_VAL_VW;


GRANT SELECT ON MANU.CNTL_REC_MPI_VAL_VW TO MANU_APP;

