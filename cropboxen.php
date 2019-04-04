<?php 

  // -----------------------------------------------------------------------  //
  // GLOBALS
  // -----------------------------------------------------------------------  //
     $srcBasePath = "_";
     $srcID  = "00b329"; // TODO: $_GET

  // -----------------------------------------------------------------------  //
  // LOAD/SET VARIABLES
  // -----------------------------------------------------------------------  //
     $versions = getVersions($srcBasePath."/".$srcID); // TODO: CHECK
     if ( isset( $_GET['v'] )) { 

      $viD = strip_tags(trim($_GET['v'])); // TODO: DIFFERENTS FORMATS/VERIFY

     }

     $boxList = $srcBasePath . "/" . $srcID . "/" . $viD . ".bxn";
     $vConf   = $srcBasePath . "/" . $srcID . "/" . $viD . ".txt";
  // -----------------------------------------------------------------------  //
     $conf = loadConfig($srcBasePath."/".$srcID."/".$viD);
     $layers = getLayers($srcBasePath."/".$srcID."/".$viD,$conf);

     $svgWdth = $conf['W'];
     $svgHght = $conf['H'];
     $zeroX   = explode(':',$conf['AREA'])[0];
     $zeroY   = explode(':',$conf['AREA'])[1];
     $gitUrl  = $conf['GITURL'];
     $bgColor = $conf['BGCOLOR'];     
  // -----------------------------------------------------------------------  //
     function getVersions($srcPath) {

       $versions = array();
       foreach (glob($srcPath."/*.txt") as $version) {

                $fiD       = rtrim(substr($version,-16,12));// TODO: BETTER
                $showDate  = "21.2.2019 10:30";
                $versions[$fiD] = $showDate;
       }

       return $versions;
     }
  // -----------------------------------------------------------------------  //
     function getLayers($vBasePath,$conf) {

      $layers = array();$count = 100001;
      foreach ( glob($vBasePath . "*.svg") as $layerFile ) {

                $liD = rtrim(substr($layerFile,-10,6));
                $layerName = $conf[$liD];
                $visibility = rtrim(substr($layerFile,-12,1));
                $zIndex = substr($count,-4);
                $layers[$liD] = array('layerfile'  => $layerFile,
                                      'layername'  => $layerName,
                                      'zindex'     => $zIndex,
                                      'visibility' => $visibility);
                $count++;
      }

      return $layers;
     }
  // -----------------------------------------------------------------------  //
     function loadConfig($vBasePath) {

         global $gitUrl,$svgWdth,$svgHght;
         $gitUrl  = "https://github.sfds/adsdsdf/bla.svg";
         $svgWdth = "11916";
         $svgHght = "7087";

         $configFile = array_values(array_filter(file($vBasePath.".txt"),"trim"));
    
         $confLoad = array();
         foreach($configFile as $line) {
       
            $key = trim(explode(':',$line)[0]);          
            $val = trim(implode(":",array_slice(explode(':',$line),1)));
            $confLoad[$key] = $val;

         }

         return $confLoad;
     }
  // -----------------------------------------------------------------------  //
     function loadCropBoxes($boxlist) {
 
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
     function humanTime($timestamp) {  


     }
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
 <script>   var gitUrl = <?php echo '"' . $gitUrl . '"'; ?>;
          var svgWidth = <?php echo $svgWdth; ?>;
             var zeroX = <?php echo $zeroX; ?>; // srcOffsetX ???
             var zeroY = <?php echo $zeroY; ?>; // srcOffsetY ???
         var svgLayers = { <?php $comma ="";
                            foreach ($layers as $liD => $layerConf) { 
                                     $layerName = $layers[$liD]['layername'];
                                     echo $comma     . 
                                         '"'         .
                                          $liD       . 
                                         '":"'       . 
                                          $layerName . 
                                         '"';
                            $comma = ",\n                           ";
                         }
                         ?> }
 </script>
 <script src="cropboxen.js"></script>
</head>
<body>
<div class="svg" id="svg">
<div class="layer">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="100%" viewBox="0 0 <?php echo $svgWdth." ".$svgHght;?>" id="fillBackground">
<rect x="0" y="0" width="<?php echo $svgWdth; ?>" height="<?php echo $svgHght; ?>" 
      fill="<?php echo $bgColor; ?>" fill-opacity="0.4" stroke="none"></rect>
</svg></div>
<?php foreach ($layers as $liD => $layerConf) {

               $layerFile  = $layers[$liD]['layerfile'];
               $visibility = $layers[$liD]['visibility'];
               if ( $visibility == 0 ) {
                      $display = "display:none";
               } else { $display = ""; }
               $zIndex     = $layers[$liD]['zindex']; 

               echo '<div class="layer src ' . 
                     $liD . 
                    '" style="background-image:url(\'' .
                     $layerFile .
                    '\');z-index:' . 
                     $zIndex . 
                    ';' .
                     $display .
                    '"></div>' . "\n";
      }
?>
<div class="layer" id="selections">
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="100%" viewBox="0 0 <?php echo $svgWdth." ".$svgHght;?>"
     id="showCropBoxes">
<?php $cropBoxes = loadCropBoxes($boxList);
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
<?php foreach ($layers as $liD => $layerConf) {

               $layerName = $layers[$liD]['layername'];
               $visibility = $layers[$liD]['visibility'];
               if ( $visibility == 0 ) {
                      $checked = "";
               } else { $checked = 'checked="checked"'; }

                 echo ' <input type="checkbox" id="' .
                        $liD . 
                       '" class="layerSwitch" ' . 
                        $checked .
                       'autocomplete="off">' . 
                        $layerName .
                       '<br>' . "\n";
      }
?>
</div>
<div class="showmdsh">
<textarea name="text" wrap="soft" id="showmdsh"></textarea>
</div>
<div id="versions">
<select id="switchversion">
<?php foreach ($versions as $fiD => $showDate) {
      if ( $fiD == $viD ) { 
           $selected = " selected";
      } else { $selected = ""; }
      echo '<option value="' . 
            $fiD . 
           '"' . $selected . '>' . 
            $showDate . '</option>' . "\n";
      }
?>
</select>
</div>

</body>
</html>
