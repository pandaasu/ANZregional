/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapUtility
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.sap;
import java.util.*;
import java.text.*;
import java.io.*;

/**
 * This class implements the SAP utility.
 */
public final class cSapUtility {

   /**
    * Retrieves the grouped OR condition statements from a list
    * @param objList the source array
    * @param strKeyCondition the key condition clause
    * @param intGroup the result grouping
    * @return ArrayList the condition array
    * @throws Exception the exception message
    */
   public static ArrayList getOrConditionsArray(ArrayList objList, String strKeyCondition, int intGroup) throws Exception {
      
      //
      // Return an empty array when required
      //
      if (objList == null || strKeyCondition == null) {
         return new ArrayList();
      }
      
      //
      // Parse the key value
      //
      String strPart1 = strKeyCondition;
      String strPart2 = null;
      String strPart3 = null;
      String strTag = "<KEYVALUE>";
      String strGat = "</KEYVALUE>";
      int intStart = 0;
      int intEnd = 0;
      if (strKeyCondition.indexOf(strTag,0) != -1) {
         intStart = strKeyCondition.indexOf(strTag,0);
         intEnd = strKeyCondition.indexOf(strGat,0);
         if (intEnd != -1) {
            strPart1 = strKeyCondition.substring(0,intStart);
            strPart2 = strKeyCondition.substring(intStart+strTag.length(),intEnd);
            strPart3 = strKeyCondition.substring(intEnd + strGat.length());
         }
      }
      
      //
      // Load the keys array
      //
      ArrayList objKeys = new ArrayList();
      String[] strKeys = null;
      int intTotal = objList.size();
      int intCount = intGroup - 1;
      for (int i=0; i<objList.size(); i++) {
         if ((intCount + 1) == intGroup) {
            if (((intTotal-i)-intGroup) > 0) {
               strKeys = new String[intGroup];
            } else {
               strKeys = new String[(intTotal-i)];
            }
            objKeys.add(strKeys);
            intCount = 0;
         } else {
            intCount++;
         }
         if (intCount == 0) {
            strKeys[intCount] = "(" + strPart1;
         } else {
            strKeys[intCount] = strPart1;
         }
         if (strPart2 != null) {
            strKeys[intCount] = strKeys[intCount] + ((String)objList.get(i)).trim();
            strKeys[intCount] = strKeys[intCount] + strPart3;
         } 
         if (intCount < (strKeys.length-1)) {
            strKeys[intCount] = strKeys[intCount] + " OR";
         } else {
            strKeys[intCount] = strKeys[intCount] + ")";
         }
      }
      strKeys = null;

      //
      // Return the condition array
      //
      return objKeys;
      
   }
   
   /**
    * Retrieves the grouped values array from a list
    * @param objList the source array
    * @param intGroup the result grouping
    * @return ArrayList the values array
    * @throws Exception the exception message
    */
   public static ArrayList getValuesArray(ArrayList objList, int intGroup) throws Exception {
      
      //
      // Return an empty array when required
      //
      if (objList == null) {
         return new ArrayList();
      }
      
      //
      // Load the keys array
      //
      ArrayList objKeys = new ArrayList();
      String[] strKeys = null;
      int intTotal = objList.size();
      int intCount = intGroup - 1;
      for (int i=0; i<objList.size(); i++) {
         if ((intCount + 1) == intGroup) {
            if (((intTotal-i)-intGroup) > 0) {
               strKeys = new String[intGroup];
            } else {
               strKeys = new String[(intTotal-i)];
            }
            objKeys.add(strKeys);
            intCount = 0;
         } else {
            intCount++;
         }
         strKeys[intCount] = ((String)objList.get(i)).trim();
      }
      strKeys = null;

      //
      // Return the values array
      //
      return objKeys;
      
   }
   
   /**
    * Concatenates two string arrays
    * @param strSource the source array
    * @param strAppend the append array
    * @return String[] the condition array
    */
   public static String[] concatenateArray(String[] strSource, String[] strAppend) throws Exception {
      String[] objResult;
      try {
         objResult = new String[strSource.length + strAppend.length];
         if (strSource.length > 0) {
            System.arraycopy(strSource, 0, objResult, 0, strSource.length);
         }
         if (strAppend.length > 0) {
            System.arraycopy(strAppend, 0, objResult, strSource.length, strAppend.length);
         }
         return objResult;
      } finally {
         objResult = null;
      }
   }
   
   /**
    * Outputs the row to the interface writer
    * @param objPrintWriter the output interface writer
    * @throws Exception the exception message
    */
   public static void appendToInterface(String strFileName, String strData) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strFileName, true));
      objPrintWriter.println();
      objPrintWriter.print(strData);
      objPrintWriter.close();
   }

}