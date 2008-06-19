DROP PACKAGE CR_APP.CARE_GRDCAR01;

CREATE OR REPLACE PACKAGE CR_APP.care_grdcar01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CARE
 Package : care_grdcar01
 Owner   : CR_APP
 Author  : Linden Glen

 Description
 -----------
 GRD to CARE - Inbound Material Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Linden Glen    Created
           Linden Glen    Added MSTAE (Material Status)
           Linden Glen    Added LCM Segment processing
 2006/04   Linden Glen    Added LCM SEQ to overcome null legacy_code values

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end care_grdcar01;
/


DROP PACKAGE BODY CR_APP.CARE_GRDCAR01;

CREATE OR REPLACE PACKAGE BODY CR_APP.care_grdcar01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_lcm(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_ignore boolean;
   rcd_grd_control sil_parameter.idoc_control;
   rcd_grd_mat_hdr grd_mat_hdr%rowtype;
   rcd_grd_mat_det grd_mat_det%rowtype;
   rcd_grd_mat_lcm grd_mat_lcm%rowtype;


   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      sil_inbound_utility.clear_definition;
      /*-*/
      sil_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      sil_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      sil_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      sil_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      sil_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      sil_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      sil_inbound_utility.set_definition('HDR','MATNR',18);
      sil_inbound_utility.set_definition('HDR','MAKTX',40);
      sil_inbound_utility.set_definition('HDR','MSTAE',2);
      sil_inbound_utility.set_definition('HDR','EAN11',18);
      sil_inbound_utility.set_definition('HDR','ZZREPMATNR',18);
      sil_inbound_utility.set_definition('HDR','MTART',4);
      sil_inbound_utility.set_definition('HDR','ZZISRSU',1);
      sil_inbound_utility.set_definition('HDR','ZZISMCU',1);
      sil_inbound_utility.set_definition('HDR','ZZISTDU',1);
      sil_inbound_utility.set_definition('HDR','ZZISINT',1);
      sil_inbound_utility.set_definition('HDR','BUSSEG',4);
      sil_inbound_utility.set_definition('HDR','BUSSEGDESC',12);
      sil_inbound_utility.set_definition('HDR','BUSSEGDESCL',30);
      sil_inbound_utility.set_definition('HDR','BRND',4);
      sil_inbound_utility.set_definition('HDR','BRNDDESC',12);
      sil_inbound_utility.set_definition('HDR','BRNDDESCL',30);
      sil_inbound_utility.set_definition('HDR','BRNDSUB',4);
      sil_inbound_utility.set_definition('HDR','BRNDSUBDESC',12);
      sil_inbound_utility.set_definition('HDR','BRNDSUBDESCL',30);
      sil_inbound_utility.set_definition('HDR','CNSPCKFRT',4);
      sil_inbound_utility.set_definition('HDR','CNSPCKFRTDESC',12);
      sil_inbound_utility.set_definition('HDR','CNSPCKFRTDESCL',30);
      sil_inbound_utility.set_definition('HDR','PRDCAT',4);
      sil_inbound_utility.set_definition('HDR','PRDCATDESC',12);
      sil_inbound_utility.set_definition('HDR','PRDCATDESCL',30);
      sil_inbound_utility.set_definition('HDR','PRDTYPE',4);
      sil_inbound_utility.set_definition('HDR','PRDTYPEDESC',12);
      sil_inbound_utility.set_definition('HDR','PRDTYPEDESCL',30);
      sil_inbound_utility.set_definition('HDR','CNSPCKTYPE',4);
      sil_inbound_utility.set_definition('HDR','CNSPCKTYPEDESC',12);
      sil_inbound_utility.set_definition('HDR','CNSPCKTYPEDESCL',30);
      sil_inbound_utility.set_definition('HDR','MAT_SIZE',4);
      sil_inbound_utility.set_definition('HDR','SIZEDESC',12);
      sil_inbound_utility.set_definition('HDR','SIZEDESCL',30);
      sil_inbound_utility.set_definition('HDR','INGVRTY',4);
      sil_inbound_utility.set_definition('HDR','INGVRTYDESC',12);
      sil_inbound_utility.set_definition('HDR','INGVRTYDESCL',30);
      sil_inbound_utility.set_definition('HDR','FUNCVRTY',4);
      sil_inbound_utility.set_definition('HDR','FUNCVRTYDESC',12);
      sil_inbound_utility.set_definition('HDR','FUNCVRTYDESCL',30);
      sil_inbound_utility.set_definition('HDR','SIZEGRP',4);
      sil_inbound_utility.set_definition('HDR','SIZEGRPDESC',12);
      sil_inbound_utility.set_definition('HDR','SIZEGRPDESCL',30);
      sil_inbound_utility.set_definition('HDR','OCCSN',4);
      sil_inbound_utility.set_definition('HDR','OCCSNDESC',12);
      sil_inbound_utility.set_definition('HDR','OCCSNDESCL',30);
      sil_inbound_utility.set_definition('HDR','SPPLYSGMNT',4);
      sil_inbound_utility.set_definition('HDR','SPPLYSGMNTDESC',12);
      sil_inbound_utility.set_definition('HDR','SPPLYSGMNTDESCL',30);
      /*-*/
      sil_inbound_utility.set_definition('DET','IDOC_DET',3);
      sil_inbound_utility.set_definition('DET','MATNR',18);
      sil_inbound_utility.set_definition('DET','USAGECODE',3);
      sil_inbound_utility.set_definition('DET','ORGENTITY',4);
      sil_inbound_utility.set_definition('DET','STARTDATE',8);
      sil_inbound_utility.set_definition('DET','ENDDATE',8);
      /*-*/
      sil_inbound_utility.set_definition('LCM','IDOC_LCM',3);
      sil_inbound_utility.set_definition('LCM','MATNR',18);
      sil_inbound_utility.set_definition('LCM','REGCODE',5);
      sil_inbound_utility.set_definition('LCM','LEGACY_CODE',18);


   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'CTL' then process_record_ctl(par_record);
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then process_record_det(par_record);
         when 'LCM' then process_record_lcm(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit the transaction
      /*-*/
      commit;


   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;


   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      on_end;

      /*-*/
      /* Reset variables
      /*-*/
      var_trn_ignore := false;

      /*-*/
      /* Parse the data record
      /*-*/
      sil_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control IDOC name
      /*-*/
      rcd_grd_control.idoc_name := sil_inbound_utility.get_variable('IDOC_NAME');
      if rcd_grd_control.idoc_name is null then
         var_trn_ignore := true;
         raise_application_error(-20000, 'Field - CTL.IDOC_NAME - Must not be null');
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_grd_control.idoc_number := sil_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if rcd_grd_control.idoc_number is null then
         var_trn_ignore := true;
         raise_application_error(-20000, 'Field - CTL.IDOC_NUMBER - Must not be null');
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_grd_control.idoc_timestamp := sil_inbound_utility.get_variable('IDOC_DATE') || sil_inbound_utility.get_variable('IDOC_TIME');
      if rcd_grd_control.idoc_timestamp is null then
         var_trn_ignore := true;
         raise_application_error(-20000, 'Field - CTL.IDOC_TIMESTAMP - Must not be null');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_grd_mat_hdr_01 is
         select
            t01.matnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from grd_mat_hdr t01
         where t01.matnr = rcd_grd_mat_hdr.matnr;
      rcd_grd_mat_hdr_01 csr_grd_mat_hdr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      sil_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_grd_mat_hdr.MATNR := sil_inbound_utility.get_variable('MATNR');
      rcd_grd_mat_hdr.MAKTX := sil_inbound_utility.get_variable('MAKTX');
      rcd_grd_mat_hdr.EAN11 := sil_inbound_utility.get_variable('EAN11');
      rcd_grd_mat_hdr.MSTAE := sil_inbound_utility.get_variable('MSTAE');
      rcd_grd_mat_hdr.ZZREPMATNR := sil_inbound_utility.get_variable('ZZREPMATNR');
      rcd_grd_mat_hdr.MTART := sil_inbound_utility.get_variable('MTART');
      rcd_grd_mat_hdr.ZZISRSU := sil_inbound_utility.get_variable('ZZISRSU');
      rcd_grd_mat_hdr.ZZISMCU := sil_inbound_utility.get_variable('ZZISMCU');
      rcd_grd_mat_hdr.ZZISTDU := sil_inbound_utility.get_variable('ZZISTDU');
      rcd_grd_mat_hdr.ZZISINT := sil_inbound_utility.get_variable('ZZISINT');
      rcd_grd_mat_hdr.BUSSEG := sil_inbound_utility.get_variable('BUSSEG');
      rcd_grd_mat_hdr.BUSSEGDESC := sil_inbound_utility.get_variable('BUSSEGDESC');
      rcd_grd_mat_hdr.BUSSEGDESCL := sil_inbound_utility.get_variable('BUSSEGDESCL');
      rcd_grd_mat_hdr.BRND := sil_inbound_utility.get_variable('BRND');
      rcd_grd_mat_hdr.BRNDDESC := sil_inbound_utility.get_variable('BRNDDESC');
      rcd_grd_mat_hdr.BRNDDESCL := sil_inbound_utility.get_variable('BRNDDESCL');
      rcd_grd_mat_hdr.BRNDSUB := sil_inbound_utility.get_variable('BRNDSUB');
      rcd_grd_mat_hdr.BRNDSUBDESC := sil_inbound_utility.get_variable('BRNDSUBDESC');
      rcd_grd_mat_hdr.BRNDSUBDESCL := sil_inbound_utility.get_variable('BRNDSUBDESCL');
      rcd_grd_mat_hdr.CNSPCKFRT := sil_inbound_utility.get_variable('CNSPCKFRT');
      rcd_grd_mat_hdr.CNSPCKFRTDESC := sil_inbound_utility.get_variable('CNSPCKFRTDESC');
      rcd_grd_mat_hdr.CNSPCKFRTDESCL := sil_inbound_utility.get_variable('CNSPCKFRTDESCL');
      rcd_grd_mat_hdr.PRDCAT := sil_inbound_utility.get_variable('PRDCAT');
      rcd_grd_mat_hdr.PRDCATDESC := sil_inbound_utility.get_variable('PRDCATDESC');
      rcd_grd_mat_hdr.PRDCATDESCL := sil_inbound_utility.get_variable('PRDCATDESCL');
      rcd_grd_mat_hdr.PRDTYPE := sil_inbound_utility.get_variable('PRDTYPE');
      rcd_grd_mat_hdr.PRDTYPEDESC := sil_inbound_utility.get_variable('PRDTYPEDESC');
      rcd_grd_mat_hdr.PRDTYPEDESCL := sil_inbound_utility.get_variable('PRDTYPEDESCL');
      rcd_grd_mat_hdr.CNSPCKTYPE := sil_inbound_utility.get_variable('CNSPCKTYPE');
      rcd_grd_mat_hdr.CNSPCKTYPEDESC := sil_inbound_utility.get_variable('CNSPCKTYPEDESC');
      rcd_grd_mat_hdr.CNSPCKTYPEDESCL := sil_inbound_utility.get_variable('CNSPCKTYPEDESCL');
      rcd_grd_mat_hdr.MAT_SIZE := sil_inbound_utility.get_variable('MAT_SIZE');
      rcd_grd_mat_hdr.SIZEDESC := sil_inbound_utility.get_variable('SIZEDESC');
      rcd_grd_mat_hdr.SIZEDESCL := sil_inbound_utility.get_variable('SIZEDESCL');
      rcd_grd_mat_hdr.INGVRTY := sil_inbound_utility.get_variable('INGVRTY');
      rcd_grd_mat_hdr.INGVRTYDESC := sil_inbound_utility.get_variable('INGVRTYDESC');
      rcd_grd_mat_hdr.INGVRTYDESCL := sil_inbound_utility.get_variable('INGVRTYDESCL');
      rcd_grd_mat_hdr.FUNCVRTY := sil_inbound_utility.get_variable('FUNCVRTY');
      rcd_grd_mat_hdr.FUNCVRTYDESC := sil_inbound_utility.get_variable('FUNCVRTYDESC');
      rcd_grd_mat_hdr.FUNCVRTYDESCL := sil_inbound_utility.get_variable('FUNCVRTYDESCL');
      rcd_grd_mat_hdr.SIZEGRP := sil_inbound_utility.get_variable('SIZEGRP');
      rcd_grd_mat_hdr.SIZEGRPDESC := sil_inbound_utility.get_variable('SIZEGRPDESC');
      rcd_grd_mat_hdr.SIZEGRPDESCL := sil_inbound_utility.get_variable('SIZEGRPDESCL');
      rcd_grd_mat_hdr.OCCSN := sil_inbound_utility.get_variable('OCCSN');
      rcd_grd_mat_hdr.OCCSNDESC := sil_inbound_utility.get_variable('OCCSNDESC');
      rcd_grd_mat_hdr.OCCSNDESCL := sil_inbound_utility.get_variable('OCCSNDESCL');
      rcd_grd_mat_hdr.SPPLYSGMNT := sil_inbound_utility.get_variable('SPPLYSGMNT');
      rcd_grd_mat_hdr.SPPLYSGMNTDESC := sil_inbound_utility.get_variable('SPPLYSGMNTDESC');
      rcd_grd_mat_hdr.SPPLYSGMNTDESCL := sil_inbound_utility.get_variable('SPPLYSGMNTDESCL');
      rcd_grd_mat_hdr.idoc_name := rcd_grd_control.idoc_name;
      rcd_grd_mat_hdr.idoc_number := rcd_grd_control.idoc_number;
      rcd_grd_mat_hdr.idoc_timestamp := rcd_grd_control.idoc_timestamp;
      rcd_grd_mat_hdr.sil_date := sysdate;
      rcd_grd_mat_hdr.sil_status := '1';

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_grd_mat_lcm.lcmseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_grd_mat_hdr.matnr is null then
         var_trn_ignore := true;
         raise_application_error(-20000, 'Missing Primary Key - HDR.MATNR');
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      var_exists := true;
      open csr_grd_mat_hdr_01;
      fetch csr_grd_mat_hdr_01 into rcd_grd_mat_hdr_01;
      if csr_grd_mat_hdr_01%notfound then
         var_exists := false;
      end if;
      close csr_grd_mat_hdr_01;

      if var_exists = true then
         if rcd_grd_mat_hdr.idoc_timestamp > rcd_grd_mat_hdr_01.idoc_timestamp then
            delete from grd_mat_det where matnr = rcd_grd_mat_hdr.matnr;
            delete from grd_mat_lcm where matnr = rcd_grd_mat_hdr.matnr;
         else
            var_trn_ignore := true;
         end if;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      update grd_mat_hdr set
         matnr = rcd_grd_mat_hdr.matnr,
         maktx = rcd_grd_mat_hdr.maktx,
         mstae = rcd_grd_mat_hdr.mstae,
         ean11 = rcd_grd_mat_hdr.ean11,
         zzrepmatnr = rcd_grd_mat_hdr.zzrepmatnr,
         mtart = rcd_grd_mat_hdr.mtart,
         zzisrsu = rcd_grd_mat_hdr.zzisrsu,
         zzismcu = rcd_grd_mat_hdr.zzismcu,
         zzistdu = rcd_grd_mat_hdr.zzistdu,
         zzisint = rcd_grd_mat_hdr.zzisint,
         busseg = rcd_grd_mat_hdr.busseg,
         bussegdesc = rcd_grd_mat_hdr.bussegdesc,
         bussegdescl = rcd_grd_mat_hdr.bussegdescl,
         brnd = rcd_grd_mat_hdr.brnd,
         brnddesc = rcd_grd_mat_hdr.brnddesc,
         brnddescl = rcd_grd_mat_hdr.brnddescl,
         brndsub = rcd_grd_mat_hdr.brndsub,
         brndsubdesc = rcd_grd_mat_hdr.brndsubdesc,
         brndsubdescl = rcd_grd_mat_hdr.brndsubdescl,
         cnspckfrt = rcd_grd_mat_hdr.cnspckfrt,
         cnspckfrtdesc = rcd_grd_mat_hdr.cnspckfrtdesc,
         cnspckfrtdescl = rcd_grd_mat_hdr.cnspckfrtdescl,
         prdcat = rcd_grd_mat_hdr.prdcat,
         prdcatdesc = rcd_grd_mat_hdr.prdcatdesc,
         prdcatdescl = rcd_grd_mat_hdr.prdcatdescl,
         prdtype = rcd_grd_mat_hdr.prdtype,
         prdtypedesc = rcd_grd_mat_hdr.prdtypedesc,
         prdtypedescl = rcd_grd_mat_hdr.prdtypedescl,
         cnspcktype = rcd_grd_mat_hdr.cnspcktype,
         cnspcktypedesc = rcd_grd_mat_hdr.cnspcktypedesc,
         cnspcktypedescl = rcd_grd_mat_hdr.cnspcktypedescl,
         mat_size = rcd_grd_mat_hdr.mat_size,
         sizedesc = rcd_grd_mat_hdr.sizedesc,
         sizedescl = rcd_grd_mat_hdr.sizedescl,
         ingvrty = rcd_grd_mat_hdr.ingvrty,
         ingvrtydesc = rcd_grd_mat_hdr.ingvrtydesc,
         ingvrtydescl = rcd_grd_mat_hdr.ingvrtydescl,
         funcvrty = rcd_grd_mat_hdr.funcvrty,
         funcvrtydesc = rcd_grd_mat_hdr.funcvrtydesc,
         funcvrtydescl = rcd_grd_mat_hdr.funcvrtydescl,
         sizegrp = rcd_grd_mat_hdr.sizegrp,
         sizegrpdesc = rcd_grd_mat_hdr.sizegrpdesc,
         sizegrpdescl = rcd_grd_mat_hdr.sizegrpdescl,
         occsn = rcd_grd_mat_hdr.occsn,
         occsndesc = rcd_grd_mat_hdr.occsndesc,
         occsndescl = rcd_grd_mat_hdr.occsndescl,
         spplysgmnt = rcd_grd_mat_hdr.spplysgmnt,
         spplysgmntdesc = rcd_grd_mat_hdr.spplysgmntdesc,
         spplysgmntdescl = rcd_grd_mat_hdr.spplysgmntdescl,
         idoc_name = rcd_grd_mat_hdr.idoc_name,
         idoc_number = rcd_grd_mat_hdr.idoc_number,
         idoc_timestamp = rcd_grd_mat_hdr.idoc_timestamp,
         sil_date = rcd_grd_mat_hdr.sil_date,
         sil_status = rcd_grd_mat_hdr.sil_status
      where matnr = rcd_grd_mat_hdr.matnr;
      if sql%notfound then
         insert into grd_mat_hdr
            (matnr,
             maktx,
             mstae,
             ean11,
             zzrepmatnr,
             mtart,
             zzisrsu,
             zzismcu,
             zzistdu,
             zzisint,
             busseg,
             bussegdesc,
             bussegdescl,
             brnd,
             brnddesc,
             brnddescl,
             brndsub,
             brndsubdesc,
             brndsubdescl,
             cnspckfrt,
             cnspckfrtdesc,
             cnspckfrtdescl,
             prdcat,
             prdcatdesc,
             prdcatdescl,
             prdtype,
             prdtypedesc,
             prdtypedescl,
             cnspcktype,
             cnspcktypedesc,
             cnspcktypedescl,
             mat_size,
             sizedesc,
             sizedescl,
             ingvrty,
             ingvrtydesc,
             ingvrtydescl,
             funcvrty,
             funcvrtydesc,
             funcvrtydescl,
             sizegrp,
             sizegrpdesc,
             sizegrpdescl,
             occsn,
             occsndesc,
             occsndescl,
             spplysgmnt,
             spplysgmntdesc,
             spplysgmntdescl,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             sil_date,
             sil_status)
         values
            (rcd_grd_mat_hdr.matnr,
             rcd_grd_mat_hdr.maktx,
             rcd_grd_mat_hdr.mstae,
             rcd_grd_mat_hdr.ean11,
             rcd_grd_mat_hdr.zzrepmatnr,
             rcd_grd_mat_hdr.mtart,
             rcd_grd_mat_hdr.zzisrsu,
             rcd_grd_mat_hdr.zzismcu,
             rcd_grd_mat_hdr.zzistdu,
             rcd_grd_mat_hdr.zzisint,
             rcd_grd_mat_hdr.busseg,
             rcd_grd_mat_hdr.bussegdesc,
             rcd_grd_mat_hdr.bussegdescl,
             rcd_grd_mat_hdr.brnd,
             rcd_grd_mat_hdr.brnddesc,
             rcd_grd_mat_hdr.brnddescl,
             rcd_grd_mat_hdr.brndsub,
             rcd_grd_mat_hdr.brndsubdesc,
             rcd_grd_mat_hdr.brndsubdescl,
             rcd_grd_mat_hdr.cnspckfrt,
             rcd_grd_mat_hdr.cnspckfrtdesc,
             rcd_grd_mat_hdr.cnspckfrtdescl,
             rcd_grd_mat_hdr.prdcat,
             rcd_grd_mat_hdr.prdcatdesc,
             rcd_grd_mat_hdr.prdcatdescl,
             rcd_grd_mat_hdr.prdtype,
             rcd_grd_mat_hdr.prdtypedesc,
             rcd_grd_mat_hdr.prdtypedescl,
             rcd_grd_mat_hdr.cnspcktype,
             rcd_grd_mat_hdr.cnspcktypedesc,
             rcd_grd_mat_hdr.cnspcktypedescl,
             rcd_grd_mat_hdr.mat_size,
             rcd_grd_mat_hdr.sizedesc,
             rcd_grd_mat_hdr.sizedescl,
             rcd_grd_mat_hdr.ingvrty,
             rcd_grd_mat_hdr.ingvrtydesc,
             rcd_grd_mat_hdr.ingvrtydescl,
             rcd_grd_mat_hdr.funcvrty,
             rcd_grd_mat_hdr.funcvrtydesc,
             rcd_grd_mat_hdr.funcvrtydescl,
             rcd_grd_mat_hdr.sizegrp,
             rcd_grd_mat_hdr.sizegrpdesc,
             rcd_grd_mat_hdr.sizegrpdescl,
             rcd_grd_mat_hdr.occsn,
             rcd_grd_mat_hdr.occsndesc,
             rcd_grd_mat_hdr.occsndescl,
             rcd_grd_mat_hdr.spplysgmnt,
             rcd_grd_mat_hdr.spplysgmntdesc,
             rcd_grd_mat_hdr.spplysgmntdescl,
             rcd_grd_mat_hdr.idoc_name,
             rcd_grd_mat_hdr.idoc_number,
             rcd_grd_mat_hdr.idoc_timestamp,
             rcd_grd_mat_hdr.sil_date,
             rcd_grd_mat_hdr.sil_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record PCH routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      sil_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_grd_mat_det.MATNR := rcd_grd_mat_hdr.matnr;
      rcd_grd_mat_det.USAGECODE := sil_inbound_utility.get_variable('USAGECODE');
      rcd_grd_mat_det.ORGENTITY := sil_inbound_utility.get_variable('ORGENTITY');
      rcd_grd_mat_det.STARTDATE := sil_inbound_utility.get_variable('STARTDATE');
      rcd_grd_mat_det.ENDDATE := sil_inbound_utility.get_variable('ENDDATE');


      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_grd_mat_det.matnr is null then
         raise_application_error(-20000, 'Missing Primary Key - DET.MATNR');
      end if;
      if rcd_grd_mat_det.usagecode is null then
         raise_application_error(-20000, 'Missing Primary Key - DET.USEAGE');
      end if;
      if rcd_grd_mat_det.orgentity is null then
         raise_application_error(-20000, 'Missing Primary Key - DET.ORGENTITY');
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      insert into grd_mat_det
         (matnr,
          usagecode,
          orgentity,
          startdate,
          enddate)
      values
         (rcd_grd_mat_det.matnr,
          rcd_grd_mat_det.usagecode,
          rcd_grd_mat_det.orgentity,
          rcd_grd_mat_det.startdate,
          rcd_grd_mat_det.enddate);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record LCM routine */
   /**************************************************/
   procedure process_record_lcm(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      sil_inbound_utility.parse_record('LCM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_grd_mat_lcm.MATNR := rcd_grd_mat_hdr.matnr;
      rcd_grd_mat_lcm.LCMSEQ := rcd_grd_mat_lcm.lcmseq+1;
      rcd_grd_mat_lcm.REGCODE := sil_inbound_utility.get_variable('REGCODE');
      rcd_grd_mat_lcm.LEGACY_CODE := sil_inbound_utility.get_variable('LEGACY_CODE');


      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_grd_mat_lcm.matnr is null then
         raise_application_error(-20000, 'Missing Primary Key - LCM.MATNR');
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      insert into grd_mat_lcm
         (matnr,
          lcmseq,
          regcode,
          legacy_code)
      values
         (rcd_grd_mat_lcm.matnr,
          rcd_grd_mat_lcm.lcmseq,
          rcd_grd_mat_lcm.regcode,
          rcd_grd_mat_lcm.legacy_code);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_lcm;

end care_grdcar01;
/


DROP PUBLIC SYNONYM CARE_GRDCAR01;

CREATE PUBLIC SYNONYM CARE_GRDCAR01 FOR CR_APP.CARE_GRDCAR01;


