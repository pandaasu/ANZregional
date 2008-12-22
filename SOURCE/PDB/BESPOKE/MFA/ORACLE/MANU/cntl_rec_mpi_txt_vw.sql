DROP VIEW MANU.CNTL_REC_MPI_TXT_VW;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_txt_vw (cntl_rec_mpi_txt_id,
                                                       proc_order,
                                                       operation,
                                                       phase,
                                                       seq,
                                                       mpi_text,
                                                       mpi_type,
                                                       machine_code,
                                                       detail_desc
                                                      )
AS
  SELECT "CNTL_REC_MPI_TXT_ID", LTRIM (proc_order, 0) proc_order, "OPERATION",
         "PHASE", "SEQ", "MPI_TEXT", "MPI_TYPE", "MACHINE_CODE",
         "DETAIL_DESC"
    FROM cntl_rec_mpi_txt;


DROP PUBLIC SYNONYM CNTL_REC_MPI_TXT_VW;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_TXT_VW FOR MANU.CNTL_REC_MPI_TXT_VW;


GRANT SELECT ON MANU.CNTL_REC_MPI_TXT_VW TO MANU_APP;

GRANT SELECT ON MANU.CNTL_REC_MPI_TXT_VW TO MANU_USER;

