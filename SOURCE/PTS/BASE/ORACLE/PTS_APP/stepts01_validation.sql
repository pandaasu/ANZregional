/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS01_VALIDATION as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS01_VALIDATION
    Owner   : PTS_APP
    Author  : Peter Tylee

    Description
    -----------
    STEPTS01 interface loader - validates OCR data to PTS (Product Testing)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/11   Peter Tylee    Created
    2014/08   Peter Tylee    Modified comments for updated market code length

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;
   

end STEPTS01_VALIDATION;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS01_VALIDATION as

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
      var_tes_code number;
      var_pet_code number;
      var_day_code number;
      var_dsp_seqn number;
      var_res_value number;
      var_mkt_code varchar2(20); --Length should never be more than 3, but we want it causing a validation message, not an exception
      
      cursor csr_question is
         select t01.*
           from pts_que_definition t01
                inner join pts_tes_question t02 on t01.qde_que_code = t02.tqu_que_code
          where t02.tqu_tes_code = var_tes_code
                and t02.tqu_day_code = var_day_code
                and t02.tqu_dsp_seqn = var_dsp_seqn;
      rcd_question csr_question%rowtype;

      cursor csr_response is
         select t01.*
           from pts_que_response t01
          where t01.qre_que_code = rcd_question.qde_que_code
            and t01.qre_res_code = var_res_value;
      rcd_response csr_response%rowtype;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
     
     var_message:=NULL;
     
     -- The data is csv, not fixed field, and the lics_inbound_utility doesn't offer any simple
     -- way of accessing the column data, so tokenize it instead.
     
     var_tokens := tokenize(par_record, ',');
     
     if upper(var_tokens(1)) = 'TEST CODE' then
        return var_message;
     end if;
     
     var_tes_code := pts_to_number(var_tokens(1));
     var_pet_code := pts_to_number(var_tokens(2));
     var_day_code := pts_to_number(var_tokens(3));
     var_mkt_code := var_tokens(4);
     
     --Check that the test exists
     select count(1)
     into   var_count
     from   pts_tes_definition
     where  tde_tes_code = var_tes_code;
     
     if var_count = 0 then
        var_message := append_string(var_message,'Test code does not exist');
     end if;
     
     --Check that the sample exists
     if var_message is not null then
       select count(1)
       into   var_count
       from   pts_tes_sample
       where  tsa_tes_code = var_tes_code
              and (
                tsa_mkt_code = var_mkt_code
                or tsa_mkt_acde = var_mkt_code
              );
            
       if var_count = 0 then
          var_message := append_string(var_message,'Sample/market code does not exist for this test');
       end if;
     end if;
     
     --Check that the pet exists
     select count(1)
     into   var_count
     from   pts_pet_definition
     where  pde_pet_code = var_pet_code;
     
     if var_count = 0 then
        var_message := append_string(var_message,'Pet code does not exist');
     end if;
               
     for idx in 5..var_tokens.count loop
        var_dsp_seqn := idx - 4;
        if var_tokens(idx) is not null then
          if trim(var_tokens(idx)) is not null then
            var_res_value := pts_to_number(var_tokens(idx));
            if var_res_value is null then
              var_message := append_string(var_message,'Response is not a number');
              exit;
            else
              open csr_question;
              fetch csr_question into rcd_question;
              if csr_question%notfound then
                 var_message := append_string(var_message,'Question sequence ('||to_char(var_dsp_seqn)||') does not exist for Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||')');
                 exit;
              else
                 if rcd_question.qde_rsp_type = 1 then
                    open csr_response;
                    fetch csr_response into rcd_response;
                    if csr_response%notfound then
                       var_message := append_string(var_message,'Question ('||to_char(rcd_question.qde_que_code)||') response value ('||to_char(var_res_value)||') does not exist for question');
                       exit;
                    end if;
                    close csr_response;
                 elsif rcd_question.qde_rsp_type = 2 then
                    if var_res_value < rcd_question.qde_rsp_str_range or var_res_value > rcd_question.qde_rsp_end_range then
                       var_message := append_string(var_message,'Question ('||to_char(rcd_question.qde_que_code)||') response value ('||to_char(var_res_value)||') is not within the defined range ('||to_char(rcd_question.qde_rsp_str_range)||' to '||to_char(rcd_question.qde_rsp_end_range)||')');
                       exit;
                    end if;
                 else
                    var_message := append_string(var_message,'Question has invalid response type');
                    exit;
                 end if;
              end if;
              close csr_question;
            end if;
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
   
end STEPTS01_VALIDATION;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym stepts01_validation for pts_app.stepts01_validation;
grant execute on pts_app.stepts01_validation to public;
