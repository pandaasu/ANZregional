
delete from lads_sto_po_con where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_dat where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_del where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_gen where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_hdr where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_hti where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_htx where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_itp where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_oid where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_org where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_pad where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_pay where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_pnr where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_ref where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_sch where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
delete from lads_sto_po_smy where belnr in (select belnr from lads_sto_po_hdr where trunc(lads_date) > to_date('20070608','yyyymmdd'));
commit;
