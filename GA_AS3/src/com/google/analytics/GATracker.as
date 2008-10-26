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
    import com.google.analytics.core.GIFRequest;
    import com.google.analytics.core.as3_api;
    import com.google.analytics.core.ga_internal;
    import com.google.analytics.core.js_bridge;
    import com.google.analytics.debug.Layout;
    import com.google.analytics.events.MessageEvent;
    import com.google.analytics.external.HTMLDOM;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.v4.Bridge;
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    import com.google.analytics.v4.Tracker;
    
    import flash.display.DisplayObject;
    
    
    /**
    * @fileoverview Google Analytic Tracker Code (GATC)'s main component.
    */
    
    public class GATracker
    {
        private var _display:DisplayObject;
        private var _localInfo:Environment;
        private var _buffer:Buffer;
        private var _gifRequest:GIFRequest;
        private var _dom:HTMLDOM;
        
        /**
        * note:
        * the GATracker need to be instancied and added to the Stage
        * or at least being placed in a display list.
        * 
        * We mainly use it for internal test and it's basically a factory.
        * 
        */
        public function GATracker( display:DisplayObject )
        {
            _display   = display;
            debug.layout = new Layout( _display );
            debug.active = true;
            
            /* note:
               for unit testing and to avoid 2 different branches AIR/Flash
               here we will detect if we are in the Flash Player or AIR
               and pass the infos to the LocalInfo
               
               By default we will define "Flash" for our local tests
            */
            _dom        = new HTMLDOM();
            _localInfo  = new Environment( "", "", "", _dom );
            _buffer     = new Buffer( false );
            _gifRequest = new GIFRequest( _buffer, _localInfo );
        }
        
        /**
        * version of our source code (not version of the GA API)
        * 
        * note:
        * each components will have also their own version
        */
        public static var version:String = "0.5.0." + "$Rev$ ".split( " " )[1];
        
        private function _onInfo( event:MessageEvent ):void
        {
            debug.info( event.message );
        }
        
        private function _onWarning( event:MessageEvent ):void
        {
            debug.warning( event.message );
        }
        
        /**
        * Factory method for returning a tracker object.
        * 
        * @param {String} account Urchin Account to record metrics in.
        * @return {GoogleAnalyticsAPI}
        */
        as3_api function getTracker( account:String ):GoogleAnalyticsAPI
        {
            debug.info( "GATracker v" + version +"\naccount: " + account );
            
            config.addEventListener( MessageEvent.INFO, _onInfo );
            config.addEventListener( MessageEvent.WARNING, _onWarning );
            
            /* note:
               To be able to obtain the URL of the main SWF containing the GA API
               we need to be able to access the stage property of a DisplayObject,
               here we open the internal namespace to be able to set that reference
               at instanciation-time.
               
               We keep the implementation internal to be able to change it if required later.
            */
            use namespace ga_internal;
            _localInfo.url = _display.stage.loaderInfo.url;
            return new Tracker( account, _localInfo, _buffer, _gifRequest, null );
        }
        
        /**
        * @private
        */
        js_bridge function getTracker( account:String ):GoogleAnalyticsAPI
        {
            return new Bridge( account );
        }
        
    }
}