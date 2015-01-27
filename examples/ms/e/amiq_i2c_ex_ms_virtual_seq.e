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
 * NAME:        amiq_i2c_ex_ms_virtual_seq.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the virtual sequence
 *              used in master-slave example.
 *******************************************************************************/
<'

sequence amiq_i2c_ex_virtual_seq using
created_driver = amiq_i2c_ex_virtual_driver_u;

extend amiq_i2c_ex_virtual_driver_u {
   event clock is only @sys.any;

   //pointer to the master agent
   master : MASTER amiq_i2c_agent_u;

   //pointer to the slave agent
   slave  : SLAVE amiq_i2c_agent_u;

   get_sub_drivers() : list of any_sequence_driver is {
      return {master.driver; slave.driver};
   };

   short_name() : string is only {
      return "VIRTUAL_DRV";
   };

   keep soft gen_and_start_main == TRUE;
};

extend amiq_i2c_ex_virtual_seq {
   //Raise an objection to TEST_DONE whenever a sequence is started
   pre_body()@sys.any is first {
      message(LOW, "Raise objection: TEST_DONE");
      driver.raise_objection(TEST_DONE);
      wait @driver.master.ptr_synch.rst_a_e;
      wait [1];
   };

   //Drop the objection to TEST_DONE drain_time clock cycles after the sequence ended
   post_body()@sys.any is also {
      message(LOW, "Drop objection: TEST_DONE");
      driver.drop_objection(TEST_DONE);
   };
};

'>