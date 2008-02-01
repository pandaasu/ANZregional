/*------------*/
/* Before row */
/*------------*/
create or replace trigger fcst_month_trigger
   before insert or update on fcst_month for each row

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the user and date
      /*-*/
      :new.fcst_month_lupdp := user;
      :new.fcst_month_lupdt := sysdate;

   /*-------------*/
   /* End trigger */
   /*-------------*/
   end;
/

