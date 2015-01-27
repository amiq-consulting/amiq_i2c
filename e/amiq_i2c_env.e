/******************************************************************************
 * (C) Copyright 2014 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME:        amiq_i2c_env.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration banner information.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_env_u {
   show_banner() is also {
      out("(c) AMIQ Consulting 2003 - 2015 : www.amiq.com");
      out("Contact: office@amiq.com");
      out("\n");
      out("I2C environment: ", config.env_name);
   };

   when PASSIVE'active_passive amiq_i2c_env_u {
      show_banner() is also {
         out("PASSIVE environment!");
      };
   };
};

'>