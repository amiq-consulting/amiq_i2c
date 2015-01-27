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
 * NAME:        amiq_i2c_p_m_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C master agent monitor
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend MASTER amiq_i2c_agent_monitor_u {
   event arbitration_status_is_ready_e;
   //Arbitration status
   !arbitration_status : amiq_i2c_arbitration_status_t;

   //method to determine if the arbitration is lost
   //@return true if arbitration is lost
   is_master_arbitration_lost()    : bool @clk_r_e is empty;

   //method to get the current status of the arbitration
   //@return arbitration status
   get_master_arbitration_status() : amiq_i2c_arbitration_status_t @clk_r_e is empty;

   is_master_arbitration_lost() : bool @clk_r_e is {
      sync @arbitration_status_is_ready_e;
      return arbitration_status == LOST;
   };

   get_master_arbitration_status() : amiq_i2c_arbitration_status_t @clk_r_e is {
      sync @arbitration_status_is_ready_e;
      return arbitration_status;
   };

   quit() is also {
      arbitration_status = IDLE;
   };
};

'>