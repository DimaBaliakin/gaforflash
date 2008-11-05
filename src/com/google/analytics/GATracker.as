﻿/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */

package com.google.analytics
{
    
    import com.google.analytics.core.Buffer;
    import com.google.analytics.core.EventTracker; EventTracker;
    import com.google.analytics.core.GIFRequest;
    import com.google.analytics.core.ga_internal;
    import com.google.analytics.core.ServerOperationMode; ServerOperationMode;
    import com.google.analytics.debug.DebugConfiguration;
    import com.google.analytics.debug.Layout;
    import com.google.analytics.external.AdSenseGlobals;
    import com.google.analytics.external.HTMLDOM;
    import com.google.analytics.external.JavascriptProxy;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Version;
    import com.google.analytics.v4.Bridge;
    import com.google.analytics.v4.Configuration;
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    import com.google.analytics.v4.Tracker;
    
    import flash.display.DisplayObject;
    
    /**
    * Google Analytic Tracker Code (GATC)'s code-only component.
    * 
    */
    public class GATracker implements AnalyticsTracker
    {
        private var _built:Boolean = false;
        
        private var _display:DisplayObject;
        private var _tracker:GoogleAnalyticsAPI;
        
        //factory
        private var _config:Configuration;
        private var _debug:DebugConfiguration;
        private var _env:Environment;
        private var _buffer:Buffer;
        private var _gifRequest:GIFRequest;
        private var _jsproxy:JavascriptProxy;
        private var _dom:HTMLDOM;
        private var _adSense:AdSenseGlobals;
        
        //object properties
        private var _account:String;
        private var _mode:String;
        private var _visualDebug:Boolean;
        
        /**
        * note:
        * the GATracker need to be instancied and added to the Stage
        * or at least being placed in a display list.
        * 
        * We mainly use it for internal test and it's basically a factory.
        * 
        */
        public function GATracker( display:DisplayObject, account:String,
                                   mode:String = "AS3", visualDebug:Boolean = false,
                                   config:Configuration = null, debug:DebugConfiguration = null )
        {
            _display = display;
            
            this.account     = account;
            this.mode        = mode;
            this.visualDebug = visualDebug;
            
            if( !debug )
            {
                this.debug = new DebugConfiguration();
            }
            
            if( !config )
            {
                this.config = new Configuration( debug );
            }
            
            if( autobuild )
            {
                _factory();
            }
        }
        
        public static var version:Version = API.version;
        
        public static var autobuild:Boolean = true;
        
        /**
        * @private
        * Factory to build the different trackers
        */
        private function _factory():void
        {
            _built = true;
            
            _jsproxy = new JavascriptProxy( debug );
            
            if( visualDebug )
            {
                debug.layout = new Layout( debug, _display );
                debug.active = visualDebug;
            }
            
            switch( mode )
            {
                case "Bridge":
                _tracker = _bridgeFactory();
                break;
                
                case "AS3":
                default:
                _tracker = _trackerFactory();
            }
            
        }
        
        /**
        * @private
        * Factory method for returning a Tracker object.
        * 
        * @return {GoogleAnalyticsAPI}
        */
        private function _trackerFactory():GoogleAnalyticsAPI
        {
            debug.info( "GATracker (AS3) v" + version +"\naccount: " + account );
            
            /* note:
               for unit testing and to avoid 2 different branches AIR/Flash
               here we will detect if we are in the Flash Player or AIR
               and pass the infos to the LocalInfo
               
               By default we will define "Flash" for our local tests
            */
            
            
            _adSense   = new AdSenseGlobals( debug );
            
            _dom        = new HTMLDOM( debug );
            _dom.cacheProperties();
            
            _env        = new Environment( "", "", "", debug, _dom );
            
            _buffer     = new Buffer( config, debug, false );
            
            _gifRequest = new GIFRequest( config, debug, _buffer, _env );
            
            /* note:
               To be able to obtain the URL of the main SWF containing the GA API
               we need to be able to access the stage property of a DisplayObject,
               here we open the internal namespace to be able to set that reference
               at instanciation-time.
               
               We keep the implementation internal to be able to change it if required later.
            */
            use namespace ga_internal;
            _env.url = _display.stage.loaderInfo.url;
            
            return new Tracker( account, config, debug, _env, _buffer, _gifRequest, _adSense );
        }
        
        /**
        * @private
        * Factory method for returning a Bridge object.
        * 
        * @return {GoogleAnalyticsAPI}
        */
        private function _bridgeFactory():GoogleAnalyticsAPI
        {
            debug.info( "GATracker (Bridge) v" + version +"\naccount: " + account );
            
            return new Bridge( account, _debug, _jsproxy );
        }
        
        public function get account():String
        {
            return _account;
        }
        
        public function set account( value:String ):void
        {
            _account = value;
        }
        
        public function get mode():String
        {
            return _mode;
        }
        
        public function set mode( value:String ):void
        {
            _mode = value;
        }
        
        public function get visualDebug():Boolean
        {
            return _visualDebug;
        }
        
        public function set visualDebug( value:Boolean ):void
        {
            _visualDebug = value;
        }
        
        public function get config():Configuration
        {
            return _config;
        }
        
        public function set config( value:Configuration ):void
        {
            _config = value;
        }
        
        public function get debug():DebugConfiguration
        {
            return _debug;
        }
        
        public function set debug( value:DebugConfiguration ):void
        {
            _debug = value;
        }
        
        public function build():void
        {
            if( !_built )
            {
                _factory();
            }
        }
        
        include "common.txt"
        
    }
}