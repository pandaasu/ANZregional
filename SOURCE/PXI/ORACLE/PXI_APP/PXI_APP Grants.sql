--select distinct 'grant execute on ' || object_name || ' to lics_app;' from all_objects where object_name like '%PXI%';
--select distinct 'grant execute on ' || object_name || ' to fflu_app;' from all_objects where object_name like '%PXI%';

grant execute on PXIPMX05_EXTRACT to lics_app;
grant execute on PXIPMX06_EXTRACT to lics_app;
grant execute on PXIATL02_EXTRACT to lics_app;
grant execute on PXIPMX08_EXTRACT to lics_app;
grant execute on PXIPMX01_EXTRACT to lics_app;
grant execute on PXIATL04_EXTRACT to lics_app;
grant execute on PXIPMX03_EXTRACT to lics_app;
grant execute on PMXPXI02_LOADER to lics_app;
grant execute on PXIPMX02_EXTRACT to lics_app;
grant execute on PXIPMX04_EXTRACT to lics_app;
grant execute on pxiatl01_extract to lics_app;
grant execute on pxi_common to lics_app;

grant execute on PXIPMX04_EXTRACT to fflu_app;
grant execute on PXIATL02_EXTRACT to fflu_app;
grant execute on PXIPMX06_EXTRACT to fflu_app;
grant execute on PXIPMX03_EXTRACT to fflu_app;
grant execute on PXIATL04_EXTRACT to fflu_app;
grant execute on PMXPXI02_LOADER to fflu_app;
grant execute on PXIPMX08_EXTRACT to fflu_app;
grant execute on PXIPMX05_EXTRACT to fflu_app;
grant execute on PXIPMX02_EXTRACT to fflu_app;
grant execute on PXI_COMMON to fflu_app;
grant execute on PXIATL01_EXTRACT to fflu_app;
grant execute on PXIPMX01_EXTRACT to fflu_app;