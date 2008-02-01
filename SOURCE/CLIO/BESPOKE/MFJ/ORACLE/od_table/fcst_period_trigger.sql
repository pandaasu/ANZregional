/*------------*/
/* Before row */
/*------------*/
create or replace trigger fcst_period_trigger
   before insert or update on fcst_period for each row

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the user and date
      /*-*/
      :new.fcst_period_lupdp := user;
      :new.fcst_period_lupdt := sysdate;

   /*-------------*/
   /* End trigger */
   /*-------------*/
   end;
/

