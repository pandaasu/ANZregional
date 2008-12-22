DROP VIEW MANU.CNTL_REC_MPI_VAL;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_mpi_val (cntl_rec_mpi_val_id,
                                                    proc_order,
                                                    operation,
                                                    phase,
                                                    seq,
                                                    mpi_tag,
                                                    mpi_desc,
                                                    mpi_val,
                                                    mpi_uom,
                                                    machine_code,
                                                    detail_desc,
                                                    plant
                                                   )
AS
  SELECT recipe_src_value_id cntl_rec_mpi_val_id, proc_order, operation,
         phase, seq, src_tag AS mpi_tag, src_desc AS mpi_desc,
         src_val AS mpi_val, src_uom AS mpi_uom, machine_code, detail_desc,
         plant_code plant
    FROM bds_recipe_src_value
   WHERE plant_code = 'AU10';


DROP PUBLIC SYNONYM CNTL_REC_MPI_VAL;

CREATE PUBLIC SYNONYM CNTL_REC_MPI_VAL FOR MANU.CNTL_REC_MPI_VAL;


GRANT SELECT ON MANU.CNTL_REC_MPI_VAL TO MANU_APP WITH GRANT OPTION;

