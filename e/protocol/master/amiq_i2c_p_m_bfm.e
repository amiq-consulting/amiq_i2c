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
 * NAME:        amiq_i2c_p_m_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C master BFM
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend MASTER amiq_i2c_bfm_u {
   skip_drive_sda() : bool is {
      case ptr_bus_mon.cs_decode_phase {
         ADDR : {
            result = (ptr_bus_mon.cnt_bits == 7);
            if (ptr_agent_smp.get_scl_in() == 0) {
               result = (ptr_bus_mon.cnt_bits == 8);
            };
         };

         DATA : {
            case ptr_bus_mon.rw {
               READ : {
                  var ack : bool = ptr_bus_mon.ack;

                  if(ptr_bus_mon.cnt_bits == 8) {
                     if(driver.ptr_bus_mon.tmp_i2c_item != NULL) {
                        if(driver.ptr_bus_mon.tmp_i2c_item.scl_def.low_length != 0){
                           if(driver.ptr_bus_mon.tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase.is_empty()
                              || driver.ptr_bus_mon.tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 0) {
                              ack = TRUE;
                           } else {
                              ack = FALSE;
                           };
                        };
                     };
                  };

                  if(ack) {
                     result = (ptr_bus_mon.cnt_bits != 7);
                  };
               };

               WRITE : {
                  result = (ptr_bus_mon.cnt_bits == 7);
               };
            };
         };
      };
      if (ptr_agent_mon.arbitration_status == LOST) {
         result = TRUE;
      };
   };
};

'>