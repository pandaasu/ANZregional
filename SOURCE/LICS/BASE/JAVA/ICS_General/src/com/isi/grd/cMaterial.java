/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cMaterial
 * Author  : Steve Gregan
 * Date    : September 2004
 */
package com.isi.grd;
import com.isi.sap.*;
import java.io.*;
import java.util.*;

/**
 * This class implements the GRD material query
 */
public final class cMaterial {
   
   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   
   /**
    * Class constructor
    * @throws Exception
    */
   public cMaterial(cSapConnection objSapConnection) throws Exception {
      cobjSapConnection = objSapConnection;
      System.out.println(Calendar.getInstance().getTime());
   }
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public void toFile(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objMARAExecution = objSapQuery.setPrimaryExecution("MARA", "MARA", "*", new String[]{"MATNR = '000000000010024928'"});
    //  cSapExecution objMARMExecution = objMARAExecution.addExecution("MARM", "MARM", "*", new String[]{"MATNR = '<SAPVALUE>MATNR</SAPVALUE>'"});
      cSapExecution objMAKTExecution = objMARAExecution.addExecution("MAKT", "MAKT", "*", new String[]{"MATNR = '<SAPVALUE>MATNR</SAPVALUE>'"});
    //  cSapExecution objMARCExecution = objMARAExecution.addExecution("MARC", "MARC", "*", new String[]{"MATNR = '<SAPVALUE>MATNR</SAPVALUE>'"});
    //  cSapExecution objINOBExecution = objMARAExecution.addExecution("INOB", "INOB", "*", new String[]{"OBJEK = '<SAPVALUE>MATNR</SAPVALUE>'"});
    //  cSapExecution objAUSPExecution = objINOBExecution.addExecution("AUSP", "AUSP", "*", new String[]{"OBJEK = '<SAPVALUE>CUOBJ</SAPVALUE>'"});
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.setHierarchy();
      
      
      while (objResultSet.getNextRow()) {
         for (int i=0; i<objResultSet.getFieldCount(); i++) {
            String x = new String(objResultSet.getFieldValue(i).getBytes(),"SJIS");
            System.out.println(objResultSet.getFieldValue(i));
         }
      }
 //     objResultSet.toFile(strFile,false);
   }
   
   /**
    * Retrieves the material data to multiple files
    * @throws Exception the exception message
    */
   public void toList(String strFile) throws Exception {
      
      //
      // Retrieve the list of MARA changes for the data range
      //
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objSapExecution = objSapQuery.setPrimaryExecution("MARA", "MARA", "MATNR, LAEDA, AENAM, LVORM, MTART", new String[]{"LAEDA >= '20070118'"});
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPMAT01", true, false);
      ArrayList objMARA = new ArrayList();
      objResultSet.setHierarchy();
      while (objResultSet.getNextRow()) {
         objMARA.add(objResultSet.getFieldValue("MATNR"));
      }
  
      //
      // Retrieve the list of MARC codes that satisfy the MARA changes
      //
      String[] strMARC = new String[objMARA.size()];
      for (int i=0; i<objMARA.size(); i++) {
         if (i == 0) {
            strMARC[i] = "MATNR = '" + (String)objMARA.get(i) + "'";
         } else {
            strMARC[i] = "or MATNR = '" + (String)objMARA.get(i) + "'";
         }
      }
      
      objSapQuery = new cSapQuery(cobjSapConnection);
      objSapExecution = objSapQuery.setPrimaryExecution("MARC", "MARC", "MATNR, WERKS", strMARC);
      objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPMAT01", true, true);
      ArrayList objMARC = new ArrayList();
      objResultSet.setHierarchy();
      while (objResultSet.getNextRow()) {
         if (objResultSet.getFieldValue("WERKS").startsWith("AU") || objResultSet.getFieldValue("WERKS").startsWith("NZ")) {
            objMARC.add(objResultSet.getFieldValue("MATNR"));
         }
      }
      
      //
      // Retrieve the list of MVKE codes that satisfy the MARA changes
      //
      String[] strMVKE = new String[objMARA.size()];
      for (int i=0; i<objMARA.size(); i++) {
         if (i == 0) {
            strMVKE[i] = "MATNR = '" + (String)objMARA.get(i) + "'";
         } else {
            strMVKE[i] = "or MATNR = '" + (String)objMARA.get(i) + "'";
         }
      }
      objSapQuery = new cSapQuery(cobjSapConnection);
      objSapExecution = objSapQuery.setPrimaryExecution("MVKE", "MVKE", "MATNR, VKORG", strMVKE);
      objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPMAT01", true, true);
      ArrayList objMVKE = new ArrayList();
      objResultSet.setHierarchy();
      while (objResultSet.getNextRow()) {
         if (objResultSet.getFieldValue("VKORG").equals("147") || objResultSet.getFieldValue("VKORG").equals("149")) {
            objMVKE.add(objResultSet.getFieldValue("MATNR"));
         }
      }
      
      //
      // Merge the MARC and MVKE lists into the CODE list
      //
      ArrayList objCODE = new ArrayList();
      boolean bolFound;
      for (int i=0; i<objMARC.size(); i++) {
         bolFound = false;
         for (int j=0; j<objCODE.size(); j++) {
            if (((String)objMARC.get(i)).equals((String)objCODE.get(j))) {
               bolFound = true;
               break;
            }
         }
         if (!bolFound) {
            objCODE.add(objMARC.get(i));
         }
      }
      for (int i=0; i<objMVKE.size(); i++) {
         bolFound = false;
         for (int j=0; j<objCODE.size(); j++) {
            if (((String)objMVKE.get(i)).equals((String)objCODE.get(j))) {
               bolFound = true;
               break;
            }
         }
         if (!bolFound) {
            objCODE.add(objMVKE.get(i));
         }
      }
      
      //
      // Print the result (temporary)
      //
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFile, true));
      objPrintWriter.println();
      objPrintWriter.print("MERGED_CODE_LIST");
      for (int i=0; i<objCODE.size(); i++) {
         objPrintWriter.println();
         objPrintWriter.print((String)objCODE.get(i));
      }
      objPrintWriter.close();
      
      
   }
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public void toJim(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objINOBExecution = objSapQuery.setPrimaryExecution("INOB", "INOB", "CUOBJ", new String[]{"OBJEK = 'N0000600'"," AND OBTAB = 'MARA'"," AND KLART = '001'"});
      cSapExecution objAUSPExecution = objINOBExecution.addExecution("AUSP", "AUSP", "*", new String[]{"OBJEK = '<SAPVALUE>CUOBJ</SAPVALUE>'"});
      cSapExecution objCABNExecution = objAUSPExecution.addExecution("CABN", "CABN", "*", new String[]{"ATINN = '<SAPVALUE>ATINN</SAPVALUE>'"});
      cSapExecution objCABNTExecution = objCABNExecution.addExecution("CABNT", "CABNT", "*", new String[]{"ATINN = '<SAPVALUE>ATINN</SAPVALUE>'"});
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.toFile(strFile,false);
   }
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public void toCAWN(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objSapExecution = objSapQuery.setPrimaryExecution("CAWN", "CAWN", "*", new String[0]);
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPCAWN", true, false);
      objSapQuery = new cSapQuery(cobjSapConnection);
      objSapExecution = objSapQuery.setPrimaryExecution("CAWNT", "CAWNT", "*", new String[0]);
      objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPCAWNT", true, true);
      objSapQuery = new cSapQuery(cobjSapConnection);
      objSapExecution = objSapQuery.setPrimaryExecution("CABN", "CABN", "*", new String[0]);
      objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPCABN", true, true);
      objSapQuery = new cSapQuery(cobjSapConnection);
      objSapExecution = objSapQuery.setPrimaryExecution("CABNT", "CABNT", "*", new String[0]);
      objResultSet = objSapQuery.execute();
      objResultSet.toInterface(strFile, "SAPCABNT", true, true);
   }
   
   /**
    * Retrieves the material changes to a file
    * @throws Exception the exception message
    */
   public void getChanges(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objCDHDRExecution = objSapQuery.setPrimaryExecution("CDHDR", "CDHDR", "*", new String[]{"OBJECTCLAS = 'MATERIAL'"," AND UDATE = '20050510'"});
      cSapExecution objCDPOSExecution = objCDHDRExecution.addExecution("CDPOS", "CDPOS", "*", new String[]{"OBJECTCLAS = 'MATERIAL'"," AND OBJECTID = '<SAPVALUE>OBJECTID</SAPVALUE>'"," AND CHANGENR = '<SAPVALUE>CHANGENR</SAPVALUE>'"});
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.toFile(strFile,false);
   }

   /**
    * Main method - provides an entry point to the application.
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cMaterial objMaterial;
      
      //
      // Process the entry point request
      //
      try {
            System.out.println(Calendar.getInstance().getTime());
        //    cSapConnection objConnection = new cSapConnection("002", "mitchala", "minolta1", "EN", "sapamb.na.mars", "01");
        //   cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "JA", "sapapb.na.mars", "02");
           cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "JA", "sapapp.na.mars", "11");
            objMaterial = new cMaterial(objConnection);
            objMaterial.toFile("c:\\isi_sap\\data\\material_english.txt");
        //    objMaterial.toList("c:\\isi_sap\\data\\apb_material_list.txt");
            
        //    objMaterial.toJim("c:\\isi_sap\\data\\material_jim.txt");
        //    objMaterial.toCAWN("c:\\isi_sap\\data\\SAP_DATA.txt");
            objConnection.disconnect();
            objConnection = null;
            System.out.println(Calendar.getInstance().getTime());
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objMaterial = null;
      }
      
   }
}