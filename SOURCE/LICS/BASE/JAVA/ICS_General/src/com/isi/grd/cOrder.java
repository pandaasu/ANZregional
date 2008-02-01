/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cOrder
 * Author  : Steve Gregan
 * Date    : September 2004
 */
package com.isi.grd;
import com.isi.sap.*;
import java.io.*;
import java.util.*;

/**
 * This class implements the Order query
 */
public final class cOrder {
   
   //
   // Class variables
   //
   private cSapConnection cobjSapConnection;
   
   /**
    * Class constructor
    * @throws Exception
    */
   public cOrder(cSapConnection objSapConnection) throws Exception {
      cobjSapConnection = objSapConnection;
      System.out.println(Calendar.getInstance().getTime());
   }
   
   /**
    * Retrieves the order audit data to a file
    * @throws Exception the exception message
    */
   public void toFile(String strFile) throws Exception {
      cSapQuery objSapQuery = new cSapQuery(cobjSapConnection);
      cSapExecution objExecution = objSapQuery.setPrimaryExecution("CDHDR", "CDHDR", "*", new String[]{"OBJECTCLAS = 'VERKBELEG'"});
    //  cSapExecution objExecution = objSapQuery.setPrimaryExecution("CDPOS", "CDPOS", "OBJECTID,CHANGENR,CHNGIND,TABNAME,TABKEY,VALUE_NEW,VALUE_OLD", new String[]{"OBJECTCLAS = 'VERKBELEG'"," AND OBJECTID = '7070017318'"});
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
      cOrder objOrder;
      
      //
      // Process the entry point request
      //
      try {
         
         System.out.println(Calendar.getInstance().getTime());
      //   cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapp.na.mars", "11");
         cSapConnection objConnection = new cSapConnection("002", "mfanzics", "mfanzics", "EN", "sapapb.na.mars", "02");
         objOrder = new cOrder(objConnection);
         objOrder.toFile("c:\\isi_sap\\data\\order_audit.txt");
         objConnection.disconnect();
         objConnection = null;
         System.out.println(Calendar.getInstance().getTime());
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objOrder = null;
      }
      
   }
}