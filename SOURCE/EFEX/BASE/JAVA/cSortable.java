/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cSortable
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application sortable object abstract.
 */
public abstract class cSortable {
   
   /**
    * Gets the sort value
    *
    * @return String the sort value
    */
   public abstract String getSortValue();
   
   /**
    * Implements the Comparable methods
    */
   public int compareTo(Object objComparator) {
      int intCompare = this.getSortValue().compareTo(((cSortable)objComparator).getSortValue());
      int intReturn = 0;
      if (intCompare == 0) {
         intReturn = 0;
      } else if (intCompare < 0) {
         intReturn = -1;
      } else {
         intReturn = 1;
      }
      return intReturn;
   }
   
}
