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
  28-Apr-2009  Ricardo Carneiro  Removed OceanSpray, Updated MPI_TAG filters and updated
                 process filter sequence to use cntl_rec_mpi_val
*******************************************************************************/

  v_mpi_desc varchar2(2000);
  v_mpi_val varchar2(30);
  v_mpi_uom varchar2(20);  
  v_material_code varchar2(54);
  v_exists number;
  
  cursor crsr_cntl_rec is
    select distinct ltrim(material,0) as material_code 
    from cntl_rec; 
    
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
          from cntl_rec_mpi_val a, 
            cntl_rec b
          where b.proc_order = a.proc_order
            and mpi_tag = '0274'
            and ltrim(material,0) = v_material_code
            and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
        )
      and b.proc_order = (select max(proc_order) from cntl_rec where ltrim(material,0) = v_material_code)
      and mpi_tag in ('0129','0002','0003','0004','0005','0007','0008','0009','0010','0013','0014','0015','0016','0028','0029','0030','0031','0122','0123','0124','0130','0137','0138'
        ,'0139','0140','0141','0153','0154','0155','0156','0157');  
     
begin
  for material_data in crsr_cntl_rec loop
    dbms_output.put_line(material_data.material_code);
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
   
end;
/

grant execute on manu_app.apc_dat_prcs_lmt_upd to lics_app;