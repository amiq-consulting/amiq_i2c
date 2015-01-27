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
 * NAME:        amiq_i2c_p_m_monitor.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C master agent monitor
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend MASTER amiq_i2c_agent_monitor_u {
   event bus_is_busy_ready_e is @ptr_bus_mon.bus_is_busy_ready_e;

   //Update arbitration_status
   on bus_is_busy_ready_e {
      if(!ptr_bus_mon.bus_is_busy) {
         arbitration_status = IDLE;
         messagef(HIGH, "Arbitration status -> %s (bus is not busy)", arbitration_status);
      } else if(ptr_agent_smp.get_scl_in() == 1) {
         messagef(HIGH, "cs_decode_phase: %s, cnt_bits: %s, rw: %s", ptr_bus_mon.cs_decode_phase, ptr_bus_mon.cnt_bits, ptr_bus_mon.rw);
         if(
               ((ptr_bus_mon.cs_decode_phase == ADDR) && (ptr_bus_mon.cnt_bits in [0..7, 9]))
            || ((ptr_bus_mon.cs_decode_phase == DATA) && (ptr_bus_mon.rw == READ)  && (ptr_bus_mon.cnt_bits == 8))
            || ((ptr_bus_mon.cs_decode_phase == DATA) && (ptr_bus_mon.rw == WRITE) && (ptr_bus_mon.cnt_bits in [0..7, 9]))
         ) {
            //Lose arbitration if bus is zero driven by others
            if(ptr_agent_smp.get_sda_in() == 0 && ptr_agent_smp.sda_out_en$ == 0) {
               if(arbitration_status == WON) {
                  if(ptr_agent_config.has_checker && ptr_agent_config.as_a(has_checker MASTER amiq_i2c_agent_config_u).amiq_i2c_hs_driving_conflict_err_en) {
                     check AMIQ_I2C_HS_DRIVING_CONFLICT_ERR that ptr_bus_mon.hs_in_progress == FALSE else
                     dut_error("AMIQ_I2C_HS_DRIVING_CONFLICT_ERR: A HIGH SPEED winning master detected a conflict on SDA line. \
                     \nPossible cause: Second source of driving on SDA line");
                  };
               };

               arbitration_status = LOST;
               messagef(HIGH, "Arbitration status -> %s", arbitration_status);
            };

            //Win arbitration if bus is zero driven by me
            if(arbitration_status != LOST && ptr_agent_smp.get_sda_in() == 0 && ptr_agent_smp.sda_out_en$ == 1 && ptr_agent_smp.sda_out$ == 0) {
               arbitration_status = WON;
               messagef(HIGH, "Arbitration status -> %s (driving 0)", arbitration_status);
            };

            if(arbitration_status != LOST && ptr_agent_smp.get_sda_in() == 1  && ptr_agent_smp.sda_out_en$ == 1 && ptr_agent_smp.sda_out$ == 1) {
               arbitration_status = WON;
               messagef(HIGH, "Arbitration status -> %s (driving 1)", arbitration_status);
            };
         } else if(ptr_bus_mon.cs_decode_phase == IDLE) {
            arbitration_status = IDLE;
            messagef(HIGH, "Arbitration status -> %s (cs_decode_phase is IDLE)", arbitration_status);
         };
      };

      emit arbitration_status_is_ready_e;
   };

   event compute_master_logic_e is @ptr_bus_mon.i2c_item_ready_e;

   on compute_master_logic_e {
      if(ptr_bus_mon.cnt_bits == 8 && arbitration_status == WON && ptr_bus_mon.cs_decode_phase == DATA) {
         send_data_mp$(ptr_bus_mon.i2c_byte);
      };
   };
};

'>