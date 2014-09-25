<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Link
 *
 * @author sedinson
 */
class Link {

    //put your code here

    static function Url($controller = "", $action = "", $get = array(), $strget = "") {
        $config = Config::singleton();

        $getTmp = "";
        foreach ($get as $key => $value) {
            $getTmp .= "/$value";
        }

        if (strlen($strget) > 0)
            $strget = ((substr($strget, 0, 1) === "/") ? "" : "/") . $strget;
        if (strlen($action) > 0)
            $action = ((substr($action, 0, 1) === "/") ? "" : "/") . $action;

        return "{$config->get('BaseUrl')}/{$controller}{$action}{$getTmp}{$strget}";
    }

    static function Go($controller = "", $action = "", $get = array(), $strget = "") {
        $config = Config::singleton();

        $getTmp = "";
        foreach ($get as $key => $value) {
            $getTmp .= "/$value";
        }

        if (strlen($strget) > 0)
            $strget = ((substr($strget, 0, 1) === "/") ? "" : "/") . $strget;
        if (strlen($action) > 0)
            $action = ((substr($action, 0, 1) === "/") ? "" : "/") . $action;

        header("Location:{$config->get('BaseUrl')}/{$controller}{$action}{$getTmp}{$strget}");
    }

    static function loadStyle($href, $type = "text/css", $rel = "stylesheet", $media = "screen") {
        $config = Config::singleton();
        $dirBase = (substr($href, 0, 4) === "http") ? "" : $config->get('BaseUrl') . '/';
        echo "<link href=\"{$dirBase}{$href}\" rel=\"{$rel}\" media=\"{$media}\" type=\"{$type}\"/>";
    }

    static function loadScript($src, $type = "text/javascript") {
        $config = Config::singleton();
        $dirBase = (substr($src, 0, 4) === "http") ? "" : $config->get('BaseUrl') . '/';
        echo "<script type=\"{$type}\" src=\"{$dirBase}{$src}\"></script>";
    }

    static function Absolute($directory) {
        $config = Config::singleton();
        $dirBase = (substr($directory, 0, 4) === "http") ? "" : $config->get('BaseUrl') . '/';
        return "{$dirBase}{$directory}";
    }

    static function loadProjectBase() {
        Link::loadScript('Scripts/load.php?file=js/projectbase.min.js&type=text/js');
        echo "<script>Link.setBaseUrl('" . Link::Url() . "');</script>";
    }

}

?>