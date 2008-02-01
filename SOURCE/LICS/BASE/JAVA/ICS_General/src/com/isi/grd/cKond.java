/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cMaterial
 * Author  : Steve Gregan
 * Date    : September 2004
 */
package com.isi.grd;
import java.io.*;
import java.util.*;
import java.text.*;

/**
 * This class implements the GRD material query
 */
public final class cKond {
   
   /**
    * Retrieves the material data to a file
    * @throws Exception the exception message
    */
   public String toFile() throws Exception {
      DecimalFormat objDecimalFormat = new DecimalFormat();
      objDecimalFormat.setGroupingSize(0);
      objDecimalFormat.setMinimumFractionDigits(0);
      GregorianCalendar objCalendar = new GregorianCalendar();
      objCalendar.setTimeInMillis(Calendar.getInstance().getTimeInMillis());
      objDecimalFormat.setMinimumIntegerDigits(4);
      String strYear = objDecimalFormat.format((long)objCalendar.get(Calendar.YEAR));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMonth = objDecimalFormat.format((long)objCalendar.get(Calendar.MONTH)+1);
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strDay = objDecimalFormat.format((long)objCalendar.get(Calendar.DATE));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strHour = objDecimalFormat.format((long)objCalendar.get(Calendar.HOUR_OF_DAY));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strMinute = objDecimalFormat.format((long)objCalendar.get(Calendar.MINUTE));
      objDecimalFormat.setMinimumIntegerDigits(2);
      String strSecond = objDecimalFormat.format((long)objCalendar.get(Calendar.SECOND));
      String strTimestamp = strYear + strMonth + strDay + strHour + strMinute + strSecond;
      return strTimestamp;
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
      cKond objKond;
      
      //
      // Process the entry point request
      //
      try {
            objKond = new cKond();
            objKond.toFile();
            System.out.println(objKond.toFile());
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objKond = null;
      }
      
   }

}