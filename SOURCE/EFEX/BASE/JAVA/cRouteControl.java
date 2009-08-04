/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cRouteControl
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.*;
import javax.microedition.lcdui.*;
import org.netbeans.microedition.lcdui.*;
import org.netbeans.microedition.lcdui.laf.ColorSchema;

/**
 * This class implements the Efex application route control.
 */
public class cRouteControl implements CommandListener, ItemCommandListener {
   
   //
   // Private class declarations
   //
   private cApplication cobjApplication;
   private Display cobjDisplay;
   private List cobjMenu;
   private List cobjOpenDisplay;
   private Form cobjDeleteDisplay;
   private Form cobjSearchDisplay;
   private List cobjSelectDisplay;
   private Form cobjDownloadDisplay;
   private Form cobjStockDisplay;
   private cTableItem cobjStockTable;
   private Form cobjStockEdit;
   private Form cobjDisplayDisplay;
   private cTableItem cobjDisplayTable;
   private Form cobjDisplayEdit;
   private Form cobjActivityDisplay;
   private cTableItem cobjActivityTable;
   private Form cobjActivityEdit;
   private Form cobjOrderDisplay;
   private cTableItem cobjOrderTable;
   private Form cobjOrderLineEdit;
   private Form cobjOrderLineDelete;
   private Form cobjOrderClearDisplay;
   private Form cobjOrderSearchDisplay;
   private List cobjOrderSelectDisplay;
   private Form cobjOrderSubmitDisplay;
   private Form cobjCloseDisplay;
   private Command cobjCommandSelect;
   private Command cobjCommandSearch;
   private Command cobjCommandDelete;
   private Command cobjCommandClear;
   private Command cobjCommandBack;
   private Command cobjCommandNext;
   private Command cobjCommandSave;
   private Command cobjCommandEdit;
   private Command cobjCommandCancel;
   private Command cobjCommandAccept;
   private Image cobjSelectOn;
   private Image cobjSelectOff;
   private Font cobjFontSmall;
   private cResourceBundle cobjResourceBundle;
   private ColorSchema cobjTableColorSchema;
   private cApplication.cNumberFormatter cobjFormatter;
   private cMobileStore cobjMobileStore;
   private cControlStore cobjControlStore;
   private cRouteStore cobjRouteStore;
   private cCustomerStore cobjCustomerStore;
   private cUomStore cobjUomStore;
   private java.util.Vector cobjRouteList;
   private java.util.Vector cobjCustomerList;
   private java.util.Vector cobjWorkList;
   private int[] cintStockPointers;
   private int[] cintOrderPointers;
   private int[] cintOrderSelectPointers;
   private int cintOrderLineCount;
   
   /**
    * Constructs a new instance
    */
   public cRouteControl(cApplication objApplication) {
      cobjApplication = objApplication;
      cobjDisplay = cobjApplication.getDisplay();
      cobjMenu = cobjApplication.getMenu();
      cobjSelectOn = cobjApplication.getImageSelectOn();
      cobjSelectOff = cobjApplication.getImageSelectOff();
      cobjFontSmall = cobjApplication.getFontSmall();
      cobjResourceBundle = cobjApplication.getResourceBundle();
      cobjTableColorSchema = cobjApplication.getTableColorSchema();
      cobjFormatter = cobjApplication.getFormatter();
      cobjMobileStore = cobjApplication.getMobileStore();
      cobjControlStore = cobjApplication.getControlStore();
      cobjRouteStore = cobjApplication.getRouteStore();
      cobjCustomerStore = cobjApplication.getCustomerStore();
      cobjUomStore = cobjApplication.getUomStore();
      cobjCommandSelect = new Command(cobjResourceBundle.getResource("CMDSELECT"), Command.ITEM, 0);
      cobjCommandSearch = new Command(cobjResourceBundle.getResource("CMDSEARCH"), Command.SCREEN, 0);
      cobjCommandDelete = new Command(cobjResourceBundle.getResource("CMDDELETE"), Command.ITEM, 0);
      cobjCommandClear = new Command(cobjResourceBundle.getResource("CMDCLEAR"), Command.SCREEN, 0);
      cobjCommandBack = new Command(cobjResourceBundle.getResource("CMDBACK"), Command.BACK, 0);
      cobjCommandNext = new Command(cobjResourceBundle.getResource("CMDNEXT"), Command.SCREEN, 0);
      cobjCommandSave = new Command(cobjResourceBundle.getResource("CMDSAVE"), Command.SCREEN, 0);
      cobjCommandEdit = new Command(cobjResourceBundle.getResource("CMDEDIT"), Command.ITEM, 0);
      cobjCommandCancel = new Command(cobjResourceBundle.getResource("CMDCANCEL"), Command.CANCEL, 0);
      cobjCommandAccept = new Command(cobjResourceBundle.getResource("CMDACCEPT"), Command.SCREEN, 0);
   }
   
   /**
    * Override the CommandListener abstract methods
    */
   public void commandAction(Command objCommand, Displayable objDisplayable) {                                               
      if (objDisplayable == cobjOpenDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjMenu);  
         } else if (objCommand == cobjCommandSelect || objCommand == List.SELECT_COMMAND) {                                         
            actionOpenDisplay("*SELECT");
         } else if (objCommand == cobjCommandSearch) {                                         
            actionOpenDisplay("*SEARCH");
         } else if (objCommand == cobjCommandDelete) {                                         
            actionOpenDisplay("*DELETE");
         }
      } else if (objDisplayable == cobjSearchDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjOpenDisplay);  
         } else if (objCommand == cobjCommandSearch) {
            actionSearchDisplay();
         }
      } else if (objDisplayable == cobjDeleteDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjOpenDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionDeleteDisplay();
         }
      } else if (objDisplayable == cobjSelectDisplay) {
         if (objCommand == cobjCommandBack) {
            loadSearchDisplay();  
         } else if (objCommand == cobjCommandSelect || objCommand == List.SELECT_COMMAND) {
            actionSelectDisplay();
         }
      } else if (objDisplayable == cobjDownloadDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjSelectDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionDownloadDisplay();
         }
      } else if (objDisplayable == cobjStockDisplay) {
         if (objCommand == cobjCommandBack) {
            showConfirmation(cobjStockDisplay);
         } else if (objCommand == cobjCommandNext) {
            loadDisplayDisplay();
         }
      } else if (objDisplayable == cobjStockEdit) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjStockDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            updateStockDisplay();
         }
      } else if (objDisplayable == cobjDisplayDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjStockDisplay); 
         } else if (objCommand == cobjCommandNext) {
            loadActivityDisplay();
         }                                                  
      } else if (objDisplayable == cobjDisplayEdit) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjDisplayDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            updateDisplayDisplay();
         }
      } else if (objDisplayable == cobjActivityDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjDisplayDisplay);
         } else if (objCommand == cobjCommandNext) {
            loadOrderDisplay();
         }                                                  
      } else if (objDisplayable == cobjActivityEdit) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjActivityDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            updateActivityDisplay();
         }
      } else if (objDisplayable == cobjOrderDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjActivityDisplay);
         } else if (objCommand == cobjCommandNext) {
            if (cintOrderLineCount == 0) {
               loadCloseDisplay();
            } else {
               loadOrderSubmitDisplay();
            }
         } else if (objCommand == cobjCommandSearch) {
            loadOrderSearchDisplay();
         } else if (objCommand == cobjCommandClear) {
            loadOrderClearDisplay();
         }
      } else if (objDisplayable == cobjOrderLineEdit) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjOrderDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionOrderLineEditDisplay();
         }
      } else if (objDisplayable == cobjOrderLineDelete) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjOrderDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionOrderLineDeleteDisplay();
         }
      } else if (objDisplayable == cobjOrderClearDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjOrderDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionOrderClearDisplay();
         }
      } else if (objDisplayable == cobjOrderSearchDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjOrderDisplay);  
         } else if (objCommand == cobjCommandSearch) {
            actionOrderSearchDisplay();
         }
      } else if (objDisplayable == cobjOrderSelectDisplay) {
         if (objCommand == cobjCommandBack) {
            loadOrderSearchDisplay();
         } else if (objCommand == cobjCommandSelect) {
            actionOrderSelectDisplay();
         }
      } else if (objDisplayable == cobjOrderSubmitDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjOrderDisplay);
         } else if (objCommand == cobjCommandNext) {
            actionOrderSubmitDisplay();
         }
      } else if (objDisplayable == cobjCloseDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjOrderDisplay);  
         } else if (objCommand == cobjCommandSave) {
            actionCloseDisplay();
         }
      }
      
   }
   
   /**
    * Override the ItemCommandListener abstract methods
    */
   public void commandAction(Command objCommand, Item objItem) {
      if (objItem == cobjStockTable) {
         if (objCommand == cobjCommandEdit || objCommand == List.SELECT_COMMAND) {
            editStockDisplay();
         }
      } else if (objItem == cobjDisplayTable) {
         if (objCommand == cobjCommandEdit || objCommand == List.SELECT_COMMAND) {
            editDisplayDisplay();
         }
      } else if (objItem == cobjActivityTable) {
         if (objCommand == cobjCommandEdit || objCommand == List.SELECT_COMMAND) {
            editActivityDisplay();
         }
      } else if (objItem == cobjOrderTable) {
         if (objCommand == cobjCommandEdit || objCommand == List.SELECT_COMMAND) {
            loadOrderLineEditDisplay();
         } else if (objCommand == cobjCommandDelete) {
            loadOrderLineDeleteDisplay();
         }
      }
   }
   
   /**
    * Sets the resource bundle
    */
   public void setResourceBundle() {
      cobjResourceBundle = cobjApplication.getResourceBundle();
   }
   
   /**
    * Show the confirmation alert
    */
   protected void showConfirmation(Displayable objParent) {
      final Displayable objParentDisplay = objParent;
      Alert objAlert = new Alert(null, cobjResourceBundle.getResource("CONCONFIRMCANCEL"), null, AlertType.CONFIRMATION);
      objAlert.addCommand(new Command(cobjResourceBundle.getResource("CMDYES"), Command.OK, 1));
      objAlert.addCommand(new Command(cobjResourceBundle.getResource("CMDNO"), Command.CANCEL, 1));
      objAlert.setCommandListener(new CommandListener() {
         public void commandAction(Command objCommand, Displayable objDisplayable) {
            if (objCommand.getCommandType() == Command.OK) {
               loadOpenDisplay();
            }
            if (objCommand.getCommandType() == Command.CANCEL) {
               cobjDisplay.setCurrent(objParentDisplay);
            }
         }
      });
      cobjDisplay.setCurrent(objAlert, objParentDisplay);
   }
   
   /**
    * Loads the open display
    */
   public void loadOpenDisplay() {
      
      //
      // Control must be loaded
      //
      if (cobjControlStore.getMobileStatus() == null) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTELSTM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenu);
         return;
      }
      
      //
      // Create and clear the open display
      //
      cobjOpenDisplay = new List(cobjResourceBundle.getResource("RTELSTHDR"), List.IMPLICIT);
      cobjOpenDisplay.addCommand(cobjCommandBack);
      cobjOpenDisplay.addCommand(cobjCommandSelect);
      cobjOpenDisplay.addCommand(cobjCommandSearch);
      cobjOpenDisplay.addCommand(cobjCommandDelete);
      cobjOpenDisplay.setCommandListener(this);
      cobjOpenDisplay.setFitPolicy(Choice.TEXT_WRAP_ON);
      cobjOpenDisplay.deleteAll();
      
      //
      // Load the open display
      //
      try {
         cobjRouteStore.clearFilters();
         cobjRouteList = cobjRouteStore.getRouteList();
         int intIndex = 0;
         for (int i=0; i<cobjRouteList.size(); i++) {
            if (((cRouteList)cobjRouteList.elementAt(i)).getStatus().equals("1")) {
               intIndex = cobjOpenDisplay.append("(" + ((cRouteList)cobjRouteList.elementAt(i)).getCustomerCode() + ") " + ((cRouteList)cobjRouteList.elementAt(i)).getCustomerName(), cobjSelectOn);
            } else {
               intIndex = cobjOpenDisplay.append("(" + ((cRouteList)cobjRouteList.elementAt(i)).getCustomerCode() + ") " + ((cRouteList)cobjRouteList.elementAt(i)).getCustomerName(), cobjSelectOff);
            }
            cobjOpenDisplay.setSelectedIndex(intIndex, false);
         }
         for (int i=0; i<cobjOpenDisplay.size(); i++) {
            cobjOpenDisplay.setFont(i, cobjFontSmall);
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenu);
         return;
      }
      
      //
      // Show the customer select display
      //
      cobjDisplay.setCurrent(cobjOpenDisplay);
   
   }
   
   /**
    * Actions the open display
    */
   public void actionOpenDisplay(String strAction) {
      
      //
      // Customer must be selected
      //
      if (strAction.equals("*SELECT") || strAction.equals("*DELETE")) {
         if (cobjOpenDisplay.getSelectedIndex() < 0) {
            Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTELSTM02"), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
            return;
         }
      }
      
      //
      // Perform the required action on a separate thread
      //
      if (strAction.equals("*SELECT")) {
         cobjDisplay.setCurrent(new cOpenAction("*SELECT"));
      } else if (strAction.equals("*SEARCH")) {
         loadSearchDisplay();
      } else if (strAction.equals("*DELETE")) {
         cobjDisplay.setCurrent(new cOpenAction("*DELETE"));
      }
      
   }
   
   /**
    * Loads the delete display
    */
   public void loadDeleteDisplay() {
      
      //
      // Create and clear the delete display
      //
      if (cobjDeleteDisplay == null) {
         cobjDeleteDisplay = new Form(cobjResourceBundle.getResource("RTEDLTHDR"));
         cobjDeleteDisplay.addCommand(cobjCommandCancel);
         cobjDeleteDisplay.addCommand(cobjCommandAccept);
         cobjDeleteDisplay.setCommandListener(this);
      }
      cobjDeleteDisplay.deleteAll();
      cobjDeleteDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEDLT001"), cobjRouteStore.getCallCustomerCode()));
      cobjDeleteDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEDLT002"), cobjRouteStore.getCallCustomerName()));
      for (int i=0; i<cobjDeleteDisplay.size(); i++) {
         ((Item)cobjDeleteDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the customer delete display
      //
      cobjDisplay.setCurrent(cobjDeleteDisplay);
   
   }
   
   /**
    * Actions the delete display
    */
   public void actionDeleteDisplay() {
      
      //
      // Customer must be a non-route customer
      //
      if (!cobjRouteStore.getCallCustomerType().toUpperCase().equals("*NONROUTE")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTEDLTM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjDeleteDisplay);
         return;
      }

      //
      // Perform the delete action on a separate thread
      //
      cobjDisplay.setCurrent(new cDeleteAction());
      
   }
   
   /**
    * Loads the search display
    */
   public void loadSearchDisplay() {
      
      //
      // Create and clear the search display
      //
      if (cobjSearchDisplay == null) {
         cobjSearchDisplay = new Form(cobjResourceBundle.getResource("RTESCHHDR"));
         cobjSearchDisplay.addCommand(cobjCommandBack);
         cobjSearchDisplay.addCommand(cobjCommandSearch);
         cobjSearchDisplay.setCommandListener(this);
      }
      cobjSearchDisplay.deleteAll();
      cobjSearchDisplay.append(new TextField(cobjResourceBundle.getResource("RTESCH001"), "", 20, TextField.NUMERIC));
      cobjSearchDisplay.append(new TextField(cobjResourceBundle.getResource("RTESCH002"), "", 50, TextField.ANY));
      for (int i=0; i<cobjSearchDisplay.size(); i++) {
         ((Item)cobjSearchDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the customer search display
      //
      cobjDisplay.setCurrent(cobjSearchDisplay);
   
   }
   
   /**
    * Actions the search display
    */
   public void actionSearchDisplay() {

      //
      // Load the select display
      //
      loadSelectDisplay();
      
   }
   
   /**
    * Loads the select display
    */
   public void loadSelectDisplay() {
      
      //
      // Create and clear the select display
      //
      cobjSelectDisplay = new List(cobjResourceBundle.getResource("RTESLTHDR"), List.IMPLICIT);
      cobjSelectDisplay.addCommand(cobjCommandBack);
      cobjSelectDisplay.addCommand(cobjCommandSelect);
      cobjSelectDisplay.setCommandListener(this);
      cobjSelectDisplay.setFitPolicy(Choice.TEXT_WRAP_ON);
      cobjSelectDisplay.deleteAll();
      
      //
      // Load the select display
      // **note** Only existing non-route customers are loaded
      //
      try {
         cobjWorkList = new java.util.Vector();
         cobjCustomerStore.clearFilters();
         if (cobjSearchDisplay != null) {
            if (((TextField)cobjSearchDisplay.get(0)).getString() != null &&
                !((TextField)cobjSearchDisplay.get(0)).getString().equals("")) {
               cobjCustomerStore.addCustomerCodeFilter(((TextField)cobjSearchDisplay.get(0)).getString());
            }
            if (((TextField)cobjSearchDisplay.get(1)).getString() != null &&
                !((TextField)cobjSearchDisplay.get(1)).getString().equals("")) {
               cobjCustomerStore.addCustomerNameFilter(((TextField)cobjSearchDisplay.get(1)).getString());
            }
         }
         cobjCustomerList = cobjCustomerStore.getCustomerList();
         int intIndex = 0;
         boolean bolFound = false;
         for (int i=0; i<cobjCustomerList.size(); i++) {
            if (((cCustomerList)cobjCustomerList.elementAt(i)).getDataType().toUpperCase().equals("*OLD")) {
               bolFound = false;
               for (int j=0; j<cobjRouteList.size(); j++) {
                  if (((cCustomerList)cobjCustomerList.elementAt(i)).getCustomerId().equals(((cRouteList)cobjRouteList.elementAt(j)).getCustomerId())) {
                     bolFound = true;
                     break;
                  }
               }
               if (!bolFound) {
                  cobjWorkList.addElement(cobjCustomerList.elementAt(i));
               }
            }
         }
         for (int i=0; i<cobjWorkList.size(); i++) {
            intIndex = cobjSelectDisplay.append("(" + ((cCustomerList)cobjWorkList.elementAt(i)).getCode() +") " +((cCustomerList)cobjWorkList.elementAt(i)).getName(), null);
            cobjSelectDisplay.setSelectedIndex(intIndex, false);
         }
         for (int i=0; i<cobjSelectDisplay.size(); i++) {
            cobjSelectDisplay.setFont(i, cobjFontSmall);
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
         return;
      }
      
      //
      // Show the customer select display
      //
      cobjDisplay.setCurrent(cobjSelectDisplay);
   
   }
   
   /**
    * Actions the select display
    */
   public void actionSelectDisplay() {
      
      //
      // Customer must be selected when required
      //
      if (cobjSelectDisplay.getSelectedIndex() < 0) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTESLTM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjSelectDisplay);
         return;
      }
          
      //
      // Load the download display
      //
      loadDownloadDisplay();
      
   }
   
   /**
    * Loads the download display
    */
   public void loadDownloadDisplay() {
      
      //
      // Create and clear the download display
      //
      if (cobjDownloadDisplay == null) {
         cobjDownloadDisplay = new Form(cobjResourceBundle.getResource("RTEDWNHDR"));
         cobjDownloadDisplay.addCommand(cobjCommandCancel);
         cobjDownloadDisplay.addCommand(cobjCommandAccept);
         cobjDownloadDisplay.setCommandListener(this);
      }
      cobjDownloadDisplay.deleteAll();
      cobjDownloadDisplay.append(new TextField(cobjResourceBundle.getResource("RTEDWN001"), "", 10, TextField.NUMERIC));
      cobjDownloadDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEDWN002"), "(" + ((cCustomerList)cobjWorkList.elementAt(cobjSelectDisplay.getSelectedIndex())).getCode() + ") " + ((cCustomerList)cobjWorkList.elementAt(cobjSelectDisplay.getSelectedIndex())).getName()));
      cobjDownloadDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEDWN003"), cobjResourceBundle.getResource("RTEDWN004")));
      for (int i=0; i<cobjDownloadDisplay.size(); i++) {
         ((Item)cobjDownloadDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the download display
      //
      cobjDisplay.setCurrent(cobjDownloadDisplay);
   
   }
   
   /**
    * Actions the download display
    */
   public void actionDownloadDisplay() {

      //
      // Perform the download action on a separate thread
      //
      cobjDisplay.setCurrent(new cSelectAction(cobjMobileStore.getUserName(),((TextField)cobjDownloadDisplay.get(0)).getString(),((cCustomerList)cobjCustomerList.elementAt(cobjSelectDisplay.getSelectedIndex())).getCustomerId()));
      
   }
   
   /**
    * Loads the stock display
    */
   public void loadStockDisplay() {
      
      //
      // Create and load the stock display
      //
      if (cobjStockDisplay == null) {
         cobjStockDisplay = new Form(cobjResourceBundle.getResource("RTEDISHDR"));
         cobjStockDisplay.addCommand(cobjCommandBack);
         cobjStockDisplay.addCommand(cobjCommandNext);
         cobjStockDisplay.setCommandListener(this);
         cintStockPointers = cobjRouteStore.getStockPointers();
         if (cobjRouteStore.getCallMarket().toUpperCase().equals("ICSF")) {
            cobjStockTable = new cTableItem(cobjDisplay, cobjRouteStore.getCallCustomerName(),new String[] {cobjResourceBundle.getResource("RTEDIS001"),cobjResourceBundle.getResource("RTEDIS003")}, cintStockPointers.length+1);
         } else {
            cobjStockTable = new cTableItem(cobjDisplay, cobjRouteStore.getCallCustomerName(),new String[] {cobjResourceBundle.getResource("RTEDIS002"),cobjResourceBundle.getResource("RTEDIS003")}, cintStockPointers.length+1);
         }
         cRouteStock objRouteStock = null;
         for (int i=0; i<cintStockPointers.length; i++) {
            objRouteStock = (cRouteStock)cobjRouteStore.getCallStocks().elementAt(cintStockPointers[i]);
            if (cobjRouteStore.getCallMarket().toUpperCase().equals("ICSF")) {
               if (objRouteStock.getStockQty().equals("1")) {
                  cobjStockTable.setValue(0, i, "Y");
               } else {
                  cobjStockTable.setValue(0, i, "");
               }
            } else {
               cobjStockTable.setValue(0, i, cobjFormatter.formatNumber(objRouteStock.getStockQty(),2,false));
            }
            cobjStockTable.setValue(1, i, objRouteStock.getName());
         }
         cobjStockTable.setValue(0, cintStockPointers.length, cobjFormatter.formatNumber(cobjRouteStore.getCallStockDistributionCount(),0,false));
         cobjStockTable.setValue(1, cintStockPointers.length, cobjResourceBundle.getResource("RTEDIS004"));
         objRouteStock = null;
         cobjStockTable.tableDataLoaded();
         cobjStockTable.setDefaultCommand(cobjCommandEdit);
         cobjStockTable.setItemCommandListener(this);
         cobjStockTable.setLayout(TableItem.LAYOUT_NEWLINE_BEFORE|TableItem.LAYOUT_CENTER);
         cobjStockDisplay.append(cobjStockTable);
      }
       
      //
      // Show the customer stock display
      //
      cobjDisplay.setCurrent(cobjStockDisplay);
   
   }
   
   /**
    * Edits the stock display
    */
   public void editStockDisplay() {
      
      //
      // Create and load the stock display
      //
      if (cobjStockEdit == null) {
         cobjStockEdit = new Form(cobjResourceBundle.getResource("RTEDIS005"));
         cobjStockEdit.addCommand(cobjCommandCancel);
         cobjStockEdit.addCommand(cobjCommandAccept);
         cobjStockEdit.setCommandListener(this);
      }
      cobjStockEdit.deleteAll();
      cobjStockEdit.append(new StringItem(cobjResourceBundle.getResource("RTEDIS006"), cobjRouteStore.getCallCustomerName()));
      if (cobjStockTable.getSelectedCellRow() == cintStockPointers.length) {
         cobjStockEdit.append(new StringItem(cobjResourceBundle.getResource("RTEDIS007"), (String)cobjStockTable.getValue(1, cobjStockTable.getSelectedCellRow())));
         cobjStockEdit.append(new TextField(cobjResourceBundle.getResource("RTEDIS008"), "", 3, TextField.NUMERIC));
      } else {
         cobjStockEdit.append(new StringItem(cobjResourceBundle.getResource("RTEDIS009"), (String)cobjStockTable.getValue(1, cobjStockTable.getSelectedCellRow())));
         if (cobjRouteStore.getCallMarket().toUpperCase().equals("ICSF")) {
            cobjStockEdit.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEDIS010"), ChoiceGroup.POPUP, new String[] {cobjResourceBundle.getResource("CONYES"),cobjResourceBundle.getResource("CONNO")}, null));
            if (((String)cobjStockTable.getValue(0, cobjStockTable.getSelectedCellRow())).toUpperCase().equals("Y")) {
               ((ChoiceGroup)cobjStockEdit.get(2)).setSelectedIndex(0, true);
            } else {
               ((ChoiceGroup)cobjStockEdit.get(2)).setSelectedIndex(1, true);
            }
         } else {
            cobjStockEdit.append(new TextField(cobjResourceBundle.getResource("RTEDIS011"), "", 6, TextField.DECIMAL));
         }
      }
      for (int i=0; i<cobjStockEdit.size(); i++) {
         ((Item)cobjStockEdit.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }

      //
      // Show the stock edit
      //
      cobjDisplay.setCurrent(cobjStockEdit);
      cobjDisplay.setCurrentItem((Item)cobjStockEdit.get(2));
   
   }
   
   /**
    * Updates the stock display
    */
   public void updateStockDisplay() {

      //
      // Update the stock data model
      //
      int intDataRow = cobjStockTable.getSelectedCellRow();
      if (cobjStockTable.getSelectedCellRow() == cintStockPointers.length) {
         cobjRouteStore.setCallStockDistributionCount(cobjFormatter.formatNumber(cobjFormatter.getNumber(((TextField)cobjStockEdit.get(2)).getString()),0,false));
         cobjStockTable.setValue(0, intDataRow, cobjFormatter.formatNumber(cobjFormatter.getNumber(((TextField)cobjStockEdit.get(2)).getString()),0,false));
      } else {
         cRouteStock objRouteStock = (cRouteStock)cobjRouteStore.getCallStocks().elementAt(cintStockPointers[intDataRow]);
         if (cobjRouteStore.getCallMarket().toUpperCase().equals("ICSF")) {
            if (((ChoiceGroup)cobjStockEdit.get(2)).getSelectedIndex() == 0) {
               objRouteStock.setStockQty("1");
               cobjStockTable.setValue(0, intDataRow, "Y");
            } else {
               objRouteStock.setStockQty("0");
               cobjStockTable.setValue(0, intDataRow, "");
            }
         } else {
            objRouteStock.setStockQty(cobjFormatter.formatNumber(cobjFormatter.getNumber(((TextField)cobjStockEdit.get(2)).getString()),2,false));
            cobjStockTable.setValue(0, intDataRow, cobjFormatter.formatNumber(cobjFormatter.getNumber(((TextField)cobjStockEdit.get(2)).getString()),2,false));
         }
      }
      cobjStockTable.tableDataChanged();
      loadStockDisplay();
      
   }
   
   /**
    * Loads the display display
    */
   public void loadDisplayDisplay() {
      
      //
      // Create and load the display display
      //
      if (cobjDisplayDisplay == null) {
         cobjDisplayDisplay = new Form(cobjResourceBundle.getResource("RTEDSPHDR"));
         cobjDisplayDisplay.addCommand(cobjCommandBack);
         cobjDisplayDisplay.addCommand(cobjCommandNext);
         cobjDisplayDisplay.setCommandListener(this);
         cobjDisplayTable = new cTableItem(cobjDisplay, cobjRouteStore.getCallCustomerName(), new String[] {cobjResourceBundle.getResource("RTEDSP001"),cobjResourceBundle.getResource("RTEDSP002")}, cobjRouteStore.getCallDisplays().size()+1);
         cRouteDisplay objRouteDisplay = null;
         for (int i=0; i<cobjRouteStore.getCallDisplays().size(); i++) {
            objRouteDisplay = (cRouteDisplay)cobjRouteStore.getCallDisplays().elementAt(i);
            if (objRouteDisplay.getFlag().equals("1")) {
               cobjDisplayTable.setValue(0, i, "Y");
            } else {
               cobjDisplayTable.setValue(0, i, "");
            }
            cobjDisplayTable.setValue(1, i, objRouteDisplay.getName());
         }
         objRouteDisplay = null;
         cobjDisplayTable.setValue(0, cobjRouteStore.getCallDisplays().size(), "");
         cobjDisplayTable.setValue(1, cobjRouteStore.getCallDisplays().size(), cobjResourceBundle.getResource("CONNODATA"));
         cobjDisplayTable.tableDataLoaded();
         cobjDisplayTable.setDefaultCommand(cobjCommandEdit);
         cobjDisplayTable.setItemCommandListener(this);
         cobjDisplayTable.setLayout(TableItem.LAYOUT_NEWLINE_BEFORE|TableItem.LAYOUT_CENTER);
         cobjDisplayDisplay.append(cobjDisplayTable);
      }

      //
      // Show the display display
      //
      cobjDisplay.setCurrent(cobjDisplayDisplay);

   }
   
   /**
    * Edits the display display
    */
   public void editDisplayDisplay() {
      
      //
      // Cancel the edit when last row
      //
      if (cobjDisplayTable.getSelectedCellRow() == cobjRouteStore.getCallDisplays().size()) {
         return;
      }
      
      //
      // Flip the display selection when selected column
      //
      int intDataRow = cobjDisplayTable.getSelectedCellRow();
      if (cobjDisplayTable.getSelectedCellColumn() == 0) {
         cRouteDisplay objRouteDisplay = (cRouteDisplay)cobjRouteStore.getCallDisplays().elementAt(intDataRow);
         if (((String)cobjDisplayTable.getValue(0, intDataRow)).toUpperCase().equals("Y")) {
            objRouteDisplay.setFlag("0");
            cobjDisplayTable.setValue(0, intDataRow, "");
         } else {
            objRouteDisplay.setFlag("1");
            cobjDisplayTable.setValue(0, intDataRow, "Y");
         }
         objRouteDisplay = null;
         cobjDisplayTable.tableDataChanged();
         cobjDisplay.setCurrentItem(cobjDisplayTable);
         return;
      }
      
      //
      // Create and load the display display
      //
      if (cobjDisplayEdit == null) {
         cobjDisplayEdit = new Form(cobjResourceBundle.getResource("RTEDSP003"));
         cobjDisplayEdit.addCommand(cobjCommandCancel);
         cobjDisplayEdit.addCommand(cobjCommandAccept);
         cobjDisplayEdit.setCommandListener(this);
      }
      cobjDisplayEdit.deleteAll();
      cobjDisplayEdit.append(new StringItem(cobjResourceBundle.getResource("RTEDSP004"), cobjRouteStore.getCallCustomerName()));
      cobjDisplayEdit.append(new StringItem(cobjResourceBundle.getResource("RTEDSP005"), (String)cobjDisplayTable.getValue(1, intDataRow)));
      cobjDisplayEdit.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEDSP006"), ChoiceGroup.POPUP, new String[] {cobjResourceBundle.getResource("CONYES"),cobjResourceBundle.getResource("CONNO")}, null));
      if (((String)cobjDisplayTable.getValue(0, intDataRow)).toUpperCase().equals("Y")) {
         ((ChoiceGroup)cobjDisplayEdit.get(2)).setSelectedIndex(0, true);
      } else {
         ((ChoiceGroup)cobjDisplayEdit.get(2)).setSelectedIndex(1, true);
      }
      for (int i=0; i<cobjDisplayEdit.size(); i++) {
         ((Item)cobjDisplayEdit.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }

      //
      // Show the display edit
      //
      cobjDisplay.setCurrent(cobjDisplayEdit);
      cobjDisplay.setCurrentItem((Item)cobjDisplayEdit.get(2));
   
   }
   
   /**
    * Updates the display display
    */
   public void updateDisplayDisplay() {

      //
      // Update the display data model
      //
      int intDataRow = cobjDisplayTable.getSelectedCellRow();
      cRouteDisplay objRouteDisplay = (cRouteDisplay)cobjRouteStore.getCallDisplays().elementAt(intDataRow);
      if (((ChoiceGroup)cobjDisplayEdit.get(2)).getSelectedIndex() == 0) {
         objRouteDisplay.setFlag("1");
         cobjDisplayTable.setValue(0, intDataRow, "Y");
      } else {
         objRouteDisplay.setFlag("0");
         cobjDisplayTable.setValue(0, intDataRow, "");
      }
      objRouteDisplay = null;
      cobjDisplayTable.tableDataChanged();
      loadDisplayDisplay();

   }
   
   /**
    * Loads the activity display
    */
   public void loadActivityDisplay() {

      //
      // Create and load the activity display
      //
      if (cobjActivityDisplay == null) {
         cobjActivityDisplay = new Form(cobjResourceBundle.getResource("RTEACTHDR"));
         cobjActivityDisplay.addCommand(cobjCommandBack);
         cobjActivityDisplay.addCommand(cobjCommandNext);
         cobjActivityDisplay.setCommandListener(this);
         cobjActivityTable = new cTableItem(cobjDisplay, cobjRouteStore.getCallCustomerName(), new String[] {cobjResourceBundle.getResource("RTEACT001"),cobjResourceBundle.getResource("RTEACT002")}, cobjRouteStore.getCallActivities().size()+1);
         cRouteActivity objRouteActivity = null;
         for (int i=0; i<cobjRouteStore.getCallActivities().size(); i++) {
            objRouteActivity = (cRouteActivity)cobjRouteStore.getCallActivities().elementAt(i);
            if (objRouteActivity.getFlag().equals("1")) {
               cobjActivityTable.setValue(0, i, "Y");
            } else {
               cobjActivityTable.setValue(0, i, "");
            }
            cobjActivityTable.setValue(1, i, objRouteActivity.getName());
         }
         objRouteActivity = null;
         cobjActivityTable.setValue(0, cobjRouteStore.getCallActivities().size(), "");
         cobjActivityTable.setValue(1, cobjRouteStore.getCallActivities().size(), cobjResourceBundle.getResource("CONNODATA"));
         cobjActivityTable.tableDataLoaded();
         cobjActivityTable.setDefaultCommand(cobjCommandEdit);
         cobjActivityTable.setItemCommandListener(this);
         cobjActivityTable.setLayout(TableItem.LAYOUT_NEWLINE_BEFORE|TableItem.LAYOUT_CENTER);
         cobjActivityDisplay.append(cobjActivityTable);
      }
      
      //
      // Show the activity display
      //
      cobjDisplay.setCurrent(cobjActivityDisplay);
   
   }
   
   /**
    * Edits the activity display
    */
   public void editActivityDisplay() {
      
      //
      // Cancel the edit when last row
      //
      if (cobjActivityTable.getSelectedCellRow() == cobjRouteStore.getCallActivities().size()) {
         return;
      }
      
      //
      // Flip the activity selection when selected column
      //
      int intDataRow = cobjActivityTable.getSelectedCellRow();
      if (cobjActivityTable.getSelectedCellColumn() == 0) {
         cRouteActivity objRouteActivity = (cRouteActivity)cobjRouteStore.getCallActivities().elementAt(intDataRow);
         if (((String)cobjActivityTable.getValue(0, intDataRow)).toUpperCase().equals("Y")) {
            objRouteActivity.setFlag("0");
            cobjActivityTable.setValue(0, intDataRow, "");
         } else {
            objRouteActivity.setFlag("1");
            cobjActivityTable.setValue(0, intDataRow, "Y");
         }
         objRouteActivity = null;
         cobjActivityTable.tableDataChanged();
         cobjDisplay.setCurrentItem(cobjActivityTable);
         return;
      }
      
      //
      // Create and load the activity display
      //
      if (cobjActivityEdit == null) {
         cobjActivityEdit = new Form(cobjResourceBundle.getResource("RTEACT003"));
         cobjActivityEdit.addCommand(cobjCommandCancel);
         cobjActivityEdit.addCommand(cobjCommandAccept);
         cobjActivityEdit.setCommandListener(this);
      }
      cobjActivityEdit.deleteAll();
      cobjActivityEdit.append(new StringItem(cobjResourceBundle.getResource("RTEACT004"), cobjRouteStore.getCallCustomerName()));
      cobjActivityEdit.append(new StringItem(cobjResourceBundle.getResource("RTEACT005"), (String)cobjActivityTable.getValue(1, intDataRow)));
      cobjActivityEdit.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEACT006"), ChoiceGroup.POPUP, new String[] {cobjResourceBundle.getResource("CONYES"),cobjResourceBundle.getResource("CONNO")}, null));
      if (((String)cobjActivityTable.getValue(0, intDataRow)).toUpperCase().equals("Y")) {
         ((ChoiceGroup)cobjActivityEdit.get(2)).setSelectedIndex(0, true);
      } else {
         ((ChoiceGroup)cobjActivityEdit.get(2)).setSelectedIndex(1, true);
      }
      for (int i=0; i<cobjActivityEdit.size(); i++) {
         ((Item)cobjActivityEdit.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }

      //
      // Show the activity edit
      //
      cobjDisplay.setCurrent(cobjActivityEdit);
      cobjDisplay.setCurrentItem((Item)cobjActivityEdit.get(2));
   
   }
   
   /**
    * Updates the activity display
    */
   public void updateActivityDisplay() {

      //
      // Update the activity data model
      //
      int intDataRow = cobjActivityTable.getSelectedCellRow();
      cRouteActivity objRouteActivity = (cRouteActivity)cobjRouteStore.getCallActivities().elementAt(intDataRow);
      if (((ChoiceGroup)cobjActivityEdit.get(2)).getSelectedIndex() == 0) {
         objRouteActivity.setFlag("1");
         cobjActivityTable.setValue(0, intDataRow, "Y");
      } else {
         objRouteActivity.setFlag("0");
         cobjActivityTable.setValue(0, intDataRow, "");
      }
      objRouteActivity = null;
      cobjActivityTable.tableDataChanged();
      loadActivityDisplay();
      
   }
   
   /**
    * Loads the order display
    */
   public void loadOrderDisplay() {
      
      //
      // Create and load the order display
      //
      if (cobjOrderDisplay == null) {
         java.util.Vector objArray = null;
         try {
            cobjUomStore.clearFilters();
            objArray = cobjUomStore.getDataList();
         } catch (Exception objException) {
            Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjOrderDisplay);
            return;
         }
         cobjOrderDisplay = new Form(cobjResourceBundle.getResource("RTEORDHDR"));
         cobjOrderDisplay.addCommand(cobjCommandBack);
         cobjOrderDisplay.addCommand(cobjCommandNext);
         cobjOrderDisplay.addCommand(cobjCommandClear);
         cobjOrderDisplay.addCommand(cobjCommandSearch);
         cobjOrderDisplay.setCommandListener(this);
         cintOrderPointers = cobjRouteStore.getOrderPointers();
         cintOrderLineCount = 0;
         double dblTotalAmount = 0;
         cobjOrderTable = new cTableItem(cobjDisplay, cobjRouteStore.getCallCustomerName(), new String[] {cobjResourceBundle.getResource("RTEORD001"),cobjResourceBundle.getResource("RTEORD002"),cobjResourceBundle.getResource("RTEORD003"),cobjResourceBundle.getResource("RTEORD004")}, cintOrderPointers.length+1);
         cRouteOrder objRouteOrder = null;
         for (int i=0; i<cintOrderPointers.length; i++) {
            objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[i]);
            cobjOrderTable.setValue(0, i, cobjFormatter.formatNumber(objRouteOrder.getOrderQty(),0,false));
            cobjOrderTable.setValue(1, i, "*NONE");
            for (int j=0; j<objArray.size(); j++) {
               if (((cUomList)objArray.elementAt(j)).getName().equals(objRouteOrder.getOrderUom())) {
                  cobjOrderTable.setValue(1, i, ((cUomList)objArray.elementAt(j)).getText());
               }
            }
            cobjOrderTable.setValue(2, i, cobjFormatter.formatNumber(objRouteOrder.getOrderValue(),2,false));
            cobjOrderTable.setValue(3, i, objRouteOrder.getName());
            dblTotalAmount = dblTotalAmount + cobjFormatter.getNumber(objRouteOrder.getOrderValue());
            if (objRouteOrder.getOrderQty() != null && !objRouteOrder.getOrderQty().equals("0")) {
               cintOrderLineCount++;
            }
         }
         objRouteOrder = null;
         cobjOrderTable.setValue(0, cintOrderPointers.length, "");
         cobjOrderTable.setValue(1, cintOrderPointers.length, "");
         cobjOrderTable.setValue(2, cintOrderPointers.length, cobjFormatter.formatNumber(dblTotalAmount,2,false));
         cobjOrderTable.setValue(3, cintOrderPointers.length, cobjResourceBundle.getResource("RTEORD005"));
         cobjOrderTable.tableDataLoaded();
         cobjOrderTable.addCommand(cobjCommandEdit);
         cobjOrderTable.addCommand(cobjCommandDelete);
         cobjOrderTable.setDefaultCommand(cobjCommandEdit);
         cobjOrderTable.setItemCommandListener(this);
        // cobjOrderTable.setLayout(TableItem.LAYOUT_NEWLINE_BEFORE|TableItem.LAYOUT_CENTER);
         cobjOrderDisplay.append(cobjOrderTable);
      }
      
      //
      // Show the order display
      //
      cobjDisplay.setCurrent(cobjOrderDisplay);
   
   }
   
   /**
    * Load the order line edit display
    */
   public void loadOrderLineEditDisplay() {
      
      //
      // Total row must not be edited
      //
      if (cobjOrderTable.getSelectedCellRow() == cintOrderPointers.length) {
         return;
      }
      int intDataRow = cobjOrderTable.getSelectedCellRow();
      cRouteOrder objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[intDataRow]);
      
      //
      // Create and load the order line edit display
      //
      if (cobjOrderLineEdit == null) {
         cobjOrderLineEdit = new Form(cobjResourceBundle.getResource("RTEORDUPDHDR"));
         cobjOrderLineEdit.addCommand(cobjCommandCancel);
         cobjOrderLineEdit.addCommand(cobjCommandAccept);
         cobjOrderLineEdit.setCommandListener(this);
      }
      cobjOrderLineEdit.deleteAll();
      cobjOrderLineEdit.append(new StringItem(cobjResourceBundle.getResource("RTEORDUPD001"), cobjRouteStore.getCallCustomerName()));
      cobjOrderLineEdit.append(new StringItem(cobjResourceBundle.getResource("RTEORDUPD002"), (String)cobjOrderTable.getValue(3, intDataRow)));
      cobjOrderLineEdit.append(new TextField(cobjResourceBundle.getResource("RTEORDUPD003"), "", 4, TextField.NUMERIC));
      cobjOrderLineEdit.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEORDUPD004"),ChoiceGroup.POPUP));
      try {
         java.util.Vector objArray = null;
         cobjUomStore.clearFilters();
         objArray = cobjUomStore.getDataList();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjOrderLineEdit.get(3)).append(((cUomList)objArray.elementAt(i)).getText(), null);
            if (((cUomList)objArray.elementAt(i)).getName().equals(objRouteOrder.getOrderUom())) {
               ((ChoiceGroup)cobjOrderLineEdit.get(3)).setSelectedIndex(i, true);
            }
         }
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderDisplay);
         return;
      }
      for (int i=0; i<cobjOrderLineEdit.size(); i++) {
         ((Item)cobjOrderLineEdit.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the order line edit
      //
      cobjDisplay.setCurrent(cobjOrderLineEdit);
      cobjDisplay.setCurrentItem((Item)cobjOrderLineEdit.get(2));
   
   }
   
   /**
    * Actions the the order line edit display
    */
   public void actionOrderLineEditDisplay() {
      
      //
      // Update the order data model
      //
      String strUomName = "";
      String strUomText = "";
      try {
         java.util.Vector objArray = null;
         cobjUomStore.clearFilters();
         objArray = cobjUomStore.getDataList();
         strUomName = ((cUomList)objArray.elementAt(((ChoiceGroup)cobjOrderLineEdit.get(3)).getSelectedIndex())).getName();
         strUomText = ((cUomList)objArray.elementAt(((ChoiceGroup)cobjOrderLineEdit.get(3)).getSelectedIndex())).getText();
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderLineEdit);
         return;
      }
      int intDataRow = cobjOrderTable.getSelectedCellRow();
      cRouteOrder objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[intDataRow]);
      double dblQty = cobjFormatter.getNumber(((TextField)cobjOrderLineEdit.get(2)).getString());
      double dblPrice = 0;
      if (strUomName.toUpperCase().equals("TDU")) {
         dblPrice = cobjFormatter.getNumber(objRouteOrder.getPriceTDU());
      } else if (strUomName.toUpperCase().equals("MCU")) {
         dblPrice = cobjFormatter.getNumber(objRouteOrder.getPriceMCU());
      } else if (strUomName.toUpperCase().equals("RSU")) {
         dblPrice = cobjFormatter.getNumber(objRouteOrder.getPriceRSU());
      }
      objRouteOrder.setOrderQty(cobjFormatter.formatNumber(dblQty,0,false));
      cobjOrderTable.setValue(0, intDataRow, cobjFormatter.formatNumber(dblQty,0,false));
      objRouteOrder.setOrderUom(strUomName);
      cobjOrderTable.setValue(1, intDataRow, strUomText);
      objRouteOrder.setOrderValue(cobjFormatter.formatNumber(dblQty * dblPrice,2,false));
      cobjOrderTable.setValue(2, intDataRow, cobjFormatter.formatNumber(dblQty * dblPrice,2,false));
      cintOrderLineCount = 0;
      double dblTotalAmount = 0;
      for (int i=0; i<cintOrderPointers.length; i++) {
         objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[i]);
         dblTotalAmount = dblTotalAmount + cobjFormatter.getNumber(objRouteOrder.getOrderValue());
         if (objRouteOrder.getOrderQty() != null && !objRouteOrder.getOrderQty().equals("0")) {
            cintOrderLineCount++;
         }
      }
      cobjOrderTable.setValue(2, cintOrderPointers.length, cobjFormatter.formatNumber(dblTotalAmount,2,false));
      objRouteOrder = null;
      cobjOrderTable.tableDataChanged();
      loadOrderDisplay();
      
   }
   
   /**
    * Loads the order line delete display
    */
   public void loadOrderLineDeleteDisplay() {
      
      //
      // Total row must not be deleted
      //
      if (cobjOrderTable.getSelectedCellRow() == cintOrderPointers.length) {
         return;
      }
      
      //
      // Create and load the order line delete display
      //
      if (cobjOrderLineDelete == null) {
         cobjOrderLineDelete = new Form(cobjResourceBundle.getResource("RTEORDDELHDR"));
         cobjOrderLineDelete.addCommand(cobjCommandCancel);
         cobjOrderLineDelete.addCommand(cobjCommandAccept);
         cobjOrderLineDelete.setCommandListener(this);
      }
      cobjOrderLineDelete.deleteAll();
      cobjOrderLineDelete.append(new StringItem(cobjResourceBundle.getResource("RTEORDDEL001"), cobjRouteStore.getCallCustomerName()));
      cobjOrderLineDelete.append(new StringItem(cobjResourceBundle.getResource("RTEORDDEL002"), (String)cobjOrderTable.getValue(3, cobjOrderTable.getSelectedCellRow())));
      cobjOrderLineDelete.append(new StringItem(cobjResourceBundle.getResource("RTEORDDEL003"), (String)cobjOrderTable.getValue(0, cobjOrderTable.getSelectedCellRow())));
      cobjOrderLineDelete.append(new StringItem(cobjResourceBundle.getResource("RTEORDDEL004"), (String)cobjOrderTable.getValue(1, cobjOrderTable.getSelectedCellRow())));
      for (int i=0; i<cobjOrderLineDelete.size(); i++) {
         ((Item)cobjOrderLineDelete.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the order line delete
      //
      cobjDisplay.setCurrent(cobjOrderLineDelete);
   
   }
   
   /**
    * Actions the order line delete display
    */
   public void actionOrderLineDeleteDisplay() {
      
      //
      // Set the selected products to ordered selected
      //
      cRouteOrder objRouteOrder;
      objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[cobjOrderTable.getSelectedCellRow()]);
      objRouteOrder.setOrderSelected(false);
      objRouteOrder.setOrderQty("0");
      objRouteOrder.setOrderUom("RSU");
      objRouteOrder.setOrderValue("0");
      objRouteOrder = null;

      //
      // Load the order display
      //
      cobjOrderDisplay = null;
      loadOrderDisplay();
      
   }
   
   /**
    * Loads the order clear display
    */
   public void loadOrderClearDisplay() {
      
      //
      // Create and load the order clear display
      //
      if (cobjOrderClearDisplay == null) {
         cobjOrderClearDisplay = new Form(cobjResourceBundle.getResource("RTEORDCLRHDR"));
         cobjOrderClearDisplay.addCommand(cobjCommandCancel);
         cobjOrderClearDisplay.addCommand(cobjCommandAccept);
         cobjOrderClearDisplay.setCommandListener(this);
      }
      cobjOrderClearDisplay.deleteAll();
      cobjOrderClearDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEORDCLR001"), cobjRouteStore.getCallCustomerName()));
      cobjOrderClearDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEORDCLR002"), cobjResourceBundle.getResource("RTEORDCLR003")));
      for (int i=0; i<cobjOrderClearDisplay.size(); i++) {
         ((Item)cobjOrderClearDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the order clear
      //
      cobjDisplay.setCurrent(cobjOrderClearDisplay);
   
   }
   
   /**
    * Actions the order clear display
    */
   public void actionOrderClearDisplay() {
      
      //
      // Set the selected products to ordered selected
      //
      cRouteOrder objRouteOrder;
      for (int i=0; i<cintOrderPointers.length; i++) {
         objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderPointers[i]);
         objRouteOrder.setOrderSelected(false);
         objRouteOrder.setOrderQty("0");
         objRouteOrder.setOrderUom("RSU");
         objRouteOrder.setOrderValue("0");
      }
      objRouteOrder = null;
      cobjRouteStore.setCallOrderSend("0");

      //
      // Load the order display
      //
      cobjOrderDisplay = null;
      loadOrderDisplay();
      
   }
   
   /**
    * Loads the order search display
    */
   public void loadOrderSearchDisplay() {
      
      //
      // Create and clear the order search display
      //
      if (cobjOrderSearchDisplay == null) {
         cobjOrderSearchDisplay = new Form(cobjResourceBundle.getResource("RTEORDSCHHDR"));
         cobjOrderSearchDisplay.addCommand(cobjCommandBack);
         cobjOrderSearchDisplay.addCommand(cobjCommandSearch);
         cobjOrderSearchDisplay.setCommandListener(this);
      }
      cobjOrderSearchDisplay.deleteAll();
      cobjOrderSearchDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEORDSCH001"), cobjRouteStore.getCallCustomerName()));
      cobjOrderSearchDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEORDSCH002"), ChoiceGroup.POPUP));
      cobjOrderSearchDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEORDSCH003"), ChoiceGroup.POPUP));
      java.util.Vector objArray = null;
      ((ChoiceGroup)cobjOrderSearchDisplay.get(1)).append(cobjResourceBundle.getResource("CONALL"), null);
      try {
         objArray = cobjRouteStore.getOrderBrands();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjOrderSearchDisplay.get(1)).append(((cListValue)objArray.elementAt(i)).getCode(), null);
         }
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderDisplay);
         return;
      }
      ((ChoiceGroup)cobjOrderSearchDisplay.get(2)).append(cobjResourceBundle.getResource("CONALL"), null);
      try {
         objArray = cobjRouteStore.getOrderPacksizes();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjOrderSearchDisplay.get(2)).append(((cListValue)objArray.elementAt(i)).getCode(), null);
         }
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderDisplay);
         return;
      }
      objArray = null;
      for (int i=0; i<cobjOrderSearchDisplay.size(); i++) {
         ((Item)cobjOrderSearchDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the order search display
      //
      cobjDisplay.setCurrent(cobjOrderSearchDisplay);
      cobjDisplay.setCurrentItem((Item)cobjOrderSearchDisplay.get(1));
   
   }
   
   /**
    * Actions the order search display
    */
   public void actionOrderSearchDisplay() {

      //
      // Perform the order search action
      //
      loadOrderSelectDisplay();
      
   }
   
   /**
    * Loads the order select display
    */
   public void loadOrderSelectDisplay() {
      
      //
      // Create and clear the order select display
      //
      cobjOrderSelectDisplay = new List(cobjResourceBundle.getResource("RTEORDSLTHDR"), List.MULTIPLE);
      cobjOrderSelectDisplay.addCommand(cobjCommandBack);
      cobjOrderSelectDisplay.addCommand(cobjCommandSelect);
      cobjOrderSelectDisplay.setCommandListener(this);
      cobjOrderSelectDisplay.setFitPolicy(Choice.TEXT_WRAP_ON);
      cobjOrderSelectDisplay.deleteAll();
      
      //
      // Load the order select display
      //
      String strBrand = ((ChoiceGroup)cobjOrderSearchDisplay.get(1)).getString(((ChoiceGroup)cobjOrderSearchDisplay.get(1)).getSelectedIndex());
      String strPacksize = ((ChoiceGroup)cobjOrderSearchDisplay.get(2)).getString(((ChoiceGroup)cobjOrderSearchDisplay.get(2)).getSelectedIndex());
      if (strBrand.equals(cobjResourceBundle.getResource("CONALL"))) {
         strBrand = "*ALL";
      }
      if (strPacksize.equals(cobjResourceBundle.getResource("CONALL"))) {
         strPacksize = "*ALL";
      }
      int intIndex = 0;
      cintOrderSelectPointers = cobjRouteStore.getOrderSelectPointers(strBrand, strPacksize);
      cRouteOrder objRouteOrder = null;
      for (int i=0; i<cintOrderSelectPointers.length; i++) {
         objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderSelectPointers[i]);
         intIndex = cobjOrderSelectDisplay.append("(" + objRouteOrder.getId() + ") " + objRouteOrder.getName(), null);
         cobjOrderSelectDisplay.setSelectedIndex(intIndex, false);
      }
      objRouteOrder = null;
      for (int i=0; i<cobjOrderSelectDisplay.size(); i++) {
         cobjOrderSelectDisplay.setFont(i, cobjFontSmall);
      }
      
      //
      // Products must be available
      //
      if (cobjOrderSelectDisplay.size() == 0) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTEORDSLTM01"), null, AlertType.INFO);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderSearchDisplay);
         cobjDisplay.setCurrentItem((Item)cobjOrderSearchDisplay.get(1));
         return;
      }
     
      //
      // Show the order select display
      //
      cobjDisplay.setCurrent(cobjOrderSelectDisplay);
   
   }
   
   /**
    * Actions the order select display
    */
   public void actionOrderSelectDisplay() {
      
      //
      // Set the selected products to ordered selected
      //
      boolean bolSelected = false;
      cRouteOrder objRouteOrder;
      for (int i=0; i<cobjOrderSelectDisplay.size(); i++) {
         if (cobjOrderSelectDisplay.isSelected(i)) {
            objRouteOrder = (cRouteOrder)cobjRouteStore.getCallOrders().elementAt(cintOrderSelectPointers[i]);
            objRouteOrder.setOrderSelected(true);
            bolSelected = true;
         }
      }
      objRouteOrder = null;
      
      //
      // At least one product must be selected
      //
      if (!bolSelected) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("RTEORDSLTM02"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOrderSelectDisplay);
         return;
      }

      //
      // Load the order display
      //
      cobjOrderDisplay = null;
      loadOrderDisplay();
      
   }
   
   /**
    * Loads the order submit display
    */
   public void loadOrderSubmitDisplay() {
         
      //
      // Create and load the order submit display
      //
      if (cobjOrderSubmitDisplay == null) {
         cobjOrderSubmitDisplay = new Form(cobjResourceBundle.getResource("RTEORDSBMHDR"));
         cobjOrderSubmitDisplay.addCommand(cobjCommandBack);
         cobjOrderSubmitDisplay.addCommand(cobjCommandNext);
         cobjOrderSubmitDisplay.setCommandListener(this);
      }
      cobjOrderSubmitDisplay.deleteAll();
      cobjOrderSubmitDisplay.append(new StringItem(cobjResourceBundle.getResource("RTEORDSBM001"), cobjRouteStore.getCallCustomerName()));
      cobjOrderSubmitDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("RTEORDSBM002"), ChoiceGroup.POPUP, new String[] {cobjResourceBundle.getResource("CONYES"),cobjResourceBundle.getResource("CONNO")}, null));
      if (cobjRouteStore.getCallOrderSend().equals("1")) {
         ((ChoiceGroup)cobjOrderSubmitDisplay.get(1)).setSelectedIndex(0, true);
      } else {
         ((ChoiceGroup)cobjOrderSubmitDisplay.get(1)).setSelectedIndex(1, true);
      }
      for (int i=0; i<cobjOrderSubmitDisplay.size(); i++) {
         ((Item)cobjOrderSubmitDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the order submit
      //
      cobjDisplay.setCurrent(cobjOrderSubmitDisplay);
      cobjDisplay.setCurrentItem((Item)cobjOrderSubmitDisplay.get(1));
   
   }
   
   /**
    * Actions the order submit display
    */
   public void actionOrderSubmitDisplay() {
      
      //
      // Set the order send property
      //
      if (((ChoiceGroup)cobjOrderSubmitDisplay.get(1)).getSelectedIndex() == 0) {
         cobjRouteStore.setCallOrderSend("1");
      } else {
         cobjRouteStore.setCallOrderSend("0");
      }

      //
      // Load the close display
      //
      loadCloseDisplay();
      
   }
   
   /**
    * Loads the close display
    */
   public void loadCloseDisplay() {
      
      //
      // Create and clear the close display
      //
      if (cobjCloseDisplay == null) {
         cobjCloseDisplay = new Form(cobjResourceBundle.getResource("RTECOMHDR"));
         cobjCloseDisplay.addCommand(cobjCommandBack);
         cobjCloseDisplay.addCommand(cobjCommandSave);
         cobjCloseDisplay.setCommandListener(this);
      }
      cobjCloseDisplay.deleteAll();
      cobjCloseDisplay.append(new StringItem(cobjResourceBundle.getResource("RTECOM001"),cobjRouteStore.getCallCustomerName()));
      cobjCloseDisplay.append(new Spacer(((StringItem)cobjCloseDisplay.get(0)).getFont().charWidth('X'),((StringItem)cobjCloseDisplay.get(0)).getFont().getHeight()));
      cobjCloseDisplay.append(new StringItem(null,cobjResourceBundle.getResource("RTECOM002")));
      for (int i=0; i<cobjCloseDisplay.size(); i++) {
         ((Item)cobjCloseDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the close display
      //
      cobjDisplay.setCurrent(cobjCloseDisplay);
   
   }
   
   /**
    * Actions the close display
    */
   public void actionCloseDisplay() {
      
      //
      // Perform the close on a separate thread
      //
      cobjDisplay.setCurrent(new cCloseAction());
      
   }
   
   /**
    * This class implements the route open functionality.
    */
   class cOpenAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private String cstrAction;
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cOpenAction(String strAction) {
         super(null);
         cstrAction = strAction;
         cobjGauge = new Gauge(cobjResourceBundle.getResource("RTELSTM03"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjOpenDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {

               //
               // Load the customer data model from the data store using the
               // record identifier from the index store and clear 
               //
               cobjRouteStore.loadCallModel(((cRouteList)cobjRouteList.elementAt(cobjOpenDisplay.getSelectedIndex())).getRecordId());
               
               //
               // Clear the function displays
               //
               cobjStockDisplay = null;
               cobjDisplayDisplay = null;
               cobjActivityDisplay = null;
               cobjOrderDisplay = null;
               cobjDeleteDisplay = null;

               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               if (cstrAction.toUpperCase().equals("*SELECT")) {
                  loadStockDisplay();
               } else {
                  loadDeleteDisplay();
               }
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the route delete functionality.
    */
   class cDeleteAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cDeleteAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("RTEDLTM02"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjDeleteDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {

               //
               // Delete the customer data model from the data store using the
               // record identifier from the index store and clear 
               //
               cobjRouteStore.deleteCallModel();

               //
               // Clear the function displays
               //
               cobjStockDisplay = null;
               cobjDisplayDisplay = null;
               cobjActivityDisplay = null;
               cobjOrderDisplay = null;
               cobjDeleteDisplay = null;
               
               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               loadOpenDisplay();
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the route close functionality.
    */
   class cCloseAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cCloseAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("RTECOMM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjCloseDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {
                
               //
               // Save the customer data model from the data store using the
               // record identifier from the index store and release the customer lock
               //
               cobjRouteStore.setCallCalled();
               cobjRouteStore.saveCallModel();
               
               //
               // Clear the function displays
               //
               cobjStockDisplay = null;
               cobjDisplayDisplay = null;
               cobjActivityDisplay = null;
               cobjOrderDisplay = null;
               cobjDeleteDisplay = null;
               
               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               loadOpenDisplay();
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the route select functionality.
    */
   class cSelectAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;
      private String cstrUserName;
      private String cstrPassword;
      private String cstrCustomerId;

      /**
       * Constructs a new instance
       */
      public cSelectAction(String strUserName, String strPassword, String strCustomerId) {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("RTEDWNM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cstrUserName = strUserName;
         cstrPassword = strPassword;
         cstrCustomerId = strCustomerId;
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjOpenDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         cConnection objConnection = null;
         cMailbox objOutbox = null;
         cMailbox objInbox = null;
         boolean bolData = false;
         try {
            
            while (cobjThread == objThread) {
               
               //
               // Load the request buffer
               //
               objOutbox = new cMailbox();
               objOutbox.addMessage(cMailbox.EFEX_RQS_USERNAME,cstrUserName);
               objOutbox.addMessage(cMailbox.EFEX_RQS_PASSWORD,cstrPassword);
               objOutbox.addMessage(cMailbox.EFEX_RQS_CUSTOMER_ID,cstrCustomerId);

               //
               // Communicate with the server
               //
               objConnection = new cConnection(cobjResourceBundle);
               String strResponse = objConnection.postDataStream(cobjMobileStore.getSecure(), cobjMobileStore.getServerUrl() + "/CallDownload.ashx", objOutbox.getBuffer().toString());
               
               //
               // Load the response messages and process
               //
               objInbox = new cMailbox();
               objInbox.putBuffer(strResponse);
               cMessage objMessage = null;
               StringBuffer objStoreBuffer = null;
               for (int i=0; i<objInbox.getMessageCount(); i++) {
                  objMessage = objInbox.getMessage(i);
                  switch (objMessage.getCode()) {
                     case cMailbox.EFEX_RQS_MESSAGE: {
                        throw new Throwable(objMessage.getData());
                     }
                     case cMailbox.EFEX_RTE_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_RTE_END: {
                        if (objStoreBuffer.length() != 0) {
                           bolData = true;
                           cobjRouteStore.appendDataStore(objStoreBuffer.toString());
                        }
                        break;
                     }
                     default: {
                        objStoreBuffer = objStoreBuffer.append(objMessage.getMessageData());
                     }
                  }
               }
               
               //
               // Load the route data model from the data store using the
               // record identifier from the appended record 
               //
               if (!bolData) {
                  throw new Exception(cobjResourceBundle.getResource("RTEDWNM02"));
               }
               cobjRouteStore.loadCallModel(cobjRouteStore.getCallId());
               
               //
               // Clear the function displays
               //
               cobjStockDisplay = null;
               cobjDisplayDisplay = null;
               cobjActivityDisplay = null;
               cobjOrderDisplay = null;
               cobjDeleteDisplay = null;

               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               loadStockDisplay();
            } 
         }
         
      }
      
   }
   
}
