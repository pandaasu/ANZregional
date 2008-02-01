/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_documentation
 Owner   : lics_app
 Author  : Steve Gregan - May 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Documentation

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/05   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_documentation as

   /*-*/
   /* Public declarations
   /*-*/
   procedure retrieve_view_source(par_owner in varchar2, par_name in varchar2);
   procedure retrieve_documentation(par_owner in varchar2, par_name in varchar2, par_type in varchar2);

end lics_documentation;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_documentation as

   /************************************************************/
   /* This procedure performs the retrieve view source routine */
   /************************************************************/
   /*
   /* The view source is retrieved from the dba_views view.
   /*
   /* 1. The view source lines are written to the lics_temp (global temporary)
   /*    table for the current session from where they can be retrieved.
   /*
   /*-*/
   procedure retrieve_view_source(par_owner in varchar2, par_name in varchar2)
      as language java name 'com.isi.utility.Documentation.retrieveViewSource(java.lang.String, java.lang.String)';

   /**************************************************************/
   /* This procedure performs the retrieve documentation routine */
   /**************************************************************/
   /*
   /* The source documentation is retrieved from the dba_source view.
   /*
   /* The documentation tags are an SQL comment group with the
   /* <DOCUMENTATION> and </DOCUMENTATION> tags. These tags must
   /* exist on separate sources line with NO other source. The
   /* documentation lines are the sourcs lines between the two
   /* documentation tag lines. For example...
   /*
   /* /*<DOCUMENTATION>
   /* documentation line 1
   /* documentation line 2
   /* </DOCUMENTATION>*/
   /*
   /* 1. The source documentation lines are written to the lics_temp (global temporary)
   /*    table for the current session from where they can be retrieved.
   /*
   /* 2. The source documentation lines can contain HTML tags for
   /*    rendering on the web site (eg. <bold>xxxx</bold>).
   /*
   /* 3. Blank source documentation lines are preserved in the output.
   /*
   /*-*/
   procedure retrieve_documentation(par_owner in varchar2, par_name in varchar2, par_type in varchar2)
      as language java name 'com.isi.utility.Documentation.retrieveDocumentation(java.lang.String, java.lang.String, java.lang.String)';

end lics_documentation;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_documentation for lics_app.lics_documentation;
grant execute on lics_documentation to public;