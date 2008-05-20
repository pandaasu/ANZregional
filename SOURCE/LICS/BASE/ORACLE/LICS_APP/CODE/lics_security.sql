create or replace package lics_security as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_security
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Security

    The package implements the security functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/06   Steve Gregan   Created
    2008/05   Linden Glen    Added Interface Security

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_security(par_user in varchar2) return lics_security_table pipelined;
   function check_security(par_user in varchar2, par_option in varchar2) return varchar2;
   function check_intfc_security(par_interface in varchar2, par_user in varchar2) return varchar2;
   function check_intfc_hdr_security(par_interface_hdr in varchar2, par_user in varchar2) return varchar2;

end lics_security;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_security as

   /*-*/
   /* Private constants
   /*-*/
   con_guest constant varchar2(32) := '*GUEST';

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /****************************************************/
   /* This procedure performs the get security routine */
   /****************************************************/
   function get_security(par_user in varchar2) return lics_security_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_user_level lics_sec_link.sel_sequence%type;
      var_user_obj_type lics_sec_link.sel_type%type;
      var_user_obj_code lics_sec_link.sel_link%type;
      var_user_obj_description lics_sec_option.seo_description%type;
      var_user_obj_status lics_sec_option.seo_status%type;
      var_user_lnk_sequence lics_sec_link.sel_sequence%type;
      var_user_lnk_type lics_sec_link.sel_type%type;
      var_user_lnk_code lics_sec_link.sel_link%type;
      var_user_lnk_description lics_sec_option.seo_description%type;
      var_user_lnk_script lics_sec_option.seo_script%type;
      var_user_lnk_status lics_sec_option.seo_status%type;
      var_guest_level lics_sec_link.sel_sequence%type;
      var_guest_obj_type lics_sec_link.sel_type%type;
      var_guest_obj_code lics_sec_link.sel_link%type;
      var_guest_obj_description lics_sec_option.seo_description%type;
      var_guest_obj_status lics_sec_option.seo_status%type;
      var_guest_lnk_sequence lics_sec_link.sel_sequence%type;
      var_guest_lnk_type lics_sec_link.sel_type%type;
      var_guest_lnk_code lics_sec_link.sel_link%type;
      var_guest_lnk_description lics_sec_option.seo_description%type;
      var_guest_lnk_script lics_sec_option.seo_script%type;
      var_guest_lnk_status lics_sec_option.seo_status%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_user is
         select 0 as sec_level,
                '*USR' as sec_obj_type,
                nvl(t01.seu_user,'*NONE') as sec_obj_code,
                nvl(t01.seu_description,'*NONE') as sec_obj_description,
                nvl(t01.seu_status,'0') as sec_obj_status,
                1 as sec_lnk_sequence,
                '*TOP' as sec_lnk_type,
                nvl(t01.seu_menu,'*NONE') as sec_lnk_code,
                nvl(t02.sem_description,'*NONE') as sec_lnk_description,
                '*NONE' as sec_lnk_script,
                '1' as sec_lnk_status
           from lics_sec_user t01,
                lics_sec_menu t02
          where (upper(t01.seu_user) = upper(par_user) or
                 upper(t01.seu_user) = upper(con_guest))
            and t01.seu_menu = t02.sem_menu(+);
      rcd_user csr_user%rowtype;

      cursor csr_security is
         select t01.sel_level as sec_level,
                '*MNU' as sec_obj_type,
                nvl(t01.sel_menu,'*NONE') as sec_obj_code,
                nvl(t02.sem_description,'*NONE') as sec_obj_description,
                '1' as sec_obj_status,
                t01.sel_sequence as sec_lnk_sequence,
                nvl(t01.sel_type,'*OPT') as sec_lnk_type,
                nvl(t01.sel_link,'*NONE') as sec_lnk_code,
                nvl(decode(t01.sel_type,'*MNU',t03.sem_description,t04.seo_description),'*NONE') as sec_lnk_description,
                nvl(decode(t01.sel_type,'*MNU',null,t04.seo_script),'*NONE') as sec_lnk_script,
                nvl(decode(t01.sel_type,'*MNU',null,t04.seo_status),'0') as sec_lnk_status
           from (select rownum as sel_rownum,
                        level as sel_level,
                        t01.*
                   from lics_sec_link t01
                  start with t01.sel_menu = var_user_lnk_code
                connect by (prior t01.sel_link = t01.sel_menu) and
                           (prior t01.sel_type = '*MNU')
                  order siblings by t01.sel_sequence) t01,
                lics_sec_menu t02,
                lics_sec_menu t03,
                lics_sec_option t04
          where t01.sel_menu = t02.sem_menu(+)
            and t01.sel_link = t03.sem_menu(+)
            and t01.sel_link = t04.seo_option(+)
          order by t01.sel_rownum;
      rcd_security csr_security%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the user information (user and guest)
      /*-*/
      var_user_obj_code := null;
      var_guest_obj_code := null;
      open csr_user;
      loop
         fetch csr_user into rcd_user;
         if csr_user%notfound then
            exit;
         end if;
         if upper(rcd_user.sec_obj_code) = upper(par_user) then
            var_user_level := rcd_user.sec_level;
            var_user_obj_type := rcd_user.sec_obj_type;
            var_user_obj_code := rcd_user.sec_obj_code;
            var_user_obj_description := rcd_user.sec_obj_description;
            var_user_obj_status := rcd_user.sec_obj_status;
            var_user_lnk_sequence := rcd_user.sec_lnk_sequence;
            var_user_lnk_type := rcd_user.sec_lnk_type;
            var_user_lnk_code := rcd_user.sec_lnk_code;
            var_user_lnk_description := rcd_user.sec_lnk_description;
            var_user_lnk_script := rcd_user.sec_lnk_script;
            var_user_lnk_status := rcd_user.sec_lnk_status;
         end if;
         if upper(rcd_user.sec_obj_code) = upper(con_guest) then
            var_guest_level := rcd_user.sec_level;
            var_guest_obj_type := rcd_user.sec_obj_type;
            var_guest_obj_code := rcd_user.sec_obj_code;
            var_guest_obj_description := rcd_user.sec_obj_description;
            var_guest_obj_status := rcd_user.sec_obj_status;
            var_guest_lnk_sequence := rcd_user.sec_lnk_sequence;
            var_guest_lnk_type := rcd_user.sec_lnk_type;
            var_guest_lnk_code := rcd_user.sec_lnk_code;
            var_guest_lnk_description := rcd_user.sec_lnk_description;
            var_guest_lnk_script := rcd_user.sec_lnk_script;
            var_guest_lnk_status := rcd_user.sec_lnk_status;
         end if;
      end loop;
      close csr_user;
      if var_user_obj_code is null and var_guest_obj_code is null then
         return;
      end if;

      /*-*/
      /* Pipe the output to the consumer
      /*-*/
      if var_user_obj_code is null then
         var_user_level := var_guest_level;
         var_user_obj_type := var_guest_obj_type;
         var_user_obj_code := var_guest_obj_code;
         var_user_obj_description := var_guest_obj_description;
         var_user_obj_status := var_guest_obj_status;
         var_user_lnk_sequence := var_guest_lnk_sequence;
         var_user_lnk_type := var_guest_lnk_type;
         var_user_lnk_code := var_guest_lnk_code;
         var_user_lnk_description := var_guest_lnk_description;
         var_user_lnk_script := var_guest_lnk_script;
         var_user_lnk_status := var_guest_lnk_status;
      end if;
      pipe row(lics_security_object(var_user_level,
                                    var_user_obj_type,
                                    var_user_obj_type,
                                    var_user_obj_description,
                                    var_user_obj_status,
                                    var_user_lnk_sequence,
                                    var_user_lnk_type,
                                    var_user_lnk_code,
                                    var_user_lnk_description,
                                    var_user_lnk_script,
                                    var_user_lnk_status));

      /*-*/
      /* Retrieve the user menu information and pipe to output when user active
      /*-*/
      if var_user_obj_status = '1' then
         open csr_security;
         loop
            fetch csr_security into rcd_security;
            if csr_security%notfound then
               exit;
            end if;
            pipe row(lics_security_object(rcd_security.sec_level,
                                          rcd_security.sec_obj_type,
                                          rcd_security.sec_obj_code,
                                          rcd_security.sec_obj_description,
                                          rcd_security.sec_obj_status,
                                          rcd_security.sec_lnk_sequence,
                                          rcd_security.sec_lnk_type,
                                          rcd_security.sec_lnk_code,
                                          rcd_security.sec_lnk_description,
                                          rcd_security.sec_lnk_script,
                                          rcd_security.sec_lnk_status));
         end loop;
         close csr_security;
      end if;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LICS_SECURITY - GET_SECURITY (' || par_user || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_security;

   /******************************************************/
   /* This procedure performs the check security routine */
   /******************************************************/
   function check_security(par_user in varchar2, par_option in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(32);
      var_user_menu lics_sec_user.seu_menu%type;
      var_user_status lics_sec_user.seu_status%type;
      var_guest_menu lics_sec_user.seu_menu%type;
      var_guest_status lics_sec_user.seu_status%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_user is
         select t01.seu_user,
                t01.seu_menu,
                t01.seu_status
           from lics_sec_user t01
          where upper(t01.seu_user) = upper(par_user) or
                upper(t01.seu_user) = upper(con_guest);
      rcd_user csr_user%rowtype;

      cursor csr_security is
         select t02.seo_status
           from (select t01.*
                   from lics_sec_link t01
                  start with t01.sel_menu = var_user_menu
                connect by (prior t01.sel_link = t01.sel_menu) and
                           (prior t01.sel_type = '*MNU')
                  order siblings by t01.sel_sequence) t01,
                lics_sec_option t02
          where t01.sel_link = t02.seo_option
            and t01.sel_type = '*OPT'
            and upper(t01.sel_link) = upper(par_option);
      rcd_security csr_security%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variable
      /*-*/
      var_return := '*OK';

      /*-*/
      /* Retrieve the user information (user and guest)
      /*-*/
      var_user_menu := null;
      var_guest_menu := null;
      var_user_status := '0';
      var_guest_status := '0';
      open csr_user;
      loop
         fetch csr_user into rcd_user;
         if csr_user%notfound then
            exit;
         end if;
         if upper(rcd_user.seu_user) = upper(par_user) then
            var_user_menu := rcd_user.seu_menu;
            var_user_status := rcd_user.seu_status;
         end if;
         if upper(rcd_user.seu_user) = upper(con_guest) then
            var_guest_menu := rcd_user.seu_menu;
            var_guest_status := rcd_user.seu_status;
         end if;
      end loop;
      close csr_user;
      if var_user_menu is null and var_guest_menu is null then
         var_return := '*USER_INVALID';
      else
         if var_user_menu is null then
            var_user_menu := var_guest_menu;
            var_user_status := var_guest_status;
         end if;
         if var_user_status != '1' then
            var_return := '*USER_INACTIVE';
         end if;
      end if;

      /*-*/
      /* Check the option validity when user valid
      /*-*/
      if var_return = '*OK' then
         open csr_security;
         fetch csr_security into rcd_security;
         if csr_security%notfound then
            var_return := '*OPTION_INVALID';
         else
            if rcd_security.seo_status != '1' then
               var_return := '*OPTION_INACTIVE';
            end if;
         end if;
         close csr_security;
      end if;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LICS_SECURITY - CHECK_SECURITY (' || par_user || ' / '  || par_option || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_security;

   /****************************************************************/
   /* This procedure performs the check interface security routine */
   /****************************************************************/
   function check_intfc_security(par_interface in varchar2, par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(64);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_lics_sec_interface is 
         select 'x'
           from lics_sec_interface t01
          where upper(t01.sei_interface) = upper(par_interface)
       group by t01.sei_interface;
      rcd_lics_sec_interface csr_lics_sec_interface%rowtype;

      cursor csr_lics_sec_interface01 is 
         select 'x'
           from lics_sec_interface t01
          where upper(t01.sei_interface) = upper(par_interface)
            and upper(t01.sei_user) = upper(par_user);
      rcd_lics_sec_interface01 csr_lics_sec_interface01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variable
      /*-*/
      var_return := '*OK';

      /*-*/
      /* User must have access to view interface data
      /*   notes : 
      /*     - User interface access is defined in LICS_SEC_INTERFACE
      /*     - Where an interface has no user access defined, it is assumed open to public
      /*     - Where an interface has one or more users defined, it is restricted to only those defined
      /*-*/
      open csr_lics_sec_interface;
      fetch csr_lics_sec_interface into rcd_lics_sec_interface;
      if csr_lics_sec_interface%found then
         open csr_lics_sec_interface01;
         fetch csr_lics_sec_interface01 into rcd_lics_sec_interface01;
         if csr_lics_sec_interface01%notfound then
            var_return := 'Access Denied - You do not have access to view this interface';
         end if;
      end if;
      close csr_lics_sec_interface;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LICS_SECURITY - CHECK_INTFC_SECURITY (' || par_interface || ' / '  || par_user || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_intfc_security;


   /********************************************************************/
   /* This procedure performs the check interface hdr security routine */
   /********************************************************************/
   function check_intfc_hdr_security(par_interface_hdr in varchar2, par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(64);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_lics_header_01 is 
         select t02.int_interface
           from lics_header t01,
                lics_interface t02
          where t01.hea_interface = t02.int_interface(+)
            and t01.hea_header = par_interface_hdr;
      rcd_lics_header_01 csr_lics_header_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variable
      /*-*/
      var_return := '*OK';

      /*-*/
      /* Header must exist
      /*-*/
      open csr_lics_header_01;
      fetch csr_lics_header_01 into rcd_lics_header_01;
      if csr_lics_header_01%notfound then
         var_return := 'Interface header (' || to_char(par_interface_hdr,'FM999999999999990') || ') does not exist';
         return var_return;
      end if;
      close csr_lics_header_01;

      /*-*/
      /* Perform Interface ID Security Check
      /*-*/
      var_return := check_intfc_security(rcd_lics_header_01.int_interface, par_user);

      /*-*/
      /* Return result
      /*-*/
      return var_return;      

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LICS_SECURITY - CHECK_INTFC_HDR_SECURITY (' || par_interface_hdr || ' / '  || par_user || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_intfc_hdr_security;

end lics_security;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_security for lics_app.lics_security;
grant execute on lics_security to public;
