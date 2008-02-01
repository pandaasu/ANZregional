<script language="javascript">
<!--
   //////////////////
   // Popup script //
   //////////////////
   var cobjPopup;
   var cobjPopupParent;
   var cobjPopupCallback;
   var cstrPopupValue;
   function doPopupShow(objParent,strUrl,objCallback,strHeading,strValue) {
      if (cobjPopup != null) {
         return;
      }
      cobjPopupParent = objParent;
      cobjPopupCallback = objCallback;
      cstrPopupValue = strValue;
      cobjPopup = document.createElement('div');
      var strText = '<table align=center border=0 cellpadding=0 cellspacing=2 cols=1>';
      strText = strText + '<tr><td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;' + strHeading + '&nbsp;</nobr></td></tr>';
      strText = strText + '<tr><td class="clsLabelBN" align=center colspan=1 nowrap><nobr><select class="clsInputBN" id="sltPopup" name="sltPopup" size=15></select></nobr></td></tr>';
      strText = strText + '<tr><td class="clsLabelBB" align=center colspan=1 nowrap><nobr>&nbsp;</td></tr>';
      strText = strText + '<tr><td class="clsLabelBB" align=center colspan=1 nowrap><nobr><table class="clsTable01" align=center cols=3 cellpadding="0" cellspacing="0"><tr>';
      strText = strText + '<td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPopupCancel();">&nbsp;Cancel&nbsp;</a></nobr></td>';
      strText = strText + '<td align=center colspan=1 nowrap><nobr>&nbsp;</nobr></td>';
      strText = strText + '<td align=center colspan=1 nowrap><nobr><a class="clsButton" href="javascript:doPopupAccept(document.getElementById(\'sltPopup\'));">&nbsp;Accept&nbsp;</a></nobr></td>';
      strText = strText + '</tr></table></nobr></td></tr></table>';
      cobjPopup.innerHTML = strText;
      cobjPopup.style.position = 'absolute';
      cobjPopup.className = 'clsSheet';
      cobjPopup.style.visibility = 'hidden';
      cobjPopupParent.appendChild(cobjPopup);
      var objSelf = this;
      if (window.XMLHttpRequest) {
         objSelf.objRequest = new XMLHttpRequest();
      } else if (window.ActiveXObject) {
         objSelf.objRequest = new ActiveXObject("Microsoft.XMLHTTP");
      }
      objSelf.objRequest.onreadystatechange = function() {doPopupLoad(objSelf);}
      objSelf.objRequest.open("GET",strUrl,false);
      objSelf.objRequest.send(null);
   }
   function doPopupLoad(objSelf) {
      if (objSelf.objRequest.readyState == 4) {
         if (objSelf.objRequest.status == 200) {
            var strResponse = objSelf.objRequest.responseText;
            if (strResponse.substring(0,3) != '*OK') {
               alert(strResponse);
            } else {
               var objSelection = document.getElementById('sltPopup');
               if (objSelection) {
                  objSelection.options.length = 0;
                  objSelection.selectedIndex = -1;
                  var aryReturn = strResponse.substring(3,strResponse.length).split('\n');
                  for (var i=0;i<aryReturn.length;i++) {
                     var intIdx = aryReturn[i].indexOf('\t');
                     if (intIdx != -1) {
                        var strValue = aryReturn[i].substring(0,intIdx);
                        var strText = aryReturn[i].substring(intIdx+1,aryReturn[i].length);
                        objSelection.options[i] = new Option(strText,strValue);
                        if (strValue == cstrPopupValue) {
                           objSelection.options[i].selected = true;
                        }
                     }
                  }
               }
            }
            cobjPopup.style.left = cobjPopupParent.offsetLeft+((cobjPopupParent.offsetWidth/2)-(cobjPopup.offsetWidth/2));
            cobjPopup.style.top = cobjPopupParent.offsetTop+((cobjPopupParent.offsetHeight/2)-(cobjPopup.offsetHeight/2));
            cobjPopup.style.visibility = 'visible';
         } else {
            alert('Request failed - status - '+objSelf.objRequest.status);
            cobjPopupParent.removeChild(cobjPopup);
            cobjPopup = null;
            cobjPopupParent = null;
            cobjPopupCallback = null;
            cstrPopupValue = null;
         }
      }
   }
   function doPopupAccept(objSelection) {
      if (cobjPopup == null) {
         return;
      }
      var strValue = '';
      for (var i=0;i<objSelection.options.length;i++) {
         if (objSelection.options[i].selected == true) {
            strValue = objSelection.options[i].value;
            break;
         }
      }
      if (strValue == null) {
         alert('Selection must be made');
         return;
      }
      cobjPopupCallback(strValue);
      cobjPopupParent.removeChild(cobjPopup);
      cobjPopup = null;
      cobjPopupParent = null;
      cobjPopupCallback = null;
      cstrPopupValue = null;
   }
   function doPopupCancel() {
      if (cobjPopup == null) {
         return;
      }
      cobjPopupCallback('*CANCEL');
      cobjPopupParent.removeChild(cobjPopup);
      cobjPopup = null;
      cobjPopupParent = null;
      cobjPopupCallback = null;
      cstrPopupValue = null;
   }
// -->
</script>