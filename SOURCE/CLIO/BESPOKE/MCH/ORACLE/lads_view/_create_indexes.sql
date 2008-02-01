/*-*/
/* Drop indexes
/*-*/
drop index lads_cla_hdr_ix01;
drop index lads_cla_chr_ix01;
drop index lads_cus_sad_ix01;
drop index lads_cus_sad_ix02;
drop index lads_del_irf_ix01;
drop index lads_ie_cus_hdr_ix01;
drop index lads_inv_dat_ix01;
drop index lads_mat_bom_det_ix01;
drop index lads_mat_bom_det_ix02;
drop index lads_mat_hdr_ix01;
drop index lads_mat_lcd_ix01;
drop index lads_mat_mbe_ix01;
drop index lads_mat_moe_ix01;
drop index lads_mat_mrc_ix01;
drop index lads_mat_pch_ix01;
drop index lads_mat_pid_ix01;
drop index lads_mat_sad_ix01;
drop index lads_mat_uom_ix01;
drop index lads_ref_dat_ix01;
drop index lads_sal_ord_dat_ix01;
drop index lads_sto_po_dat_ix01;

/*-*/
/* Create indexes
/*-*/
create index lads_cla_hdr_ix01 on lads_cla_hdr
   (obtab, klart, objek);

create index lads_cla_chr_ix01 on lads_cla_chr
   (obtab, klart, objek);

create index lads_cus_sad_ix01 on lads_cus_sad
   (vkorg, vtweg, spart);

create index lads_cus_sad_ix02 on lads_cus_sad
   (vkorg, spart, vtweg);

create index lads_del_irf_ix01 on lads_del_irf
   (belnr);

create index lads_mat_bom_det_ix01 on lads_mat_bom_det
   (stlnr, stlal);

create index lads_mat_bom_det_ix02 on lads_mat_bom_det
   (idnrk);

create index lads_mat_hdr_ix01 on lads_mat_hdr
   (mtart);

create index lads_mat_lcd_ix01 on lads_mat_lcd
   (z_lcdid);

create index lads_mat_mbe_ix01 on lads_mat_mbe
   (matnr, bwkey);

create index lads_mat_moe_ix01 on lads_mat_moe
   (moe, usagecode);

create index lads_mat_mrc_ix01 on lads_mat_mrc
   (werks, mmsta);

create index lads_mat_pch_ix01 on lads_mat_pch
   (kotabnr);

create index lads_mat_pid_ix01 on lads_mat_pid
   (component);

create index lads_mat_sad_ix01 on lads_mat_sad
   (vkorg, vtweg, vmsta);

create index lads_mat_uom_ix01 on lads_mat_uom
   (matnr, meinh);

create index lads_mat_uom_ix02 on lads_mat_uom
   (matnr, meinh);

create index lads_ref_dat_ix01 on lads_ref_dat
   (z_data);

create index lads_sal_ord_dat_ix01 on lads_sal_ord_dat
   (iddat, datum);

create index lads_inv_dat_ix01 on lads_inv_dat
   (iddat,datum);

create index lads_sto_po_dat_ix01 on lads_sto_po_dat
   (iddat,datum);

create index lads_hie_cus_hdr_ix01 on lads_hie_cus_hdr
   (hdrdat, hdrseq, hityp);