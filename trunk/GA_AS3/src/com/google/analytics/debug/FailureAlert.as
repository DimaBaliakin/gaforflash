/*
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

package com.google.analytics.debug
{
    import com.google.analytics.config;
    
    /**
    * The FailureAlert allow to indicates visualy a failure.
    * 
    * note:
    * depending on the configuration the alert
    * will display 1 line aligned on the bottom-left
    * or
    * will display aligned in the center with a title 
    * and the full failure information.
    */
    public class FailureAlert extends Alert
    {
        public function FailureAlert( text:String, actions:Array )
        {
            var alignement:Align = Align.bottomLeft;
            var stickToEdge:Boolean = true;
            var actionOnNextLine:Boolean = false;
            
            if( config.debugVerbose )
            {
                text = "<u><span class=\"uiAlertTitle\">Failure</span>"+spaces(18)+"</u>\n\n"+text;
                alignement = Align.center;
                stickToEdge = false;
                actionOnNextLine = true;
            }
            
            super( text, actions, "uiFailure", Style.failureColor, alignement, stickToEdge, actionOnNextLine );
        }
        
    }
}