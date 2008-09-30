DROP VIEW MANU_APP.PET_MATL_PLT_LABL_VW;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.pet_matl_plt_labl_vw (matl_code,
                                                            matl_desc,
                                                            plant,
                                                            matl_type,
                                                            rgnl_code_nmbr,
                                                            base_uom,
                                                            altrntv_uom,
                                                            net_wght,
                                                            ean_code,
                                                            shelf_life,
                                                            trdd_unit,
                                                            semi_fnshd_prdct,
                                                            vndr_code,
                                                            vndr_name,
                                                            crtns_per_pllt
                                                           )
AS
  SELECT "MATL_CODE", "MATL_DESC", "PLANT", "MATL_TYPE", "RGNL_CODE_NMBR",
         "BASE_UOM", "ALTRNTV_UOM", "NET_WGHT", "EAN_CODE", "SHELF_LIFE",
         "TRDD_UNIT", "SEMI_FNSHD_PRDCT", "VNDR_CODE", "VNDR_NAME",
         "CRTNS_PER_PLLT"
    FROM pet_matl_plt_labl;


DROP PUBLIC SYNONYM PET_MATL_PLT_LABL_VW;

CREATE PUBLIC SYNONYM PET_MATL_PLT_LABL_VW FOR MANU_APP.PET_MATL_PLT_LABL_VW;


GRANT SELECT ON MANU_APP.PET_MATL_PLT_LABL_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.PET_MATL_PLT_LABL_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.PET_MATL_PLT_LABL_VW TO MANU_USER;

