CREATE OR REPLACE FUNCTION EXCH_RATE_FACTOR (
  i_exch_rate_type_code       VARCHAR2,
  i_currcy_code_from          VARCHAR2,
  i_currcy_code_to            VARCHAR2,
  i_valid_from                DATE
  ) RETURN NUMBER IS
  
  c_redirection_limit         NUMBER(3) := 5;
  
  v_exch_rate_type_code       exch_rate_fctr.exch_rate_type_code%TYPE;
  v_currcy_code_from          exch_rate_fctr.currcy_code_from%TYPE;
  v_currcy_code_to            exch_rate_fctr.currcy_code_to%TYPE;
  v_valid_from                exch_rate_fctr.valid_from%TYPE;
  v_ratio_from                exch_rate_fctr.ratio_from%TYPE;
  v_to_ratio                  exch_rate_fctr.to_ratio%TYPE;
  v_alt_exch_rate_type_code   exch_rate_fctr.alt_exch_rate_type_code%TYPE;
  v_alt_valid_from            exch_rate_fctr.alt_valid_from%TYPE;

  v_counter                   NUMBER(3);
 
  -- Get the appropriate validity date based on the parameters entered.
  CURSOR csr_max_factor IS
    SELECT
      exch_rate_type_code,
      currcy_code_from,  
      currcy_code_to, 
      max(valid_from) AS valid_from 
    FROM
      exch_rate_fctr
    WHERE
      exch_rate_type_code = v_exch_rate_type_code AND
      currcy_code_from = v_currcy_code_from AND  
      currcy_code_to = v_currcy_code_to AND 
      valid_from <= v_valid_from
    GROUP BY
      exch_rate_type_code,
      currcy_code_from,  
      currcy_code_to;
  rv_max_factor csr_max_factor%ROWTYPE;

  -- Get the factors based on the parameters and validity date.
  CURSOR csr_factor IS
    SELECT
      * 
    FROM
      exch_rate_fctr
    WHERE
      exch_rate_type_code = rv_max_factor.exch_rate_type_code AND
      currcy_code_from = rv_max_factor.currcy_code_from AND  
      currcy_code_to = rv_max_factor.currcy_code_to AND 
      valid_from = rv_max_factor.valid_from;
  rv_factor csr_factor%ROWTYPE;      
         
BEGIN

  -- Initialise the working variables.
  v_exch_rate_type_code := i_exch_rate_type_code;
  v_currcy_code_from := i_currcy_code_from;
  v_currcy_code_to := i_currcy_code_to;
  v_valid_from := i_valid_from;

  -- If the from and to currency code are the same, return 1 immediately.
  IF v_currcy_code_from = v_currcy_code_to THEN
    RETURN 1;
  END IF;
     
  
  -- Loop through and find the correct factor record. 
  v_counter := 0;
  OPEN csr_max_factor;
  LOOP

    v_counter := v_counter + 1;

    -- Determine the most appropriate validity date based on the parameters entered.
    FETCH csr_max_factor INTO rv_max_factor;
    IF csr_max_factor%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20000,'EXCH_RATE_FCTR: Max Factor data not found for parameters specified.'); 
    ELSE
      -- Using the validity date, get the factors. 
      OPEN csr_factor;
      FETCH csr_factor INTO rv_factor;
      IF csr_factor%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'EXCH_RATE_FCTR: Factor data not found for parameters specified.'); 
      END IF;

      v_ratio_from := rv_factor.ratio_from;
      v_to_ratio := rv_factor.to_ratio;
      v_alt_exch_rate_type_code := rv_factor.alt_exch_rate_type_code; 
      v_alt_valid_from := rv_factor.alt_valid_from;
      
      CLOSE csr_factor;
    END IF;   

    -- If there is an override in place, we'll need to read records for the override.
    IF v_alt_exch_rate_type_code IS NOT NULL AND v_alt_valid_from <= TRUNC(sysdate,'DD') THEN
    
      -- If we've been redirected too many times, raise an exception (no endless loops!).
      IF v_counter > c_redirection_limit THEN
        RAISE_APPLICATION_ERROR(-20002,'EXCH_RATE_FCTR: Redirection limit exceeded.');
      END IF;
      
      -- Update the keys to retrieve the alternate record, and close and reopen the cursor.
      v_exch_rate_type_code := v_alt_exch_rate_type_code;
      CLOSE csr_max_factor;
      OPEN csr_max_factor;
      
    ELSE

      -- Return the valid factor.
      CLOSE csr_max_factor;
      RETURN rv_factor.ratio_from / rv_factor.to_ratio;
    END IF;   

  END LOOP;
  CLOSE csr_max_factor;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END EXCH_RATE_FACTOR;
/

/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_exch_rate_factor(par_date in varchar2, par_format in varchar2) return number is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    System  : cdw
    Package : dw_exch_rate_factor
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Corporate Data Warehouse - Exchange Rate Factor Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/10   Steve Gregan   Created

   *******************************************************************************/

      /*-*/
      /* Local definitions
      /*-*/
      var_return date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the date value
      /*-*/
      var_return := null;
      begin
         var_return := to_date(par_date,par_format);
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dw_exch_rate_factor;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_exch_rate_factor for dw_app.dw_exch_rate_factor;
grant execute on dw_exch_rate_factor to public with grant option;

