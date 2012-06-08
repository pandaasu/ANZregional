DROP PACKAGE ICS_APP.ICS_SECURITY_AUDIT;

CREATE OR REPLACE PACKAGE ICS_APP.ics_security_audit as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ICS
 Package : ics_security_audit
 Owner   : ICS_APP
 Author  : Linden Glen

 Description
 -----------
    Provides an emailed extract of login activity on the database, selected
    from SYS.DBA_AUDIT_TRAIL view.


 YYYY/MM   Author               Description
 -------   ------               -----------
 2006/06   Linden Glen          Created
 2012/06   Ben Halicki          Added additional reporting functionality


*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_security_audit;
/


DROP PUBLIC SYNONYM ICS_SECURITY_AUDIT;

CREATE OR REPLACE PUBLIC SYNONYM ICS_SECURITY_AUDIT FOR ICS_APP.ICS_SECURITY_AUDIT;


GRANT EXECUTE ON ICS_APP.ICS_SECURITY_AUDIT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_SECURITY_AUDIT TO LICS_APP;
DROP PACKAGE BODY ICS_APP.ICS_SECURITY_AUDIT;

CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_security_audit as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local Variables
      /*-*/
      var_ema_group        varchar2(512 char);
      var_last_status      number;
      
      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_dba_audit_trail is
      select timestamp,
             os_username,
             username,
             sessionid,
             host_ip,
             status,
             note
        from (select a.timestamp,
                     decode(a.terminal,null,a.os_username,a.os_username || '(' || a.terminal || ')') as os_username,
                     a.username,
                     a.sessionid,
                     decode(a.returncode,0,'YES','NO(' || a.returncode || ')') as return_code,
                     substr(a.comment_text,instr(a.comment_text,'(HOST=')+6,instr(substr(a.comment_text,instr(a.comment_text,'(HOST=')+6),')',1)-1) as host_ip,
                     case 
                        when upper(a.username) in ('ICS_READER','APPSUPPORT') then 0
                        when upper(a.username) in ('LICS','LICS_APP','BDS','BDS_APP','LADS','LADS_APP') and upper(a.os_username) in ('WUDER','HALICBEN') then 1
                        when upper(a.username) in ('LICS_APP','SITE_APP') and upper(a.os_username) in ('NETWORK SERVICE') then 2
                        when upper(a.username) in ('LICS','LICS_APP','BDS','BDS_APP','LADS','LADS_APP','ICS','ICS_APP') and upper(a.os_username) not in ('WUDER','HALICBEN','NETWORK SERVICE') then 3
                        when upper(a.username) in ('SYS','SYSTEM','RMAN') then 4
                        else 5
                     end as status,
                     case 
                        when upper(a.username) in ('LICS','LICS_APP','BDS','BDS_APP','LADS','LADS_APP') and upper(a.os_username) in ('WUDER','HALICBEN') then 'Template Support - Valid Login'
                        when upper(a.username) in ('LICS_APP','SITE_APP') and upper(a.os_username) in ('NETWORK SERVICE') then 'Network Service - Valid Login'
                        when upper(a.username) in ('LICS','LICS_APP','BDS','BDS_APP','LADS','LADS_APP','ICS','ICS_APP') and upper(a.os_username) not in ('WUDER','HALICBEN','NETWORK SERVICE') then 'Invalid Login (ICS/LADS Template Account)'
                        when upper(a.username) in ('SYS','SYSTEM','RMAN') then 'Oracle DBA - Confirm Requirement'
                        when upper(a.username) in ('ICS_READER','APPSUPPORT') then 'Login Valid'
                        else 'Confirmation Required'
                     end as note
                from dba_audit_trail a
               where trunc(a.timestamp) > trunc(sysdate-7)
                 and returncode=0 -- successful login
                 and upper(a.os_username) not in ('MQM','ORACLE','MQFTS','DWTRNSFR','NETWORK SERVICE'))
       where status != 0 
       order by status desc;
      rec_dba_audit_trail csr_dba_audit_trail%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve recipient Email Group
      /*-*/
      var_ema_group := lics_setting_configuration.retrieve_setting('ICS_SECURITY', 'EMAIL_GROUP');

      /*-*/
      /* Create Email
      /*-*/
      isi_mailer.create_email(var_ema_group,
                              'ICS Security Audit for '
                                 || upper(sys_context ('USERENV', 'DB_NAME'))
                                 || ' on ' || to_char(sysdate,'DD/MM/YYYY')
                              ,null,null);


      /*-*/
      /* Write Email header
      /*-*/
      isi_mailer.append_data('ICS SECURITY AUDIT');
      isi_mailer.append_data('*---------------------------------------------------------------------------------------------------------------------------------------------*');
      isi_mailer.append_data('DATE RANGE   : ' || to_char(sysdate-7,'DD/MM/YYYY') || ' - ' || to_char(sysdate,'DD/MM/YYYY'));
      isi_mailer.append_data('DATABASE     : ' || upper(sys_context ('USERENV', 'DB_NAME')));
      isi_mailer.append_data('ENVIRONMENT  : ' || lics_parameter.system_unit || '/' || lics_parameter.system_environment);
      isi_mailer.append_data('NOTES        : Excludes OS_USERNAME = mqm, oracle, mqfts, dwtrnsfr');
      /*-*/

      open csr_dba_audit_trail;
      loop
         fetch csr_dba_audit_trail into rec_dba_audit_trail;
         if (csr_dba_audit_trail%notfound) then
            exit;
         end if;

         /* detect status change and display new header */
         if (var_last_status != rec_dba_audit_trail.status) then
            isi_mailer.append_data('*=============================================================================================================================================*');
         end if;
         
         if (var_last_status is null or var_last_status != rec_dba_audit_trail.status) then
            isi_mailer.append_data(null);
            isi_mailer.append_data('Status: ' || rec_dba_audit_trail.note);
            isi_mailer.append_data('*---------------------------------------------------------------------------------------------------------------------------------------------*');
            isi_mailer.append_data('| TIMESTAMP           | OS USERNAME            | DB USERNAME      | SESSION ID | OS IP ADDRESS     | Status                                   |');
            isi_mailer.append_data('*=============================================================================================================================================*');
         end if;
         
         isi_mailer.append_data('| ' || to_char(rec_dba_audit_trail.timestamp,'DD/MM/YYYY HH24:MI:SS')
                                     || ' | ' || rpad(nvl(rec_dba_audit_trail.os_username,' '),22,' ')
                                     || ' | ' || rpad(nvl(rec_dba_audit_trail.username,' '),16,' ')
                                     || ' | ' || rpad(rec_dba_audit_trail.sessionid,10,' ')
                                     || ' | ' || rpad(nvl(rec_dba_audit_trail.host_ip,' '),17,' ')
                                     || ' | ' || rpad(nvl(rec_dba_audit_trail.note,' '),40,' ')
                                     || ' |');

      
         var_last_status := rec_dba_audit_trail.status;
      
      end loop;
      close csr_dba_audit_trail;

      isi_mailer.append_data('*=============================================================================================================================================*');

      /*-*/
      /* Finalise Email
      /*-*/
      isi_mailer.finalise_email(lics_parameter.system_unit || '.' || lics_parameter.system_environment || '@' || upper(sys_context ('USERENV', 'DB_NAME')));


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise Email
         /*-*/
         if (isi_mailer.is_created) then
            isi_mailer.append_data('** FATAL ERROR DURING SYSTEM AUDIT EXTRACT ** - ' || SQLERRM);
            isi_mailer.finalise_email(lics_parameter.system_environment || '@' || upper(sys_context ('USERENV', 'DB_NAME')));
         end if;

         /*-*/
         /* Raise the exception
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ics_security_audit;
/


DROP PUBLIC SYNONYM ICS_SECURITY_AUDIT;

CREATE OR REPLACE PUBLIC SYNONYM ICS_SECURITY_AUDIT FOR ICS_APP.ICS_SECURITY_AUDIT;


GRANT EXECUTE ON ICS_APP.ICS_SECURITY_AUDIT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_SECURITY_AUDIT TO LICS_APP;

