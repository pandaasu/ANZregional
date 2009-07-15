/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pet_allocation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_allocation
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet allocation

    This package contain the pet allocation functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure perform_allocation(par_tes_code in number);

end pts_pet_allocation;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pet_allocation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure standard(par_tes_code in number, par_day_count in number);
   procedure difference(par_tes_code in number, par_day_count in number);

   /*-*/
   /* Private constants
   /*-*/
   con_key_map constant varchar2(36) := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

   /**********************************************************/
   /* This procedure performs the perform allocation routine */
   /**********************************************************/
   procedure perform_allocation(par_tes_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                nvl(t02.tty_sam_count,1) as tty_sam_count,
                t02.tty_alc_proc
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = par_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the existing test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(par_tes_code) || ') must be status (Raised) - allocation not allowed');
      end if;

      /*-*/
      /* Execute the allocation procedure
      /*-*/
      if upper(rcd_retrieve.tty_alc_proc) = 'STANDARD' then
         standard(rcd_retrieve.tde_tes_code,rcd_retrieve.tde_tes_day_count);
      elsif upper(rcd_retrieve.tty_alc_proc) = 'DIFFERENCE' then
         difference(rcd_retrieve.tde_tes_code,rcd_retrieve.tde_tes_day_count);
      else
         raise_application_error(-20000, 'Pet allocation (' || upper(rcd_retrieve.tty_alc_proc) || ') is not supported');
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_ALLOCATION - PERFORM_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end perform_allocation;

   /***********************************************************/
   /* This procedure performs the standard allocation routine */
   /***********************************************************/
   procedure standard(par_tes_code in number, par_day_count in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;
      type typ_akey is table of varchar2(36) index by binary_integer;
      tbl_akey typ_akey;
      rcd_pts_tes_allocation pts_tes_allocation%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = par_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_allocation is
         select t01.*
           from table(pts_gen_function.randomize_allocation((select count(*) from pts_tes_sample where tsa_tes_code = par_tes_code), (select count(*) from pts_tes_panel where tpa_tes_code = par_tes_code))) t01;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01
                  where t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = par_tes_code
          order by nvl(t02.tcl_val_code,1),
                   t01.tpa_pan_code;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;
      if par_day_count != tbl_scod.count then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration days and sample count must match');
      end if;

      /*-*/
      /* Retrieve and load the allocation key array
      /*-*/
      tbl_akey.delete;
      open csr_allocation;
      fetch csr_allocation bulk collect into tbl_akey;
      close csr_allocation;

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized so panel
      /*              does not need to be randomized
      /*           2. The panel has been sort by pet size to introduce
      /*              the sample randomization into the pet type
      /*-*/
      var_key_index := tbl_akey.count;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Create the test panel allocation
         /*-*/
         var_key_index := var_key_index + 1;
         if var_key_index > tbl_akey.count then
            var_key_index := 1;
         end if;
         var_key_work := tbl_akey(var_key_index);
         for idx in 1..length(var_key_work) loop
            var_sam_index := instr(con_key_map,substr(var_key_work,idx,1));
            if var_sam_index != 0 then
               rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
               rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
               rcd_pts_tes_allocation.tal_day_code := idx;
               rcd_pts_tes_allocation.tal_sam_code := tbl_scod(var_sam_index).tsa_sam_code;
               rcd_pts_tes_allocation.tal_seq_numb := idx;
               insert into pts_tes_allocation values rcd_pts_tes_allocation;
            end if;
         end loop;

      end loop;
      close csr_panel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end standard;

   /*************************************************************/
   /* This procedure performs the difference allocation routine */
   /*************************************************************/
   procedure difference(par_tes_code in number, par_day_count in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      var_switch boolean;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;
      type typ_akey is table of varchar2(36) index by binary_integer;
      tbl_akey typ_akey;
      rcd_pts_tes_allocation pts_tes_allocation%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = par_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_allocation is
         select t01.*
           from table(pts_gen_function.randomize_allocation((select count(*) from pts_tes_sample where tsa_tes_code = par_tes_code), (select count(*) from pts_tes_panel where tpa_tes_code = par_tes_code))) t01;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01
                  where t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = par_tes_code
          order by nvl(t02.tcl_val_code,1),
                   t01.tpa_pan_code;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Test validation
      /*-*/
      if par_day_count != 2 then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration must be 2 days for a difference allocation');
      end if;

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;
      if par_day_count != tbl_scod.count then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration days and sample count must match');
      end if;

      /*-*/
      /* Retrieve and load the allocation key array
      /*-*/
      tbl_akey.delete;
      open csr_allocation;
      fetch csr_allocation bulk collect into tbl_akey;
      close csr_allocation;

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized so panel
      /*              does not need to be randomized
      /*           2. The panel has been sort by pet size to introduce
      /*              the sample randomization into the pet type
      /*-*/
      var_switch := false;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Create the test panel allocation
         /*-*/
         if var_switch = false then
            var_key_index := tbl_akey.count;
         else
            var_key_index := 1;
         end if;
         for idx in 1..par_day_count loop
            if var_switch = false then
               var_key_index := var_key_index + 1;
               if var_key_index > tbl_akey.count then
                  var_key_index := 1;
               end if;
            else
               var_key_index := var_key_index - 1;
               if var_key_index < 1 then
                  var_key_index := tbl_akey.count;
               end if;
            end if;
            var_key_work := tbl_akey(var_key_index);
            for idy in 1..length(var_key_work) loop
               var_sam_index := instr(con_key_map,substr(var_key_work,idy,1));
               if var_sam_index != 0 then
                  rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
                  rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
                  rcd_pts_tes_allocation.tal_day_code := idx;
                  rcd_pts_tes_allocation.tal_sam_code := tbl_scod(var_sam_index).tsa_sam_code;
                  rcd_pts_tes_allocation.tal_seq_numb := idy;
                  insert into pts_tes_allocation values rcd_pts_tes_allocation;
               end if;
            end loop;
         end loop;
         if var_switch = false then
            var_switch := true;
         else
            var_switch := false;
         end if;

      end loop;
      close csr_panel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end difference;

end pts_pet_allocation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_allocation for pts_app.pts_pet_allocation;
grant execute on pts_app.pts_pet_allocation to public;
