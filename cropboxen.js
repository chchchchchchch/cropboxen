   var panZoom;var pzSave;var panX = 0;var panY = 0;var pzScale = 1;

   var sArea;

   var editMode = false;
   var selection = false;
   var svgNS = "http://www.w3.org/2000/svg";

   var resizing = false;var resizeTimeout;

   var svgScale;

   var windowWidth;
   var viewPortCenterX;var viewPortCenterY;

   var cBList = [];
   var pendingRm = ""; // WAIT HERE BEFORE BEING REMOVED

   var layerVisibility;
   var visibleLayersByID;
   var visibleLayersByName;

// ========================================================================= //
   $(document).ready(function(){
// ------------------------------------------------------------------------- //
/*
   windowWidth = $(window).width();                    // INIT
   viewPortCenterX = ($(window).width()/100*80) / 2;   // INIT
   viewPortCenterY = ($(window).height()/100*90) / 2;  // INIT
   svgScale    = $('div#svg').width() / svgWidth;      // INIT
   saveLayerVisibility();                              // INIT
*/
// ------------------------------------------------------------------------- //
   sArea = $('#viewport')
           .imgAreaSelect({handles:true,
                           instance:true,
                           onSelectEnd:function(){ selection = true; 
                                                   rmCropBox(pendingRm);
                                                   pendingRm = ""; }
                          });
// ------------------------------------------------------------------------- //
   $('svg#showCropBoxes > rect').each(function () {

      cBList.push($(this).attr('id'));

   });
// ------------------------------------------------------------------------- //
  // https://alvarotrigo.com/blog/
  // -> firing-resize-event-only-once-when-resizing-is-finished/
   window.addEventListener('resize',function() { 
                           if ( resizing != true ) {
                                pushSelection();
                                resizing = true;
                           }
                           clearTimeout(resizeTimeout);
                           resizeTimeOut = setTimeout(doneResizing(),800);});
// ------------------------------------------------------------------------- //
  // https://stackoverflow.com/questions/13283875/
  // -> how-can-i-stop-a-html-checkbox-from-getting-focus-on-click
  $('input[type=checkbox]').mousedown(function (event) {
                                                  event.preventDefault();});
// ------------------------------------------------------------------------- //
   $('.layerSwitch').click(function() {
       layerName = $(this).attr('id');
       if( $(this).is(':checked')) {
          $('#svg > div.layer.' + layerName).each(function() {
             $(this).show();
          });
       } else {
          $('#svg > div.layer.' + layerName).each(function() {
             $(this).hide();
          });   
       }
       saveLayerVisibility();
     });
// ------------------------------------------------------------------------- //
   $("#switchversion").change(function(){ 
     //window.location = "?v=" + this.value + "&show=" + srcID;
     currentView = getView();
     currentLayers = visibleLayersByID.join("");
     $.redirect("?v=" + this.value + "&show=" + srcID, 
               {currentView:currentView,
                currentLayers:currentLayers},
               "POST","_self");
   });
   //$("#switchversion").mouseup(function(event){$(this).blur()});
// ------------------------------------------------------------------------- //
   })
// ========================================================================= //
// ------------------------------------------------------------------------- //
   function pushSelection() {

      W = sArea.getSelection().width  / svgScale / pzScale;

      if ( W > 0 ) {

           selection = true;
           H = sArea.getSelection().height / svgScale / pzScale;
           X = (sArea.getSelection().x1 - panX) / svgScale / pzScale;
           Y = (sArea.getSelection().y1 - panY) / svgScale / pzScale;
     
           cB = document.createElementNS(svgNS,"rect");
           cB.setAttributeNS(null,"id","tmp");
           cB.setAttributeNS(null,"x",X)
           cB.setAttributeNS(null,"y",Y);
           cB.setAttributeNS(null,"width",W)
           cB.setAttributeNS(null,"height",H);
           cB.setAttributeNS(null,"style","visibility:hidden");
           document.getElementById("showCropBoxes").appendChild(cB);

      } else { selection = false; }

   }
// ------------------------------------------------------------------------- //
   function popSelection() {

      if ( selection == true ) {

           sID = document.getElementById('tmp');
     
           svgX = getCoords(sID)[0];
           svgY = getCoords(sID)[1];
           svgW = Number($(sID).attr("width"));
           svgH = Number($(sID).attr("height"));
           sID.remove();
     
           canvasWidth = $('div#svg').width();
           svgScale = canvasWidth / svgWidth;
     
           x = svgX;y = svgY;
           w = svgW * svgScale * pzScale;
           h = svgH * svgScale * pzScale;
     
           sArea.setSelection(x,y,x+w,y+h);
           sArea.setOptions({show:true});
           sArea.update();

      }
   }
// ------------------------------------------------------------------------- //
   function editCropBox(sID) {

       if ( pendingRm != "" ) {
            rmCropBox(pendingRm);
            pendingRm = ""; 
       }

       iD = $(sID).attr('id');

       strokeWidth = $(sID).css("stroke-width");
       $(sID).css("stroke-width","0");
       svgX = getCoords(sID)[0];
       svgY = getCoords(sID)[1];
       $(sID).css("stroke-width",strokeWidth);

       svgW = Number($(sID).attr("width"));
       svgH = Number($(sID).attr("height"));

    // RM FROM UI BUT WAIT FOR DELETION UNTIL SELECTION CHANGES
       pendingRm = sID;
       i = cBList.indexOf(iD);
       if (i != -1) { cBList.splice(i,1); }
       sID.remove();

       canvasWidth = $('div#svg').width();
       svgScale = canvasWidth / svgWidth;

       x = Math.floor(svgX);
       y = Math.floor(svgY);
       w = Math.ceil(svgW * svgScale * pzScale);
       h = Math.ceil(svgH * svgScale * pzScale);
 
       sArea.setSelection(x,y,x+w,y+h);
       sArea.setOptions({show:true});
       sArea.update();

   }
// ------------------------------------------------------------------------- //
   function rmCropBox(sID) { 
 
      if ( sID != "" ) {

        iD = $(sID).attr('id');
  
        i = cBList.indexOf(iD);
        if (i != -1) { cBList.splice(i,1); }
        $(sID).remove(); 
  
        flag = "D";
        xywh = "0:0:0:0"; 

        $.ajax({
           url: "?do=w",
           data: {flag:flag,area:xywh,id:iD,viD:viD,srcID:srcID},
           datatype: "text",
           type: "POST",
        });

      } // else { console.log("NOTHING TO DO"); }

   }
// ------------------------------------------------------------------------- //
   function drawCropBox(X,Y,W,H) {

      iD = $.md5(X+""+Y+""+""+W+""+""+H).substr(0,11);
      checkCBList = $.grep(cBList,function(e){
                      return e.match(iD);}).length;

      if ( checkCBList <= 0 ) {

        cB = document.createElementNS(svgNS,"rect");
        cB.setAttributeNS(null,"id",iD);
        cB.setAttributeNS(null,"x",X);
        cB.setAttributeNS(null,"y",Y);
        cB.setAttributeNS(null,"width",W);
        cB.setAttributeNS(null,"height",H);
        cB.setAttributeNS(null,"class","croparea");
        cB.setAttributeNS(null,"onclick","editCropBox(this)");
        cB.setAttributeNS(null,"onmouseover","showCropBox(this)");
        document.getElementById("showCropBoxes").appendChild(cB);

        cBList.push(iD);

      }

      pendingRm = ""; // RESET (=> DO NOT DELETE)

  }
// ------------------------------------------------------------------------- //
   function saveCropBox(X,Y,W,H) {

      iD = $.md5(X+""+Y+""+""+W+""+""+H).substr(0,11);
      checkCBList = $.grep(cBList,function(e){
                      return e.match(iD);}).length;

      if ( checkCBList <= 0 ) {
  
        drawCropBox(X,Y,W,H);
        flag = "A";
        xywh = X+":"+Y+":"+W+":"+H; 

        $.ajax({
           url: "?do=w",
           data: {flag:flag,area:xywh,id:iD,viD:viD,srcID:srcID},
           datatype: "text",
           type: "POST",
        });

       }
   }
// ------------------------------------------------------------------------- //
   function showCropBox(sID) {

     x = Math.floor(zeroX + Number($(sID).attr("x")));
     y = Math.floor(zeroY + Number($(sID).attr("y")));
     w = Math.ceil($(sID).attr("width"));
     h = Math.ceil($(sID).attr("height"));

     if ( visibleLayersByName.length < Object.keys(svgLayers).length ) {
          layers = " --layers=" + visibleLayersByName.join(",");
     } else { layers = ""; }

     if ( visibleLayersByName.length == 0 ) { mdshcode = "NOTHING TO SEE!"
     } else { 
                      mdshcode = "% SHOW: " + gitUrl + 
                                 " --area=" + x + 
                                 ":"        + y +
                                 ":"        + w +
                                 ":"        + h +
                                 layers;
     } 
   
     $('#showmdsh').val(mdshcode);

   }
// ------------------------------------------------------------------------- //
   function saveLayerVisibility() {

     layerVisibility = "";     // RESET
     visibleLayersByID = [];   // RESET
     visibleLayersByName = []; // RESET

     $('div#layercontrol > input[type=checkbox]').each(function () {
        liD = $(this).attr('id');
        lName = svgLayers[liD];
        if  ( this.checked ) {

                 visibleLayersByID.push(liD);
                 visibleLayersByName.push(lName);
                 layerVisibility = layerVisibility + "1";

        } else { layerVisibility = layerVisibility + "0"; }

     });

   }
// ------------------------------------------------------------------------- //
   function toggleLayerVisibility(L) {

     if ( L.match(/^([01]*)$/) &&
          L.length  == Object.keys(svgLayers).length ) {
 
          var i = 0;
          $('.layerSwitch').each(function () {
             if ( L.charAt(i) == 0 ) {
                      $(this).prop( "checked",false);
              } else { $(this).prop( "checked",true);
             }
            i++;
          });
     
          var i = 0;
          $('.layer.src').each(function () {
             if ( L.charAt(i) == 0 ) {
                      $(this).hide();
              } else { $(this).show(); 
             }
            i++;
          });
 
     } else {
 
          $('.layerSwitch').each(function () {
            liD = $(this).attr('id');
            if ( L.includes(liD) ) {

                     $(this).prop( "checked",true);
                     $('#svg > div.layer.'+liD).each(function() {
                      $(this).show();
                     });

            } else { $(this).prop( "checked",false);
                     $('#svg > div.layer.'+liD).each(function() {
                      $(this).hide();
                     });
            }
          }); 
     }
   }
// ------------------------------------------------------------------------- //
   function getView() {

      viewZoom = panZoom.getTransform().scale.toFixed(3);
      viewPanX = Math.round(panZoom.getTransform().x);
      viewPanY = Math.round(panZoom.getTransform().y);

      srcViewScale = Number((srcWidth * svgScale / windowWidth) 
                            * viewZoom).toFixed(4);
      srcViewCenterX = Math.round((viewPanX / svgScale / viewZoom - zeroX) 
                       - (viewPortCenterX / svgScale / viewZoom)) * -1;
      srcViewCenterY = Math.round((viewPanY / svgScale / viewZoom - zeroY) 
                       - (viewPortCenterY / svgScale / viewZoom)) * -1;

      thisView = srcViewScale + ":" + srcViewCenterX + ":" + srcViewCenterY;

      return thisView;

   }
// ------------------------------------------------------------------------- //
   function setView(Z,X,Y,L) {

      srcViewScale   = Number(Z);
      srcViewCenterX = Number(X);
      srcViewCenterY = Number(Y);

      toggleLayerVisibility(L);

      viewZoom = Number(srcViewScale 
                       / (srcWidth * svgScale / windowWidth)).toFixed(4);
      viewPanX = ((srcViewCenterX / -1) 
                  + (viewPortCenterX / svgScale / viewZoom)
                  + zeroX) * svgScale * viewZoom;
      viewPanY = ((srcViewCenterY / -1) 
                  + (viewPortCenterY / svgScale / viewZoom)
                  + zeroY) * svgScale * viewZoom;

      panZoom.zoomAbs(0,0,viewZoom);   
      panZoom.moveTo(viewPanX,viewPanY);
      saveLayerVisibility();

   }
// ------------------------------------------------------------------------- //   
   function saveView() {

     thisView = getView();
     Z = thisView.split(':')[0];
     X = thisView.split(':')[1];
     Y = thisView.split(':')[2];
     iD = $.md5(Z 
                +""+ 
                Math.floor(X/40) 
                +""+
                Math.floor(Y/40)
                +""+
                layerVisibility).substr(0,11);

     if ( savedViews[iD] == undefined ) {

     thisView = String(Z+":"+X+":"+Y+":"+layerVisibility).split(':');
     savedViews[iD] = thisView;

     $.ajax({
        url: "?do=w",
        data: {id:iD,
               flag:"A",
               z:Z,x:X,y:Y,
               viD:viD,srcID:srcID,
               layers:layerVisibility},
        datatype: "text",
        type: "POST",
     });

     } //else { console.log("VIEW ALREADY SAVED"); }

   }
// ------------------------------------------------------------------------- //   
   function rmView() {

     thisView = getView();
     Z = thisView.split(':')[0];
     X = thisView.split(':')[1];
     Y = thisView.split(':')[2];
     iD = $.md5(Z 
                +""+ 
                Math.floor(X/40) 
                +""+
                Math.floor(Y/40)
                +""+
                layerVisibility).substr(0,11);

     if ( savedViews[iD] != undefined ) {

          delete savedViews[iD];
          $.ajax({
             url: "?do=w",
             data: {id:iD,
                    flag:"D",
                    z:Z,x:X,y:Y,
                    viD:viD,srcID:srcID,
                    layers:layerVisibility},
             datatype: "text",
             type: "POST",
          });

     } //else { console.log("THIS IS NOT A SAVED VIEW"); }

   }
// ------------------------------------------------------------------------- //
   function doneResizing(){ resizing = false;
                            popSelection();
                            windowWidth = $(window).width();
                            viewPortCenterX = ($(window).width()/100*80) / 2;
                            viewPortCenterY = ($(window).height()/100*90) / 2;
                            svgScale = $('div#svg').width() / svgWidth; }
// ------------------------------------------------------------------------- //
  // https://stackoverflow.com/questions/5598743/
 // -> finding-elements-position-relative-to-the-document
// ----------------------------------------------------------------------- // 
   function getCoords(elem) { // crossbrowser version

       var box = elem.getBoundingClientRect();
       var body = document.body;
       var docEl = document.documentElement;
       var scrollTop = window.pageYOffset 
                       || docEl.scrollTop || body.scrollTop;
       var scrollLeft = window.pageXOffset 
                        || docEl.scrollLeft || body.scrollLeft;
       var clientTop = docEl.clientTop || body.clientTop || 0;
       var clientLeft = docEl.clientLeft || body.clientLeft || 0; 
       var top  = box.top +  scrollTop - clientTop;
       var left = box.left + scrollLeft - clientLeft;
   
     //return { top: Math.round(top), left: Math.round(left) };
     //return [Math.round(left),Math.round(top)];
       return [left,top];
   }
// ------------------------------------------------------------------------- //
   function rndItem(object) {
            keys = Object.keys(object);
            return object[keys[Math.floor(keys.length * Math.random())]];
   };
// ------------------------------------------------------------------------- //
// ========================================================================= //
//  U I
// ========================================================================= //
   $(document).ready(function(){
// ------------------------------------------------------------------------- //
// POST NOTICE IF F5 (UNLOAD) IS PRESSED
// ------------------------------------------------------------------------- //
     $(window).bind('keydown',function(e) {
       keyCode = e.keyCode || e.which;
       if ( keyCode == 116) { 
            $.ajax({url:"cropboxen.php",data:{unset:'session'},
                    datatype: "text",type: "POST"});
       }
     })
// ------------------------------------------------------------------------- //
     window.addEventListener("keydown", function(e) {
      // console.log(e.keyCode);
      // space and arrow keys and return
      // and tab and s and l and d
      if([32,37,38,39,40,13,9,83,76,68].indexOf(e.keyCode) > -1) {
          e.preventDefault();
      }
     }, false); 
  // --------------------------------------------------------------------- //
     $(window).bind('keydown',function(e) {

       keyCode = e.keyCode || e.which;

       if ( keyCode == 76) {
        if ( Object.keys(savedViews).length != 0 ) {
             randomView = rndItem(savedViews);
             Z = randomView[0];X = randomView[1];
             Y = randomView[2];L = randomView[3];
             setView(Z,X,Y,L);
        }
       }
       if ( keyCode == 68) { rmView(); }
       if ( keyCode == 83) { saveView(); }
       if ( keyCode == 9 && editMode != true ) {

            editMode = true;
            pzSave = $('#svg').attr("style"); // SAVE
         // WORKAROUND: MOVE PANZOOM TRANSFORM 
         //             TO SUB ELEMENTS (MAKE CLICKABLE)
            pzMatrix = $('#svg').css("transform"); 
            $('div.layer').each(function() {
              $(this).css({ 'transform':pzMatrix});
            });
            $('#svg').removeAttr("style");
            $('#selections').addClass('onTop');

       }

       if ( editMode != true ) {
        if ( keyCode == 32 ) {

         if (  panZoom.isPaused() ) { 
               sArea.setOptions({disable:true})
               panZoom.resume();
         }
        }

        if ( keyCode == 13 ) {

             svgScale = $('div#svg').width() / svgWidth;
             svgX = Math.round((sArea.getSelection().x1 - panX) 
                               / svgScale / pzScale);
             svgY = Math.round((sArea.getSelection().y1 - panY) 
                               / svgScale / pzScale);
             svgW = Math.round(sArea.getSelection().width 
                               / svgScale / pzScale);
             svgH = Math.round(sArea.getSelection().height 
                               / svgScale / pzScale);

             if ( pendingRm != "" ) {

                 drawCropBox(svgX,svgY,svgW,svgH);

             } else {

                 saveCropBox(svgX,svgY,svgW,svgH);

             }
         }
       }
     })
  // --------------------------------------------------------------------- //
     $(window).bind('keyup',function(e) { 

               keyCode = e.keyCode || e.which;

               if ( keyCode == 32 ) {

                 panZoom.pause();
                 sArea.setOptions({disable:false});

               }

               if ( keyCode == 9 ) {

                 editMode = false;
              // RESTORE PANZOOM TRANSFORM
                 $('div.layer').each(function() {
                    $(this).css({ 'transform':''});
                 });
                 $('#svg').attr("style",pzSave);
                 pzSave = ''; // RESET
                 $('#selections').removeClass('onTop');

               }
     })
  // --------------------------------------------------------------------- //
   })
// ------------------------------------------------------------------------- //

