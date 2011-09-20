CREATE OR REPLACE FUNCTION PS_APP.get_token(par_string in varchar2, par_index in number,  par_delim in varchar2 := ',') return varchar2 is

    /******************************************************************************/
    /* Package Definition                                                         */
    /******************************************************************************/
    /**

    Function : get_token
    Owner    : ps_app

    Description
    -----------
    Production Scheduling - Split string and return a token

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/08   Ben Halicki    1. Created this function

    *******************************************************************************/

        /*-*/
        /* Local definitions
        /*-*/
        var_start_pos number;
        var_end_pos   number;
    
    /*-------------*/
    /* Begin block */
    /*-------------*/    
    begin
    
        if par_index = 1 then
            var_start_pos := 1;
        else
            var_start_pos := instr(par_string, par_delim, 1, par_index - 1);
        
            if var_start_pos = 0 then
               return null;
            else
               var_start_pos := var_start_pos + length(par_delim);
            end if;
            
        end if;

        var_end_pos := instr(par_string, par_delim, var_start_pos, 1);

        if var_end_pos = 0 then
            return substr(par_string, var_start_pos);
        else
            return substr(par_string, var_start_pos, var_end_pos - var_start_pos);
        end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
    end get_token;
/
