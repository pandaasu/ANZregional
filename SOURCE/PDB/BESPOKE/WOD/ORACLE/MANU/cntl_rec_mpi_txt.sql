DROP VIEW MANU.CNTL_REC_MPI_TXT;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_txt (cntl_rec_mpi_txt_id,
                                                    proc_order,
                                                    opertn,
                                                    phase,
                                                    seq,
                                                    mpi_text,
                                                    mpi_type,
                                                    mc_code,
                                                    dtl_desc,
                                                    plant
                                                   )
AS
  SELECT recipe_src_text_id cntl_rec_mpi_txt_id, proc_order, operation opertn,
         phase, seq, src_text mpi_text, src_type mpi_type,
         machine_code mc_code, detail_desc dtl_desc, plant_code plant
    FROM bds_recipe_src_text
   WHERE plant_code IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25');


DROP PUBLIC SYNONYM CNTL_REC_MPI_TXT;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_TXT FOR MANU.CNTL_REC_MPI_TXT;


GRANT SELECT ON MANU.CNTL_REC_MPI_TXT TO MANU_APP WITH GRANT OPTION;

