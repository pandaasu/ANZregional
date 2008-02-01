/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cTransform
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;

/**
 * This class implements the distribution transformation functionality.
 */
public class cTransform {
   
   //
   // Instance private declarations
   //
   private String cstrCode;
   private String cstrText;
   private String cstrClass;
   private String cstrMode;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the transform parameter array
    */
   public cTransform(String[] strParameters) {
      cstrCode = strParameters[0];
      cstrText = strParameters[1];
      cstrClass = strParameters[2];
      cstrMode = strParameters[3];
   }
   
   /**
    * Gets the transform mode
    *
    * @return String the transform mode
    */
   public String getMode() {
      return cstrMode;
   }
   
   /**
    * Processes the distribution transform using the supplied configuration.
    *
    * @param strInputFiles the transform input file array
    * @param strOutputFiles the transform output file array
    * @throws Exception the exception message
    */
   public void process(String[] strInputFiles, String[] strOutputFiles) throws Exception {
      
      //
      // Process the transformation
      //
      iTransform objTransformInstance;
      try {
      
         //
         // Load and instance the transformation class
         //
         try {
            Class objTransformClass = Class.forName(cstrClass);
            try {
               objTransformInstance = (iTransform)objTransformClass.newInstance();
            } catch(Exception objException) {
               throw new Exception("Class (" + cstrClass + ") unable to cast to iTransform");
            }
         } catch(ClassNotFoundException objException) {
            throw new Exception("Class (" + cstrClass + ") not found");
         }

         //
         // Execute the transformation instance
         //
         try {
            objTransformInstance.transform(strInputFiles, strOutputFiles);
         } catch(Exception objException) {
            throw new Exception("Execution Failed - " + objException.getMessage());
         }
         
      } catch(Exception objException) {
         throw new Exception("Transformation (" + cstrCode + ") - " + objException.getMessage());
      } finally {
         objTransformInstance = null;
      }
      
   }

}