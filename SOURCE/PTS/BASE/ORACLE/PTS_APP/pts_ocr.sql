/******************/
/* Package Header */
/******************/
create or replace
package PTS_OCR as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : PTS_OCR
    Owner   : PTS_APP
    Author  : Peter Tylee

    Description
    -----------
    Imports the csv column-based OCR responses to the row-based PTS system

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/11   Peter Tylee    Created

   *******************************************************************************/

  procedure data_import;
  procedure error_report;
 
end PTS_OCR;
 
/

/****************/
/* Package Body */
/****************/
create or replace
package body         PTS_OCR as

  v_error_email    varchar2(100) := 'jason.fraser@effem.com;peter.j.tylee@effem.com'; --Receives exception reports 
  v_fe_email       varchar2(200) := 'jason.fraser@effem.com;peter.j.tylee@effem.com'; --Receives validation error report
  --Example of multiple recipients: 'jason.fraser@effem.com;recipient2@domain.com'
  v_sender_email   varchar2(100) := 'pts-error-reporting@effem.com';


/********************************************************************************
   NAME:      data_import
   PURPOSE:   Validates uploaded CSV data and imports to response table
   
   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     26/10/2011  Peter Tylee      Created.
********************************************************************************/
procedure data_import is
begin
  
  /* There are fundamentally 2 ways the data can be structured for import:
      1) Data in rows
      2) Data in columns
      
      The OCR software outputs the data in columns, and this is the structure most
      natural for the users to interact with. To avoid the necessity of pivoting the
      data (eg, with Excel, a C# utility, etc) the data will be uploaded in columns.
      
      Consequently:
        1) The questions must appear in the same order in the columns as the order
        that they appear in the questionnaire.
        2) The data will need to be imported column by column
        3) To support the situation where some days in the test have a different
        number of questions to other days, the data also has to be imported day by day.
        This does result in more merge statements (typically 5 days * 7 questions = 35 iterations),
        but the volume of data imported is expected to be reasonable (approx 7,500 records at a time)
        so the impact on performance should not be an issue.
  
      Algorithm:
      1) Import data into tmp table (done prior to calling this procedure)
      2) Identify and flag the records that fail validation (for test code, pet code, sample code, eg. if test code doesn't exist in pts_tes_definition)
      3) Merge the invalid records into the error table (invalid records have tra_valid = 0)
      4) For each test code
      5)   For each day
      6)      For each response column in the table
      7)         Merge data into response table
  */
  
  --Identify validation failures
  --In theory, now that the validation is handled by the stepts01_validation package at the
  --time the csv file is uploaded, it shouldn't identify any invalid records.
  update    pts_tes_temp
  set       tra_valid = 0
  where     not exists (
              select  1
              from    pts_tes_definition tes
              where   tes.tde_tes_code = tra_tes_code
            )
            or not exists (
              select  1
              from    pts_pet_definition pet
              where   pet.pde_pet_code = tra_pet_code
            );
            
  --Merge validation failures into error table
  merge into pts_tes_error e
  using (
          select  distinct
                  tra_tes_code,
                  tra_pet_code,
                  tra_day_code,
                  tra_mkt_code,
                  tra_q1,
                  tra_q2,
                  tra_q3,
                  tra_q4,
                  tra_q5,
                  tra_q6,
                  tra_q7,
                  tra_q8,
                  tra_q9,
                  tra_q10,
                  tra_q11,
                  tra_q12,
                  tra_q13,
                  tra_q14,
                  tra_q15
          from    pts_tes_temp
          where tra_valid = 0
        ) t on (
          e.era_tes_code = t.tra_tes_code
          and e.era_pet_code = t.tra_pet_code
          and e.era_day_code = t.tra_day_code
          and e.era_mkt_code = t.tra_mkt_code
        )
  when matched then
        update
        set     e.era_q1 = t.tra_q1,
                e.era_q2 = t.tra_q2,
                e.era_q3 = t.tra_q3,
                e.era_q4 = t.tra_q4,
                e.era_q5 = t.tra_q5,
                e.era_q6 = t.tra_q6,
                e.era_q7 = t.tra_q7,
                e.era_q8 = t.tra_q8,
                e.era_q9 = t.tra_q9,
                e.era_q10 = t.tra_q10,
                e.era_q11 = t.tra_q11,
                e.era_q12 = t.tra_q12,
                e.era_q13 = t.tra_q13,
                e.era_q14 = t.tra_q14,
                e.era_q15 = t.tra_q15,
                e.era_rpt_flg = 0
        where   nvl(e.era_q1,0) <> nvl(t.tra_q1,0)
                or nvl(e.era_q2,0) <> nvl(t.tra_q2,0)
                or nvl(e.era_q3,0) <> nvl(t.tra_q3,0)
                or nvl(e.era_q4,0) <> nvl(t.tra_q4,0)
                or nvl(e.era_q5,0) <> nvl(t.tra_q5,0)
                or nvl(e.era_q6,0) <> nvl(t.tra_q6,0)
                or nvl(e.era_q7,0) <> nvl(t.tra_q7,0)
                or nvl(e.era_q8,0) <> nvl(t.tra_q8,0)
                or nvl(e.era_q9,0) <> nvl(t.tra_q9,0)
                or nvl(e.era_q10,0) <> nvl(t.tra_q10,0)
                or nvl(e.era_q11,0) <> nvl(t.tra_q11,0)
                or nvl(e.era_q12,0) <> nvl(t.tra_q12,0)
                or nvl(e.era_q13,0) <> nvl(t.tra_q13,0)
                or nvl(e.era_q14,0) <> nvl(t.tra_q14,0)
                or nvl(e.era_q15,0) <> nvl(t.tra_q15,0)
  when not matched then
        insert
        (
          era_tes_code, 
          era_pet_code,
          era_day_code,
          era_mkt_code,
          era_q1,
          era_q2,
          era_q3,
          era_q4,
          era_q5,
          era_q6,
          era_q7,
          era_q8,
          era_q9,
          era_q10,
          era_q11,
          era_q12,
          era_q13,
          era_q14,
          era_q15
        )
        values
        (
          t.tra_tes_code, 
          t.tra_pet_code,
          t.tra_day_code,
          t.tra_mkt_code,
          t.tra_q1,
          t.tra_q2,
          t.tra_q3,
          t.tra_q4,
          t.tra_q5,
          t.tra_q6,
          t.tra_q7,
          t.tra_q8,
          t.tra_q9,
          t.tra_q10,
          t.tra_q11,
          t.tra_q12,
          t.tra_q13,
          t.tra_q14,
          t.tra_q15
        );
  
  -- For each test
  for test_code in (
    select    distinct
              tra_tes_code as code
    from      pts_tes_temp
  )
  loop

    -- For each day in the test
    for test_day in (
      select    distinct
                tqu_day_code as day_code
      from      pts_tes_question
      where     tqu_tes_code = test_code.code
      order by  tqu_day_code asc
    ) loop
  
      -- For each question in the sequence
      for question in (
        select    distinct
                  tqu_dsp_seqn as seq
        from      pts_tes_question
        where     tqu_tes_code = test_code.code
                  and tqu_day_code = test_day.day_code
        order by  tqu_dsp_seqn asc
      ) loop
          
          -- Merge into the response table
          merge into pts_tes_response r
          using (
                  select  distinct
                          test_code.code as tra_tes_code,
                          t.tra_pet_code,
                          t.tra_day_code,
                          nvl((
                            select  a.tal_sam_code
                            from    pts_tes_allocation a
                            where   a.tal_tes_code = test_code.code
                                    and a.tal_pan_code = t.tra_pet_code
                                    and a.tal_day_code = t.tra_day_code
                                    and a.tal_mkt_code = t.tra_mkt_code
                                    and rownum = 1
                          ),(
                            select  tsa_sam_code
                            from    pts_tes_sample
                            where   tsa_tes_code = test_code.code
                                    and (
                                      tsa_mkt_code = t.tra_mkt_code
                                      or tsa_mkt_acde = t.tra_mkt_code
                                    )
                                    and rownum = 1
                          )) as tra_sam_code,
                          q.tqu_que_code as tra_que_code,
                          case
                            when question.seq = 1 then t.tra_q1 
                            when question.seq = 2 then t.tra_q2 
                            when question.seq = 3 then t.tra_q3 
                            when question.seq = 4 then t.tra_q4 
                            when question.seq = 5 then t.tra_q5 
                            when question.seq = 6 then t.tra_q6 
                            when question.seq = 7 then t.tra_q7 
                            when question.seq = 8 then t.tra_q8 
                            when question.seq = 9 then t.tra_q9 
                            when question.seq = 10 then t.tra_q10 
                            when question.seq = 11 then t.tra_q11 
                            when question.seq = 12 then t.tra_q12 
                            when question.seq = 13 then t.tra_q13 
                            when question.seq = 14 then t.tra_q14 
                            when question.seq = 15 then t.tra_q15 
                          end as tra_res_code
                  from    pts_tes_temp t
                          inner join pts_tes_question q on (
                            t.tra_tes_code = q.tqu_tes_code
                            and q.tqu_day_code = 1
                            and q.tqu_dsp_seqn = question.seq
                          )
                  where   t.tra_tes_code = test_code.code
                          and t.tra_valid = 1
                          and case
                            when question.seq = 1 then t.tra_q1 
                            when question.seq = 2 then t.tra_q2 
                            when question.seq = 3 then t.tra_q3 
                            when question.seq = 4 then t.tra_q4 
                            when question.seq = 5 then t.tra_q5 
                            when question.seq = 6 then t.tra_q6 
                            when question.seq = 7 then t.tra_q7 
                            when question.seq = 8 then t.tra_q8 
                            when question.seq = 9 then t.tra_q9 
                            when question.seq = 10 then t.tra_q10 
                            when question.seq = 11 then t.tra_q11 
                            when question.seq = 12 then t.tra_q12 
                            when question.seq = 13 then t.tra_q13 
                            when question.seq = 14 then t.tra_q14 
                            when question.seq = 15 then t.tra_q15
                          end is not null
                ) t on (
                  r.tre_tes_code = t.tra_tes_code
                  and r.tre_pan_code = t.tra_pet_code
                  and r.tre_day_code = t.tra_day_code
                  and r.tre_que_code = t.tra_que_code
                  and r.tre_sam_code = t.tra_sam_code
                  
                )
          when matched then
                update
                set     r.tre_res_value = t.tra_res_code
                where   r.tre_res_value <> t.tra_res_code
          when not matched then
                insert
                (
                  tre_tes_code,
                  tre_pan_code,
                  tre_day_code,
                  tre_que_code,
                  tre_sam_code,
                  tre_res_value    
                )
                values
                (
                  t.tra_tes_code,
                  t.tra_pet_code,
                  t.tra_day_code,
                  t.tra_que_code,
                  t.tra_sam_code,
                  t.tra_res_code
                );
                
      end loop; -- Question
      
    end loop; -- Day
    
  end loop; -- Test
  
  exception
    when others then
      smtp_mailer.mail(v_sender_email, v_error_email, 'PTS CSV Validation Exception', 'Exception in PTS_OCR.VALIDATE_CSV'||chr(13)||SQLERRM);

end data_import;

/********************************************************************************
   NAME:      error_report
   PURPOSE:   Sends e-mail report of validation errors to functional expert
   
   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     26/10/2011  Peter Tylee      Created.
********************************************************************************/
procedure error_report is
  conn        utl_smtp.connection;
  v_count     number;
begin

  select  count(1)
  into    v_count
  from    pts_tes_error
  where   era_rpt_flg = 0;

  if v_count > 0 then
      conn := smtp_mailer.begin_mail(
	  sender     => v_sender_email,
	  recipients => v_fe_email,
	  subject    => 'Validation Failure on PTS ' || to_char(sysdate, 'dd/MM/yyyy'),
	  mime_type  => smtp_mailer.MULTIPART_MIME_TYPE
      );
          
          smtp_mailer.begin_attachment(
            conn          => conn,
            mime_type     => 'text/html',
            filename      => 'body',
            inline        => true
          );
  	  smtp_mailer.write_mb_text(conn, 'Attached is the data<br /><br />');
          smtp_mailer.end_attachment(conn => conn);
          
          smtp_mailer.begin_attachment(
            conn          => conn,
            mime_type     => 'application/vnd.ms-excel',
            inline        => false,
            filename      => 'report.xls'
          );

          smtp_mailer.write_mb_text(conn, 
            '<html xmlns:x=""urn:schemas-microsoft-com:office:excel"">
              <head>
                  <meta http-equiv=""content-type"" content=""text/html; charset=UTF-8"" />
                  <!--[if gte mso 9]>
                  <xml>
                      <x:ExcelWorkbook>
                          <x:ExcelWorksheets>
                              <x:ExcelWorksheet>
                                  <x:Name>Items</x:Name>
                                  <x:WorksheetOptions>
                                      <x:Panes>
                                      </x:Panes>
                                  </x:WorksheetOptions>
                              </x:ExcelWorksheet>
                          </x:ExcelWorksheets>
                      </x:ExcelWorkbook>
                  </xml>
                  <![endif]-->
              </head>
              <body><table><tr><td><b>Test Code</b></td><td><b>File Number</b></td><td><b>Day Number</b></td><td><b>Sample Code</b></td><td><b>Question 1</b></td><td><b>Question 2</b></td><td><b>Question 3</b></td><td><b>Question 4</b></td><td><b>Question 5</b></td><td><b>Question 6</b></td><td><b>Question 7</b></td><td><b>Question 8</b></td><td><b>Question 9</b></td><td><b>Question 10</b></td><td><b>Question 11</b></td><td><b>Question 12</b></td><td><b>Question 13</b></td><td><b>Question 14</b></td><td><b>Question 15</b></td></tr>');

          for rec in (
            select    distinct
                      era_tes_code,
                      era_pet_code,
                      era_day_code,
                      era_mkt_code,
                      era_q1,
                      era_q2,
                      era_q3,
                      era_q4,
                      era_q5,
                      era_q6,
                      era_q7,
                      era_q8,
                      era_q9,
                      era_q10,
                      era_q11,
                      era_q12,
                      era_q13,
                      era_q14,
                      era_q15
            from      pts_tes_error
            where     era_rpt_flg = 0
            order by  era_tes_code,
                      era_pet_code,
                      era_day_code,
                      era_mkt_code
          )
          loop
            smtp_mailer.write_mb_text(conn, '<tr><td>'||to_char(rec.era_tes_code)||'</td><td>'||rec.era_pet_code||'</td><td>'||to_char(rec.era_day_code)||'</td><td>'||rec.era_mkt_code||'</td><td>'||rec.era_q1||'</td><td>'||rec.era_q2||'</td><td>'||rec.era_q3||'</td><td>'||rec.era_q4||'</td><td>'||rec.era_q5||'</td><td>'||rec.era_q6||'</td><td>'||rec.era_q7||'</td><td>'||rec.era_q8||'</td><td>'||rec.era_q9||'</td><td>'||rec.era_q10||'</td><td>'||rec.era_q11||'</td><td>'||rec.era_q12||'</td><td>'||rec.era_q13||'</td><td>'||rec.era_q14||'</td><td>'||rec.era_q15||'</td></tr>');
          end loop;
          
          smtp_mailer.write_mb_text(conn, '</table></body></html>');
          smtp_mailer.end_attachment(conn => conn, last => true);
  	  smtp_mailer.end_mail(conn => conn);
          
          -- Only send the report for each row once
          update  pts_tes_error
          set     era_rpt_flg = 1
          where   era_rpt_flg = 0;
  end if;
  
  exception
    when others then
      smtp_mailer.mail(v_sender_email,v_error_email, 'PTS CSV Error Report Exception', 'Exception in PTS_OCR.ERROR_REPORT'||chr(13)||SQLERRM);
      
end error_report;

end PTS_OCR;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_ocr for pts_app.pts_ocr;
grant execute on pts_app.pts_ocr to public;
