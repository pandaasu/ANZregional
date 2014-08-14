/******************/
/* Package Header */
/******************/
create or replace
package         pts_map_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_map_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Mapping Function

    This package contain the mapping functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function select_question return pts_xml_type pipelined;
   procedure execute_extract;

end pts_map_function;
/

/****************/
/* Package Body */
/****************/
create or replace
package         pts_map_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_map_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Mapping Function

    This package contain the mapping functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function select_question return pts_xml_type pipelined;
   procedure execute_extract;

end pts_map_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_map_function for pts_app.pts_map_function;
grant execute on pts_app.pts_map_function to public;
