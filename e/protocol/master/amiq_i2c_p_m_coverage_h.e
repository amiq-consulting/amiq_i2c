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
 * NAME:        amiq_i2c_p_m_coverage_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the master coverage definitions related to
 *              protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend has_coverage MASTER amiq_i2c_agent_config_u {
   cover cover_config_on_quit_e is also {
      item bus_is_busy_beh;
      item lost_arb_beh;
      transition lost_arb_beh;
   };

   when HIGH_SPEED'speed_mode {
      cover cover_config_on_quit_e is also {
         item sub_speed_mode using ignore = (sub_speed_mode == HIGH_SPEED);
      };
   };
};

extend has_coverage MASTER amiq_i2c_agent_monitor_u {
   cover arbitration_status_is_ready_e is {
      item arbitration_status;
   };
};

'>