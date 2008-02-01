/**
 * Package : ISI Transform
 * Type    : Class
 * Name    : cZipFile
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.transform;
import com.isi.distribution.iTransform;
import java.io.*;
import java.util.zip.*;

/**
 * This class implements the file ZIP compression transformation.
 */
public final class cZipFile implements iTransform {
   
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
      if (strInputFiles.length != strOutputFiles.length) {
         throw new Exception("Transformation - ZIP File Failed - Input and output file counts must match for individual transformation");
      } 
      
      //
      // Compress (ZIP) the input files to the output files
      //
      try {
         for (int i=0; i<strInputFiles.length; i++) {
            objOutputStream = new ZipOutputStream(new FileOutputStream(strOutputFiles[i]));
            objOutputStream.putNextEntry(new ZipEntry(new File(strInputFiles[i]).getName()));
            objInputStream = new FileInputStream(strInputFiles[i]);
            while ((intLength = objInputStream.read(bytBuffer)) > 0) {
               objOutputStream.write(bytBuffer,0,intLength);
            }
            objInputStream.close();
            objOutputStream.closeEntry();
            objOutputStream.close();
         }
      } catch(Exception objException) {
         throw new Exception("Transformation - ZIP File Failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }
      
   }

}