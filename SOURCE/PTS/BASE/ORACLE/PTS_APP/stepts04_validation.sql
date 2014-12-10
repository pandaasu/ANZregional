/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS04_VALIDATION as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS04_VALIDATION
    Owner   : PTS_APP
    Author  : Peter Tylee

    Description
    -----------
    STEPTS01 interface loader - validates OCR data to PTS (Product Testing) for 
                                pet survey data.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2014/11   Peter Tylee    Created.

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;
   

end STEPTS04_VALIDATION;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS04_VALIDATION as

   function validate_record(par_record in varchar2) return varchar2;

   /**********************/
   /*    Private Type    */
   /**********************/
   type token_list is varray(100) of varchar2(100);

   /**********************/
   /* Private functions  */
   /**********************/
   function append_string(var_old_msg in varchar2, var_new_msg in varchar2) return varchar2;
   function tokenize (str varchar2, delim char) return token_list;

  
   /***********************************************/
   /* This function performs the on data routine  */
   /***********************************************/
   function on_data(par_record in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;

      /*-*/
      /* Validate the data
      /*-*/
      var_message:=validate_record(par_record);

      /*-*/
      /* Return the message
      /*-*/          
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
   function validate_record(par_record in varchar2) return varchar2 is
   /*-*/
   /* Local definitions
   /*-*/
   
      var_message varchar2(4000);
      var_tokens token_list;
      var_count number;
      var_last_name varchar2(120);
      var_hou_code number;
      var_pet_code number;
      var_pet_type varchar2(120);
      var_pet_name varchar2(120);
      var_birth_year number;
      var_val_code number;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
     
      var_message:=NULL;
     
      -- The data is csv, not fixed field, and the lics_inbound_utility doesn't offer any simple
      -- way of accessing the column data, so tokenize it instead.
     
      var_tokens := tokenize(par_record, ',');
     
      if upper(substr(par_record,1,7)) = 'HH_NAME' then      
        return var_message;
      end if;
     
      var_last_name := trim(var_tokens(1));
      var_hou_code := pts_to_number(var_tokens(2));
      var_pet_type := trim(var_tokens(3));
      var_pet_code := pts_to_number(var_tokens(4));
      var_pet_name := trim(var_tokens(5));
      var_birth_year := pts_to_number(var_tokens(6));
     
      -- Check that the lastname exists
      if var_last_name is null then
        var_message := append_string(var_message,'Last name is required');
      end if;
     
      -- Check that if the household code was provided that it is numeric
      if trim(var_tokens(2)) is not null then
      
        -- Check that the household exists
        select count(1)
        into   var_count
        from   pts_hou_definition
        where  hde_hou_code = var_hou_code;
         
        if var_count = 0 then
          var_message := append_string(var_message,'Household code does not exist');
        end if;
        
      elsif var_hou_code is null then
        
          -- If there is no household code, it must be possible to link the record
          -- to a household record via the last_name field that was created in the
          -- past day.
        
          select  count(1)
          into    var_count
          from    pts_hou_definition
          where   upper(hde_con_surname) = upper(var_last_name)
                  and hde_crt_date > sysdate - 1;
           
          if var_count = 0 then
            var_message := append_string(var_message,'Cannot find newly created household for last name');
          elsif var_count > 1 then
            var_message := append_string(var_message,'Ambiguous household reference. You will need to specify the household code.');
          end if;
        
      end if;
      
      -- Check that if the household code was provided that it is numeric
      if trim(var_tokens(3)) is not null then
      
        --Check that the pet exists
        select count(1)
        into   var_count
        from   pts_pet_definition
        where  pde_pet_code = var_pet_code;
         
        if var_count = 0 then
          var_message := append_string(var_message,'Pet code does not exist');
        end if;
        
      end if;
      
      -- Check that the pet type exists
      select count(1)
      into   var_count
      from   pts_pet_type
      where  upper(pty_typ_text) = upper(var_pet_type);
       
      if var_count = 0 then
        var_message := append_string(var_message,'Pet type does not exist');
      end if;
      
      -- Check that the pet name exists
      if var_pet_name is null then
        var_message := append_string(var_message,'Pet name is required');
      end if;
     
      -- Check birth year
      if trim(var_tokens(6)) is not null and var_birth_year is null then
        var_message := append_string(var_message,'Birth year must be a number');
      elsif var_birth_year is not null and (var_birth_year > extract(year from sysdate) or var_birth_year < extract(year from sysdate) - 40) then
        var_message := append_string(var_message,'Birth year is unrealistic');
      end if;
      
      -- Check any classification data
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index,
                  description
        from      pts.pts_inbound_config
        where     config_type = '*PET'
        order by  column_index asc
      ) loop
      
        var_val_code := pts_to_number(var_tokens(rcd_column.column_index));
      
        if var_val_code is null and length(trim(var_tokens(rcd_column.column_index))) > 0 then
          var_message := append_string(var_message,rcd_column.description||' must be a number');
        elsif var_val_code is not null and var_val_code <> -1 then
          
          -- Check that the value exists
          select  count(1)
          into    var_count
          from    pts_sys_value v
          where   v.sva_val_code = var_val_code
                  and v.sva_tab_code = rcd_column.tab_code
                  and v.sva_fld_code = rcd_column.fld_code;
         
          if var_count = 0 then
            var_message := append_string(var_message,rcd_column.description||' ('||to_char(var_val_code)||') is not a valid response');
          end if;
          
        end if;
        
      end loop;
      
      return var_message;
          
   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_record;
   
   function append_string(var_old_msg in varchar2, var_new_msg in varchar2) return varchar2 is     
   /*-*/
   /* Local definitions
   /*-*/     
   
     var_string  varchar2(4000);
   
   begin
     var_string:=var_old_msg;     
   
     if not(var_string is null) then
       var_string := var_string || '; ';
     end if;

     var_string := var_string || var_new_msg;
        
     return var_string;
    
   end;
 
   /****************************************************************************/
   /* This function performs the splitter count, used in tokenizing a csv line */
   /****************************************************************************/
   function splitter_count(str in varchar2, delim in char) return int as val int;
   begin
      val := length(replace(str, delim, delim || ' '));
      return val - length(str); 
   end;
   
   /**************************************/
   /* This function tokenizes a csv line */
   /**************************************/
   function tokenize (str varchar2, delim char) return token_list as ret token_list;
      target int;
      i int;
      this_delim int;
      last_delim int;
    begin
      ret := token_list();
      i := 1;
      last_delim := 0;
      target := splitter_count(str, delim);
      while i <= target
      loop
        ret.extend();
        this_delim := instr(str, delim, 1, i);
        ret(i):= substr(str, last_delim + 1, this_delim - last_delim -1);
        i := i + 1;
        last_delim := this_delim;
      end loop;
      ret.extend();
      ret(i):= substr(str, last_delim + 1);
      return ret;
    end;
   
end STEPTS04_VALIDATION;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on pts_app.stepts04_validation to public;
