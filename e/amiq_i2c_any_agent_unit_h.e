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
 * NAME:        amiq_i2c_any_agent_unit_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the generic agent unit
 *              used in the VIP
 *******************************************************************************/

<'

package amiq_i2c;

//any agent unit over which all the agent units of the VIP are build
unit amiq_i2c_any_agent_unit_u like amiq_i2c_any_unit_u {
   //Master or Slave
   const agt_kind : amiq_i2c_agent_kind_t;
   keep soft agt_kind == SLAVE;

   //Index of the agent
   agt_index : uint;
   keep soft agt_index == 0;
};

'>
