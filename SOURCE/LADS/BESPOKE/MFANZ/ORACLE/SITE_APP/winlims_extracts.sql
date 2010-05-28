/******************/
/* Package Header */
/******************/
CREATE OR REPLACE PACKAGE SITE_APP.WINLIMS_EXTRACTS AS
/******************************************************************************
*       NAME: WINLIMS_EXTRACTS 
*    PURPOSE: LADS Extracts to provide reference data to the winlims system.
*               Flat files are generated and output to an MQSeries QUEUE 
*              Supplier data is retrieved by the winlims server WOU008 and 
*              is loaded into WinLIMS using SQL Loader. All other data is sent to
*              WODNTS24 where it is loaded into the WinLIMS database by the 
              WinLIMS loader windows executable.
*  REVISIONS: 
*  Ver     Date        Author           Description 
*  ------  ----------  ---------------  ------------------------------------ 
*  1.0     23/11/2005  Steve Ostler     Create Package 
*  1.1     11/09/2009  Emma Elcombe     Created procedure MATERIAL_FULL_EXTRACT, 
*                                       MATERIAL_UPDATE_EXTRACT, EXTRACT_UPDATE, 
*                                       EXTRACT_FULL

*******************************************************************************/ 

  --  Produces the WinLIMS supplier extract file SUPPLIER.DAT
  -- Data file is sent to wou008 for loading 
  PROCEDURE SUPPLIER_EXTRACT;
  
  --  Produces the WinLIMS Item Master (Classification) extract file item_mst.dat
  --  Used by the WinLIMS Loader program on WODNTS24 
  PROCEDURE ITEM_MASTER_EXTRACT;
 
  --  Produces the WinLIMS Item extract file item_full.dat containing all items 
  --  Used by the WinLIMS Loader program on WODNTS24 
  PROCEDURE ITEM_FULL_EXTRACT;
 
  --  Produces the WinLIMS Item extract file item_full.dat containing all items 
  --  Used by the WinLIMS Loader program on WODNTS24 
  PROCEDURE ITEM_UPDATE_EXTRACT;
 
  --  Produces the WinLIMS Item extract file item_full.dat containing all items 
  --  Used by the WinLIMS Loader program on WODNTS24 
  PROCEDURE RAWS_FULL_EXTRACT;
 
  --  Produces the WinLIMS Raws extract file raws_upd.dat providing 
  --  changes that have occurred over the last 7  days  
  --  Used by the WinLIMS Loader program on WODNTS24 
  PROCEDURE RAWS_UPDATE_EXTRACT;
 

-- Produces all required Update files for WinLIMS reference data providing 
  -- changes that have occurred over the last 7  days 
  -- Data files are sent both to wou008 and the WinLIMS Loader program on WODNTS24
  
  PROCEDURE ANZ_PET_MATL_FULL_EXTRACT;
 
  --  Produces the WinLIMS Materials extract file winlims_anzpet.csv 
  --  Extract is for WinLIMS 7 and include Finished good and Raw material data
  PROCEDURE ANZ_PET_MATL_UPDATE_EXTRACT;
  
  -- Produces all required Update files for WinLIMS reference data providing 
  -- changes that have occurred over the last 7  days 
  -- Data files are sent both to wou008 and the WinLIMS Loader program on WODNTS24
  
  PROCEDURE ANZ_CONF_MATL_FULL_EXTRACT;
 
  --  Produces the WinLIMS Materials extract file winlims_anzpet.csv 
  --  Extract is for WinLIMS 7 and include Finished good and Raw material data
  PROCEDURE ANZ_CONF_MATL_UPDATE_EXTRACT;

  --  Produces all required Update files for WinLIMS reference data providing 
  -- changes that have occurred over the last 7  days 
  -- Data files are sent both to wou008 and the WinLIMS Loader program on WODNTS24
  PROCEDURE ALL_EXTRACTS_UPDATE;
 
  -- Produces a FULL extract of all reference data required by the WinLIMS system
  -- Data files are sent both to wou008 and the WinLIMS Loader program on WODNTS24 
  PROCEDURE ALL_EXTRACTS_FULL;

-- Produces the only Update file for WinLIMS reference data providing 
  -- changes that have occurred over the last 14  days 
  -- Extract is for WinLIMS 7 and include Finished good and Raw material data
  PROCEDURE EXTRACT_UPDATE;
 
  -- Produces a FULL extract of all reference data required by the WinLIMS system
  PROCEDURE EXTRACT_FULL;

  
END WINLIMS_EXTRACTS;
/

/****************/
/* Package Body */
/****************/
CREATE OR REPLACE PACKAGE BODY SITE_APP.WINLIMS_EXTRACTS AS

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  g_supplier_intfc_code             CONSTANT VARCHAR2(10):= 'LADLIM01';
  g_item_intfc_code                   CONSTANT VARCHAR2(10):= 'LADLIM02';
  

  -- Private variable declarations
  var_instance          number(15,0);
  var_data              varchar2(4000);
  v_phase_desc          varchar2(50);
  v_file_name        VARCHAR2(30);
    
  
  /* Package history
  The Following proceedures were used by WinLIMS PET Version 2. They are no longer used
  SUPPLIER EXTRACT
  ITEM_MASTER_EXTRACT
  ITEM_FULL_EXTRACT
  ITEM_UPUDATE_EXTRACT
  RAWS_FULL_EXTRACT
  RAWS_UPDATE_EXTRACT
  ALL_EXTRACTS_UPDATE
  ALL_EXTRACTS_FULL
  When these Prceedures are de-cimmissioned, the LADLIM01 interface should also be decommissioned as it is no-longer needed either 
  */
  
  /***********************************************    
  Supplier Extract - Run the supplier extract
  ************************************************/
  PROCEDURE SUPPLIER_EXTRACT IS

            
     -- Supplier data for Winlims
     -- There is no way to filter Vendors for Petcare so all MFANZ is included in the output file 
     CURSOR CSR_SUPPLIER_EXTRACT
     IS
     SELECT vndr_nmbr,'N' delind,vndr_name   
     FROM mfanz_vndr
     WHERE sales_org = '147';
    
    
  BEGIN
    
     v_file_name := 'supplier.dat';
    
     FOR recs in CSR_SUPPLIER_EXTRACT LOOP
          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
          IF CSR_SUPPLIER_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_supplier_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.vndr_nmbr,10)||recs.delind||RPAD(recs.vndr_name,25);
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;

     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 

    
  EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
     END IF;
     RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_SUPPLIER_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
           
  END SUPPLIER_EXTRACT; 
  
  /***********************************************    
  Item Master Extract - Run the update for all item classifications
  ************************************************/
  PROCEDURE ITEM_MASTER_EXTRACT IS 
   
   CURSOR CSR_ITEM_MSTR_EXTRACT
   IS
        SELECT distinct 'BRANDE' TABLEID,                      -- sampletype BRAND 
               A.BRAND_FLAG_CODE REFCODE,                      -- Varchar2(3) 
               B.BRAND_FLAG_SHORT_DESC SHORTDESC,
               B.BRAND_FLAG_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             brand_flag B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code
        and A.brand_flag_code=B.BRAND_FLAG_CODE
        UNION ALL
        SELECT DISTINCT 'MKTSEG' TABLEID,                           -- sampletype CARE    
               A.MKT_SGMNT_CODE REFCODE,                      -- Varchar2(2) 
               B.MKT_SGMNT_SHORT_DESC SHORTDESC,
               B.MKT_SGMNT_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             MKT_SGMNT B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code
        and A.mkt_sgmnt_code=B.mkt_sgmnt_code
        UNION ALL
        SELECT DISTINCT 'VARIANT' TABLEID,                        -- sampletype VARIETY        
               A.INGRDNT_VRTY_CODE REFCODE,                      -- Varchar2(4) 
               B.INGRDNT_VRTY_SHORT_DESC SHORTDESC,
               B.INGRDNT_VRTY_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             INGRDNT_VRTY B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code
        and A.INGRDNT_vrty_code=B.INGRDNT_vrty_code
        UNION ALL
        SELECT DISTINCT 'PRDFORM' TABLEID,                         -- sampletype TEXTURE    
               A.PRDCT_TYPE_CODE REFCODE,                      -- Varchar2(3) 
               B.PRDCT_TYPE_SHORT_DESC SHORTDESC,
               B.PRDCT_TYPE_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             PRDCT_TYPE B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code
        and A.prdct_type_code=B.prdct_type_code     
        UNION ALL
        SELECT DISTINCT 'RSUFMT' TABLEID,                        -- sampletype CATEGORY 
               A.CNSMR_PACK_FRMT_CODE REFCODE,                  -- Varchar2(2) 
                B.CNSMR_PACK_FRMT_SHORT_DESC SHORTDESC,
               B.CNSMR_PACK_FRMT_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             CNSMR_PACK_FRMT B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code
        and A.cnsmr_pack_frmt_code=B.cnsmr_pack_frmt_code     
        UNION ALL
        SELECT DISTINCT 'ORGENT' TABLEID,                      
               'P'||TRIM(SUBSTR(A.z_data, 4, 4)) REFCODE,          -- Varchar2(4) 
               TRIM(SUBSTR(A.z_data, 8, 12)) SHORTDESC,
               TRIM(SUBSTR(A.z_data, 8, 32)) LONGDESC
        FROM     lads_ref_dat A,
                  lads_ref_hdr B,
                (select X.matl_code, X.moe_code 
                from mfanz_matl_moe X,
                mfanz_matl Y
                where X.item_usage_code='MKE'
                and X.matl_code=Y.matl_code
                and Y.dvsn='05'
                ) C
        WHERE  A.z_tabname = '/MARS/MDMOE'
        AND C.moe_code=TRIM(SUBSTR(A.z_data, 4, 4))
        AND A.z_tabname = B.z_tabname (+)
        UNION ALL
        SELECT DISTINCT 'ORGENT' TABLEID,
               TRIM(SUBSTR(A.z_data, 4, 4)) REFCODE,             -- Varchar2(4) 
               TRIM(SUBSTR(A.z_data, 8, 12)) SHORTDESC,
               TRIM(SUBSTR(A.z_data, 8, 32)) LONGDESC
        FROM     lads_ref_dat A,
                  lads_ref_hdr B,
                (select distinct moe_code 
                from mfanz_matl_moe X,
                mfanz_matl Y
                where X.item_usage_code='SEL'
                and X.matl_code=Y.matl_code
                and Y.dvsn='05'
                ) C
        WHERE  A.z_tabname = '/MARS/MDMOE'
        AND C.moe_code=TRIM(SUBSTR(A.z_data, 4, 4))
        AND A.z_tabname = B.z_tabname (+)
        UNION ALL
        SELECT DISTINCT 'NATURE' TABLEID,                             -- sampletype NATURE        
               B.SPPLY_SGMNT_CODE||C.PRDCT_CTGRY_CODE REFCODE,-- Varchar2(5) 
               trim(B.SPPLY_SGMNT_SHORT_DESC)||' '||C.PRDCT_CTGRY_SHORT_DESC SHORTDESC,
               trim(B.SPPLY_SGMNT_LONG_DESC)||' '||C.PRDCT_CTGRY_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             spply_sgmnt B,
             prdct_ctgry C,
             mfanz_matl D 
        where D.dvsn='05'
        and D.matl_code=A.matl_code 
        and A.spply_sgmnt_code=B.spply_sgmnt_code
        and A.prdct_ctgry_code=C.prdct_ctgry_code
        UNION ALL
        SELECT DISTINCT 'UNITSIZE' TABLEID,                       -- sampletype UNITSIZE 
               A.SIZE_CODE REFCODE,                              -- Varchar2(3) 
               B.SIZE_SHORT_DESC SHORTDESC,
               B.SIZE_LONG_DESC LONGDESC
        FROM mfanz_fg_matl_clssfctn A, 
             size_dscrptv B,
             mfanz_matl C 
        where C.dvsn='05'
        and C.matl_code=A.matl_code 
        and A.size_code=B.size_code
        UNION ALL
        SELECT 'WANT' TABLEID,
               'ADULT' REFCODE,
               'ADULT' SHORTDESC,
               'ADULT' LONGDESC
        FROM dual       
        ORDER BY 1,2;


  BEGIN

     -- Declare output filename
     v_file_name := 'item_mst.dat';
    
     FOR recs in CSR_ITEM_MSTR_EXTRACT LOOP

          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_ITEM_MSTR_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
        
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.TABLEID,8)||RPAD(recs.REFCODE,8)||RPAD(recs.SHORTDESC,12)||RPAD(recs.LONGDESC,32);
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;

      IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_ITEM_MSTR_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');

  END ITEM_MASTER_EXTRACT;
       
 /***********************************************    
  Item Full Extract - Run the full update for all finished Goods items
  ************************************************/
   PROCEDURE ITEM_FULL_EXTRACT IS
    
    CURSOR CSR_ITEM_EXTRACT
    IS
        select ltrim(A.matl_code,0) as matl_code,                                                                  
           decode(A.x_plant_matl_sts,'10','A','40','A','W') as status,                       
           A.matl_desc as matl_desc,                                                                   
           'P'||D.MOE_CODE as plant,             -- Make moe                   
           C.moe_code as dest_mkt_code, -- sell moe                     
           B.brand_flag_code as BRANDE,                                
           B.mkt_sgmnt_code as MKTSEG,                                         
           B.ingrdnt_vrty_code as VARIANT,                                
           B.prdct_type_code as PRDFORM,                              
           RPAD('ADULT',8) as WANT,                              
           B.cnsmr_pack_frmt_code as RSUFMT,                              
           B.spply_sgmnt_code||B.PRDCT_CTGRY_CODE as NATURE,           
           B.size_code as UNITSIZE                                      
        from mfanz_matl A,
             mfanz_fg_matl_clssfctn B,
             mfanz_matl_moe C,
             mfanz_matl_moe D     
        where A.trdd_unit='X'
        and A.matl_type='FERT'
        and A.x_plant_matl_sts in (10,40) --Active or R&D
        and A.dvsn='05'
        and C.item_usage_code='SEL'
        and D.item_usage_code='MKE'
        and A.matl_code=B.matl_code
        and A.matl_code=C.matl_code
        and A.matl_code=D.matl_code;
    
    
  BEGIN

     -- Declare output filename 
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the item load file must be called item_upd.dat.
     v_file_name := 'item_upd.dat';
    
      FOR recs in CSR_ITEM_EXTRACT LOOP

          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_ITEM_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.matl_code,8)||recs.status||RPAD(recs.matl_desc,40)||RPAD(recs.plant,5)||
                    RPAD(recs.dest_mkt_code,4)||RPAD(recs.brande,8)||RPAD(recs.mktseg,8)||RPAD(recs.variant,8)||
                   RPAD(recs.prdform,8)||RPAD(recs.want,8)||RPAD(recs.rsufmt,8)||RPAD(recs.nature,8)||RPAD(recs.unitsize,8);
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_ITEM_FULL_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');

  END ITEM_FULL_EXTRACT;
  
 /***********************************************    
  Item Update Extract - Run the update from the past 7 days for all Finished Goods items
  ************************************************/
  PROCEDURE ITEM_UPDATE_EXTRACT IS
    
    CURSOR CSR_ITEM_EXTRACT
    IS
        select ltrim(A.matl_code,0) as matl_code,                                                                  
           decode(A.x_plant_matl_sts,'10','A','40','A','W') as status,                       
           A.matl_desc as matl_desc,                                                                   
           'P'||D.MOE_CODE as plant,             -- Make moe                   
           C.moe_code as dest_mkt_code, -- sell moe                     
           B.brand_flag_code as BRANDE,                                
           B.mkt_sgmnt_code as MKTSEG,                                         
           B.ingrdnt_vrty_code as VARIANT,                                
           B.prdct_type_code as PRDFORM,                              
           RPAD('ADULT',8) as WANT,                              
           B.cnsmr_pack_frmt_code as RSUFMT,                              
           B.spply_sgmnt_code||B.PRDCT_CTGRY_CODE as NATURE,           
           B.size_code as UNITSIZE                                      
        from mfanz_matl A,
             mfanz_fg_matl_clssfctn B,
             mfanz_matl_moe C,
             mfanz_matl_moe D     
        where A.trdd_unit='X'
        and A.matl_type='FERT'
        and A.x_plant_matl_sts in (10,40) --Active or R&D
        and (trunc(sysdate) - lads_to_date(A.chng_date,'YYYYMMDD'))<100    
        and A.dvsn='05'
        and C.item_usage_code='SEL'
        and D.item_usage_code='MKE'
        and A.matl_code=B.matl_code
        and A.matl_code=C.matl_code
        and A.matl_code=D.matl_code;
        
  BEGIN

     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the item load file must be called item_upd.dat.
     v_file_name := 'item_upd.dat';
    
      FOR recs in CSR_ITEM_EXTRACT LOOP
          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_ITEM_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.matl_code,8)||recs.status||RPAD(recs.matl_desc,40)||RPAD(recs.plant,5)||
                    RPAD(recs.dest_mkt_code,4)||RPAD(recs.brande,8)||RPAD(recs.mktseg,8)||RPAD(recs.variant,8)||
                   RPAD(recs.prdform,8)||RPAD(recs.want,8)||RPAD(recs.rsufmt,8)||RPAD(recs.nature,8)||RPAD(recs.unitsize,8);
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_ITEM_UPDATE_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');

  END ITEM_UPDATE_EXTRACT;
  
  /***********************************************    
  Raws Full Extract - Run the full Raw Item Load 
  ************************************************/
 PROCEDURE RAWS_FULL_EXTRACT IS

    CURSOR CSR_RAWS_EXTRACT
    IS
    SELECT ltrim(A.matl_code,0) matl_code,                                     
              decode(A.x_plant_matl_sts,'10','A','40','A','W') status,             
           A.matl_desc matl_desc                                                
    FROM mfanz_matl A, 
    (--Use Plant to determine which products are related to Petcare
     select distinct matl_code 
     from mfanz_matl_by_plant 
     where plant in ('AU20','AU21','AU22','AU23','AU25','AU30')
    ) B
    WHERE A.matl_type='ROH' --raw material
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code;
    
    
  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the raws load file must be called raw_upd.dat.
     v_file_name := 'raw_upd.dat';
    
     FOR recs in CSR_RAWS_EXTRACT LOOP
          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_RAWS_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;

         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.matl_code,8)||recs.status||RPAD(recs.matl_desc,40);
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 
         
  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_RAWS_FULL_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END RAWS_FULL_EXTRACT;
  

 /***********************************************    
  Raws Update Extract - Run the update from the past 7 days for Raws
  ************************************************/
  PROCEDURE RAWS_UPDATE_EXTRACT IS

      dataflag            BOOLEAN:=FALSE;        
            
    CURSOR CSR_RAWS_EXTRACT
    IS
    SELECT ltrim(A.matl_code,0) matl_code,                                     
              decode(A.x_plant_matl_sts,'10','A','40','A','W') status,             
           A.matl_desc matl_desc                                                
    FROM mfanz_matl A, 
    (--Use Plant to determine which products are related to Petcare
     select distinct matl_code 
     from mfanz_matl_by_plant 
     where plant in ('AU20','AU21','AU22','AU23','AU25','AU30')
    ) B
    WHERE A.matl_type='ROH' --raw material
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code
    AND (trunc(sysdate) - lads_to_date(A.chng_date,'YYYYMMDD'))<8;

  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the raws load file must be called raw_upd.dat.
     v_file_name := 'raw_upd.dat';
    
     FOR recs in CSR_RAWS_EXTRACT LOOP

          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_RAWS_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:=RPAD(recs.matl_code,8)||recs.status||RPAD(recs.matl_desc,40);
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF;    

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<WINLIMS_UPDATE_FULL_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END RAWS_UPDATE_EXTRACT;
  
  
  
  /***********************************************    
  Aust/NZ Petfood - Material Full Extract - Run the full Raw Item Load 
  ************************************************/
  PROCEDURE ANZ_PET_MATL_FULL_EXTRACT IS
 
    CURSOR CSR_MATERIAL_EXTRACT
      IS
      SELECT ltrim(A.matl_code,0) matl_code,                                     
           decode(A.x_plant_matl_sts,'10','A','40','A','W') status,             
           replace (UPPER(A.matl_desc),',','') matl_desc,
           b.plant site,  -- adding plant,
           decode(a.matl_type,'FERT','TDU','ROH',b.matl_type,'OTHER') matl_type --adding MATERIAL type                 
    FROM mfanz_matl A, 
    (--Use Plant to determine which products are related to Petcare
     select distinct matl_code, 
                     plant, 
                     prcrmnt_type, 
                     spcl_prcrmnt_type,
                     decode(prcrmnt_type||spcl_prcrmnt_type,'E','SFPR','E50','NAKE','RAW') matl_type,
                     PLANT_ORNTD_MATL_TYPE
     from mfanz_matl_by_plant 
     where plant in ('AU20','AU21','AU22','AU23','AU25','AU30')
    ) B
    WHERE ((A.trdd_unit='X'
            and A.matl_type='FERT')  -- Finshed Good Traded Unit, or
            or
            A.matl_type='ROH')        --raw MATERIAL
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code
    AND ((b.prcrmnt_type||b.spcl_prcrmnt_type <> 'E50')  
          or (b.prcrmnt_type||b.spcl_prcrmnt_type = 'E50')
          and b.PLANT_ORNTD_MATL_TYPE = '07');
    
    
  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the MATERIAL load file must be called winlims_anzpet.csv.
     v_file_name := 'WINLIMS_ANZPET.CSV';
    
     FOR recs in CSR_MATERIAL_EXTRACT LOOP
          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_MATERIAL_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;

         v_phase_desc:='WRITING DATA TO FILE';
         var_data:= '3,'||recs.matl_code||','||recs.status||','||UPPER(recs.matl_desc)||','||recs.site||','||recs.matl_type||',COA.rpt';
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 
         
  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<ANZ_PET_MATL_FULL_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ANZ_PET_MATL_FULL_EXTRACT; 

/***********************************************    
 Aust/NZ Petcare - Material Update Extract - Run the update from the past 7 days for all items
  ************************************************/
  PROCEDURE ANZ_PET_MATL_UPDATE_EXTRACT IS

      dataflag            BOOLEAN:=FALSE;        

  CURSOR CSR_MATERIAL_EXTRACT
      IS
      SELECT ltrim(A.matl_code,0) matl_code,                                     
           decode(A.x_plant_matl_sts,'10','A','40','A','W') status,             
           replace (UPPER(A.matl_desc),',','') matl_desc,
           b.plant site,  -- adding plant,
           decode(a.matl_type,'FERT','TDU','ROH',b.matl_type,'OTHER') matl_type --adding MATERIAL type                 
    FROM mfanz_matl A, 
    (--Use Plant to determine which products are related to Petcare
     select distinct matl_code, 
                     plant, 
                     prcrmnt_type, 
                     spcl_prcrmnt_type,
                     decode(prcrmnt_type||spcl_prcrmnt_type,'E','SFPR','E50','NAKE','RAW') matl_type,
                     PLANT_ORNTD_MATL_TYPE
     from mfanz_matl_by_plant 
     where plant in ('AU20','AU21','AU22','AU23','AU25','AU30')
    ) B
    WHERE ((A.trdd_unit='X'
            and A.matl_type='FERT')  -- Finshed Good Traded Unit, or
            or
            A.matl_type='ROH')        --raw MATERIAL
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code
    AND ((b.prcrmnt_type||b.spcl_prcrmnt_type <> 'E50')  
          or (b.prcrmnt_type||b.spcl_prcrmnt_type = 'E50')
          and b.PLANT_ORNTD_MATL_TYPE = '07')          
    AND (trunc(sysdate) - lads_to_date(A.chng_date,'YYYYMMDD'))<15;
    
  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the MATERIAL load file must be called winlims_anzpet.csv.
     v_file_name := 'WINLIMS_ANZPET.CSV';
    
     FOR recs in CSR_MATERIAL_EXTRACT LOOP

          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_MATERIAL_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:= '3,'||recs.matl_code||','||recs.status||','||UPPER(recs.matl_desc)||','||recs.site||','||recs.matl_type||',COA.rpt';
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF;    

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<ANZ_PET_MATL_UPDATE_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ANZ_PET_MATL_UPDATE_EXTRACT;
  
  
  
  /***********************************************    
  Aust/NZ Confectionary - Material Full Extract - Run the full Raw Item Load 
  ************************************************/
  PROCEDURE ANZ_CONF_MATL_FULL_EXTRACT IS
 
    CURSOR CSR_MATERIAL_EXTRACT
      IS
      SELECT ltrim(A.matl_code,0) matl_code, 
           b.matl_stat,             
           replace (UPPER(A.matl_desc),',','') matl_desc,
           decode(a.matl_type,'ROH',b.matl_type,'OTHER') matl_type               
    FROM mfanz_matl A    , 
    (--Use Plant to determine which products are related to Snackfood
     select distinct matl_code, 
                     plant, 
                     prcrmnt_type, 
                     spcl_prcrmnt_type,
                     prcrmnt_type||spcl_prcrmnt_type,
                     decode(prcrmnt_type||spcl_prcrmnt_type,'E','F','E50','F','R') matl_type,
                     PLANT_ORNTD_MATL_TYPE,
                     decode (plant_sts, '99','O','A') Matl_stat
     from mfanz_matl_by_plant 
     where plant in ('AU40','AU89')
     and ( plant_sts <> '99' 
        or ( plant_sts = '99'  
        and  prcrmnt_type ='E'))
    ) B
    WHERE A.matl_type='ROH'        --raw MATERIAL
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code
    AND ((b.prcrmnt_type||b.spcl_prcrmnt_type = 'F53')
     or ((b.prcrmnt_type||b.spcl_prcrmnt_type = 'E50'
     or b.prcrmnt_type||b.spcl_prcrmnt_type = 'E')
          and b.PLANT_ORNTD_MATL_TYPE = '07'));
    
    
  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the MATERIAL load file must be called winlims_anzconf.csv.
     v_file_name := 'WINLIMS_ANZCONF.CSV';
    
     FOR recs in CSR_MATERIAL_EXTRACT LOOP
          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         
         IF CSR_MATERIAL_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;

         v_phase_desc:='WRITING DATA TO FILE';
         var_data:= '3,'||recs.matl_code||','||recs.matl_stat||','||UPPER(recs.matl_desc)||','||recs.matl_type;
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF; 
         
  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<ANZ_CONF_MATL_FULL_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ANZ_CONF_MATL_FULL_EXTRACT; 

/***********************************************    
 Aust/NZ Confectionary - Material Update Extract - Run the update from the past 7 days for all items
  ************************************************/
  PROCEDURE ANZ_CONF_MATL_UPDATE_EXTRACT IS

      dataflag            BOOLEAN:=FALSE;        

  CURSOR CSR_MATERIAL_EXTRACT
      IS
      SELECT ltrim(A.matl_code,0) matl_code, 
           b.matl_stat,             
           replace (UPPER(A.matl_desc),',','') matl_desc,
           decode(a.matl_type,'ROH',b.matl_type,'OTHER') matl_type                
    FROM mfanz_matl A    , 
    (--Use Plant to determine which products are related to Snackfood
     select distinct matl_code, 
                     plant, 
                     prcrmnt_type, 
                     spcl_prcrmnt_type,
                     prcrmnt_type||spcl_prcrmnt_type,
                     decode(prcrmnt_type||spcl_prcrmnt_type,'E','F','E50','F','R') matl_type,
                     PLANT_ORNTD_MATL_TYPE,
                     decode (plant_sts, '99','O','A') Matl_stat
     from mfanz_matl_by_plant 
     where plant in ('AU40','AU89')
     and ( plant_sts <> '99' 
        or ( plant_sts = '99'  
        and  prcrmnt_type ='E'))
    ) B
    WHERE A.matl_type='ROH'        --raw MATERIAL
    AND A.x_plant_matl_sts in (10,40) --Active or R&D
    AND A.matl_code=B.matl_code
    AND ((b.prcrmnt_type||b.spcl_prcrmnt_type = 'F53')
     or ((b.prcrmnt_type||b.spcl_prcrmnt_type = 'E50'
     or b.prcrmnt_type||b.spcl_prcrmnt_type = 'E')
          and b.PLANT_ORNTD_MATL_TYPE = '07'))
    AND (trunc(sysdate) - lads_to_date(A.chng_date,'YYYYMMDD'))<15;
    
  BEGIN


     -- Declare output filename
     -- The WinLIMS item.exe load application is hard coded with the following file name 
     -- the MATERIAL load file must be called winlims_anzconf.csv.
     v_file_name := 'WINLIMS_ANZCONF.CSV';
    
     FOR recs in CSR_MATERIAL_EXTRACT LOOP

          -- Create OUTBOUND LOADER interface on ICS for file output if the cursor return rows
         IF CSR_MATERIAL_EXTRACT%ROWCOUNT=1 THEN 
              var_instance := lics_outbound_loader.create_interface(g_item_intfc_code,v_file_name);
         END IF;
            
         v_phase_desc:='WRITING DATA TO FILE';
         var_data:= '3,'||recs.matl_code||','||recs.matl_stat||','||UPPER(recs.matl_desc)||','||recs.matl_type;
                   
         lics_outbound_loader.append_data(var_data);
    
     END LOOP;
     
     IF (lics_outbound_loader.is_created = true) THEN
         lics_outbound_loader.finalise_interface;
     END IF;    

  EXCEPTION
       WHEN OTHERS THEN
       ROLLBACK;
       IF (lics_outbound_loader.is_created = true) THEN
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
       END IF;
       RAISE_APPLICATION_ERROR(-20001, '<ANZ_CONF_MATL_UPDATE_EXTRACT>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ANZ_CONF_MATL_UPDATE_EXTRACT;
  
   
 /***********************************************    
  ALL_ITEM_UPDATE - Run the update from the past 7 days for all items
  ************************************************/
  PROCEDURE ALL_EXTRACTS_UPDATE IS
    BEGIN

     v_phase_desc:='Running Supplier Extract';
     SUPPLIER_EXTRACT;

     v_phase_desc:='Running Item Master Extract';
     ITEM_MASTER_EXTRACT;
     
     v_phase_desc:='Running Item Update Extract';
     ITEM_UPDATE_EXTRACT;
     
     v_phase_desc:='Running Raws Update Extract';
     RAWS_UPDATE_EXTRACT;

    EXCEPTION
       WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002, '<ALL_ITEM_UPDATE>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ALL_EXTRACTS_UPDATE;
   
  /***********************************************    
  ALL_ITEM_FULL - Run the full load of all item extracts 
  ************************************************/
  PROCEDURE ALL_EXTRACTS_FULL IS
    BEGIN

     v_phase_desc:='Running Supplier Extract';
     SUPPLIER_EXTRACT;

     v_phase_desc:='Running Item Master Extract';
     ITEM_MASTER_EXTRACT;
     
     v_phase_desc:='Running Item Full Extract';
     ITEM_FULL_EXTRACT;
     
     v_phase_desc:='Running Raws Full Extract';
     RAWS_FULL_EXTRACT;

    EXCEPTION
       WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002, '<ALL_ITEM_FULL>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END ALL_EXTRACTS_FULL; 


/***********************************************    
  MATERIAL_UPDATE - Run the update from the past 7 days for all items
  ************************************************/
  PROCEDURE EXTRACT_UPDATE IS
    BEGIN

     --v_phase_desc:='Running Material Extract';
     --MATERIAL_UPDATE_EXTRACT;

     v_phase_desc:='Running Pet Material Extract';
     ANZ_PET_MATL_UPDATE_EXTRACT;
     
     v_phase_desc:='Running Snack Material Extract';
     ANZ_CONF_MATL_UPDATE_EXTRACT;

     
    EXCEPTION
       WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002, '<MATERIAL_UPDATE>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END EXTRACT_UPDATE;
  
 /***********************************************    
  MATERIAL_FULL - Run the full load of all item extracts 
  ************************************************/
  PROCEDURE EXTRACT_FULL IS
    BEGIN

     v_phase_desc:='Running Pet Material Extract';
     ANZ_PET_MATL_FULL_EXTRACT;
     
     v_phase_desc:='Running Snack Material Extract';
     ANZ_CONF_MATL_FULL_EXTRACT;

    
    EXCEPTION
       WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002, '<MATERIAL_FULL>, RETURN ['||v_phase_desc||' '||SQLERRM(SQLCODE)||']');
  END EXTRACT_FULL; 

END WINLIMS_EXTRACTS;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym winlims_extracts for site_app.winlims_extracts;
GRANT EXECUTE ON SITE_APP.WINLIMS_EXTRACTS TO ICS_APP;
GRANT EXECUTE ON SITE_APP.WINLIMS_EXTRACTS TO ICS_EXECUTOR;
GRANT EXECUTE ON SITE_APP.WINLIMS_EXTRACTS TO LICS_APP;