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
 * NAME:        amiq_i2c_i_bus_monitor.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C monitor required by
 *              interface logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_bus_monitor_u {
   when has_coverage amiq_i2c_bus_monitor_u {
      event cover_item_e is only @i2c_item_ready_e;
   };

   //Sampled I2C item
   !i2c_item : amiq_i2c_item_s;

   //event emitted when an I2C item is ready
   event i2c_item_ready_e;

   //event emitted when I2C bus is busy
   event bus_is_busy_ready_e;

   event bus_monitor_done_e;

   //Item in which data will be collected and analyzed
   !tmp_i2c_item : amiq_i2c_item_s;

   bus_monitor_tcm()@clk_r_e is {
      start bus_is_busy_monitor_tcm();
      start collect_item_tcm();
      if (ptr_env_config.has_checker) {
         if (ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_undetermined_case_err_en){
            start check_sda_during_scl_trans();
         };
         start bus_is_stuck_low_monitor_tcm();
      };
   };


   //Check that SDA is stable during SCL transitions
   //if a SDA transition occurred at the same time with a SCL transition, an undetermined state may result
   check_sda_during_scl_trans()@clk_r_e is {
      var prev_scl : bit = ptr_smp.scl_in$;
      var prev_sda : bit = ptr_smp.sda_in$;

      while(TRUE){
         wait [1];

         if (ptr_smp.scl_in$ != prev_scl && ptr_smp.reset_n$ != 0){
            check AMIQ_I2C_UNDETERMINED_CASE_ERR that ptr_smp.sda_in$ == prev_sda
            else dut_error("AMIQ_I2C_UNDETERMINED_CASE_ERR: A SDA transition occurred at the same time with a SCL transition. This is an undetermined case! SDA should change only on the negative front of SCL.");
         };

         prev_scl = ptr_smp.scl_in$;
         prev_sda = ptr_smp.sda_in$;
      };
   };

   //Called when an item is ready, just before @i2c_item_ready_e
   //in order to allow for protocol level monitor computations
   post_i2c_item_ready() is undefined;

   //TCM to determine if the bus us busy
   bus_is_busy_monitor_tcm()@clk_r_e is {
      //Previous SCL value
      var prev_scl : bit = 1;

      //Previous SDA value
      var prev_sda : bit = 1;

      //Counter for cycles until SDA line is considered released when in IDLE
      var sda_idle_counter : uint = 0;

      //Counter for cycles until SDA line is considered released after a STOP
      var sda_stop_counter : uint = 0;

      while(TRUE) {
         if((ptr_smp.sda_in$ == 1) &&
            (ptr_smp.scl_in$ == 1) &&
            (sda_idle_counter != 0)) {
            //Decrement counter if SDA and SCL are HIGH
            sda_idle_counter -= 1;
         } else if((ptr_smp.sda_in$  == 0) ||
            (ptr_smp.scl_in$  == 0)) {
            //Initialize counter if SDA or SCL are not HIGH
            sda_idle_counter = ptr_env_config.sda_idle_threshold;
         };

         if(prev_scl == 1 && ptr_smp.scl_in$ == 1 && prev_sda == 0 && ptr_smp.sda_in$ == 1) {
            if((ptr_smp.sda_in$  == 1) &&
               (ptr_smp.scl_in$  == 1) &&
               (sda_stop_counter != 0)) {
               //Decrement counter if SDA and SCL are HIGH
               sda_stop_counter -= 1;
            } else if((ptr_smp.sda_in$  == 0) ||
               (ptr_smp.scl_in$  == 0)) {
               //Initialize counter if SDA or SCL are not in HIGH
               sda_stop_counter = ptr_env_config.sda_stop_threshold;
            };
         } else {
            sda_stop_counter = ptr_env_config.sda_stop_threshold;
         };

         prev_scl = ptr_smp.scl_in$;
         prev_sda = ptr_smp.sda_in$;

         bus_is_busy = ((sda_idle_counter != 0) && (sda_stop_counter != 0));

         emit bus_is_busy_ready_e;

         wait[1];
      };
   };

   //TCM for collecting an I2C item
   collect_item_tcm()@bus_is_busy_ready_e is {
      //Assigning memory to local variable
      tmp_i2c_item = new amiq_i2c_item_s with {
         .env_name   = env_name;
      };
      tmp_i2c_item.sda_def = new amiq_i2c_sda_def_s;
      tmp_i2c_item.scl_def = new amiq_i2c_scl_def_s;

      //Collecting variable for LOW front of SCL
      var low_sda_element : amiq_i2c_sda_element_s = new amiq_i2c_sda_element_s;

      //Collecting variable for HIGH front of SCL
      var high_sda_element : amiq_i2c_sda_element_s = new amiq_i2c_sda_element_s;

      //Collecting variable for SCL line
      var scl_def : amiq_i2c_scl_def_s = new amiq_i2c_scl_def_s;

      //Previous SCL value
      var prev_scl : bit;

      //Monitor current state
      var cs_decode_symbol : amiq_i2c_cs_decode_symbol_t = MONITORING;

      while(TRUE) {
         if(ptr_env_config.has_checker) {
            if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_scl_in_on_bus_value_err_en){
               check AMIQ_I2C_ILLEGAL_SCL_IN_ON_BUS_VALUE_ERR that ptr_smp.scl_in$ in {0; 1} else
               dut_error("AMIQ_I2C_ILLEGAL_SCL_IN_ON_BUS_VALUE_ERR: Illegal value for SCL:",ptr_smp.scl_in$, ".");
            };

            if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_sda_in_on_bus_value_err_en){
               check AMIQ_I2C_ILLEGAL_SDA_IN_ON_BUS_VALUE_ERR that ptr_smp.sda_in$ in {0; 1} else
               dut_error("AMIQ_I2C_ILLEGAL_SDA_IN_ON_BUS_VALUE_ERR: Illegal value for SDA:",ptr_smp.sda_in$, ".");
            };
         };

         sample_sda_element(0, tmp_i2c_item, low_sda_element);
         sample_sda_element(1, tmp_i2c_item, high_sda_element);

         //MECHANISM: SCL LINE MONITORING

         if((ptr_smp.scl_in$ == 0) && (prev_scl  == 1)) {
            tmp_i2c_item.scl_def.high_length = scl_def.high_length;
            scl_def.high_length  = 0;
         };

         if((ptr_smp.scl_in$  == 1) && (prev_scl == 0)) {
            tmp_i2c_item.scl_def.low_length = scl_def.low_length;
            scl_def.low_length  = 0;
         };

         scl_def.low_length  = ((ptr_smp.scl_in$ == 0)  ? (scl_def.low_length  + 1) : scl_def.low_length);
         scl_def.high_length = ((ptr_smp.scl_in$  == 1) ? (scl_def.high_length + 1) : scl_def.high_length);

         //MECHANISM: DATA DECODING

         case (cs_decode_symbol) {
            MONITORING : {
               //This state can detect START, STOP, LOGIC_0, LOGIC_1 and ERROR
               //ERROR is treated as an illegal value for the SDA line

               if(ptr_smp.scl_in$  == 1) {
                  //In the HIGH front of the SCL line START, STOP and ERROR can be detected
                  if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase.size() == 2) {
                     if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 1 &&
                        tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[1].sda_value == 0) {
                        //Conditions for a START symbol where satisfied
                        tmp_i2c_item.sda_symbol = START;

                        cs_decode_symbol = START_STOP_RECEIVED;
                     } else if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 0 &&
                        tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[1].sda_value == 1) {

                        //Conditions for a STOP symbol where satisfied
                        tmp_i2c_item.sda_symbol = STOP;

                        cs_decode_symbol = START_STOP_RECEIVED;
                     } else {
                        //Shouldn't happen
                        error("Unknown symbol detected !");
                     };

                     i2c_item = tmp_i2c_item.copy();
                     messagef(MEDIUM,"%s", i2c_item.to_string());
                     post_i2c_item_ready();
                     emit i2c_item_ready_e;
                     send_i2c_item_mp$(i2c_item);

                     init_high_sda_elements(tmp_i2c_item, low_sda_element, high_sda_element);
                  };
               } else if(ptr_smp.scl_in$  == 0) {
                  //In the LOW front of the SCL line LOGIC_0 and LOGIC_1 can be detected
                  if(prev_scl  == 1) {
                     //Falling edge of SCL line detected
                     if(tmp_i2c_item.scl_def.low_length != 0) {

                        //Previous to this falling edge of SCL there was a rising edge of SCL
                        if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 1) {
                           //Conditions for a LOGIC_1 symbol where satisfied
                           tmp_i2c_item.sda_symbol = LOGIC_1;
                        } else if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 0) {
                           //Conditions for a LOGIC_0 symbol where satisfied
                           tmp_i2c_item.sda_symbol = LOGIC_0;
                        } else {
                           //Shouldn't happen
                           error("Unknown symbol detected !");
                        };

                        i2c_item = tmp_i2c_item.copy();
                        messagef(MEDIUM,"%s", i2c_item.to_string());
                        post_i2c_item_ready();
                        emit i2c_item_ready_e;
                        send_i2c_item_mp$(i2c_item);
                     };

                     init_low_sda_elements(tmp_i2c_item, low_sda_element, high_sda_element);
                  };
               };
            };

            START_STOP_RECEIVED : {
               //In this state START, STOP or ERROR can be detected. Exit from this state is also done when SDA line becomes free
               //ERROR is treated as an illegal value for SDA line

               if(ptr_smp.scl_in$  == 1) {
                  //In the HIGH front of the SCL line START, STOP and ERROR can be detected

                  if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase.size() == 2) {
                     if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value  == 1 &&
                        tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[1].sda_value  == 0) {

                        //Conditions for a START symbol where satisfied
                        tmp_i2c_item.sda_symbol = START;
                     } else if(tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value  == 0 &&
                        tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[1].sda_value  == 1) {

                        //Conditions for a STOP symbol where satisfied
                        tmp_i2c_item.sda_symbol = STOP;
                     } else {
                        //Shouldn't happen
                        error("Unknown symbol detected !");
                     };

                     i2c_item = tmp_i2c_item.copy();
                     messagef(MEDIUM,"%s", i2c_item.to_string());
                     post_i2c_item_ready();
                     emit i2c_item_ready_e;
                     send_i2c_item_mp$(i2c_item);

                     init_high_sda_elements(tmp_i2c_item, low_sda_element, high_sda_element);
                  };
               } else if(ptr_smp.scl_in$  == 0) {

                  init_low_sda_elements(tmp_i2c_item, low_sda_element, high_sda_element);

                  cs_decode_symbol = MONITORING;
               };
            };
         };

         prev_scl = ptr_smp.scl_in$;

         emit bus_monitor_done_e;

         wait[1];
      };
   };

   //method for initializing the SDA low elements
   //@param a_i2c_item - pointer to the I2S item
   //@param a_low_sda_element - low SDA element
   //@param a_high_sda_element - high SDA element
   init_low_sda_elements(a_i2c_item: amiq_i2c_item_s, a_low_sda_element : amiq_i2c_sda_element_s, a_high_sda_element : amiq_i2c_sda_element_s) is {
      a_i2c_item.sda_def = new amiq_i2c_sda_def_s;
      a_high_sda_element = new amiq_i2c_sda_element_s;
      a_low_sda_element  = new amiq_i2c_sda_element_s with {
         it.sda_value    = ptr_smp.sda_in$;
         it.nof_cycles_from_a_scl_transition = 0;
      };

      a_i2c_item.sda_def.lof_sda_elements_for_scl_low_phase.add(a_low_sda_element.copy());
      a_low_sda_element.nof_cycles_from_a_scl_transition += 1;
   };

   //method for initializing the SDA high elements
   //@param a_i2c_item - pointer to the I2S item
   //@param a_low_sda_element - low SDA element
   //@param a_high_sda_element - high SDA element
   init_high_sda_elements(a_i2c_item: amiq_i2c_item_s, a_low_sda_element : amiq_i2c_sda_element_s, a_high_sda_element : amiq_i2c_sda_element_s) is {
      a_i2c_item.sda_def = new amiq_i2c_sda_def_s;
      a_high_sda_element = new amiq_i2c_sda_element_s with {
         it.sda_value    = ptr_smp.sda_in$;
         it.nof_cycles_from_a_scl_transition = 0;
      };

      a_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase.add(a_high_sda_element.copy());
      a_high_sda_element.nof_cycles_from_a_scl_transition += 1;
   };

   //method for sampling SDA line
   //@param a_front
   //@param a_i2c_item - pointer to the I2S item
   //@param a_sda_element - pointer to SDA element
   sample_sda_element(a_front: bit, a_i2c_item: amiq_i2c_item_s, a_sda_element : amiq_i2c_sda_element_s) is {
      var lof_sda_elements_to_update : list of amiq_i2c_sda_element_s;

      if(a_front == 0) {
         lof_sda_elements_to_update = a_i2c_item.sda_def.lof_sda_elements_for_scl_low_phase;
      } else {
         lof_sda_elements_to_update = a_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase;
      };

      if(ptr_smp.scl_in$  == a_front) {
         a_sda_element.sda_value = ptr_smp.sda_in$;

         a_sda_element.nof_cycles_from_a_scl_transition += 1;

         if(lof_sda_elements_to_update.size() == 0) {
            lof_sda_elements_to_update.add(a_sda_element.copy());
         } else {
            if(lof_sda_elements_to_update.top().sda_value != a_sda_element.sda_value) {
               lof_sda_elements_to_update.add(a_sda_element.copy());
            };
         };
      } else {
         a_sda_element.nof_cycles_from_a_scl_transition = 0;
      };
   };

   //TCM for checking if the bus is stuck in low state
   bus_is_stuck_low_monitor_tcm()@clk_r_e is {
      var sda_stuck_cnt : uint;
      var scl_stuck_cnt : uint;

      while (TRUE) {
         sda_stuck_cnt = ((ptr_smp.sda_in$ == 0) ? (sda_stuck_cnt + 1) : 0);
         scl_stuck_cnt = ((ptr_smp.scl_in$ == 0) ? (scl_stuck_cnt + 1) : 0);

         if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_scl_stuck_in_low_err_en){
            check AMIQ_I2C_SCL_STUCK_IN_LOW_ERR that (scl_stuck_cnt < ptr_env_config.scl_stuck_low_threshold) else
            dut_error("AMIQ_I2C_SCL_STUCK_IN_LOW_ERR: SCL line stuck in LOW. Threshold reached: ", dec(scl_stuck_cnt));
         };

         if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_sda_stuck_in_low_err_en){
            check AMIQ_I2C_SDA_STUCK_IN_LOW_ERR that (sda_stuck_cnt < ptr_env_config.sda_stuck_low_threshold) else
            dut_error("AMIQ_I2C_SDA_STUCK_IN_LOW_ERR: SDA line stuck in LOW. Threshold reached: ", dec(sda_stuck_cnt));
         };

         wait [1];
      };
   };

   quit() is also {
      i2c_item      = NULL;
      tmp_i2c_item  = NULL;
   };
};

'>