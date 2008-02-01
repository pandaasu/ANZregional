/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cTransformAction
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.io.*;

/**
 * This class implements the transform action functionality.
 */
public class cTransformAction {
   
   //
   // Instance private declarations
   //
   private String cstrType;
   private String cstrText;
   private String cstrFiles;
   private String cstrOutputName;
   private String cstrOutputExtension;
   private String cstrMode;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the transform action parameter array
    * @param strMode the transform action mode
    */
   public cTransformAction(String[] strParameters, String strMode) {
      cstrType = strParameters[0];
      cstrText = strParameters[1];
      cstrFiles = strParameters[2];
      cstrOutputName = strParameters[3];
      cstrOutputExtension = strParameters[4];
      cstrMode = strMode;
   }
   
   /**
    * Processes the distribution transform action
    *
    * @param objConfiguration the configuration reference
    * @param strTransferPath the transfer path
    * @param strTransformPath the transform path
    * @throws Exception the exception message
    */
   public void process(cConfiguration objConfiguration, String strTransferPath, String strTransformPath) throws Exception {
      
      //
      // Output the log start
      //
      objConfiguration.putLogLine("-----> TRANSFORM - " + cstrType + " (" + cstrText + ") - Files=(" + cstrFiles + ")");
      
      //
      // Process the transformation
      //
      try {
         File[] objInputFiles = objConfiguration.retrieveFileList(strTransferPath, cstrFiles);
         String[] strInputFiles = objConfiguration.retrieveNameList(objInputFiles);
         String[] strOutputFiles = null;
         if (cstrMode.equalsIgnoreCase("*SINGLE")) {
            strOutputFiles = new String[strInputFiles.length];
            for (int i=0; i<strInputFiles.length; i++) {
               int intSep = strInputFiles[i].lastIndexOf(File.separator);
               int intDot = strInputFiles[i].lastIndexOf(".");
               String strName = new String("");
               String strExtn = new String("");
               if (intDot != -1 && intDot > intSep) {
                  strName = strInputFiles[i].substring(intSep + 1, intDot);
                  strExtn = strInputFiles[i].substring(intDot);
               } else {
                  strName = strInputFiles[i].substring(intSep + 1);
               }
               if (cstrOutputName.equalsIgnoreCase("@@FDU_SAME")) {
                  strOutputFiles[i] = strName;
               } else {
                  strOutputFiles[i] = cstrOutputName;
               }
               if (cstrOutputExtension.equalsIgnoreCase("@@FDU_SAME")) {
                  strOutputFiles[i] = strOutputFiles[i] + strExtn;
               } else {
                  strOutputFiles[i] = strOutputFiles[i] + "." + cstrOutputExtension;
               }
               strOutputFiles[i] = strTransformPath + File.separator + strOutputFiles[i];
            }
         } else {
            strOutputFiles = new String[1];
            strOutputFiles[0] = strTransformPath + File.separator + cstrOutputName + "." + cstrOutputExtension;
         }
         objConfiguration.processTransform(cstrType, strInputFiles, strOutputFiles);
         for (int i=0; i<objInputFiles.length; i++) {
            if (!objInputFiles[i].delete()) {
               objConfiguration.putLogLine("-----> **EXCEPTION** - Unable to delete file (" + objInputFiles[i].getName() + ") from transfer directory");
            }
         }
         File[] objOutputFiles = objConfiguration.retrieveFileList(strTransformPath, "*.*");
         for (int i=0; i<objOutputFiles.length; i++) {
            if (!objOutputFiles[i].renameTo(new File(strTransferPath, objOutputFiles[i].getName()))) {
               objConfiguration.putLogLine("-----> **EXCEPTION** - Unable to move file (" + objOutputFiles[i].getName() + ") from transform directory to transfer directory");
            }
         }
      } catch(Exception objException) {
         objConfiguration.putLogLine("-----> **EXCEPTION** - Transform failed - " + objException.getMessage());
         throw new Exception("Transform action Exception");
      }
      
   }

}