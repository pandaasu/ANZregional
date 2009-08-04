/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cTableItem
 * Author  : Steve Gregan
 * Date    : October 2008
 */
package com.isi.efex;
import javax.microedition.lcdui.Canvas;
import javax.microedition.lcdui.CustomItem;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Font;
import javax.microedition.lcdui.Graphics;

/**
 * Table item
 */
public final class cTableItem extends CustomItem {

   //
   // Private class declarations
   //
   private Display cobjDisplay;
   private String cstrTitle;
   private String[] cstrColumnNames = new String[0];
   private String[][] cstrCellValues = new String[0][0];
   private int cintRowCount;
   private int cintColumnCount;
   private int[] cintColumnWidths;
   private int[] cintRowHeights;
   private int cintTableWidth;

   private boolean bolHasFocus = false;
   private int cintThisX;
   private int cintThisY;
   private int cintSX = 0;
   private int cintSY = 0;
   
   private int cintTH = 0;
   private int cintHH = 0;
   private int cintBH = 0;
   private int cintVH = 0;
   private int cintVR = 0;
   

   private static final Font STATIC_TEXT_FONT = Font.getFont(Font.FONT_STATIC_TEXT);
   private static final Font DEFAULT_TITLE_FONT = Font.getFont(STATIC_TEXT_FONT.getFace(), STATIC_TEXT_FONT.getStyle()|Font.STYLE_BOLD, STATIC_TEXT_FONT.getSize());
   private static final Font DEFAULT_HEADERS_FONT = Font.getFont(STATIC_TEXT_FONT.getFace(), STATIC_TEXT_FONT.getStyle()|Font.STYLE_BOLD, STATIC_TEXT_FONT.getSize());;
   private static final Font DEFAULT_VALUES_FONT = STATIC_TEXT_FONT;

   
   private static final int COLOR_CANVAS = 0x202020;
   private static final int COLOR_HEAD_BACKGROUND = 0x708090;
   private static final int COLOR_HEAD_FOREGROUND = 0xffffff;
   private static final int COLOR_BACKGROUND = 0xe0e0e0;
   private static final int COLOR_HIGHLIGHTED_FOREGROUND = 0xffffff;
   private static final int COLOR_HIGHLIGHTED_BACKGROUND = 0x0033ff;
   private static final int COLOR_BORDER = 0xc0c0c0;
   private static final int COLOR_FOREGROUND = 0x000000;
   private static final int COLOR_HIGHLIGHTED_BORDER = 0x84ffff;


   private int cintCellWidth;
   private int cintCellHeight;

   private static final int OFFSET = 1;
   private static final int CELL_PADDING = 2;
   private static final int DOUBLE_CELL_PADDING = 2 * CELL_PADDING;
   private static final int BORDER_LINE_WIDTH = 1;

   private boolean bolPaintStart = true;

   private int cintSizeWidth = 0;
   private int cintSizeHeight = 0;



   /**
    * Creates a new instance of <code>TableItem</code> with a model.
    *
    * @param display non-null display parameter.
    * @param label label for the item
    * @param model a <code>TableModel</code> to be visualized by this item
    * @throws java.lang.IllegalArgumentException if the display parameter is null
    */
   public cTableItem(Display objDisplay,
                     String strTitle,
                     String[] strColumnNames,
                     int intRowCount) {
      super(null);
      cobjDisplay = objDisplay;
      cstrTitle = strTitle;
      cintRowCount = intRowCount;
      cintColumnCount = strColumnNames.length;
      cintTH = CELL_PADDING + DEFAULT_TITLE_FONT.getHeight() + CELL_PADDING;
      cintHH = CELL_PADDING + DEFAULT_TITLE_FONT.getHeight() + CELL_PADDING;
      cintBH = CELL_PADDING + DEFAULT_TITLE_FONT.getHeight() + CELL_PADDING;
      cintThisY = 0;
      cintThisX = 0;
      cintSY = 0;
      cintSX = 0;
      
      cstrCellValues = new String[cintRowCount][cintColumnCount];
      for (int i=0;i<cintRowCount;i++) {
         cstrCellValues[i] = new String[cintColumnCount];
      }
      
      cstrColumnNames = new String[strColumnNames.length];
      for (int j=0;j<strColumnNames.length;j++) {
         cstrColumnNames[j] = strColumnNames[j];
      }
      cintCellWidth = DEFAULT_VALUES_FONT.stringWidth("X");
      cintCellHeight = DEFAULT_VALUES_FONT.getHeight();
      
      cintColumnWidths = new int[cintColumnCount];

   }
    
   /**
    * Sets the value to the defined row and column of the model. 
    */
   public void setValue(int intColumn, int intRow, String strValue) {
      if (strValue == null) {
         return;
      }
      if (cstrCellValues.length < intRow) {
         return;
      }
      if (cstrCellValues[intRow].length < intColumn) {
         return;
      }
      cstrCellValues[intRow][intColumn] = strValue;
   }

   /**
    * Gets the value of a table cell at a specified location.
    */
   public String getValue(int intColumn, int intRow) {
      if (cstrCellValues.length < intRow) {
         return null;
      }
      if (cstrCellValues[intRow].length < intColumn) {
         return null;
      }
      return cstrCellValues[intRow][intColumn];
   }

   /**
    * Gets the row position of the cursor in the table.
    * @return selected cell row
    */
   public int getSelectedCellRow() {
      return cintThisY;
   }

   /**
    * Gets the column position of the cursor in the table.
    * @return selected cell column
    */
   public int getSelectedCellColumn() {
      return cintThisX;
   }

   /**
    * implementation of the abstract method
    * @return minimal content height
    */
   protected int getMinContentHeight() {
      if (cintSizeHeight != 0) {
         return cintSizeHeight - 2;
      }
      return cobjDisplay.getCurrent().getHeight() - 2;
   }
   protected int getMinContentWidth() {
      if (cintSizeWidth != 0) {
         return cintSizeWidth - 2;
      }
      return cobjDisplay.getCurrent().getWidth() - 2;
   }

   /**
    * implementation of the abstract method
    * @param width
    * @return preferred contnent height
    */
   protected int getPrefContentHeight(int intWidth) {
      return getMinContentHeight();
   }

   /**
    * implementation of the abstract method
    * @param height 
    * @return preferred content width
    */
   protected int getPrefContentWidth(int intHeight) {
      return getMinContentWidth();
   }

   /**
    * implementation of the abstract method
    * @param g
    * @param width
    * @param height
    */
   protected void paint(Graphics g, int width, int height) {

      bolPaintStart = false;

      // save color and stroke
      int intSaveColor = g.getColor();
      int intSaveStrokeStyle = g.getStrokeStyle();
      boolean bolViewable = false;

      int intPW = width - (OFFSET * 2);
      int intPH = height - (OFFSET * 2);
      int intX = 0;
      int intY = 0;
      int intW = 0;
      int intH = 0;
      int intFX = 0;
      int intFY = 0;
      int intFW = 0;
      int intFH = 0;
      int intBX1 = 0;
      int intBY1 = 0;
      int intBX2 = 0;
      int intBY2 = 0;
      int intTH = 0;
      int intTY = 0;
      int intHY = 0;
      int intVY = 0;
      int intVX = 0;

      intTH = OFFSET + BORDER_LINE_WIDTH + CELL_PADDING + DEFAULT_TITLE_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
      intTY = OFFSET + BORDER_LINE_WIDTH + CELL_PADDING + DEFAULT_TITLE_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
      intHY = intTY + CELL_PADDING + DEFAULT_HEADERS_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
      
      bolViewable = false;
      while (!bolViewable) {
         intVY = intHY;
         for (int i=cintSY;i<cintRowCount;i++) {
            intVY = intVY + CELL_PADDING + DEFAULT_VALUES_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
            if (intVY > intPH - 18) {
               intVY = intPH - 18 - 1;
               break;
            }
            if (i == cintThisY) {
               bolViewable = true;
            }
         }
         if (!bolViewable) {
            if (cintSY > cintThisY) {
               cintSY--;
               if (cintSY <= 0) {
                  cintSY = 0;
                  bolViewable = true;
               }
            } else {
               cintSY++;
               if (cintSY >= cintRowCount) {
                  cintSY = cintRowCount - 1;
                  bolViewable = true;
               }
            }
         }
      }
      
      bolViewable = false;
      while (!bolViewable) {
         intVY = intVY + 1;
         intVX = OFFSET + BORDER_LINE_WIDTH;
         for (int j=cintSX;j<cintColumnCount;j++) {
            intVX = intVX + CELL_PADDING + cintColumnWidths[j] + CELL_PADDING + BORDER_LINE_WIDTH;
            if (intVX > intPW) {
               intVX = intPW - 1;
               break;
            }
            if (j == cintThisX) {
               bolViewable = true;
            }
         }
         if (!bolViewable) {
            if (cintSX > cintThisX) {
               cintSX--;
               if (cintSX <= 0) {
                  cintSX = 0;
                  bolViewable = true;
               }
            } else {
               cintSX++;
               if (cintSX >= cintColumnCount) {
                  cintSX = cintColumnCount - 1;
                  bolViewable = true;
               }
            }
         }
      }
      intVX = intVX + 1;
      
      // canvas background
      intFX = OFFSET;
      intFY = OFFSET;
      intFW = intPW;
      intFH = intPH;
      g.setColor(COLOR_CANVAS);
      g.fillRect(intFX, intFY, intFW, intFH);
      
      // title background
      intFX = OFFSET;
      intFY = OFFSET;
      intFW = intPW;
      intFH = intHY;
      g.setColor(COLOR_HEAD_BACKGROUND);
      g.fillRect(intFX, intFY, intFW, intFH);

      // table background
      intFX = OFFSET;
      intFY = intHY;
      intFW = intPW;
      intFH = intPH - 18;
      g.setColor(COLOR_BACKGROUND);
      g.fillRect(intFX, intFY, intFW, intFH);
      
      // draw title
      g.setColor(COLOR_HEAD_FOREGROUND);
      g.setFont(DEFAULT_TITLE_FONT);
      intX = OFFSET + BORDER_LINE_WIDTH + CELL_PADDING;
      intY = OFFSET + BORDER_LINE_WIDTH + CELL_PADDING;
      g.drawString(cstrTitle, intX, intY, Graphics.TOP|Graphics.LEFT);

      // draw headers
      g.setColor(COLOR_HEAD_FOREGROUND);
      g.setFont(DEFAULT_HEADERS_FONT);  
      intX = OFFSET + BORDER_LINE_WIDTH;
      intY = intTY + CELL_PADDING;
      for (int j=cintSX;j<cintColumnCount;j++) {
         intX = intX + CELL_PADDING + 1;
         if (cstrColumnNames[j] != null) {
            g.drawString(cstrColumnNames[j],intX, intY, Graphics.TOP|Graphics.LEFT);
         }
         intX = intX + cintColumnWidths[j] + CELL_PADDING + BORDER_LINE_WIDTH;
         if (intX > intVX) {
            break;
         }
      }

      //  draw values
      g.setColor(COLOR_FOREGROUND);
      g.setFont(DEFAULT_VALUES_FONT);
      intY = intHY;
      for (int i=cintSY;i<cintRowCount;i++) {
         intY = intY + CELL_PADDING;
         intX = OFFSET + BORDER_LINE_WIDTH;
         for (int j=cintSX;j<cintColumnCount;j++) {
            intFX = intX;
            intFY = intY - 1;
            intFW = CELL_PADDING + cintColumnWidths[cintThisX] + CELL_PADDING;
            intFH = CELL_PADDING + DEFAULT_VALUES_FONT.getHeight() + 1;
            intX = intX + CELL_PADDING + 1;
            if (cstrCellValues[i][j] != null) {
               if (bolHasFocus && i == cintThisY && j == cintThisX) {
                  g.drawString(cstrCellValues[i][j], intX, intY, Graphics.TOP|Graphics.LEFT);
                  g.setColor(COLOR_HIGHLIGHTED_BACKGROUND);
                  g.setStrokeStyle(Graphics.SOLID);
                  g.drawRect(intFX, intFY, intFW, intFH);
                  g.drawRect(intFX+1, intFY+1, intFW-2, intFH-2);
                  g.setColor(COLOR_FOREGROUND);
               } else {
                  g.drawString(cstrCellValues[i][j], intX, intY, Graphics.TOP|Graphics.LEFT);
               }
            }
            intX = intX + cintColumnWidths[j] + CELL_PADDING + BORDER_LINE_WIDTH;
            if (intX > intVX) {
               break;
            }
         }
         intY = intY + DEFAULT_VALUES_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
         if (intY > intPH - intTH) {
            break;
        }
      }
      
      // trailer background
      intFX = OFFSET;
      intFY = intPH - 17;
      intFW = intPW;
      intFH = 18;
      g.setColor(COLOR_HEAD_BACKGROUND);
      g.fillRect(intFX, intFY, intFW, intFH);
      
      // draw trailer
      g.setColor(COLOR_BORDER);
      g.setColor(COLOR_HIGHLIGHTED_BORDER);
      if (cintThisY == 0) {
         g.setColor(COLOR_BORDER);
         g.fillTriangle(intFX+(intFW/2),intFY+2,intFX+(intFW/2)-6,intFY+8,intFX+(intFW/2)+5,intFY+8);
      } else {
         g.setColor(COLOR_HIGHLIGHTED_BORDER);
         g.fillTriangle(intFX+(intFW/2),intFY+2,intFX+(intFW/2)-6,intFY+8,intFX+(intFW/2)+5,intFY+8);
      }
      if (cintThisY == cintRowCount - 1) {
         g.setColor(COLOR_BORDER);
         g.fillTriangle(intFX+(intFW/2),intFY+intFH-2,intFX+(intFW/2)-5,intFY+intFH-8,intFX+(intFW/2)+6,intFY+intFH-8);
      } else {
         g.setColor(COLOR_HIGHLIGHTED_BORDER);
         g.fillTriangle(intFX+(intFW/2),intFY+intFH-2,intFX+(intFW/2)-5,intFY+intFH-8,intFX+(intFW/2)+6,intFY+intFH-8);
      }
      if (cintThisX == 0) {
         g.setColor(COLOR_BORDER);
         g.fillTriangle(intFX+2,intFY+(intFH/2),intFX+8,intFY+(intFH/2)-6,intFX+8,intFY+(intFH/2)+5);
      } else {
         g.setColor(COLOR_HIGHLIGHTED_BORDER);
         g.fillTriangle(intFX+2,intFY+(intFH/2),intFX+8,intFY+(intFH/2)-6,intFX+8,intFY+(intFH/2)+5);
      }
      if (cintThisX == cintColumnCount - 1) {
         g.setColor(COLOR_BORDER);
         g.fillTriangle(intFX+intFW-2,intFY+(intFH/2),intFX+intFW-8,intFY+(intFH/2)-5,intFX+intFW-8,intFY+(intFH/2)+6);
      } else {
         g.setColor(COLOR_HIGHLIGHTED_BORDER);
         g.fillTriangle(intFX+intFW-2,intFY+(intFH/2),intFX+intFW-8,intFY+(intFH/2)-5,intFX+intFW-8,intFY+(intFH/2)+6);
      }
      

      // draw borders
      g.setColor(COLOR_BORDER);
      g.setStrokeStyle(Graphics.SOLID);
      // outline
      intFX = OFFSET;
      intFY = OFFSET;
      intFW = intPW;
      intFH = intPH;
      g.drawRect(intFX, intFY, intFW, intFH);
      
      // internal borders
      g.setColor(COLOR_BORDER);
      g.setStrokeStyle(Graphics.SOLID);
      
      // vertical lines
      intBX1 = OFFSET + BORDER_LINE_WIDTH;
      intBY1 = intTY;
      intBX2 = OFFSET + BORDER_LINE_WIDTH;
      intBY2 = intVY - 1;
      for (int j=cintSX;j<cintColumnCount;j++) {
         intBX1 = intBX1 + CELL_PADDING + cintColumnWidths[j] + CELL_PADDING + BORDER_LINE_WIDTH;
         intBX2 = intBX1;
         if (intBX1 > intVX) {
            break;
         }
         g.drawLine(intBX1, intBY1, intBX2, intBY2);
      }
      
      // horizontal lines
      intBX1 = OFFSET;
      intBY1 = intTY;
      intBX2 = intPW;
      intBY2 = intTY;
      g.drawLine(intBX1, intBY1, intBX2, intBY2);
      intBY1 = intHY;
      intBY2 = intHY;
      g.drawLine(intBX1, intBY1, intBX2, intBY2);
      intBX1 = OFFSET;
      intBY1 = intHY;
      intBX2 = intVX - 1;
      intBY2 = intHY;
      for (int i=cintSY;i<cintRowCount;i++) {
         intBY1 = intBY1 + CELL_PADDING + DEFAULT_VALUES_FONT.getHeight() + CELL_PADDING + BORDER_LINE_WIDTH;
         intBY2 = intBY1;
         if (intBY1 > intPH - 18) {
            break;
         }
         g.drawLine(intBX1, intBY1, intBX2, intBY2);
      }
      intBX1 = OFFSET;
      intBY1 = intPH - 18;
      intBX2 = intPW;
      intBY2 = intPH - 18;
      g.drawLine(intBX1, intBY1, intBX2, intBY2);

      // restore color and stroke
      g.setColor(intSaveColor);
      g.setStrokeStyle(intSaveStrokeStyle);
      
   }

   /**
    * implementation of the abstract method - if the item size has changed, simply repaint the table
    * @param w
    * @param h
    */
   protected void sizeChanged(int w, int h) {
      if ((!bolPaintStart) && (w > 0) && (h > 0) && (w != cintSizeWidth) && (h != cintSizeHeight)) {
         cintSizeWidth = w;
         cintSizeHeight = h;
         repaint();
      }
   }

   /**
    * implementation of the abstract method
    */
   protected boolean traverse(int dir, int viewportWidth, int viewportHeight, int[] visRect_inout) {
      boolean bolReturn = false;
      boolean bolRepaint = false;
      if (bolHasFocus == false) {
         if (dir == Canvas.UP) {
            cintThisY = cintRowCount - 1;
         } else if (dir == Canvas.DOWN) {
            cintThisY = 0;
         } else if (dir == Canvas.RIGHT) {
            cintThisY = 0;
            cintThisX = 0;
         } else if (dir == Canvas.LEFT) {
            cintThisY = cintRowCount - 1;
            cintThisX = cintColumnCount - 1;
         }
         bolHasFocus = true;
         bolReturn = true;
         bolRepaint = true;
      } else {
         if (dir == Canvas.UP) {
            cintThisY--;
            if (cintThisY < 0) {
               cintThisY = 0;
            }
         } else if (dir == Canvas.DOWN) {
            cintThisY++;
            if (cintThisY >= cintRowCount) {
               cintThisY = cintRowCount - 1;
            }
         } else if (dir == Canvas.LEFT) {
            cintThisX--;
            if (cintThisX < 0) {
               cintThisX = 0;
            }
         } else if (dir == Canvas.RIGHT) {
            cintThisX++;
            if (cintThisX >= cintColumnCount) {
               cintThisX = cintColumnCount - 1;
            }
         }
         bolReturn = true;
         bolRepaint = true;
      }
      visRect_inout[0] = OFFSET;
      visRect_inout[1] = OFFSET;
      visRect_inout[2] = cintCellWidth;
      visRect_inout[3] = cintCellHeight;
      if (bolRepaint) {
         repaint();
      }
      return bolReturn;
   }

   /**
    * implementation of the abstract method
    */
   protected void traverseOut() {
      super.traverseOut();
      bolHasFocus = false;
      repaint();
   }

   /**
    * Table data has been changed (invalidate and repaint)
    */
   public void tableDataLoaded() {
      recalculateSize();
      repaint();
   }
   
   /**
    * Table data has been loaded
    */
   public void tableDataChanged() {
      recalculateSize();
      repaint();
   }
   
   /**
    * Recalculates the table sizing
    */
   private void recalculateSize() {
      for (int j=0;j<cintColumnCount;j++) {
         cintColumnWidths[j] = cintCellWidth;
      }
      for (int i=0;i<cintRowCount;i++) {
         for (int j=0;j<cintColumnCount;j++) {
            if (cstrCellValues[i][j] != null) {
               int intWidth = DEFAULT_VALUES_FONT.stringWidth(cstrCellValues[i][j]);
               if (intWidth > cintColumnWidths[j]) {
                  cintColumnWidths[j] = intWidth;
               }
            }
         }
      }
      for (int j=0;j<cintColumnCount;j++) {
         if (cstrColumnNames[j] != null) {
            int intWidth = DEFAULT_HEADERS_FONT.stringWidth(cstrColumnNames[j]);
            if (intWidth > cintColumnWidths[j]) {
               cintColumnWidths[j] = intWidth;
            }
         }
      }
      cintTableWidth = BORDER_LINE_WIDTH;
      for (int i=0;i<cintColumnWidths.length;i++) {
         cintTableWidth += CELL_PADDING;
         cintTableWidth += cintColumnWidths[i];
         cintTableWidth += CELL_PADDING;
         cintTableWidth += BORDER_LINE_WIDTH;
      }
      cintTableWidth += BORDER_LINE_WIDTH;
      invalidate();
   }

}
