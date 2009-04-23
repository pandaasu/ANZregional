create or replace procedure manu_app.apc_dat_prcs_lmt_upd is
/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/** 
  System    : Plant DB
  Procedure : apc_dat_prcs_lmt_upd
  Owner     : manu_app  
  Author    : Unknown

  Description 
  ----------- 
  Plant DB - APC_DAT_PRCS_LMT_UPD

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  ??-???-????  Unknown          Created 
  23-Apr-2009  Trevor Keon      Updated MPI_TAG filters as per WO #175945
*******************************************************************************/

  v_mpi_desc varchar2(2000);
  v_mpi_val varchar2(30);
  v_mpi_uom varchar2(20);  
  v_material_code varchar2(54);
  v_exists number;
  
  cursor crsr_cntl_rec is
    select distinct ltrim(material,0) as material_code 
    from cntl_rec
    where material not in 
      (
        select material 
        from cntl_rec a, 
          cntl_rec_mpi_val b
        where a.proc_order = b.proc_order
          and upper(b.mpi_desc) = 'SPEC SHEET'
      ); 
   
  cursor crsr_cntl_rec_osci is
    select distinct ltrim(material,0) material_code from cntl_rec
    where material in (select material from cntl_rec a, cntl_rec_mpi_val b
    where a.proc_order = b.proc_order
    and upper(b.mpi_desc) = 'SPEC SHEET'); 
   
  cursor crsr_cntl_rec_osci_label is
    select distinct mpi_val, 
      ltrim(material,0) as material_code 
    from cntl_rec a, 
      cntl_rec_mpi_val b
    where a.proc_order = b.proc_order
      and upper(b.mpi_desc) = 'SPEC SHEET';
    
  cursor crsr_mpi_items is
    select upper(mpi_desc) as mpi_desc,
      mpi_val,
      mpi_uom
    from cntl_rec_mpi_val a, 
      cntl_rec b
    where ltrim(material,0) = v_material_code
      and b.proc_order = a.proc_order
      and seq > 
        (
          select distinct seq 
          from cntl_rec_mpi_txt a, 
            cntl_rec b
          where b.proc_order = a.proc_order
            and upper(a.mpi_text) = 'PROCESS'
            and ltrim(material,0) = v_material_code
            and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
        )
      and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
      and mpi_tag in ('129','2','3','4','5','7','8','9','10','13','14','15','16','28','29','30','31','122','123','124','130','137','138'
        ,'139','140','141','153','154','155','156','157');  
    
  cursor crsr_mpi_items_osci is
    select upper(mpi_desc) mpi_desc,
      mpi_val,
      mpi_uom
    from cntl_rec_mpi_val a, 
      cntl_rec b
    where ltrim(material,0) = v_material_code
      and b.proc_order = a.proc_order
      and seq > 
      (
        select distinct seq 
        from cntl_rec_mpi_txt a, 
          cntl_rec b
        where b.proc_order = a.proc_order
          and upper(a.mpi_text) = 'PROCESS - FINAL PRODUCT'
          and ltrim(material,0) = v_material_code
          and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
      )
      and seq < 
        (
          select distinct seq 
          from cntl_rec_mpi_txt a, 
            cntl_rec b
          where b.proc_order = a.proc_order
            and upper(a.mpi_text) = 'LABELLER'
            and ltrim(material,0) = v_material_code
            and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
        )
      and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
      and mpi_tag in ('129','2','3','4','5','7','8','9','10','13','14','15','16','28','29','30','31','122','123','124','130','137','138'
        ,'139','140','141','153','154','155','156','157');
    
  cursor crsr_mpi_items_osci_label is
    select upper(mpi_desc) as mpi_desc,
      mpi_val,
      mpi_uom
    from cntl_rec_mpi_val a, 
      cntl_rec b
    where ltrim(material,0) = v_material_code
      and b.proc_order = a.proc_order
      and seq > 
        (
          select distinct seq from 
            cntl_rec_mpi_txt a, 
            cntl_rec b
          where b.proc_order = a.proc_order
            and upper(a.mpi_text) = 'LABELLER'
            and ltrim(material,0) = v_material_code
            and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
        )
      and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
      and mpi_tag in ('129','2','3','4','5','7','8','9','10','13','14','15','16','28','29','30','31','122','123','124','130','137','138'
        ,'139','140','141','153','154','155','156','157');
  
begin
  for material_data in crsr_cntl_rec loop
    dbms_output.put_line(material_data.material_code);
    --normal materials 
    begin 
      v_material_code := material_data.material_code;
          
      for mpi_data in crsr_mpi_items loop
        v_exists := 0;
        select count(*) into v_exists
        from apc_dat_ktchn_prcs_lmt
        where material_code = v_material_code
          and mpi_type = mpi_data.mpi_desc;
            
        if v_exists = 0 then
          insert into apc_dat_ktchn_prcs_lmt 
          (
            material_code,
            mpi_type,
            mpi_val,
            mpi_uom,
            mpi_desc
          )
          values
          (
            v_material_code,
            mpi_data.mpi_desc,
            mpi_data.mpi_val,
            mpi_data.mpi_uom,
            mpi_data.mpi_desc
          );
        else 
          update apc_dat_ktchn_prcs_lmt set
            mpi_val = mpi_data.mpi_val,
            mpi_uom = mpi_data.mpi_uom,
            mpi_desc = mpi_data.mpi_desc
          where material_code = v_material_code
            and mpi_type = mpi_data.mpi_desc;
        end if;
      end loop;
        
    exception
      when no_data_found then
        dbms_output.put_line(material_data.material_code || ' No Data');
        v_material_code := 0;
      when others then
        dbms_output.put_line(material_data.material_code || sqlerrm);
        v_material_code := 0;
    end; 
  end loop;
   
  for material_data in crsr_cntl_rec_osci loop
    dbms_output.put_line(material_data.material_code);
    --normal materials 
    begin 
      v_material_code := material_data.material_code;
          
      for mpi_data in crsr_mpi_items_osci loop
        v_exists := 0;
        select count(*) into v_exists
        from apc_dat_ktchn_prcs_lmt
        where material_code = v_material_code
          and mpi_type = mpi_data.mpi_desc;
            
        if v_exists = 0 then
          insert into apc_dat_ktchn_prcs_lmt 
          (
            material_code,
            mpi_type,
            mpi_val,
            mpi_uom,
            mpi_desc
          )
          values
          (
            v_material_code,
            mpi_data.mpi_desc,
            mpi_data.mpi_val,
            mpi_data.mpi_uom,
            mpi_data.mpi_desc
          );
        else 
          update apc_dat_ktchn_prcs_lmt set
            mpi_val = mpi_data.mpi_val,
            mpi_uom = mpi_data.mpi_uom,
            mpi_desc = mpi_data.mpi_desc
          where material_code = v_material_code
            and mpi_type = mpi_data.mpi_desc;
        end if;
      end loop;
        
    exception
      when no_data_found then
        dbms_output.put_line(material_data.material_code || ' No Data');
        v_material_code := 0;
      when others then
        dbms_output.put_line(material_data.material_code || sqlerrm);
        v_material_code := 0;
    end; 
  end loop;
   
  for material_data in crsr_cntl_rec_osci_label loop
    dbms_output.put_line(material_data.material_code);
    --normal materials 
    begin 
      v_material_code := material_data.material_code;
          
      for mpi_data in crsr_mpi_items_osci_label loop
        v_exists := 0;
        select count(*) into v_exists
        from apc_dat_ktchn_prcs_lmt
        where material_code = material_data.mpi_val
          and mpi_type = mpi_data.mpi_desc;
            
        if v_exists = 0 then
          insert into apc_dat_ktchn_prcs_lmt 
          (
            material_code,
            mpi_type,
            mpi_val,
            mpi_uom,
            mpi_desc
          )
          values
          (
            material_data.mpi_val,
            mpi_data.mpi_desc,
            mpi_data.mpi_val,
            mpi_data.mpi_uom,
            mpi_data.mpi_desc
          );
        else 
          update apc_dat_ktchn_prcs_lmt set
            mpi_val = mpi_data.mpi_val,
            mpi_uom = mpi_data.mpi_uom,
            mpi_desc = mpi_data.mpi_desc
          where material_code = material_data.mpi_val
            and mpi_type = mpi_data.mpi_desc;
        end if;
      end loop;
        
    exception
      when no_data_found then
        dbms_output.put_line(material_data.material_code || ' No Data');
        v_material_code := 0;
      when others then
        dbms_output.put_line(material_data.material_code || sqlerrm);
        v_material_code := 0;
    end; 
  end loop;
end;
/

grant execute on manu_app.apc_dat_prcs_lmt_upd to lics_app;