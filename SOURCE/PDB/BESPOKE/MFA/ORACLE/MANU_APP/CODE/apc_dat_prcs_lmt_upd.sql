DROP PROCEDURE MANU_APP.APC_DAT_PRCS_LMT_UPD;

CREATE OR REPLACE PROCEDURE MANU_APP.APC_DAT_PRCS_LMT_UPD IS
  v_mpi_desc varchar2(2000);
  v_mpi_val varchar2(30);
  v_mpi_uom varchar2(20);  
  v_material_code varchar2(54);
  v_exists number;
  
  CURSOR crsr_cntl_rec IS
   select distinct ltrim(material,0) material_code from cntl_rec
  where material not in (select material from cntl_rec a, cntl_rec_mpi_val b
  where a.proc_order = b.proc_order
  and upper(b.mpi_desc) = 'SPEC SHEET'); 
 
  CURSOR crsr_cntl_rec_osci IS
   select distinct ltrim(material,0) material_code from cntl_rec
  where material in (select material from cntl_rec a, cntl_rec_mpi_val b
  where a.proc_order = b.proc_order
  and upper(b.mpi_desc) = 'SPEC SHEET'); 
 
  CURSOR crsr_cntl_rec_osci_label IS
   select distinct mpi_val, ltrim(material,0) material_code from cntl_rec a, cntl_rec_mpi_val b
  where a.proc_order = b.proc_order
  and upper(b.mpi_desc) = 'SPEC SHEET';
  
 CURSOR crsr_mpi_items IS
  select UPPER(mpi_desc) mpi_desc,mpi_val,mpi_uom
  from cntl_rec_mpi_val a, cntl_rec b
  where ltrim(material,0) = v_material_code
  and b.proc_order = a.proc_order
  and seq > (
  select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
  where b.proc_order = a.proc_order
  and upper(a.mpi_text) = 'PROCESS'
  and ltrim(material,0) = v_material_code
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code))
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code)
  and mpi_tag in('162','165','167','163','166','168','161','164','176','179','177','180','175',
  '178','191','194','192','195','190','193','5','9','11','15','17','27','29','6','10','12','16','18','28','30','7','8','13',
  '14','3','4','2','44','42');  
  
 CURSOR crsr_mpi_items_osci IS
  select UPPER(mpi_desc) mpi_desc,mpi_val,mpi_uom
  from cntl_rec_mpi_val a, cntl_rec b
  where ltrim(material,0) = v_material_code
  and b.proc_order = a.proc_order
  and seq > (
  select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
  where b.proc_order = a.proc_order
  and upper(a.mpi_text) = 'PROCESS - FINAL PRODUCT'
  and ltrim(material,0) = v_material_code
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code))
  and seq < (
  select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
  where b.proc_order = a.proc_order
  and upper(a.mpi_text) = 'LABELLER'
  and ltrim(material,0) = v_material_code
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code))
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code)
  and mpi_tag in('162','165','167','163','166','168','161','164','176','179','177','180','175',
  '178','191','194','192','195','190','193','5','9','11','15','17','27','29','6','10','12','16','18','28','30','7','8','13',
  '14','3','4','2','44','42');
  
 CURSOR crsr_mpi_items_osci_label IS
  select UPPER(mpi_desc) mpi_desc,mpi_val,mpi_uom
  from cntl_rec_mpi_val a, cntl_rec b
  where ltrim(material,0) = v_material_code
  and b.proc_order = a.proc_order
  and seq > (
  select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
  where b.proc_order = a.proc_order
  and upper(a.mpi_text) = 'LABELLER'
  and ltrim(material,0) = v_material_code
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code))
  and b.proc_order = (select max(proc_order) from cntl_rec
  where ltrim(material,0) = v_material_code)
  and mpi_tag in('162','165','167','163','166','168','161','164','176','179','177','180','175',
  '178','191','194','192','195','190','193','5','9','11','15','17','27','29','6','10','12','16','18','28','30','7','8','13',
  '14','3','4','2','44','42');   
  
BEGIN
  FOR material_data in crsr_cntl_rec LOOP
    dbms_output.put_line(material_data.material_code);
    --NORMAL MATERIALS 
   BEGIN 
    v_material_code := material_data.material_code;
    
    FOR mpi_data in crsr_mpi_items LOOP
     v_exists := 0;
     select count(*) into v_exists
     from apc_dat_ktchn_prcs_lmt
     WHERE material_code = v_material_code
     AND MPI_TYPE = mpi_data.mpi_desc;
    
     IF v_exists = 0 then
      insert into apc_dat_ktchn_prcs_lmt (material_code,mpi_type,
     mpi_val,mpi_uom,mpi_desc)
     values(
     v_material_code,
     mpi_data.mpi_desc,
     mpi_data.mpi_val,
     mpi_data.mpi_uom,
     mpi_data.mpi_desc);
     ELSE 
     update apc_dat_ktchn_prcs_lmt
     set
     MPI_VAL = mpi_data.mpi_val,
     MPI_UOM = mpi_data.mpi_uom,
     MPI_DESC = mpi_data.mpi_desc
     WHERE material_code = v_material_code
     AND MPI_TYPE = mpi_data.mpi_desc;
     END IF;
     END LOOP;
    
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
     dbms_output.put_line(material_data.material_code||' No Data');
     v_material_code := 0;
   WHEN OTHERS THEN
     dbms_output.put_line(material_data.material_code||SQLERRM);
     v_material_code := 0;
   END; 
  END LOOP;
 
   FOR material_data in crsr_cntl_rec_osci LOOP
    dbms_output.put_line(material_data.material_code);
    --NORMAL MATERIALS 
   BEGIN 
    v_material_code := material_data.material_code;
    
    FOR mpi_data in crsr_mpi_items_osci LOOP
     v_exists := 0;
     select count(*) into v_exists
     from apc_dat_ktchn_prcs_lmt
     WHERE material_code = v_material_code
     AND MPI_TYPE = mpi_data.mpi_desc;
    
     IF v_exists = 0 then
      insert into apc_dat_ktchn_prcs_lmt (material_code,mpi_type,
     mpi_val,mpi_uom,mpi_desc)
     values(
     v_material_code,
     mpi_data.mpi_desc,
     mpi_data.mpi_val,
     mpi_data.mpi_uom,
     mpi_data.mpi_desc);
     ELSE 
     update apc_dat_ktchn_prcs_lmt
     set
     MPI_VAL = mpi_data.mpi_val,
     MPI_UOM = mpi_data.mpi_uom,
     MPI_DESC = mpi_data.mpi_desc
     WHERE material_code = v_material_code
     AND MPI_TYPE = mpi_data.mpi_desc;
     END IF;
     END LOOP;
    
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
     dbms_output.put_line(material_data.material_code||' No Data');
     v_material_code := 0;
   WHEN OTHERS THEN
     dbms_output.put_line(material_data.material_code||SQLERRM);
     v_material_code := 0;
   END; 
  END LOOP;
 
     FOR material_data in crsr_cntl_rec_osci_label LOOP
    dbms_output.put_line(material_data.material_code);
    --NORMAL MATERIALS 
   BEGIN 
    v_material_code := material_data.material_code;
    
    FOR mpi_data in crsr_mpi_items_osci_label LOOP
     v_exists := 0;
     select count(*) into v_exists
     from apc_dat_ktchn_prcs_lmt
     WHERE material_code = material_data.mpi_val
     AND MPI_TYPE = mpi_data.mpi_desc;
    
     IF v_exists = 0 then
      insert into apc_dat_ktchn_prcs_lmt (material_code,mpi_type,
     mpi_val,mpi_uom,mpi_desc)
     values(
     material_data.mpi_val,
     mpi_data.mpi_desc,
     mpi_data.mpi_val,
     mpi_data.mpi_uom,
     mpi_data.mpi_desc);
     ELSE 
     update apc_dat_ktchn_prcs_lmt
     set
     MPI_VAL = mpi_data.mpi_val,
     MPI_UOM = mpi_data.mpi_uom,
     MPI_DESC = mpi_data.mpi_desc
     WHERE material_code = material_data.mpi_val
     AND MPI_TYPE = mpi_data.mpi_desc;
     END IF;
     END LOOP;
    
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
     dbms_output.put_line(material_data.material_code||' No Data');
     v_material_code := 0;
   WHEN OTHERS THEN
     dbms_output.put_line(material_data.material_code||SQLERRM);
     v_material_code := 0;
   END; 
  END LOOP;
 
/*   FOR material_data in crsr_cntl_rec_osci LOOP
    dbms_output.put_line(material_data.material_code);
    --OCEAN SPRAY 
   BEGIN
    select mpi_desc,mpi_val,mpi_uom  into v_mpi_desc,v_mpi_val,v_mpi_uom 
    from cntl_rec_mpi_val a, cntl_rec b
    where ltrim(material,0) = material_data.material_code
    and b.proc_order = a.proc_order
    and seq > (
    select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
    where b.proc_order = a.proc_order
    and upper(a.mpi_text) = 'PROCESS - FINAL PRODUCT'
    and ltrim(material,0) = material_data.material_code
    and b.proc_order = (select max(proc_order) from cntl_rec
    where ltrim(material,0) = material_data.material_code))
    and b.proc_order = (select max(proc_order) from cntl_rec
    where ltrim(material,0) = material_data.material_code)
    and mpi_tag in(162,165,167,163,166,168,161,164,176,179,177,180,175,
    178,191,194,192,195,190,193,5,9,11,15,17,27,29,6,10,12,16,18,28,30,7,8,13,
    14,3,4,2,44,42);
    
    v_exists := 0;
    
    select count(*) into v_exists
    from apc_dat_ktchn_prcs_lmt
    WHERE material_code = material_data.material_code
    AND MPI_TYPE = v_mpi_desc;
    
    IF v_exists = 0 then
     insert into apc_dat_ktchn_prcs_lmt (material_code,mpi_type,
    mpi_val,mpi_uom,mpi_desc)
    values(
    material_data.material_code,
    v_mpi_desc,
    v_mpi_val,
    v_mpi_uom,
    v_mpi_desc);
    ELSE 
    update apc_dat_ktchn_prcs_lmt
    set
    MPI_VAL = v_mpi_val,
    MPI_UOM = v_mpi_uom,
    MPI_DESC = v_mpi_desc
    WHERE material_code = material_data.material_code
    AND MPI_TYPE = v_mpi_desc;
    END IF;
   
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
     v_material_code := 0;
   WHEN OTHERS THEN
     v_material_code := 0;
   END; 
  END LOOP;
  
  FOR material_data in crsr_cntl_rec_osci_label LOOP
    dbms_output.put_line(material_data.mpi_val);
    --OCEAN SPRAY LABELLER SPEC 
   BEGIN
    select mpi_desc,mpi_val,mpi_uom  into v_mpi_desc,v_mpi_val,v_mpi_uom 
    from cntl_rec_mpi_val a, cntl_rec b
    where ltrim(material,0) = material_data.material_code
    and b.proc_order = a.proc_order
    and seq > (
    select distinct seq from cntl_rec_mpi_txt a, cntl_rec b
    where b.proc_order = a.proc_order
    and upper(a.mpi_text) = 'LABELLER'
    and ltrim(material,0) = material_data.material_code
    and b.proc_order = (select max(proc_order) from cntl_rec
    where ltrim(material,0) = material_data.material_code))
    and b.proc_order = (select max(proc_order) from cntl_rec
    where ltrim(material,0) = material_data.material_code)
    and mpi_tag in(162,165,167,163,166,168,161,164,176,179,177,180,175,
    178,191,194,192,195,190,193,5,9,11,15,17,27,29,6,10,12,16,18,28,30,7,8,13,
    14,3,4,2,44,42);
    
    v_exists := 0;
    
    select count(*) into v_exists
    from apc_dat_ktchn_prcs_lmt
    WHERE material_code = material_data.mpi_val
    AND MPI_TYPE = v_mpi_desc;
    
    IF v_exists = 0 then
     insert into apc_dat_ktchn_prcs_lmt (material_code,mpi_type,
    mpi_val,mpi_uom,mpi_desc)
    values(
    material_data.mpi_val,
    v_mpi_desc,
    v_mpi_val,
    v_mpi_uom,
    v_mpi_desc);
    ELSE 
    update apc_dat_ktchn_prcs_lmt
    set
    MPI_VAL = v_mpi_val,
    MPI_UOM = v_mpi_uom,
    MPI_DESC = v_mpi_desc
    WHERE material_code = material_data.mpi_val
    AND MPI_TYPE = v_mpi_desc;
    END IF;
   
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
     v_material_code := 0;
   WHEN OTHERS THEN
     v_material_code := 0;
   END; 
  END LOOP;
 */
END;
/


GRANT EXECUTE ON MANU_APP.APC_DAT_PRCS_LMT_UPD TO LICS_APP;

