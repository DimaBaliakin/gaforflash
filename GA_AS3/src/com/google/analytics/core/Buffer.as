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
 *   Marc Alcaraz <ekameleon@gmail.com>.
 */

package com.google.analytics.core
{
    import com.google.analytics.config;
    import com.google.analytics.data.UTMA;
    import com.google.analytics.data.UTMB;
    import com.google.analytics.data.UTMC;
    import com.google.analytics.data.UTMK;
    import com.google.analytics.data.UTMV;
    import com.google.analytics.data.UTMZ;
    import com.google.analytics.utils.generateHash;
    
    import flash.events.NetStatusEvent;
    import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
    
    /**
     * Google Analytics Tracker Code (GATC)'s memory module.
     * 
     * note:
     * 
     * 
     */
    public dynamic class Buffer
    {
        private var _SO:SharedObject;
        
        private var _OBJ:Object;
        
        /* indicates if the buffer has a volatile memory
           volatile means we'll lose the memory as soon as the application is closed
           non-volatile means we are saving the memory data on the local hard drive
        */
        private var _volatile:Boolean;
        
        private var _utma:UTMA;
        private var _utmb:UTMB;
        private var _utmc:UTMC;
        private var _utmk:UTMK;
        private var _utmv:UTMV;
        private var _utmz:UTMZ;
        
        /**
         * Creates a new Buffer instance.
         * 
         * volatile: if true no use of SO, only in-memory data
         * data: can be used to inject data into OBJ or SO
         * 
         * note:
         * data should be used to inject the data from the query string
         * 
         */
        public function Buffer( volatile:Boolean = false, data:Object = null )
        {
            if( !volatile )
            {
                _SO = SharedObject.getLocal( config.cookieName, config.cookiePath );
                //_SO.clear();
                
                trace( "---------------------------" );
                trace( "SO size: " + _SO.size );
                trace( "---------------------------" );
                
                if( _SO.data.utma )
                {
                    if( !hasUTMA() )
                    {
                        _createUMTA();
                    }
                    _utma.fromSharedObject( _SO.data.utma );
                    trace( "UTMA = " + _utma.toString() + " found !!" );
                }
                
                if( _SO.data.utmb )
                {
                    if( !hasUTMB() )
                    {
                        _createUMTB();
                    }
                    _utmb.fromSharedObject( _SO.data.utmb );
                    trace( "UTMB = " + _utmb.toString() + " found !!" );
                }
                
                /* note:
                   utmc should always be volatile
                   as we never save it in a cookie, it expires as soon as
                   the user end the session
                */
                if( _SO.data.utmc )
                {
                    delete _SO.data.utmc;
//                    if( !hasUTMC() )
//                    {
//                        _createUMTC();
//                    }
//                    _utmc.fromSharedObject( _SO.data.utmc );
//                    trace( "UTMC = " + _utmc.toString() + " found !!" );
                }
                
                if( _SO.data.utmk )
                {
                    if( !hasUTMK() )
                    {
                        _createUMTK();
                    }
                    _utmk.fromSharedObject( _SO.data.utmk );
                    trace( "UTMK = " + _utmk.toString() + " found !!" );
                }
                
                if( _SO.data.utmv )
                {
                    if( !hasUTMV() )
                    {
                        _createUMTV();
                    }
                    _utmv.fromSharedObject( _SO.data.utmv );
                    trace( "UTMV = " + _utmv.toString() + " found !!" );
                }
                
                if( _SO.data.utmz )
                {
                    if( !hasUTMZ() )
                    {
                        _createUMTZ();
                    }
                    _utmv.fromSharedObject( _SO.data.utmz );
                    trace( "UTMZ = " + _utmz.toString() + " found !!" );
                }
                
            }
            else
            {
                _OBJ = new Object();
                
                if( data )
                {
                    //inject data
                    for( var prop:String in data )
                    {
                        _OBJ[prop] = data[prop];
                    }
                }
                
            }
            
            _volatile = volatile;
            
        }
        
        private function _onFlushStatus( event:NetStatusEvent ):void
        {
            trace("User closed permission dialog...");
            
            switch( event.info.code )
            {
                case "SharedObject.Flush.Success":
                trace("User granted permission -- value saved.");
                break;
                
                case "SharedObject.Flush.Failed":
                trace("User denied permission -- value not saved.");
                break;
            }
            
            _SO.removeEventListener( NetStatusEvent.NET_STATUS, _onFlushStatus );
        }
        
        private function _createUMTA():void
        {
            _utma = new UTMA();
            _utma.proxy = this;
        }
        
        private function _createUMTB():void
        {
            _utmb = new UTMB();
            _utmb.proxy = this;
        }
        
        private function _createUMTC():void
        {
            _utmc = new UTMC();
            //_utmc.proxy = this;
        }
        
        private function _createUMTK():void
        {
            _utmk = new UTMK();
            _utmk.proxy = this;
        }
        
        private function _createUMTV():void
        {
            _utmv = new UTMV();
            _utmv.proxy = this;
        }
        
        private function _createUMTZ():void
        {
            _utmz = new UTMZ();
            _utmz.proxy = this;
        }
        
        public function get utma():UTMA
        {
            if( !hasUTMA() )
            {
                _createUMTA();
            }
            
            return _utma;
        }
        
        public function get utmb():UTMB
        {
            if( !hasUTMB() )
            {
                _createUMTB();
            }
            
            return _utmb;
        }
        
        public function get utmc():UTMC
        {
            if( !hasUTMC() )
            {
                _createUMTC();
            }
            
            return _utmc;
        }
        
        public function get utmk():UTMK
        {
            if( !hasUTMK() )
            {
                _createUMTK();
            }
            
            return _utmk;
        }
        
        public function get utmv():UTMV
        {
            if( !hasUTMV() )
            {
                _createUMTV();
            }
            
            return _utmv;
        }
        
        public function get utmz():UTMZ
        {
            if( !hasUTMZ() )
            {
                _createUMTZ();
            }
            
            return _utmz;
        }
        
        public function hasUTMA():Boolean
        {
            if( _utma )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasUTMB():Boolean
        {
            if( _utmb )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasUTMC():Boolean
        {
            if( _utmc )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasUTMK():Boolean
        {
            if( _utmk )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasUTMV():Boolean
        {
            if( _utmv )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasUTMZ():Boolean
        {
            if( _utmz )
            {
                return true;
            }
            
            return false;
        }
        
        public function hasStoredValue( name:String ):Boolean
        {
            if( isVolatile() )
            {
                if( _OBJ[name] )
                {
                    return true;
                }
                
                return false;
            }
            else
            {
                if( _SO.data[name] )
                {
                    return true;
                }
                
                return false;
            }
        }
        
        public function update( name:String, value:* ):void
        {
            if( isVolatile() )
            {
                _OBJ[name] = value;
            }
            else
            {
                _SO.data[name] = value;
            }
        }
        
        /**
        * This method clears all the fields of the cookie.
        */
        public function clearCookies():void
        {
            utma.reset();
            utmb.reset();
            utmc.reset();
            utmz.reset();
            utmv.reset();
            utmk.reset();
        }
        
        /**
        * This method generates a digest of all the __utm* values.
        */
        public function generateCookiesHash():Number
        {
            var value:String = "";
                value += utma.valueOf();
                value += utmb.valueOf();
                value += utmc.valueOf();
                value += utmz.valueOf();
                value += utmv.valueOf();
            
            return generateHash( value );
        }
        
        public function isVolatile():Boolean
        {
            return _volatile;
        }
        
        public function updateUTMA( timestamp:Number ):void
        {
            trace( ">>>> updateUTMA("+timestamp+")" );
            // if __utma value is not empty, update
            if( !utma.isEmpty() )
            {
                trace( ">>>> utma is not empty" )
                // update session count
                if( isNaN( utma.sessionCount ) )
                {
                    
                    utma.sessionCount = 1;
                }
                else
                {
                    utma.sessionCount += 1;
                }
                trace( ">>>> sessionCount = " + utma.sessionCount )
                
                // last session time, is current session time (update)
                utma.lastTime = utma.currentTime;
                
                // current session time is now
                utma.currentTime = timestamp;
            }
        }
        
        public function save():void
        {
            //we save only when using SharedObject
            if( !isVolatile() )
            {
                var flushStatus:String = null;
                try
                {
                    flushStatus = _SO.flush();
                }
                catch( e:Error )
                {
                    /* note:
                       Flash Player cannot write the shared object to disk.
                       This error might occur if the user has permanently disallowed local
                       information storage for objects from this domain. 
                    */
                    trace("Error...Could not write SharedObject to disk");
                }
                
                switch( flushStatus )
                {
                    case SharedObjectFlushStatus.PENDING:
                    trace("Requesting permission to save object...");
                    _SO.addEventListener( NetStatusEvent.NET_STATUS, _onFlushStatus );
                    break;
                    
                    case SharedObjectFlushStatus.FLUSHED:
                    trace("Value flushed to disk.");
                    break;
                }
            }
        }
        
    }
}
