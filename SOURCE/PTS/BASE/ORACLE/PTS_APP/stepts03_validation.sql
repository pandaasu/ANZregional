/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS03_VALIDATION as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS03_VALIDATION
    Owner   : PTS_APP
    Author  : Peter Tylee

    Description
    -----------
    STEPTS01 interface loader - validates OCR data to PTS (Product Testing) for 
                                household survey data.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2014/11   Peter Tylee    Created.

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;
   

end STEPTS03_VALIDATION;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS03_VALIDATION as

   function validate_record(par_record in varchar2) return varchar2;

   /**********************/
   /*    Private Type    */
   /**********************/
   type token_list is varray(20) of varchar2(100);

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
      var_hou_code number;
      var_title varchar2(120);
      var_first_name varchar2(120);
      var_last_name varchar2(120);
      var_street_number varchar2(120);
      var_street varchar2(120);
      var_city varchar2(120);
      var_postcode varchar2(32);
      var_phone varchar2(32);
      var_geo_zone number;
      var_length number;
      var_val_code number;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
     
      var_message:=NULL;
     
      -- The data is csv, not fixed field, and the lics_inbound_utility doesn't offer any simple
      -- way of accessing the column data, so tokenize it instead.
     
      var_tokens := tokenize(par_record, ',');
     
      if upper(substr(par_record,1,4)) = 'HHNO' then      
        return var_message;
      end if;
     
      var_hou_code := pts_to_number(var_tokens(1));
      var_title := trim(var_tokens(2));
      var_first_name := trim(var_tokens(3));
      var_last_name := trim(var_tokens(4));
      var_street_number := trim(var_tokens(5));
      var_street := trim(var_tokens(6));
      var_city := trim(var_tokens(7));
      var_postcode := trim(var_tokens(8));
      var_phone := trim(var_tokens(9));
      var_geo_zone := pts_to_number(var_tokens(10));
     
      --Check that if the household code was provided that it is numeric
      if trim(var_tokens(1)) is not null then
      
        --Check that the household exists
        select count(1)
        into   var_count
        from   pts_hou_definition
        where  hde_hou_code = var_hou_code;
         
        if var_count = 0 then
          var_message := append_string(var_message,'Household code does not exist');
        end if;
        
      end if;
     
      if var_geo_zone is null then
        var_message := append_string(var_message,'Area code is required');
      else
      
        --Check that the area code exists
        select  count(1)
        into    var_count
        from    pts_geo_zone
        where   gzo_geo_zone = var_geo_zone
                and gzo_zon_status = 1 --Active
                and gzo_geo_type = 40; --Area
       
        if var_count = 0 then
          var_message := append_string(var_message,'Area code ('||var_tokens(10)||') does not exist or is inactive');
        end if;
        
      end if;
     
      -- Check that the lastname exists
      if var_last_name is null then
        var_message := append_string(var_message,'Last name is required');
      end if;
      
      -- Check that the title + first + last name fits within 120 characters
      var_length := length(var_title ||' '|| var_first_name ||' '|| var_last_name);
      if var_length > 120 then
        var_message := append_string(var_message,'Length of title + first + last name ('||to_char(var_length)||') must not exceed 120 characters');
      end if;
      
      -- Check that street1 + street2 fits within 120 characters
      var_length := length(var_street_number ||' '|| var_street);
      if var_length > 120 then
        var_message := append_string(var_message,'Length of street number and name ('||to_char(var_length)||') must not exceed 120 characters');
      end if;
      
      var_length := length(var_city);
      if var_length > 120 then
        var_message := append_string(var_message,'Length of city ('||to_char(var_length)||') must not exceed 120 characters');
      end if;
      
      var_length := length(var_postcode);
      if var_length <> 0 and var_length <> 4 or (var_length = 4 and pts_to_number(var_postcode) is null) then
        var_message := append_string(var_message,'Not a valid postcode ('||to_char(var_postcode)||')');
      end if;
      
      var_length := length(var_phone);
      if var_length > 120 then
        var_message := append_string(var_message,'Length of phone ('||to_char(var_length)||') must not exceed 32 characters');
      end if;
      
      -- Check any classification data
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index,
                  description
        from      pts.pts_inbound_config
        where     config_type = '*HOU'
        order by  column_index asc
      ) loop
      
        var_val_code := pts_to_number(var_tokens(rcd_column.column_index));
      
        if var_val_code is null and length(trim(var_tokens(rcd_column.column_index))) > 0 then
          var_message := append_string(var_message,rcd_column.description||' must be a number');
        elsif var_val_code is not null and var_val_code <> -1 then
          
          --Check that the value exists
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
   
end STEPTS03_VALIDATION;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on pts_app.stepts03_validation to public;
