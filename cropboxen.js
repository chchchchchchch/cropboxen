   var panZoom;var pzSave;var panX = 0;var panY = 0;var pzScale = 1;

   var sArea;

   var editMode = false;
   var selection = false;
   var svgNS = "http://www.w3.org/2000/svg";

   var resizing = false;var resizeTimeout;

   var svgScale;
   var windowWidth;
   var vLList;var vLCount;
   var cBList = [];
   var pendingRm = ""; // WAIT HERE BEFORE BEING REMOVED

// ========================================================================= //
   $(document).ready(function(){
// ------------------------------------------------------------------------- //
   windowWidth = $(window).width();
   svgScale = $('div#svg').width() / svgWidth;
   visibleLayers(); // INIT
// ------------------------------------------------------------------------- //
   sArea = $('#viewport')
           .imgAreaSelect({handles:true,
                           instance:true,
                           onSelectEnd:function(){ selection = true; 
                                                   rmCropBox(pendingRm);
                                                   pendingRm = ""; }
                          });

// ------------------------------------------------------------------------- //
   panZoom = panzoom(document.getElementById('svg'));
   panZoom.on('transform', function(e) {
               panX = panZoom.getTransform().x;
               panY = panZoom.getTransform().y;
               pzScale = panZoom.getTransform().scale;
   });
   panZoom.pause();
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

       visibleLayers();
     });
// ------------------------------------------------------------------------- //
   $("#switchversion").change(function(){ 
     window.location = "?v=" + this.value + "&show=" + srcID;
   });
   $("#switchversion").mouseup(function(event){$(this).blur()});
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

     if ( vLCount < Object.keys(svgLayers).length ) { 
          layers = " --layers=" + vLList;
     } else { layers = ""; }

     if ( vLCount == 0 ) { mdshcode = "NOTHING TO SEE!"
     } else { mdshcode = "% SHOW: " + gitUrl + 
                         " --area=" + x + 
                         ":"        + y +
                         ":"        + w +
                         ":"        + h +
                         layers;
     } 
   
     $('#showmdsh').val(mdshcode);

   }
// ------------------------------------------------------------------------- //   
   function visibleLayers() { // https://stackoverflow.com/questions/1965075

     vLList = "";vLCount = 0
     $('div#layercontrol > input[type=checkbox]').each(function () {
         liD = $(this).attr('id');
         lName = svgLayers[liD];
         var lThisVal = (this.checked ? lName : "");
         if ( lThisVal != "" ) {
         vLList += (vLList=="" ? lThisVal : "," + lThisVal);
         vLCount++;
         }
      });

   }
// ------------------------------------------------------------------------- //   
   function saveView() { // TODO

       canvasWidth = $('div#svg').width();
       svgScale = canvasWidth / svgWidth;

       loadZoom = panZoom.getTransform().scale;
       loadPanX = panZoom.getTransform().x / (loadZoom - 1) * -1; 
       loadPanY = panZoom.getTransform().y / (loadZoom - 1) * -1;

       console.log("saveView");
       console.log("loadPanX: " + loadPanX + " " +
                   "loadPanY: " + loadPanY + " " +
                   "loadZoom: " + loadZoom);
       console.log("");

   }
// ------------------------------------------------------------------------- //   
   function loadView() { // TODO

       $('#svg').removeAttr("style");
       panZoom = panzoom(document.getElementById('svg'));
       panZoom.on('transform', function(e) {
                   panX = panZoom.getTransform().x;
                   panY = panZoom.getTransform().y;
                   pzScale = panZoom.getTransform().scale;
       });
       panZoom.pause();

       loadZoom = 15;
       loadPanX = 800;
       loadPanY = 100;

       panZoom.zoomAbs(loadPanX,loadPanY,loadZoom);   

       console.log("loadView");
       console.log("loadPanX: " + loadPanX + " " +
                   "loadPanY: " + loadPanY + " " +
                   "loadZoom: " + loadZoom);
       console.log("");

   }
// ------------------------------------------------------------------------- //
   function doneResizing(){ resizing = false;
                            popSelection();
                            windowWidth = $(window).width();
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
// ========================================================================= //
//  U I
// ========================================================================= //
   $(document).ready(function(){
// ------------------------------------------------------------------------- //
     window.addEventListener("keydown", function(e) {
      // console.log(e.keyCode);
      // space and arrow keys and return and tab and s and l
      if([32,37,38,39,40,13,9,83,76].indexOf(e.keyCode) > -1) {
          e.preventDefault();
      }
     }, false); 
  // --------------------------------------------------------------------- //
     $(window).bind('keydown',function(e) {

       keyCode = e.keyCode || e.which;

       if ( keyCode == 83) { saveView(); }
       if ( keyCode == 76) { loadView(); }
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

