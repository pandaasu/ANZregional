CREATE OR REPLACE package ics_ladchn01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : ics_ladchn01 as
 Owner   : ICS_APP
 Author  : Linden Glen

 Description
 -----------
    LADS -> CHINA DATA WAREHOUSE MATERIAL MASTER EXTRACT


 YYYY/MM   Author               Description
 -------   ------               -----------
 2006/06   Linden Glen          Created
 2006/08   Steve Gregan         Added EACH conversion factors for CS, SB and PCE

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_ladchn01;
/

