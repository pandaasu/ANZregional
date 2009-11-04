alter table lics_triggered add tri_log_data varchar2(512 char) null;
comment on column lics_triggered.tri_log_data is 'Triggered - log data';