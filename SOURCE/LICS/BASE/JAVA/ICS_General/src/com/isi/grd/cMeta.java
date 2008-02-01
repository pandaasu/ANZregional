/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cMeta
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
public final class cMeta {
   
   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   
   /**
    * Class constructor
    * @throws Exception
    */
   public cMeta(cSapConnection objSapConnection) throws Exception {
      cobjSapConnection = objSapConnection;
   }
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public void toFile(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objExecution = objSapQuery.setPrimaryExecution("DD03L", "DD03L", "*", new String[]{"TABNAME = 'LIKP'"});
   //   cSapExecution objExecution = objSapQuery.setPrimaryExecution("DD03L", "DD03L", "*", new String[]{"TABNAME = 'LIPS'"});
      cSapResultSet objResultSet = objSapQuery.execute();
      objResultSet.toFile(strFile,false);
   }
   
   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    * 1. -action = *LOAD_TO_ORACLE
    * 2. -connection = the connection property file
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cMeta objMeta;
      
      //
      // Process the entry point request
      //
      try {
         System.out.println(Calendar.getInstance().getTime());
      //   cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapp.na.mars", "11");
         cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapb.na.mars", "02");
         objMeta = new cMeta(objConnection);
         objMeta.toFile("C:\\ISI_REPOSITORY\\SOURCE\\ISI_CDW\\VERSION2\\LIKP.txt");
         System.out.println(Calendar.getInstance().getTime());
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objMeta = null;
      }
      
   }

}