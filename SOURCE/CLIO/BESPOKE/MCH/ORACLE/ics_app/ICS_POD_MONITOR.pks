CREATE OR REPLACE package         ics_pod_monitor as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ICS
 Package : ics_pod_monitor
 Owner   : ICS_APP
 Author  : Linden Glen

 Description
 -----------
    Provides an emailed extract of outbound deliveries which have been invoiced,
    but no POD data has been received into LADS.
    This is only required temporarily until the "ZSH7&8 issue" stopping POD documents
    automatically being sent from SAP is correct by Outbound GSM. This expected to be in
    place by end of P10 2006.


 YYYY/MM   Author               Description
 -------   ------               -----------
 2006/08   Linden Glen          Created


*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_pod_monitor;
/

