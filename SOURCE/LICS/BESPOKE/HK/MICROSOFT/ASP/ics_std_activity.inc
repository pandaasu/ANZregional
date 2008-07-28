<script language="javascript">
<!--
   /////////////////////
   // Activity script //
   /////////////////////
   var cobjActivity;
   var cobjActivityParent;
   function doActivityStart(objParent) {
      if (cobjActivity != null) {
         return;
      }
      cobjActivityParent = objParent;
      cobjActivity = document.createElement('div');
      cobjActivity.style.position = 'absolute';
      cobjActivity.style.left = cobjActivityParent.offsetLeft+((cobjActivityParent.offsetWidth/2)-200);
      cobjActivity.style.top = cobjActivityParent.offsetTop+((cobjActivityParent.offsetHeight/2)-24);
      cobjActivity.style.height = 48;
      cobjActivity.style.width = 400;
      cobjActivity.style.backgroundColor = '#ffff00';
      cobjActivity.innerHTML = '<table align=center height="100%" width="100%" border=0 cellpadding=0 cellspacing=0 cols=1><tr><td class="clsLabelPB" align=center valign=center><nobr>Processing - Please Wait</nobr></td></tr></table>';
      cobjActivityParent.appendChild(cobjActivity);
   }
   function doActivityStop() {
      if (cobjActivity != null) {
         cobjActivityParent.removeChild(cobjActivity);
      }
      cobjActivity = null;
      cobjActivityParent = null;
   }
// -->
</script>