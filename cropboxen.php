<?php // GLOBALS
      // -------------------------------------------------------------- //
         $mainSrcDir  = "_";
      // -------------------------------------------------------------- //
      // LOAD VARIABLES
      // -------------------------------------------------------------- //
         $boxlist = "_/68b329/7c56127c.bxn";   
         $svgUrl  = "https://github.sfds/adsdsdf/bla.svg";
         $svgWdth = "11916";
         $svgHght = "7087";

  // -----------------------------------------------------------------------  //
     function getCropBoxes($boxlist) {
 
        $list = array_values(array_filter(file($boxlist),"trim"));
 
       // GET FLAG/DATE FOR EACH HASH (=KEY)
       // OVERWRITE ITEM => HAS LATEST STATE/DATE
          $unify = array();
          foreach($list as $line) {
                  $flag = rtrim(substr($line,0,1));
                  if ( $flag != '#' ) {
                       $date = rtrim(substr($line,2,13));
                       $hash = rtrim(substr($line,16,11));
                       $area = rtrim(substr($line,28));
                       $unify[$hash] = array('flag' => $flag,
                                             'area' => $area,
                                             'date' => $date);
                 }
          }
 
       // SELECT/SORT 
          $select = array();
          foreach($unify as $key => $item) {
             $flag = $item['flag'];
             $date = $item['date'];
             $area = $item['area'];
             if ( $flag != 'D' ) {
             $select[$key] = $area;
             }
          }
          asort($select);
 
        return $select;
     }
  // -----------------------------------------------------------------------  //
  
  // -----------------------------------------------------------------------  //
?>
<!doctype html>
<html lang="en">
<head><meta charset="UTF-8">

 <link rel="stylesheet" href="lib/css/svg.css">
 <link rel="stylesheet" href="lib/css/imgareaselect-animated.css">
 <link rel="stylesheet" href="lib/css/imgareaselect-default.css">

 <script src="lib/js/jquery-3.3.1.js"></script>
 <script src="lib/js/jquery.imgareaselect.js"></script>
 <script src="lib/js/jquery.md5.js"></script>
 <script src="lib/js/panzoom.js"></script>
 <script>   var svgUrl = <?php echo '"' . $svgUrl . '"'; ?>;
          var svgWidth = <?php echo $svgWdth; ?>;
             var zeroX = -1646; // srcOffsetX ???
             var zeroY = -1617; // srcOffsetY ???
         var svgLayers = { "5acfd7":"Layer_1",
                           "65f439":"Layer_2",
                           "f27510":"Layer_3",
                           "947d72":"Layer_4" }
 </script>
 <script src="cropboxen.js"></script>
</head>
<body>

<div class="svg" id="svg">
<div class="layer">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="100%" viewBox="0 0 <?php echo $svgWdth." ".$svgHght;?>" id="fillBackground">
<rect x="0" y="0" width="<?php echo $svgWdth; ?>" height="<?php echo $svgHght; ?>" 
      fill="#ff0000" fill-opacity="0.4" stroke="none"></rect>
</svg></div>
<div class="layer src 5acfd7" style="background-image:url('_/68b329/7c56127c_00010_5acfd7.svg');z-index:0001;"></div>
<div class="layer src 65f439" style="background-image:url('_/68b329/7c56127c_00021_65f439.svg');z-index:0002;"></div>
<div class="layer src f27510" style="background-image:url('_/68b329/7c56127c_00031_f27510.svg');z-index:0003;"></div>
<div class="layer src 947d72" style="background-image:url('_/68b329/7c56127c_00041_947d72.svg');z-index:0004;"></div>
<div class="layer" id="selections">
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="100%" viewBox="0 0 <?php echo $svgWdth." ".$svgHght;?>"
     id="showCropBoxes">
<?php $cropBoxes = getCropBoxes($boxlist);
      foreach ($cropBoxes as $id => $area) {

               $x = trim(explode(':',$area)[0]);
               $y = trim(explode(':',$area)[1]);
               $w = trim(explode(':',$area)[2]);
               $h = trim(explode(':',$area)[3]);

               echo '  <rect id="'      . $id . '"' .
                            ' x="'      . $x  . '"' .
                            ' y="'      . $y  . '"' .
                            ' width="'  . $w  . '"' .
                            ' height="' . $h  . '"' .
                            ' class="croparea"' .
                            ' onclick="editCropBox(this)"' .
                            ' onmouseover="showCropBox(this)">' . 
                            '</rect>' . "\n";
      }
?>
</svg></div>
</div>
<div id="viewport" style="position:fixed;width:100vw;height:100vh;z-index:100000"></div>
<div id="layercontrol">
 <input type="checkbox" id="5acfd7" class="layerSwitch" checked="checked">fdsfs <br>
 <input type="checkbox" id="65f439" class="layerSwitch" checked="checked">fdsfs <br>
 <input type="checkbox" id="f27510" class="layerSwitch" checked="checked">fdsfs <br>
 <input type="checkbox" id="947d72" class="layerSwitch" checked="checked">fdsfs <br>
</div>
<div class="showmdsh">
<textarea name="text" wrap="soft" id="showmdsh"></textarea>
</div>

</body>
</html>
