CREATE OR REPLACE package ics_ladwms01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : ics_ladwms01
 Owner   : ICS_APP
 Author  : Linden Glen

 Description
 -----------
    LADS -> HK WAREHOUSE MATERIAL MASTER EXTRACT

    PARAMETERS:

      1. PAR_DAYS - number of days of changes to extract
            0 = full extract (extract all materials)
            n = number provided will extract changed materials for sysdate - n
            DEFAULT = no parameter specified, default is 0 (full extract)



 YYYY/MM   Author               Description
 -------   ------               -----------
 2006/04   Linden Glen          Created
                                MOD: If material code is numeric - then lpad with 0
                                     If alphanumeric, then leave as is
 2006/07   Linden Glen          MOD: retrieve material description from material_dim
                                     allows logic around Sales Text/Market text to be used
 2006/08   Linden Glen          ADD: parameter to allow number of days changes to extract
                                MOD: query as requested by Cheryl Cheah
 2006/08   Linden Glen          MOD: output of volume and weight to 00000000.000 if not defined
 2006/08   Linden Glen          MOD: change PAC to PK - initially incorrectly specified
 2006/08   Linden Glen          MOD: MATL_B_UOM logic to use (in order of availability) SB, PK, null
 2006/10   Linden Glen          MOD: Hardcode MATL_GROSS_WGT and MATL_VOL_PER_BASE to 0000000000.000


 NOTES:
  * It is assumed that material codes for HK will not exceed 8 character in length (Zou Kai)
  * The weight and volume provided to DHL should be the weight of the
    PC for all finished goods (material type = FERT), POS materials (material type = ZPRM)
    and packaging materials (material type = VERP)
  * The weight (field = MATL_GROSS_WGT) provided to DHL must be in KGs.  Currently,
    it seems we maintain weight in either grams or kilograms. So if weight is maintained
    in grams (GRM) = then weight/1000 And therefore, field = MATL_WGT_UOM can be hard-coded to KG
    If the weight is not maintained in either grams or kgs, then please leave the Weight
    as 0000000000.000 and Weight UOM fields as blank  This will prompt the warehouse to enter
    this in themselves instead.
  * The volume (field = MATL_VOL_PER_BASE) provided to DHL must be in cubic metres (M3).  Currently,
    it seems we maintain the volume in either cubic decimetres (DMQ) or cubic metres (M3).
    If volume is in cubic decimetres (DMQ), then volume/1000  (ie. 1000 cubic decimetres = 1 cubic metre)
    If volume is in cubic centimetres (CMQ), then volume/1000000 (ie. 1,000,000 cubic cm = 1 cubic metre)
    If volume is not maintained in either cubic metres, cubic decimetres or cubic centimetres, then leave
    the Volume as 000000000.000 and Volume UOM fields blank.  This will prompt the warehouse to enter this
    in themselves instead.




*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_days in number default 0);

end ics_ladwms01;
/

