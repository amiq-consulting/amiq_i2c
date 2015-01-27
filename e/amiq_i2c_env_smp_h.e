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
 * NAME:        amiq_i2c_env_smp_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the signal map unit.
 *******************************************************************************/
<'

package amiq_i2c;

//signal map unit
unit amiq_i2c_env_smp_u like amiq_i2c_any_unit_u {
   //Clock
   clock : inout simple_port of bit is instance;
   keep bind(clock, empty);

   //Reset
   reset_n : inout simple_port of bit is instance;
   keep bind(reset_n, empty);

   //SDA bus line (input relative to each agent)
   sda_in  : inout simple_port of bit is instance;
   keep bind(sda_in, empty);

   //SCL bus line (input relative to each agent)
   scl_in  : inout simple_port of bit is instance;
   keep bind(scl_in, empty);
};

'>