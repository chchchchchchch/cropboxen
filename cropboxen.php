<?php 

   session_start();
// ------------------------------------------------------------------------- //
// GLOBALS                                                                   //
// ------------------------------------------------------------------------- //
   $srcBasePath = "_";
   $jsPath  = "lib/js/";
   $cssPath = "lib/css/";
   $foo = array();$foo[0] = '/%SRCID%/';$foo[1] = '/%VERSION%/';
   $baseUrl = "https://freeze.sh/_/2019/icebergen/cropboxen.php";
   $urlPattern  = $baseUrl . "?show=%SRCID%&v=%VERSION%";
// ------------------------------------------------------------------------- // 
// CLEAR SESSION VARIABLES                                                   // 
// ------------------------------------------------------------------------- //
   if ( isset($_POST['unset']) ) { session_unset();exit(); }
// ------------------------------------------------------------------------- // 
// DO WRITE                                                                  // 
// ------------------------------------------------------------------------- //
   if ( isset( $_GET['do']) &&
        $_GET['do'] == "w" ) {
    // -------------------------------------------------------------------
   // SAVE CROPBOX
  // -------------------------------------------------------------------- //
     if ( isset($_POST['id']) &&
          isset($_POST['viD']) &&
          isset($_POST['area']) &&
          isset($_POST['flag'])  &&
          isset($_POST['srcID'])  &&
          count($_POST) == 5 ) {

          $id    = strip_tags(trim($_POST['id']));
          $viD   = strip_tags(trim($_POST['viD']));
          $flag  = strip_tags(trim($_POST['flag']));
          $area  = strip_tags(trim($_POST['area']));
          $srcID = strip_tags(trim($_POST['srcID']));

       // VERIFY INPUT

          if ($flag=="D"){$idMatch=true;}
          if ($flag=="A"){if(substr(md5($area),0,11)==$id){$idMatch=true;}}

          if ( $flag == "A" || $flag == "D"           &&
               strlen($id) == 11 && $idMatch           &&
               preg_replace('/[0-9a-f]/','',$id) == ""  &&
               preg_replace('/[0-9:-]/','',$area) == ""  &&
               preg_replace('/[0-9a-f]/','',$viD)  == ""  &&
               preg_replace('/[0-9a-f]/','',$srcID) == "" ){

           $vBasePath = $srcBasePath . "/" . $srcID . "/" .$viD;

           if ( file_exists($vBasePath . ".txt")) {
                $file = $vBasePath . ".bxn";

            if ( file_exists($file) && is_writeable($file) ) {
                 $timestamp = round(microtime(true) * 1000);
                 if ( $flag == "A" ) {
                       $write = $flag.":".$timestamp.":".$id.":".$area;
                 } else if ( $flag == "D" ) {
                              $write = $flag.":".$timestamp.":".$id; 
                 }
                 $f = fopen($file, "a"); // APPEND
                 fwrite($f,$write."\n");
                 // Close the text file
                 fclose($f);
            }
           }
          }
       }
    // -------------------------------------------------------------------
   // SAVE VIEW
  // -------------------------------------------------------------------- //
     if ( isset($_POST['x']) &&
          isset($_POST['y'])  &&
          isset($_POST['z'])   &&
          isset($_POST['id'])   &&
          isset($_POST['viD'])   &&
          isset($_POST['flag'])   &&
          isset($_POST['srcID'])   &&
          isset($_POST['layers'])   &&
          count($_POST) == 8 ) {

          $x      = strip_tags(trim($_POST['x']));
          $y      = strip_tags(trim($_POST['y']));
          $z      = strip_tags(trim($_POST['z']));
          $id     = strip_tags(trim($_POST['id']));
          $viD    = strip_tags(trim($_POST['viD']));
          $flag   = strip_tags(trim($_POST['flag']));
          $srcID  = strip_tags(trim($_POST['srcID']));
          $layers = strip_tags(trim($_POST['layers']));

          $checkid = substr(md5($z.floor($x/40).floor($y/40).$layers),0,11);

          if ( $flag == "A" || $flag == "D"         &&
               strlen($id) == 11 && $id == $checkid  &&
               preg_replace('/[0-9-]/','',$x)  == ""  &&
               preg_replace('/[0-9-]/','',$y)   == ""  &&
               preg_replace('/[0-9\.-]/','',$z)  == ""  &&
               preg_replace('/[0-9a-f]/','',$id)  == ""  &&
               preg_replace('/[0-9a-f]/','',$viD)  == ""  &&
               preg_replace('/[0-9a-f]/','',$srcID) == "" ){

          $vBasePath = $srcBasePath . "/" . $srcID . "/" .$viD;

           if ( file_exists($vBasePath . ".txt")) {
                $file = $vBasePath . ".views";

            if ( file_exists($file) && is_writeable($file) ) {
                 $timestamp = round(microtime(true) * 1000);
                 if ( $flag == "A" ) {
                       $write = $flag.":".
                                $timestamp.":".
                                $id.":".
                                $z.":".
                                $x.":".
                                $y.":".
                                $layers;

                 } else if ( $flag == "D" ) {
                              $write = $flag.":".$timestamp.":".$id; 
                 }
                 $f = fopen($file, "a"); // APPEND
                 fwrite($f,$write."\n");
                 // Close the text file
                 fclose($f);
            }
           }
          }
       }
    // -------------------------------------------------------------------
     exit;
   } 
// ------------------------------------------------------------------------- // 
// DISPLAY/EDIT                                                              // 
// ------------------------------------------------------------------------- // 
   if ( isset($_GET['show']) ) {

     $srcID = strip_tags(trim($_GET['show']));
   
   } else if ( !isset($_GET['show']) && 
                isset($_GET['v'])  ) {

     echo "NO SOURCE BUT VERSION SET. ";
     $viD = strip_tags(trim($_GET['v']));
     $allViD  = array_filter(glob($srcBasePath."/*/*.txt"));
     $viDMatch  = array_values(preg_grep('/'.$viD.'/i',$allViD))[0];

     $srcID = substr($viDMatch,2,6);
   //------
     $bar = array();$bar[0] =  $srcID ;$bar[1] = $viD;
     $altUrl   = preg_replace($foo,$bar,$urlPattern);
     echo '<a href="'.$altUrl.'">MAYBE?</a>';
     exit;

   } else { 

     echo "SOMETHING WENT WRONG. ";
     $allSrcID = array_filter(glob($srcBasePath.'/*'),'is_dir');
     $rndSrcID = substr($allSrcID[array_rand($allSrcID)],-6,6);
   //------
     $bar = array();$bar[0] =  $rndSrcID ;$bar[1] = '0';
     $altUrl   = preg_replace($foo,$bar,$urlPattern);
   //header('Location:'.$altUrl);
     echo '<a href="'.$altUrl.'">MAYBE?</a>';
     exit;

   }
// ------------------------------------------------------------------------- //
  // ==================================================================== //
  // LOAD/SET VARIABLES
  // -------------------------------------------------------------------- //
  // SET AND REDIRECT IF VIEW IS SET
  // -------------------------------------------------------------------- //
     if ( isset($_POST['currentView']) &&
          isset($_POST['currentLayers']) ) { // TODO: VERIFY

      $_SESSION[$srcID.'View'] = strip_tags(trim($_POST['currentView']));
      $_SESSION[$srcID.'Layers'] = strip_tags(trim($_POST['currentLayers']));
      header("Location:".$_SERVER['REQUEST_URI']);

     } 
  // -------------------------------------------------------------------- //
     if ( isset( $_GET['v'] )) { 

      $viD = strip_tags(trim($_GET['v'])); // TODO: DIFFERENT FORMATS/VERIFY

     } else { $viD = "X"; }
  // -------------------------------------------------------------------- //
     $vConf   = $srcBasePath . "/" . $srcID . "/" . $viD . ".txt";
  // -------------------------------------------------------------------- //
     if ( !file_exists($vConf) ) {

     //echo "SOMETHING WENT WRONG. ";
       $allViD  = array_filter(glob($srcBasePath."/".$srcID."/*.txt"));
     //$rndViD  = substr($allViD[array_rand($allViD)],-16,12);
       $lastViD = substr(end($allViD),-16,12);
       $bar = array();$bar[0] =  $srcID ;$bar[1] = $lastViD;
       $altUrl   = preg_replace($foo,$bar,$urlPattern);
     //echo '<a href="'.$altUrl.'">MAYBE?</a>';
       header('Location:'.$altUrl);
       exit;

     }
  // -------------------------------------------------------------------- //
     $versions = getVersions($srcBasePath."/".$srcID); // TODO: CHECK
     $boxList  = $srcBasePath . "/" . $srcID . "/" . $viD . ".bxn";
     $viewList = $srcBasePath . "/" . $srcID . "/" . $viD . ".views";
  // -------------------------------------------------------------------- //
     $conf    = loadConfig($srcBasePath."/".$srcID."/".$viD);
     $layers  = getLayers($srcBasePath."/".$srcID."/".$viD,$conf);

     $svgWdth = getValue($conf,'W','REQUIRED');
     $svgHght = getValue($conf,'H','REQUIRED');
     $srcWdth = getValue($conf,'SRCW','800');
     $zeroX   = explode(':',getValue($conf,'AREA','REQUIRED'))[0];
     $zeroY   = explode(':',getValue($conf,'AREA','REQUIRED'))[1];
     $gitUrl  = getValue($conf,'GITURL','GIT URL MISSING');
     $bgColor = getValue($conf,'BGCOLOR','#ffffff');     
  // -------------------------------------------------------------------- //
     function getVersions($srcPath) {

       $versions = array();
       foreach (glob($srcPath."/*.txt") as $version) {

                $fiD       = rtrim(substr($version,-16,12));// TODO: BETTER
                $showDate  = humanTime($fiD);
                $versions[$fiD] = $showDate;
       }

       return $versions;
     }
  // -------------------------------------------------------------------- //
     function getLayers($vBasePath,$conf) {

      $layers = array();$count = 100001;
      foreach ( glob($vBasePath . "*.svg") as $layerFile ) {

                $liD = rtrim(substr($layerFile,-10,6));
                $layerName = getValue($conf,$liD,'LAYER NAME MISSING');
                $visibility = rtrim(substr($layerFile,-12,1));
                $zIndex = substr($count,-4);
                $layers[$count] = array('zindex'     => $zIndex,                                        
                                        'layerfile'  => $layerFile,
                                        'layername'  => $layerName,
                                        'visibility' => $visibility,
                                        'liD'        => $liD.$zIndex);
                $count++;
      }

      return $layers;

     }
  // -------------------------------------------------------------------- //
     function loadConfig($vBasePath) {

       if ( file_exists($vBasePath.".txt") ) {

         $configFile = array_values(
                        array_filter(
                         file($vBasePath.".txt"),"trim" ) );

         $confLoad = array();
         foreach($configFile as $line) {
       
            $key = trim(explode(':',$line)[0]);          
            $val = trim(implode(":",array_slice(explode(':',$line),1)));
            $confLoad[$key] = $val;

         } return $confLoad;

       } else { echo "CONFIG FILE MISSING. EXITING."; exit;  }

     }
  // -------------------------------------------------------------------- //
     function loadCropBoxes($boxlist) {
 
      if ( file_exists($boxlist) ) {

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
     }
  // -------------------------------------------------------------------- //
     function loadViews($viewlist) {
 
      if ( file_exists($viewlist) ) {

        $list = array_values(array_filter(file($viewlist),"trim"));
 
       // GET FLAG/DATE FOR EACH HASH (=KEY)
       // OVERWRITE ITEM => HAS LATEST STATE/DATE
          $unify = array();
          foreach($list as $line) {
                  $flag = rtrim(substr($line,0,1));
                  if ( $flag != '#' ) {
                       $date = rtrim(substr($line,2,13));
                       $hash = rtrim(substr($line,16,11));
                       if ( $flag == 'A' ) {
                       $rest = rtrim(substr($line,28));
                       } else { $rest = "::::"; }
                       $zoom = explode(':',$rest)[0];
                       $panx = explode(':',$rest)[1];
                       $pany = explode(':',$rest)[2];
                       $lyrs = explode(':',$rest)[3];

                       $unify[$hash] = array('flag' => $flag,
                                             'date' => $date,
                                             'zoom' => $zoom,
                                             'panx' => $panx,
                                             'pany' => $pany,
                                             'lyrs' => $lyrs);
                 }
          }
 
       // SELECT/SORT 
          $select = array();
          foreach($unify as $key => $item) {
             $flag = $item['flag'];
             $date = $item['date'];
             $zoom = $item['zoom'];
             $panx = $item['panx'];
             $pany = $item['pany'];
             $lyrs = $item['lyrs'];
             if ( $flag != 'D' ) {
             $select[$key] = array('zoom' => $zoom,
                                   'panx' => $panx,
                                   'pany' => $pany,
                                   'lyrs' => $lyrs);
             }
          }
          asort($select);
 
        return $select;

      }
     }
  // -------------------------------------------------------------------- //
     function humanTime($time) {  
 
     // date +%y%m%d%H%M%S
        $y = '20' . substr($time,0,2);
        $m = substr($time,2,2);
        $d = substr($time,4,2);
        $H = substr($time,6,2);
        $M = substr($time,8,2);
        $S = substr($time,10,2);

        $humantime = $d.'.'.$m.'.'.$y.' '.'('.$H.':'.$M.':'.$S.')';

        return $humantime;
     }
  // -------------------------------------------------------------------- //
     function getValue($array,$index,$continue = 'NOT REQUIRED') {

        if (isset($array[$index])) { $value = $array[$index];
                                     return $value;
        } else { if ( $continue == "REQUIRED" ) {
                      echo "SOMETHING WENT WRONG";
                      exit;
                 } else if ( $continue != "NOT REQUIRED" ) {
                             return $continue;
                 }
        }
     }
  // -------------------------------------------------------------------- //
?>
<!doctype html>
<html lang="en">
<head><meta charset="UTF-8">
 <link rel="stylesheet" href="<?php echo $cssPath;?>svg.css">
 <style> div.svg { width:80vw;
                   height:<?php echo ceil($svgHght/$svgWdth*80); ?>vw; }
 </style>
 <link rel="stylesheet" href="<?php echo $cssPath;?>imgareaselect-default.css">
 <script src="<?php echo $jsPath;?>jquery-3.3.1.js"></script>
 <script src="<?php echo $jsPath;?>jquery.imgareaselect.js"></script>
 <script src="<?php echo $jsPath;?>jquery.md5.js"></script>
 <script src="<?php echo $jsPath;?>jquery.redirect.js"></script>
 <script src="<?php echo $jsPath;?>panzoom.js"></script>
 <script>      var viD = <?php echo '"' . $viD . '"'; ?>;
             var srcID = <?php echo '"' . $srcID . '"'; ?>;
            var gitUrl = <?php echo '"' . $gitUrl . '"'; ?>;
          var svgWidth = <?php echo $svgWdth; ?>;
         var svgHeight = <?php echo $svgHght; ?>;
          var srcWidth = <?php echo $srcWdth; ?>;
             var zeroX = <?php echo $zeroX; ?>; // srcOffsetX ???
             var zeroY = <?php echo $zeroY; ?>; // srcOffsetY ???
         var svgLayers = { <?php $comma = "";
                            foreach ($layers as $cnt => $layerConf) { 
                                     $liD       = $layers[$cnt]['liD'];
                                     $layerName = $layers[$cnt]['layername'];
                                     echo $comma     . 
                                         '"'         .
                                          $liD       . 
                                         '":"'       . 
                                          $layerName . 
                                         '"';
                            $comma = ",\n                           ";
                         }
                         ?> };

<?php   $savedViews = loadViews($viewList); ?>
        var savedViews = {<?php 
        if ( isset($savedViews) ) {

          $comma = " ";
          foreach ($savedViews as $hash => $view) { 
  
            echo $comma . '"' . $hash . '":' .
                 '[\'' .
                 $savedViews[$hash]['zoom'] .
                 '\',\'' .
                 $savedViews[$hash]['panx'] .
                 '\',\'' .
                 $savedViews[$hash]['pany'] .
                 '\',\'' .
                 $savedViews[$hash]['lyrs'] . '\']';
  
          $comma = ",\n                           ";
          }
        } ?>
 };

 $(document).ready(function(){ 

   windowWidth = $(window).width();                    // INIT
   viewPortCenterX = ($(window).width()/100*80) / 2;   // INIT
   viewPortCenterY = ($(window).height()/100*90) / 2;  // INIT
   svgScale    = $('div#svg').width() / svgWidth;      // INIT
   saveLayerVisibility();                              // INIT
   
                               panZoom = panzoom(document.getElementById('svg'));
                               panZoom.on('transform', function(e) {
                                           panX = panZoom.getTransform().x;
                                           panY = panZoom.getTransform().y;
                                           pzScale = panZoom.getTransform().scale;
                               });
                               panZoom.pause() 
  });
<?php if ( isset($_SESSION[$srcID.'View']) &&
           isset($_SESSION[$srcID.'Layers']) ) {

           $currentView = $_SESSION[$srcID.'View'];
           $currentLayers = $_SESSION[$srcID.'Layers'];

         //echo 'console.log("'. $currentView . '");' . "\n";
         //echo 'console.log("'. $currentLayers . '");' . "\n";

           echo "\n" . ' $(document).ready(function(){' .
                       'setView(' . preg_replace('/:/',',',$currentView) 
                                  . ',"' . $currentLayers . '");});' . "\n\n";
       } ?>
 </script><script src="cropboxen.js"></script>
</head>
<body style="background-color:<?php echo $bgColor; ?>;">
<div class="svg" id="svg">
<div class="layer">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="100%" viewBox="0 0 <?php echo $svgWdth." ".$svgHght;?>" id="fillBackground">
</svg></div>
<?php foreach ($layers as $cnt => $layerConf) {

               $liD        = $layers[$cnt]['liD'];
               $layerFile  = $layers[$cnt]['layerfile'];
               $visibility = $layers[$cnt]['visibility'];
               if ( $visibility == 0 ) {
                      $display = "display:none";
               } else { $display = ""; }
               $zIndex     = $layers[$cnt]['zindex']; 

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
      if ( isset($cropBoxes) ) {
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
      }
?>
</svg></div>
</div>
<div id="viewport" style="position:fixed;width:100vw;height:100vh;z-index:100000"></div>
<div id="layercontrol">
<?php foreach ($layers as $cnt => $layerConf) {

               $liD        = $layers[$cnt]['liD'];
               $layerName  = $layers[$cnt]['layername'];
               $visibility = $layers[$cnt]['visibility'];
               if ( $visibility == 0 ) {
                      $checked = "";
               } else { $checked = 'checked="checked"'; }

                 echo ' <input type="checkbox" id="' .
                        $liD . 
                       '" class="layerSwitch" ' . 
                        $checked .
                       ' autocomplete="off">' . 
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
