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
public final class cDelivery {
   
   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   
   /**
    * Class constructor
    * @throws Exception
    */
   public cDelivery(cSapConnection objSapConnection) throws Exception {
      cobjSapConnection = objSapConnection;
      System.out.println(Calendar.getInstance().getTime());
   }
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public void toFile(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objLIKPExecution = objSapQuery.setPrimaryExecution("LIKP", "LIKP", "*", new String[]{"VBELN = '7081172850'"});
      cSapExecution objLIPSExecution = objLIKPExecution.addExecution("LIPS", "LIPS", "*", new String[]{"VBELN = '<SAPVALUE>VBELN</SAPVALUE>'"});
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
      cDelivery objDelivery;
      
      //
      // Process the entry point request
      //
      try {
         
         System.out.println(Calendar.getInstance().getTime());
      //   cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapp.na.mars", "11");
         cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapb.na.mars", "02");
         objDelivery = new cDelivery(objConnection);
         objDelivery.toFile("C:\\ISI_REPOSITORY\\SOURCE\\ISI_CDW\\VERSION2\\test_delivery_7081172850.txt");
         objConnection.disconnect();
         objConnection = null;
         System.out.println(Calendar.getInstance().getTime());
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objDelivery = null;
      }
      
   }
}