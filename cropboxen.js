   var panZoom;var pzSave;var panX = 0;var panY = 0;var pzScale = 1;

   var sArea;

   var editMode = false;
   var selection = false;
   var svgNS = "http://www.w3.org/2000/svg";

   var resizing = false;var resizeTimeout;

   var svgScale;
   var windowWidth;

// ========================================================================= //
   $(document).ready(function(){
// ------------------------------------------------------------------------- //
   windowWidth = $(window).width();
   svgScale = $('div#svg').width() / svgWidth;
// ------------------------------------------------------------------------- //
   sArea = $('#viewport')
           .imgAreaSelect({handles:true,
                           instance:true,
                           onSelectEnd:function(){ selection = true; }
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
     });
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
           cB.setAttributeNS(null,"x",X)
           cB.setAttributeNS(null,"y",Y);
           cB.setAttributeNS(null,"width",W)
           cB.setAttributeNS(null,"height",H);
           cB.setAttributeNS(null,"id","tmp");
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

       borderWidth = 10;

       svgX = getCoords(sID)[0];
       svgY = getCoords(sID)[1];
       svgW = Number($(sID).attr("width"));
       svgH = Number($(sID).attr("height"));
       sID.remove();

       canvasWidth = $('div#svg').width();
       svgScale = canvasWidth / svgWidth;

       x = svgX + (borderWidth/2 * svgScale * pzScale);
       y = svgY + (borderWidth/2 * svgScale * pzScale);
       w = Math.round(svgW * svgScale * pzScale);
       h = Math.round(svgH * svgScale * pzScale);
 
       sArea.setSelection(x,y,x+w,y+h);
       sArea.setOptions({show:true});
       sArea.update();

   }
// ------------------------------------------------------------------------- //
   function rmCropBox(sID) { // TODO: post
                               sID.remove(); }
// ------------------------------------------------------------------------- //
   function saveCropBox(X,Y,W,H) {

      cB = document.createElementNS(svgNS,"rect");
      iD = $.md5(X + "" + Y + "" + "" + W + "" + ""+  H).substr(0,11);
      cB.setAttributeNS(null,"x",X);
      cB.setAttributeNS(null,"y",Y);
      cB.setAttributeNS(null,"width",W);
      cB.setAttributeNS(null,"height",H);
      cB.setAttributeNS(null,"id",iD);
      cB.setAttributeNS(null,"class","croparea");
    //cB.setAttributeNS(null,"onclick","rmCropBox(this)");
      cB.setAttributeNS(null,"onclick","editCropBox(this)");
      cB.setAttributeNS(null,"onmouseover","showCropBox(this)");
      document.getElementById("showCropBoxes").appendChild(cB);

      // TODO: post

   }
// ------------------------------------------------------------------------- //
   function showCropBox(sID) {

     x = Math.round(zeroX + Number($(sID).attr("x")));
     y = Math.round(zeroY + Number($(sID).attr("y")));
     w = Math.round($(sID).attr("width"));
     h = Math.round($(sID).attr("height"));
     mdshcode = "% SHOW: " + svgUrl + 
                " --area=" + x + 
                ":"        + y +
                ":"        + w +
                ":"        + h;
     $('#showmdsh').val(mdshcode);

   }
// ------------------------------------------------------------------------- //   
   function visibleLayers() {




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
      // space and arrow keys and return and tab
      if([32,37,38,39,40,13,9].indexOf(e.keyCode) > -1) {
          e.preventDefault();
      }
     }, false); 
  // --------------------------------------------------------------------- //
     $(window).bind('keydown',function(e) {

       keyCode = e.keyCode || e.which;

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

             saveCropBox(svgX,svgY,svgW,svgH);
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

