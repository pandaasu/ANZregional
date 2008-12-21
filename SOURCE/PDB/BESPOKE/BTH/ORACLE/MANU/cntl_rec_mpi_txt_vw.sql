DROP VIEW MANU.CNTL_REC_MPI_TXT_VW;

/* Formatted on 2008/12/22 10:52 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_txt_vw (cntl_rec_mpi_txt_id,
                                                       proc_order,
                                                       opertn,
                                                       phase,
                                                       seq,
                                                       mpi_text,
                                                       mpi_type,
                                                       mc_code,
                                                       detail_desc
                                                      )
AS
  SELECT "CNTL_REC_MPI_TXT_ID", LTRIM (proc_order, 0) proc_order, "OPERTN",
         "PHASE", "SEQ", "MPI_TEXT", "MPI_TYPE", "MC_CODE", "DTL_DESC"
    FROM cntl_rec_mpi_txt;


DROP PUBLIC SYNONYM CNTL_REC_MPI_TXT_VW;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_TXT_VW FOR MANU.CNTL_REC_MPI_TXT_VW;


GRANT SELECT ON MANU.CNTL_REC_MPI_TXT_VW TO MANU_APP WITH GRANT OPTION;

