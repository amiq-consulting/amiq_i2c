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
 * NAME:        amiq_i2c_i_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C BFM required by
 *              interface logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_bfm_u {
   //Method for determining if SDA line should not be driven, for example when losing arbitration
   skip_drive_sda() : bool is empty;

   //TCM for driving a basic I2C SDA
   drive_item_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
      if(ptr_agent_smp.get_scl_in() == 0) {
         item_to_drive.scl_already_low_when_started_driving = TRUE;
      };

      messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "%s : Start (SCL LOW: %s) driving %s"
         , agt_kind
         , item_to_drive.scl_already_low_when_started_driving
         , item_to_drive.to_string());

      all of {
         {
            drive_scl_with_hooks_tcm(item_to_drive);
         };
         {
            drive_sda_with_hooks_tcm(item_to_drive);
         };
      };

      messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "%s : Done %s driving "
         , agt_kind
         , item_to_drive.to_string());
   };

   //TCM for driving SDA line
   drive_sda_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
      messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "%s: - DRIVE SDA TCM - Start Driving SDA %s", agt_kind, item_to_drive.to_string());


      sync @ptr_bus_mon.bus_monitor_done_e;
      var skip_drive_sda : bool = item_to_drive.force_sda_driving ? FALSE : skip_drive_sda();

      messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "%s: - DRIVE SDA TCM - Skip drive SDA: %s", agt_kind, skip_drive_sda);

      item_to_drive.check_and_fix_item(ptr_agent_config);

      //SCL LOW
      first of {
         {
            if(skip_drive_sda) {
               messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL LOW - (skip) Disable SDA 1", agt_kind);
               wait[1];
               ptr_agent_smp.disable_sda_out();
               messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL LOW - (skip) Disable SDA 2", agt_kind);
            } else {
               var prev_sda_low_element : amiq_i2c_sda_element_s = NULL;
               for each (sda_low_element) in item_to_drive.sda_def.lof_fixed_sda_elements_for_scl_low_phase {
                  var wait_length := sda_low_element.nof_cycles_from_a_scl_transition - 1 - item_to_drive.scl_already_low_when_started_driving.as_a(bit);

                  if(prev_sda_low_element != NULL) {
                     wait_length = sda_low_element.nof_cycles_from_a_scl_transition - prev_sda_low_element.nof_cycles_from_a_scl_transition;
                  };

                  messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL LOW - Waiting %d cycles...", agt_kind, wait_length);
                  wait[wait_length];

                  if (sda_low_element.sda_value == 1) {
                     messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL LOW - Disable SDA", agt_kind);
                     ptr_agent_smp.disable_sda_out();

                  } else {
                     messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL LOW - Drive SDA %d", agt_kind, sda_low_element.sda_value);
                     ptr_agent_smp.enable_and_drive_sda_out(sda_low_element.sda_value);

                  };

                  prev_sda_low_element = sda_low_element;
               };
            };
         };
         {
            sync @ptr_synch.scl_r_e;
            messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL gone HIGH", agt_kind);

         };
      };

      sync @ptr_synch.scl_r_e;

      //SCL HIGH
      first of {
         {
            if(skip_drive_sda) {
               messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL HIGH - (skip) Disable SDA", agt_kind);
            } else {
               var prev_sda_high_element : amiq_i2c_sda_element_s = NULL;
               item_to_drive.check_and_fix_item(ptr_agent_config);

               for each (sda_high_element) in item_to_drive.sda_def.lof_fixed_sda_elements_for_scl_high_phase {
                  var wait_length := sda_high_element.nof_cycles_from_a_scl_transition - 2;

                  if(prev_sda_high_element != NULL) {
                     wait_length = sda_high_element.nof_cycles_from_a_scl_transition - sda_high_element.nof_cycles_from_a_scl_transition;
                  };

                  messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL HIGH - Waiting %d cycles...", agt_kind, wait_length);

                  wait[wait_length];

                  if(sda_high_element.sda_value == 1) {
                     messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL HIGH - Disable SDA", agt_kind);
                     ptr_agent_smp.disable_sda_out();
                  } else {
                     messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL HIGH - Drive SDA %d", agt_kind, sda_high_element.sda_value);
                     ptr_agent_smp.enable_and_drive_sda_out(sda_high_element.sda_value);
                  };
               };
            };
         };
         {
            sync @ptr_synch.scl_f_e;
            messagef(AMIQ_I2C_COMMON_BFM, HIGH, "%s: - DRIVE SDA TCM - SCL gone LOW", agt_kind );
         };
      };

      messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "%s: - DRIVE SDA TCM - Done Driving SDA %s", agt_kind, item_to_drive.to_string());
   };
};

'>