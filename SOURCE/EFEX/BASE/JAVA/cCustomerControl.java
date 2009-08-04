/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cCustomerControl
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.*;
import javax.microedition.lcdui.*;
import org.netbeans.microedition.lcdui.*;


/**
 * This class implements the Efex application customer control.
 */
public class cCustomerControl implements CommandListener {
   
   //
   // Private class declarations
   //
   private cApplication cobjApplication;
   private Display cobjDisplay;
   private List cobjMenu;
   private List cobjOpenDisplay;
   private Form cobjDownloadDisplay;
   private Form cobjSearchDisplay;
   private Form cobjCreateDisplay;
   private Form cobjUpdateDisplay;
   private Command cobjCommandBack;
   private Command cobjCommandSearch;
   private Command cobjCommandCreate;
   private Command cobjCommandUpdate;
   private Command cobjCommandCancel;
   private Command cobjCommandAccept;
   private Command cobjCommandSave;
   private Font cobjFontSmall;
   private cResourceBundle cobjResourceBundle;
   private cMobileStore cobjMobileStore;
   private cControlStore cobjControlStore;
   private cCustomerLocationStore cobjCustomerLocationStore;
   private cCustomerTypeStore cobjCustomerTypeStore;
   private cDistributorStore cobjDistributorStore;
   private cCustomerStore cobjCustomerStore;
   private java.util.Vector cobjCustomerList;
   
   /**
    * Constructs a new instance
    */
   public cCustomerControl(cApplication objApplication) {
      cobjApplication = objApplication;
      cobjDisplay = cobjApplication.getDisplay();
      cobjMenu = cobjApplication.getMenu();
      cobjFontSmall = cobjApplication.getFontSmall();
      cobjResourceBundle = cobjApplication.getResourceBundle();
      cobjMobileStore = cobjApplication.getMobileStore();
      cobjControlStore = cobjApplication.getControlStore();
      cobjCustomerLocationStore = cobjApplication.getCustomerLocationStore();
      cobjCustomerTypeStore = cobjApplication.getCustomerTypeStore();
      cobjDistributorStore = cobjApplication.getDistributorStore();
      cobjCustomerStore = cobjApplication.getCustomerStore();
      cobjCommandBack = new Command(cobjResourceBundle.getResource("CMDBACK"), Command.BACK, 0);
      cobjCommandSearch = new Command(cobjResourceBundle.getResource("CMDSEARCH"), Command.ITEM, 0);
      cobjCommandCreate = new Command(cobjResourceBundle.getResource("CMDCREATE"), Command.ITEM, 0);
      cobjCommandUpdate = new Command(cobjResourceBundle.getResource("CMDUPDATE"), Command.ITEM, 0);
      cobjCommandCancel = new Command(cobjResourceBundle.getResource("CMDCANCEL"), Command.CANCEL, 0);
      cobjCommandAccept = new Command(cobjResourceBundle.getResource("CMDACCEPT"), Command.SCREEN, 0);
      cobjCommandSave = new Command(cobjResourceBundle.getResource("CMDSAVE"), Command.SCREEN, 0);
   }
   
   /**
    * Override the CommandListener abstract methods
    */
   public void commandAction(Command objCommand, Displayable objDisplayable) {                                               
      if (objDisplayable == cobjOpenDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjMenu);  
         } else if (objCommand == cobjCommandSearch) {                                         
            actionOpenDisplay("*SEARCH");
         } else if (objCommand == cobjCommandCreate) {                                         
            actionOpenDisplay("*CREATE");
         } else if (objCommand == cobjCommandUpdate || objCommand == List.SELECT_COMMAND) {                                         
            actionOpenDisplay("*UPDATE");
         }
      } else if (objDisplayable == cobjDownloadDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjOpenDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionDownloadDisplay();
         }
      } else if (objDisplayable == cobjSearchDisplay) {
         if (objCommand == cobjCommandBack) {
            loadOpenDisplay();
         } else if (objCommand == cobjCommandSearch) {
            actionSearchDisplay();
         }
      } else if (objDisplayable == cobjCreateDisplay) {
         if (objCommand == cobjCommandCancel) {
            showConfirmation(cobjCreateDisplay);
         } else if (objCommand == cobjCommandSave) {
            actionCreateDisplay();
         }
      } else if (objDisplayable == cobjUpdateDisplay) {
         if (objCommand == cobjCommandCancel) {
             showConfirmation(cobjUpdateDisplay);
         } else if (objCommand == cobjCommandSave) {
            actionUpdateDisplay();
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
      // Customer must be loaded
      //
      if (cobjControlStore.getMobileStatus() == null) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("CUSLSTM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenu);
         return;
      }
      
      //
      // Create and clear the open display
      //
      cobjOpenDisplay = new List(cobjResourceBundle.getResource("CUSLSTHDR"), List.IMPLICIT);
      cobjOpenDisplay.addCommand(cobjCommandBack);
      cobjOpenDisplay.addCommand(cobjCommandSearch);
      cobjOpenDisplay.addCommand(cobjCommandUpdate);
      cobjOpenDisplay.addCommand(cobjCommandCreate);
      cobjOpenDisplay.setCommandListener(this);
      cobjOpenDisplay.setFitPolicy(Choice.TEXT_WRAP_ON);
      cobjOpenDisplay.deleteAll();
      
      //
      // Load the open display
      //
      try {
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
            cobjSearchDisplay = null;
         }
         cobjCustomerList = cobjCustomerStore.getCustomerList();
         int intIndex = 0;
         for (int i=0; i<cobjCustomerList.size(); i++) {
            intIndex = cobjOpenDisplay.append("(" + ((cCustomerList)cobjCustomerList.elementAt(i)).getCode() + ") " + ((cCustomerList)cobjCustomerList.elementAt(i)).getName(), null);
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
      // Customer must be selected when required
      //
      if (strAction.equals("*UPDATE")) {
         if (cobjOpenDisplay.getSelectedIndex() < 0) {
            Alert objAlert = new Alert(null, cobjResourceBundle.getResource("CUSLSTM02"), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
            return;
         }
      }
         
      //
      // Perform the open action
      //
      if (strAction.equals("*SEARCH")) {
         loadSearchDisplay();
      } else if (strAction.equals("*CREATE")) {
         cobjCustomerStore.clearCustomerModel();
         loadCreateDisplay();
      } else {
         try {
            cobjCustomerStore.loadCustomerModel(((cCustomerList)cobjCustomerList.elementAt(cobjOpenDisplay.getSelectedIndex())).getRecordId());
         } catch(Exception objException) {
            Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
            return;
         }
         if (cobjCustomerStore.getCustomerDataType().toUpperCase().equals("*OLD") &&
             cobjCustomerStore.getCustomerDataAction().toUpperCase().equals("*NONE")) {
            loadDownloadDisplay();
         } else {
            loadUpdateDisplay();
         }
      }
      
   }
   
   /**
    * Loads the download display
    */
   public void loadDownloadDisplay() {
      
      //
      // Create and clear the download display
      //
      if (cobjDownloadDisplay == null) {
         cobjDownloadDisplay = new Form(cobjResourceBundle.getResource("CUSDWNHDR"));
         cobjDownloadDisplay.addCommand(cobjCommandCancel);
         cobjDownloadDisplay.addCommand(cobjCommandAccept);
         cobjDownloadDisplay.setCommandListener(this);
      }
      cobjDownloadDisplay.deleteAll();
      cobjDownloadDisplay.append(new TextField(cobjResourceBundle.getResource("CUSDWN001"), "", 10, TextField.NUMERIC));
      cobjDownloadDisplay.append(new StringItem(cobjResourceBundle.getResource("CUSDWN002"), "(" + ((cCustomerList)cobjCustomerList.elementAt(cobjOpenDisplay.getSelectedIndex())).getCode() + ") " + ((cCustomerList)cobjCustomerList.elementAt(cobjOpenDisplay.getSelectedIndex())).getName()));
      cobjDownloadDisplay.append(new StringItem(cobjResourceBundle.getResource("CUSDWN003"), cobjResourceBundle.getResource("CUSDWN004")));
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
      cobjDisplay.setCurrent(new cOpenAction(cobjMobileStore.getUserName(),((TextField)cobjDownloadDisplay.get(0)).getString(),((cCustomerList)cobjCustomerList.elementAt(cobjOpenDisplay.getSelectedIndex())).getRecordId()));
      
   }
   
   /**
    * Loads the search display
    */
   public void loadSearchDisplay() {
      
      //
      // Create and clear the search display
      //
      if (cobjSearchDisplay == null) {
         cobjSearchDisplay = new Form(cobjResourceBundle.getResource("CUSSCHHDR"));
         cobjSearchDisplay.addCommand(cobjCommandBack);
         cobjSearchDisplay.addCommand(cobjCommandSearch);
         cobjSearchDisplay.setCommandListener(this);
      }
      cobjSearchDisplay.deleteAll();
      cobjSearchDisplay.append(new TextField(cobjResourceBundle.getResource("CUSSCH001"), "", 20, TextField.NUMERIC));
      cobjSearchDisplay.append(new TextField(cobjResourceBundle.getResource("CUSSCH002"), "", 50, TextField.ANY));
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
      // Reloads the open display
      //
      loadOpenDisplay();
      
   }
   
   /**
    * Loads the create display
    */
   public void loadCreateDisplay() {
      
      //
      // Create and load the create display
      //
      if (cobjCreateDisplay == null) {
         cobjCreateDisplay = new Form(cobjResourceBundle.getResource("CUSCRTHDR"));
         cobjCreateDisplay.addCommand(cobjCommandCancel);
         cobjCreateDisplay.addCommand(cobjCommandSave);
         cobjCreateDisplay.setCommandListener(this);
      }
      cobjCreateDisplay.deleteAll();
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT001"), cobjCustomerStore.getCustomerName(), 100, TextField.ANY));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT002"), cobjCustomerStore.getCustomerAddress(), 100, TextField.ANY));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT003"), cobjCustomerStore.getCustomerContactName(), 50, TextField.ANY));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT004"), cobjCustomerStore.getCustomerPhoneNumber(), 50, TextField.NUMERIC));
      cobjCreateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSCRT005"),ChoiceGroup.POPUP));
      cobjCreateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSCRT006"),ChoiceGroup.POPUP));
      cobjCreateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSCRT007"),ChoiceGroup.POPUP));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT008"), cobjCustomerStore.getCustomerPostcode(), 50, TextField.NUMERIC));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT009"), cobjCustomerStore.getCustomerFaxNumber(), 50, TextField.NUMERIC));
      cobjCreateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSCRT010"), cobjCustomerStore.getCustomerEmailAddress(), 50, TextField.ANY));
      try {
         java.util.Vector objArray = null;
         cobjCustomerTypeStore.clearFilters();
         objArray = cobjCustomerTypeStore.getDataList();
         ((ChoiceGroup)cobjCreateDisplay.get(4)).append(cobjResourceBundle.getResource("CUSCRT011"), null);
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjCreateDisplay.get(4)).append(((cCustomerTypeList)objArray.elementAt(i)).getName(), null);
         }
         cobjCustomerLocationStore.clearFilters();
         objArray = cobjCustomerLocationStore.getDataList();
         ((ChoiceGroup)cobjCreateDisplay.get(5)).append(cobjResourceBundle.getResource("CUSCRT011"), null);
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjCreateDisplay.get(5)).append(((cCustomerLocationList)objArray.elementAt(i)).getText(), null);
         }
         cobjDistributorStore.clearFilters();
         objArray = cobjDistributorStore.getDataList();
         ((ChoiceGroup)cobjCreateDisplay.get(6)).append(cobjResourceBundle.getResource("CUSCRT011"), null);
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjCreateDisplay.get(6)).append(((cDistributorList)objArray.elementAt(i)).getName(), null);
         }
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
         return;
      }
      for (int i=0; i<cobjCreateDisplay.size(); i++) {
         ((Item)cobjCreateDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
       
      //
      // Show the customer create display
      //
      cobjDisplay.setCurrent(cobjCreateDisplay);
   
   }
   
   /**
    * Actions the create display
    */
   public void actionCreateDisplay() {
      
      //
      // Update the customer data model
      //
      String strOutletType = "";
      String strOutletLocation = "";
      String strWholesaler = "";
      try {
         java.util.Vector objArray = null;
         if (((ChoiceGroup)cobjCreateDisplay.get(4)).getSelectedIndex() != 0) {
            cobjCustomerTypeStore.clearFilters();
            objArray = cobjCustomerTypeStore.getDataList();
            strOutletType = ((cCustomerTypeList)objArray.elementAt(((ChoiceGroup)cobjCreateDisplay.get(4)).getSelectedIndex()-1)).getId();
         }
         if (((ChoiceGroup)cobjCreateDisplay.get(5)).getSelectedIndex() != 0) {
            cobjCustomerLocationStore.clearFilters();
            objArray = cobjCustomerLocationStore.getDataList();
            strOutletLocation = ((cCustomerLocationList)objArray.elementAt(((ChoiceGroup)cobjCreateDisplay.get(5)).getSelectedIndex()-1)).getName();
         }
         if (((ChoiceGroup)cobjCreateDisplay.get(6)).getSelectedIndex() != 0) {
            cobjDistributorStore.clearFilters();
            objArray = cobjDistributorStore.getDataList();
            strWholesaler = ((cDistributorList)objArray.elementAt(((ChoiceGroup)cobjCreateDisplay.get(6)).getSelectedIndex()-1)).getId();
         }
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjCreateDisplay);
         return;
      }
      cobjCustomerStore.setCustomerStatus("A");
      cobjCustomerStore.setCustomerCode("*NEW");
      cobjCustomerStore.setCustomerName(((TextField)cobjCreateDisplay.get(0)).getString());
      cobjCustomerStore.setCustomerAddress(((TextField)cobjCreateDisplay.get(1)).getString());
      cobjCustomerStore.setCustomerContactName(((TextField)cobjCreateDisplay.get(2)).getString());
      cobjCustomerStore.setCustomerPhoneNumber(((TextField)cobjCreateDisplay.get(3)).getString());
      cobjCustomerStore.setCustomerTypeId(strOutletType);
      cobjCustomerStore.setCustomerOutletLocation(strOutletLocation);
      cobjCustomerStore.setCustomerDistributorId(strWholesaler);
      cobjCustomerStore.setCustomerPostcode(((TextField)cobjCreateDisplay.get(7)).getString());
      cobjCustomerStore.setCustomerFaxNumber(((TextField)cobjCreateDisplay.get(8)).getString());
      cobjCustomerStore.setCustomerEmailAddress(((TextField)cobjCreateDisplay.get(9)).getString());   
      try {
         java.util.Vector objMessages = cobjCustomerStore.validateCustomerModel(cobjResourceBundle);
         if (objMessages.size() != 0) {
            String strMessage = new String("");
            for (int i=0; i<objMessages.size(); i++) {
               if (i > 0) {
                  strMessage = strMessage + "\r\n";
               }
               strMessage = strMessage + (String)objMessages.elementAt(i);
            }
            Alert objAlert = new Alert(null, strMessage, null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjCreateDisplay);
            return;
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjCreateDisplay);
         return;
      }
      
      //
      // Perform the create on a separate thread
      //
      cobjDisplay.setCurrent(new cCreateAction());
      
   }
   
   /**
    * Loads the update display
    */
   public void loadUpdateDisplay() {
      
      //
      // Create and load the create display
      //
      if (cobjUpdateDisplay == null) {
         cobjUpdateDisplay = new Form(cobjResourceBundle.getResource("CUSUPDHDR"));
         cobjUpdateDisplay.addCommand(cobjCommandCancel);
         cobjUpdateDisplay.addCommand(cobjCommandSave);
         cobjUpdateDisplay.setCommandListener(this);
      }
      cobjUpdateDisplay.deleteAll();
      cobjUpdateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSUPD001"),ChoiceGroup.POPUP,new String[] {cobjResourceBundle.getResource("CONACTIVE"), cobjResourceBundle.getResource("CONINACTIVE")},null));
      if (cobjCustomerStore.getCustomerStatus().equals("A")) {
         ((ChoiceGroup)cobjUpdateDisplay.get(0)).setSelectedIndex(0, true);
      } else {
         ((ChoiceGroup)cobjUpdateDisplay.get(0)).setSelectedIndex(1, true);
      }
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD002"), cobjCustomerStore.getCustomerName(), 100, TextField.ANY));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD003"), cobjCustomerStore.getCustomerAddress(), 100, TextField.ANY));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD004"), cobjCustomerStore.getCustomerContactName(), 50, TextField.ANY));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD005"), cobjCustomerStore.getCustomerPhoneNumber(), 50, TextField.ANY));
      cobjUpdateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSUPD006"),ChoiceGroup.POPUP));
      cobjUpdateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSUPD007"),ChoiceGroup.POPUP));
      cobjUpdateDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("CUSUPD008"),ChoiceGroup.POPUP));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD009"), cobjCustomerStore.getCustomerPostcode(), 50, TextField.NUMERIC));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD010"), cobjCustomerStore.getCustomerFaxNumber(), 50, TextField.ANY));
      cobjUpdateDisplay.append(new TextField(cobjResourceBundle.getResource("CUSUPD011"), cobjCustomerStore.getCustomerEmailAddress(), 50, TextField.EMAILADDR));
      try {
         java.util.Vector objArray = null;
         cobjCustomerTypeStore.clearFilters();
         objArray = cobjCustomerTypeStore.getDataList();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjUpdateDisplay.get(5)).append(((cCustomerTypeList)objArray.elementAt(i)).getName(), null);
            if (((cCustomerTypeList)objArray.elementAt(i)).getId().equals(cobjCustomerStore.getCustomerTypeId())) {
               ((ChoiceGroup)cobjUpdateDisplay.get(5)).setSelectedIndex(i, true);
            }
         }
         cobjCustomerLocationStore.clearFilters();
         objArray = cobjCustomerLocationStore.getDataList();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjUpdateDisplay.get(6)).append(((cCustomerLocationList)objArray.elementAt(i)).getText(), null);
            if (((cCustomerLocationList)objArray.elementAt(i)).getName().equals(cobjCustomerStore.getCustomerOutletLocation())) {
               ((ChoiceGroup)cobjUpdateDisplay.get(6)).setSelectedIndex(i, true);
            }
         }
         cobjDistributorStore.clearFilters();
         objArray = cobjDistributorStore.getDataList();
         for (int i=0; i<objArray.size(); i++) {
            ((ChoiceGroup)cobjUpdateDisplay.get(7)).append(((cDistributorList)objArray.elementAt(i)).getName(), null);
            if (((cDistributorList)objArray.elementAt(i)).getId().equals(cobjCustomerStore.getCustomerDistributorId())) {
               ((ChoiceGroup)cobjUpdateDisplay.get(7)).setSelectedIndex(i, true);
            }
         }
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjOpenDisplay);
         return;
      }
      for (int i=0; i<cobjUpdateDisplay.size(); i++) {
         ((Item)cobjUpdateDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
       
      //
      // Show the customer update display
      //
      cobjDisplay.setCurrent(cobjUpdateDisplay);
   
   }
   
   /**
    * Actions the update display
    */
   public void actionUpdateDisplay() {
      
      //
      // Update the customer data model as required
      //
      String strOutletType = "";
      String strOutletLocation = "";
      String strWholesaler = "";
      try {
         java.util.Vector objArray = null;
         cobjCustomerTypeStore.clearFilters();
         objArray = cobjCustomerTypeStore.getDataList();
         strOutletType = ((cCustomerTypeList)objArray.elementAt(((ChoiceGroup)cobjUpdateDisplay.get(5)).getSelectedIndex())).getId();
         cobjCustomerLocationStore.clearFilters();
         objArray = cobjCustomerLocationStore.getDataList();
         strOutletLocation = ((cCustomerLocationList)objArray.elementAt(((ChoiceGroup)cobjUpdateDisplay.get(6)).getSelectedIndex())).getName();
         cobjDistributorStore.clearFilters();
         objArray = cobjDistributorStore.getDataList();
         strWholesaler = ((cDistributorList)objArray.elementAt(((ChoiceGroup)cobjUpdateDisplay.get(7)).getSelectedIndex())).getId();
         objArray = null;
      } catch (Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjCreateDisplay);
         return;
      }
      if (((ChoiceGroup)cobjUpdateDisplay.get(0)).isSelected(0)) {
         cobjCustomerStore.setCustomerStatus("A");
      } else {
         cobjCustomerStore.setCustomerStatus("X");
      }
      cobjCustomerStore.setCustomerName(((TextField)cobjUpdateDisplay.get(1)).getString());
      cobjCustomerStore.setCustomerAddress(((TextField)cobjUpdateDisplay.get(2)).getString());
      cobjCustomerStore.setCustomerContactName(((TextField)cobjUpdateDisplay.get(3)).getString());
      cobjCustomerStore.setCustomerPhoneNumber(((TextField)cobjUpdateDisplay.get(4)).getString());
      cobjCustomerStore.setCustomerTypeId(strOutletType);
      cobjCustomerStore.setCustomerOutletLocation(strOutletLocation);
      cobjCustomerStore.setCustomerDistributorId(strWholesaler);
      cobjCustomerStore.setCustomerPostcode(((TextField)cobjUpdateDisplay.get(8)).getString());
      cobjCustomerStore.setCustomerFaxNumber(((TextField)cobjUpdateDisplay.get(9)).getString());
      cobjCustomerStore.setCustomerEmailAddress(((TextField)cobjUpdateDisplay.get(10)).getString());   
      try {
         java.util.Vector objMessages = cobjCustomerStore.validateCustomerModel(cobjResourceBundle);
         if (objMessages.size() != 0) {
            String strMessage = new String("");
            for (int i=0; i<objMessages.size(); i++) {
               if (i > 0) {
                  strMessage = strMessage + "\r\n";
               }
               strMessage = strMessage + (String)objMessages.elementAt(i);
            }
            Alert objAlert = new Alert(null, strMessage, null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
            cobjDisplay.setCurrent(objAlert, cobjUpdateDisplay);
            return;
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjUpdateDisplay);
         return;
      }
      
      //
      // Perform the update on a separate thread
      //
      cobjDisplay.setCurrent(new cUpdateAction());
      
   }
   
   /**
    * This class implements the route open functionality.
    */
   class cOpenAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;
      private String cstrUserName;
      private String cstrPassword;
      private int cintCustomerId;

      /**
       * Constructs a new instance
       */
      public cOpenAction(String strUserName, String strPassword, int intCustomerId) {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("CUSDWNM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cstrUserName = strUserName;
         cstrPassword = strPassword;
         cintCustomerId = intCustomerId;
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
               objOutbox.addMessage(cMailbox.EFEX_RQS_CUSTOMER_ID,cobjCustomerStore.getCustomerId());
            
               //
               // Communicate with the server
               //
               objConnection = new cConnection(cobjResourceBundle);
               String strResponse = objConnection.postDataStream(cobjMobileStore.getSecure(), cobjMobileStore.getServerUrl() + "/CustomerDownload.ashx", objOutbox.getBuffer().toString());

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
                     case cMailbox.EFEX_CUS_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CUS_END: {
                        if (objStoreBuffer.length() != 0) {
                           bolData = true;
                           cobjCustomerStore.updateDataStore(cintCustomerId, objStoreBuffer.toString());
                        }
                        break;
                     }
                     default: {
                        objStoreBuffer = objStoreBuffer.append(objMessage.getMessageData());
                     }
                  }
               }

               //
               // Load the customer data model from the data store using the
               // record identifier from the appended record 
               //
               if (!bolData) {
                  throw new Throwable(cobjResourceBundle.getResource("CUSDWNM02"));
               }
               cobjCustomerStore.loadCustomerModel(cintCustomerId);

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
               loadUpdateDisplay();
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the customer create functionality.
    */
   class cCreateAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cCreateAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("CUSCRTM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
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
               // Add the customer data model to the data store using the
               // record identifier from the index store and release the customer lock
               //
               cobjCustomerStore.addCustomerModel();
               
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
    * This class implements the customer update functionality.
    */
   class cUpdateAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cUpdateAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("CUSUPDM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
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
               // Save the customer data model from the data store using the
               // record identifier from the index store and release the customer lock
               //
               cobjCustomerStore.saveCustomerModel();
               
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
   
}
