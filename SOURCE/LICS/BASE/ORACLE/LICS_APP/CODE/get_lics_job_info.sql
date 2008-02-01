CREATE OR REPLACE PROCEDURE get_lics_job_info(
  lics_int_job_name OUT lics_job_trace.jot_job%TYPE,
  job_type          OUT lics_job_trace.jot_type%TYPE,
  interface_group   OUT lics_job_trace.jot_int_group%TYPE,
  jot_procedure     OUT lics_job_trace.jot_procedure%TYPE,
  jot_user          OUT lics_job_trace.jot_user%TYPE
  ) IS

  -- CURSOR
  CURSOR csr_jot_job_info IS
    SELECT
      A.jot_job       AS lics_interface_job_name,
      A.jot_type      AS job_type,
      A.jot_int_group AS interface_group,
      A.jot_procedure AS jot_procedure,
      A.jot_user      AS jot_user
    FROM
      lics_job_trace A,
      v$session      B
    WHERE
      SUBSTR(B.client_info, 1, 6) = 'ICSJOB'
      AND A.jot_execution = TO_NUMBER(SUBSTR(B.client_info, 8, LENGTH(B.client_info) - 7))
      AND B.client_info = (SELECT
                             sys_context('USERENV', 'CLIENT_INFO')
                           FROM
                             dual);

BEGIN

  -- Get the lics_job info for the job that was started by this session
  OPEN csr_jot_job_info;
  FETCH csr_jot_job_info INTO lics_int_job_name,
                              job_type,
                              interface_group,
                              jot_procedure,
                              jot_user;
  CLOSE csr_jot_job_info;

END get_lics_job_info;
/

grant execute on get_lics_job_info to ods_app;