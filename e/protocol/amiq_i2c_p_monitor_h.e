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
 * NAME:        amiq_i2c_p_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C agent monitor
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_agent_monitor_u {
   //Method port for sending the data
   send_data_mp : out method_port of amiq_i2c_mp_byte_t is instance;
   keep bind(send_data_mp, empty);

   //START symbol event
   event i2c_start_e  is @ptr_bus_mon.i2c_start_e;

   //STOP symbol event
   event i2c_stop_e   is @ptr_bus_mon.i2c_stop_e;

   run() is also  {
       if(ptr_agent_config.has_checker) {
           start check_pads();
       };
   };

   //TCM for checking pads
   check_pads() @clk_r_e is  {
       while(TRUE) {
           if(ptr_agent_config.as_a(has_checker amiq_i2c_agent_config_u).amiq_i2c_illegal_scl_out_value_err_en)  {
               check AMIQ_I2C_ILLEGAL_SCL_OUT_VALUE_ERR that ptr_agent_smp.scl_out$  in  {
                   0;
                   1
               }
               else
               dut_error("AMIQ_I2C_ILLEGAL_SCL_OUT_VALUE_ERR: Illegal value for SCL OUT:", ptr_agent_smp.scl_out$, ".");
           };
           if(ptr_agent_config.as_a(has_checker amiq_i2c_agent_config_u).amiq_i2c_illegal_scl_out_en_value_err_en) {
               check AMIQ_I2C_ILLEGAL_SCL_OUT_EN_VALUE_ERR that ptr_agent_smp.scl_out_en$ in  {
                   0;
                   1
               }
               else
               dut_error("AMIQ_I2C_ILLEGAL_SCL_OUT_EN_VALUE_ERR: Illegal value for SCL OUTPUT ENABLE:", ptr_agent_smp.scl_out_en$, ".");
           };
           if(ptr_agent_config.as_a(has_checker amiq_i2c_agent_config_u).amiq_i2c_illegal_sda_out_value_err_en) {
               check AMIQ_I2C_ILLEGAL_SDA_OUT_VALUE_ERR that ptr_agent_smp.sda_out$  in  {
                   0;
                   1
               }
               else
               dut_error("AMIQ_I2C_ILLEGAL_SDA_OUT_VALUE_ERR: Illegal value for SDA OUT:", ptr_agent_smp.sda_out$, ".");
           };
           if(ptr_agent_config.as_a(has_checker amiq_i2c_agent_config_u).amiq_i2c_illegal_sda_out_en_value_err_en) {
               check AMIQ_I2C_ILLEGAL_SDA_OUT_EN_VALUE_ERR that ptr_agent_smp.sda_out_en$ in  {
                   0;
                   1
               }
               else
               dut_error("AMIQ_I2C_ILLEGAL_SDA_OUT_EN_VALUE_ERR: Illegal value for SDA OUTPUT ENABLE:", ptr_agent_smp.sda_out_en$, ".");
           };
           wait [1];
       };
   };

   when has_coverage {
       event cover_transfer_e is @ptr_bus_mon.as_a(has_coverage amiq_i2c_bus_monitor_u).cover_transfer_e;
   };
};

'>