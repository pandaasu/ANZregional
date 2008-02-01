<script language="javascript">
<!--
   /////////////////////////////////
   // Classification rules script //
   /////////////////////////////////
   var objRules = new Array();<%for i = objSelection.ListLower("RULE") to objSelection.ListUpper("RULE")%>
   objRules[<%=i%>] = new clsRule('<%=objSelection.ListValue01("RULE",i)%>','(<%=objSelection.ListValue01("RULE",i)%>) <%=replace(objSelection.ListValue02("RULE",i), "'", "\'", 1, -1, 1)%>','<%=objSelection.ListValue03("RULE",i)%>');<%next%>
   function clsRule(strRule,strDescription,strSelected) {
      this.rule = strRule;
      this.description = strDescription;
      this.oldSelected = strSelected;
      this.newSelected = strSelected;
   }
   function selectClassRules() {
      var objSltRule = document.getElementById('sltRule');
      for (var i=0;i<objSltRule.options.length;i++) {
         if (objSltRule.options[i].selected == true) {
            for (var j=0;j<objRules.length;j++) {
               if (objRules[j].rule == objSltRule.options[i].value) {
                  objRules[j].newSelected = '1';
                  break;
               }
            }
         }
      }
      paintClassRules();
   }
   function removeClassRules() {
      var objSltRuleSelected = document.getElementById('sltRuleSelected');
      for (var i=0;i<objSltRuleSelected.options.length;i++) {
         if (objSltRuleSelected.options[i].selected == true) {
            for (var j=0;j<objRules.length;j++) {
               if (objRules[j].rule == objSltRuleSelected.options[i].value) {
                  objRules[j].newSelected = '0';
                  break;
               }
            }
         }
      }
      paintClassRules();
   }
   function checkClassRules() {
      var strReturn = '';
      var objHidden = null;
      var objSltRuleSelected = document.getElementById('sltRuleSelected');
      for (var i=0;i<objSltRuleSelected.options.length;i++) {
         objHidden = document.createElement('input');
         objHidden.setAttribute('type','hidden');
         objHidden.setAttribute('name','DET_Rule'+(i+1));
         objHidden.setAttribute('value',objSltRuleSelected.options[i].value);
         document.forms['main'].appendChild(objHidden);
      }
      document.getElementById('DET_RuleCount').value = objSltRuleSelected.options.length; 
      return strReturn;
   }
   function changeClassRules() {
      var bolReturn = false;
      for (var i=0;i<objRules.length;i++) {
         if (objRules[i].oldSelected != objRules[i].newSelected) {
            bolReturn = true;
            break;
         }
      }
      return bolReturn;
   }
   function paintClassRules() {
      var intRuleCount = -1;
      var objSltRule = document.getElementById('sltRule');
      objSltRule.options.length = 0;
      objSltRule.selectedIndex = -1;
      for (var i=0;i<objRules.length;i++) {
         if (objRules[i].newSelected == '0') {
            intRuleCount++;
            objSltRule.options[intRuleCount] = new Option(objRules[i].description,objRules[i].rule);
         }
      }
      var intRuleSelectedCount = -1;
      var objSltRuleSelected = document.getElementById('sltRuleSelected');
      objSltRuleSelected.options.length = 0;
      objSltRuleSelected.selectedIndex = -1;
      for (var i=0;i<objRules.length;i++) {
         if (objRules[i].newSelected == '1') {
            intRuleSelectedCount++;
            objSltRuleSelected.options[intRuleSelectedCount] = new Option(objRules[i].description,objRules[i].rule);
         }
      }
   }
// -->
</script>