/**
 * Package : ISI Transform
 * Type    : Class
 * Name    : cRichTextToCsv
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.transform;
import com.isi.distribution.iTransform;
import java.io.*;

/**
 * This class implements the file RichText to CSV transformation.
 */
public final class cRichtextToCsv implements iTransform {
   
   /**
    * Implements the iTransform interface transform method
    */
   public void transform(String[] strInputFiles, String[] strOutputFiles) throws Exception {
      
      //
      // Local variables
      //
      BufferedWriter objOutputWriter = null;
      BufferedReader objInputReader = null;
      char[] chrBuffer = new char[4096];
      int intLength = 0;
      String strRTrow = "\\row";
      String strRTcell = "\\cell";
      String strCommand = new String("");
      String strRow = new String("");
      String strCell = new String("");
      String strText = new String("");
      boolean bolCommand = false;
      
      //
      // Validate the output file
      //
      if (strInputFiles.length != strOutputFiles.length) {
         throw new Exception("Transformation - Richtext to CSV Failed - Input and output file counts must match for individual transformation");
      }
      
      //
      // Convert (Richtext format to CSV format) the input files to the output files
      //
      try {
         for (int i=0; i<strInputFiles.length; i++) {
            bolCommand = false;
            strCommand = "";
            strRow = "";
            strCell = "";
            objOutputWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(strOutputFiles[i]),"8859_1"));
            objInputReader = new BufferedReader(new InputStreamReader(new FileInputStream(strInputFiles[i])));
            while ((intLength = objInputReader.read(chrBuffer)) > 0) {
               for (int c=0; c<intLength; c++) {
                  if (chrBuffer[c] == '\\') {
                     if (strCommand.equals(strRTrow)) {
                        if (!strRow.equals("")) {
                           objOutputWriter.write(strRow);
                           objOutputWriter.newLine();
                        }
                        strRow = "";
                        strCell = "";
                     } else if (strCommand.equals(strRTcell)) {
                        if (!strRow.equals("")) {
                           strRow = strRow + ",";
                        }
                        if (isNumeric(strCell)) {
                           strRow = strRow + strCell;
                        } else {
                           strRow = strRow + "\"" + strCell + "\"";
                        }
                        strCell = "";
                     } else {  
                        if (!strCommand.equals("")) {
                           strCell = "";
                        } 
                     }
                     strCommand = "" + chrBuffer[c];
                     bolCommand = true;
                  } else if (chrBuffer[c] == ' ') {
                     if (bolCommand) {
                        if (strCommand.equals(strRTrow)) {
                           if (!strRow.equals("")) {
                              objOutputWriter.write(strRow);
                              objOutputWriter.newLine();
                           }
                           strRow = "";
                           strCell = "";
                        } else if (strCommand.equals(strRTcell)) {
                           if (!strRow.equals("")) {
                              strRow = strRow + ",";
                           }
                           if (isNumeric(strCell)) {
                              strRow = strRow + strCell;
                           } else {
                              strRow = strRow + "\"" + strCell + "\"";
                           }
                           strCell = "";
                        } else {  
                           strCell = "";
                        }
                        strCommand = "";
                        bolCommand = false;
                     } else {
                        if (chrBuffer[c] == ',' || chrBuffer[c] == '\t') {
                           strCell = strCell + " ";
                        } else {
                           strCell = strCell + chrBuffer[c];
                           if (chrBuffer[c] == '\"' ) {
                              strCell = strCell + "\"";
                           }
                        }
                     }     
                  } else {
                     if (bolCommand) {
                        strCommand = strCommand + chrBuffer[c];
                     } else {
                        if (chrBuffer[c] == ',' || chrBuffer[c] == '\t') {
                           strCell = strCell + " ";
                        } else {
                           strCell = strCell + chrBuffer[c];
                           if (chrBuffer[c] == '\"' ) {
                              strCell = strCell + "\"";
                           }
                        }
                     }
                  }
               }
            }
            objInputReader.close();
            objOutputWriter.close();               
         }
      } catch(Exception objException) {
         throw new Exception("Transformation - Richtext to CSV Failed - " + objException.getMessage());
      } finally {
         objOutputWriter = null;
         objInputReader = null;
      }
      
   }
   
   /**
    * Checks a string for a numeric value
    * 
    * @param strNumber the string containing the number to check
    * @return boolean - true = numeric - false = non numeric
    */
   private boolean isNumeric(String strNumber) {
      try {
         Double.parseDouble(strNumber);
      } catch(NumberFormatException objException) {
        return false;
      }
      return true;
   }

}