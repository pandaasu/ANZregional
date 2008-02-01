/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_definition
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Definitions

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_definition as

   /*-*/
   /* Public control definition
   /*-*/
   type idoc_control is record(idoc_name varchar2(30),
                               idoc_number number(16,0),
                               idoc_timestamp varchar2(14));

end lads_definition;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_definition for lads_app.lads_definition;
grant execute on lads_definition to public;