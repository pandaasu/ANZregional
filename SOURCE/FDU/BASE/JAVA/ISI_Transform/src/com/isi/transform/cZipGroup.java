/**
 * Package : ISI Transform
 * Type    : Class
 * Name    : cZipGroup
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.transform;
import com.isi.distribution.iTransform;
import java.io.*;
import java.util.zip.*;

/**
 * This class implements the group ZIP compression transformation.
 */
public final class cZipGroup implements iTransform {
   
   /**
    * Implements the iTransform interface transform method
    */
   public void transform(String[] strInputFiles, String[] strOutputFiles) throws Exception {
      
      //
      // Local variables
      //
      ZipOutputStream objOutputStream = null;
      FileInputStream objInputStream = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      
      //
      // Validate the output file
      //
      if (strOutputFiles.length != 1) {
         throw new Exception("Transformation - ZIP Group Failed - Only one output file allowed for group transformation");
      }
      
      //
      // Compress (ZIP) the input files to the first output file
      //
      try {
         objOutputStream = new ZipOutputStream(new FileOutputStream(strOutputFiles[0]));
         for (int i=0; i<strInputFiles.length; i++) {
            objOutputStream.putNextEntry(new ZipEntry(new File(strInputFiles[i]).getName()));
            objInputStream = new FileInputStream(strInputFiles[i]);
            while ((intLength = objInputStream.read(bytBuffer)) > 0) {
               objOutputStream.write(bytBuffer,0,intLength);
            }
            objInputStream.close();
            objOutputStream.closeEntry();
         }
         objOutputStream.close();
      } catch(Exception objException) {
         throw new Exception("Transformation - ZIP Group Failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }
      
   }

}