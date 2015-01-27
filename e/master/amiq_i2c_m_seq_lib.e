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
 * NAME:        amiq_i2c_m_seq_lib.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the implementation of the sequences which are part
 *              of the sequence library of the master I2C agent.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_m_seq {
   //TCM for deciding depending on bus_is_busy_beh whether or not the master should continue driving
   should_transfer_be_dropped() : bool @driver.clock is undefined;

   //Method for testing if the monitor is receiving so far an ACKNOWLEDGE
   check_receiving_ack_m() : bool is undefined;
};

extend amiq_i2c_m_seq {
   should_transfer_be_dropped() : bool @driver.clock is {
      result = TRUE;

      if(driver.ptr_agent_mon.get_master_arbitration_status() in {IDLE; LOST} && driver.ptr_bus_mon.bus_is_busy){
         case driver.ptr_agent_config.bus_is_busy_beh {
            DROP_TRANSFER : {
               messagef(MEDIUM, "Should drop transfer...");
               result = FALSE;
            };

            WAIT_FREE_LINE : {
               messagef(MEDIUM, "Wait for free line...");
               while (driver.ptr_bus_mon.bus_is_busy) {
                  wait [1];
                  sync @driver.ptr_bus_mon.bus_monitor_done_e;
               };
            };
         };
      };

      messagef(MEDIUM, "Continue driving: %s", result);
   };

   //Method for testing if the monitor is receiving so far an ACKNOWLEDGE
   check_receiving_ack_m() : bool is {
      if(driver.ptr_agent_mon.ptr_agent_smp.get_scl_in() == 1) {
         if(driver.ptr_bus_mon.tmp_i2c_item != NULL) {
            if(driver.ptr_bus_mon.tmp_i2c_item.sda_def.lof_sda_elements_for_scl_high_phase[0].sda_value == 0) {
               result = TRUE;
            };
         };
      } else {
         if(driver.ptr_bus_mon.i2c_item != NULL) {
            result = (driver.ptr_bus_mon.i2c_item.sda_symbol == LOGIC_0);
         };
      };
   };
};


extend SYMBOL amiq_i2c_m_seq {
   !amiq_i2c_item : MASTER amiq_i2c_item_s;

   body()@driver.clock is only {
      messagef(MEDIUM, "Driving symbol %s", i2c_symbol.sda_symbol);
      do amiq_i2c_item keeping {
         it == i2c_symbol.copy();
      };
   };
};


extend BYTE amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;

   body()@driver.clock is only {

      if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
         if(speed_mode == HIGH_SPEED) {
            if(driver.ptr_bus_mon.hs_in_progress == FALSE) {
               if(driver.ptr_agent_config.en_war_p_m_00) {
                  warning("AMIQ_I2C_P_M_WARNING_00: Trying to drive a byte in HIGH SPEED mode but the monitor did not detected a HIGH SPEED master code\
                  \n\tTO DISABLE WARNING: en_war_p_m_00 == FALSE");
               };
            };
         };

         for i from 7 down to 0 {
            if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
               if(driver.ptr_agent_config.lost_arb_beh == DROP_IMM) {
                  break;
               } else if(driver.ptr_agent_config.lost_arb_beh == DROP_AFTER_BYTE) {
                  messagef(MEDIUM,"Driving bit %d with value %d", i, data[i:i]);
                  do amiq_i2c_symbol keeping {
                     .driver                == driver;
                     .i2c_symbol.sda_symbol == LOGIC_1;
                     .i2c_symbol.speed_mode == speed_mode;
                  };
               };
            } else {
               messagef(MEDIUM,"Driving bit %d with value %d", i, data[i:i]);
               do amiq_i2c_symbol keeping {
                  .driver                == driver;
                  .i2c_symbol.sda_symbol == ((data[i:i] == 1) ? LOGIC_1 : LOGIC_0);
                  .i2c_symbol.speed_mode == speed_mode;
               };
            };
         };

         if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
            if(driver.ptr_agent_config.lost_arb_beh == DROP_AFTER_BYTE) {
               messagef(MEDIUM,"Driving ACK bit with value %s", ack);
               do amiq_i2c_symbol keeping {
                  .driver                == driver;
                  .i2c_symbol.sda_symbol == (ack ? LOGIC_0 : LOGIC_1);
                  .i2c_symbol.speed_mode == speed_mode;
               };
            };
         } else {
            messagef(MEDIUM,"Driving ACK bit with value %s", ack);
            do amiq_i2c_symbol keeping {
               .driver                == driver;
               .i2c_symbol.sda_symbol == (ack ? LOGIC_0 : LOGIC_1);
               .i2c_symbol.speed_mode == speed_mode;
            };
         };
      };
   };
};


extend TRANSFER amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   hook_address_acknowledged(seq : amiq_i2c_m_seq) is empty;

   body() @driver.clock is only {
      messagef(MEDIUM, "Start driving TRANSFER!");

      var drop_transfer : bool = !should_transfer_be_dropped();

      if(drop_transfer) {
         messagef(LOW, "Dropped TRANSFER!");
         return;
      };

      var all_ok : bool = TRUE;

      if(speed_mode == HIGH_SPEED) {
         if(driver.ptr_bus_mon.hs_in_progress == FALSE) {
            if(driver.ptr_agent_config.en_war_p_m_01) {
               warning("AMIQ_I2C_P_M_WARNING_01: Trying to drive a transfer in HIGH SPEED mode but the monitor did not detected a HIGH SPEED master code\
               \n\tTO DISABLE WARNING: en_war_p_m_01 == FALSE");
            };
         };
      };

      messagef(MEDIUM, "Start driving START symbol!");
      do amiq_i2c_symbol keeping {
         .driver                == driver;
         .i2c_symbol.sda_symbol == START;
         .i2c_symbol.speed_mode == speed_mode;
      };

      if(driver.ptr_agent_mon.is_master_arbitration_lost()
         || (driver.ptr_bus_mon.i2c_item != NULL && driver.ptr_bus_mon.i2c_item.sda_symbol != START)) {
         messagef(MEDIUM,"START symbol failed %s, %s!", driver.ptr_agent_mon.arbitration_status, driver.ptr_bus_mon.i2c_item);
         all_ok = FALSE;
      } else {
         messagef(MEDIUM,"START symbol succeeded %s, %s!", driver.ptr_agent_mon.arbitration_status, driver.ptr_bus_mon.i2c_item);
         //DRIVE ADDRESS
         case(addr_mode) {
            AM_7BITS : {
               messagef(LOW, "Start driving address: %02X in 7-BITS mode. direction: %s", addr[6:0], rw);

               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == %{addr[6:0], rw.as_a(bit)};
                  .ack        == FALSE;
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  all_ok = FALSE;
               };

               if(all_ok) {
                  //Check that so far the monitor is receiving an ack
                  sync @driver.ptr_bus_mon.bus_monitor_done_e;
                  var receiving_ack : bool = check_receiving_ack_m();

                  if(receiving_ack == FALSE) {
                     messagef(LOW,"No SLAVE ACK for address: %X", addr[6:0]);
                     all_ok = FALSE;

                     if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        if(has_stop) {
                           messagef(MEDIUM, "Start driving STOP symbol!");
                           do amiq_i2c_symbol keeping {
                              .driver                == driver;
                              .i2c_symbol.sda_symbol == STOP;
                              .i2c_symbol.speed_mode == speed_mode;
                           };
                           messagef(MEDIUM, "Done driving STOP symbol!");
                        } else {
                           messagef(MEDIUM, "Skip driving STOP symbol!");
                        };
                     };
                  } else {
                     messagef(MEDIUM,"Got SLAVE ACK for address: %X", addr[6:0]);
                  };
               };
            };

            AM_10BITS : {
               messagef(LOW, "Start driving address: %02X in 10-BITS mode. direction: %s", addr, rw);

               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == %{5'b1111_0, addr[9:8], 1'b0};
                  .ack        == FALSE;
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  all_ok = FALSE;
               };

               if(all_ok) {
                  sync @driver.ptr_bus_mon.bus_monitor_done_e;
                  var receiving_ack : bool = check_receiving_ack_m();

                  if(receiving_ack == FALSE) {
                     messagef(LOW,"No SLAVE ACK for address: %X", addr);
                     all_ok = FALSE;

                     if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        if(has_stop) {
                           do amiq_i2c_symbol keeping {
                              .driver                == driver;
                              .i2c_symbol.sda_symbol == STOP;
                              .i2c_symbol.speed_mode == speed_mode;
                           };
                        };
                     };
                  } else {
                     messagef(LOW,"Got SLAVE ACK for address: %X", addr);
                     do amiq_i2c_byte keeping {
                        .driver     == driver;
                        .data       == addr[7:0];
                        .ack        == FALSE;
                        .speed_mode == speed_mode;
                     };

                     if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        all_ok = FALSE;
                     };

                     if(all_ok) {
                        //Check that so far the monitor is receiving an ack
                        sync @driver.ptr_bus_mon.bus_monitor_done_e;
                        var receiving_ack : bool = check_receiving_ack_m();

                        if(receiving_ack == FALSE) {
                           messagef(LOW,"No SLAVE ACK for address: %X", addr);
                           all_ok = FALSE;

                           if(has_stop) {
                              if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                                 do amiq_i2c_symbol keeping {
                                    .driver                == driver;
                                    .i2c_symbol.sda_symbol == STOP;
                                    .i2c_symbol.speed_mode == speed_mode;
                                 };
                              };
                           };
                        } else {
                           messagef(LOW,"Got SLAVE ACK for address: %X", addr);
                           if(rw == READ) {
                              if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                                 do amiq_i2c_symbol keeping {
                                    .driver                == driver;
                                    .i2c_symbol.sda_symbol == START;
                                    .i2c_symbol.speed_mode == speed_mode;
                                 };

                                 do amiq_i2c_byte keeping {
                                    .driver     == driver;
                                    .data       == %{5'b1111_0, addr[9:8], 1'b1};
                                    .ack        == FALSE;
                                    .speed_mode == speed_mode;
                                 };

                                 if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                                    all_ok = FALSE;
                                 };

                                 if(all_ok) {
                                    //Check that so far the monitor is receiving an ack
                                    sync @driver.ptr_bus_mon.bus_monitor_done_e;
                                    var receiving_ack : bool = check_receiving_ack_m();

                                    if(receiving_ack == FALSE) {
                                       messagef(LOW,"No SLAVE ACK for address: %X", addr);
                                       all_ok = FALSE;

                                       if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                                          if(has_stop) {
                                             do amiq_i2c_symbol keeping {
                                                .driver                == driver;
                                                .i2c_symbol.sda_symbol == STOP;
                                                .i2c_symbol.speed_mode == speed_mode;
                                             };
                                          };
                                       };
                                    } else {
                                       messagef(MEDIUM,"Got SLAVE ACK for address: %X", addr);
                                    };
                                 };
                              };
                           };
                        };
                     };
                  };
               };
            };
         };
      };
      //DRIVE DATA
      if(all_ok) {

      	hook_address_acknowledged(me);

         if(me is a WRITE'rw TRANSFER amiq_i2c_m_seq (tr_wr)) {
            for each (data) in tr_wr.data_l {
               messagef(LOW, "Start driving WRITE DATA: %02X", data);

               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == data;
                  .ack        == FALSE;
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  messagef(LOW, "Lost arbitration!");
                  all_ok = FALSE;
                  break;
               };

               //Check that so far the monitor is receiving an ack
               sync @driver.ptr_bus_mon.bus_monitor_done_e;
               var receiving_ack : bool = check_receiving_ack_m();

               if(receiving_ack == FALSE) {
                  messagef(MEDIUM,"No SLAVE ACK at last data transfer");
                  break;
               } else {
                  messagef(MEDIUM,"Got SLAVE ACK at last data transfer");
               };

               messagef(MEDIUM, "Done writing WRITE DATA: %02X", data);
            };
         } else if(me is a READ'rw TRANSFER amiq_i2c_m_seq (read_transfer)) {
            for i from 1 to read_transfer.num_rd {
               messagef(MEDIUM, "Start driving READ DATA");

               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == 0xFF;
                  .ack        == (i != read_transfer.num_rd);
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  messagef(LOW, "Lost arbitration!");
                  all_ok = FALSE;
                  break;
               };

               messagef(MEDIUM, "Done writing READ DATA");
            };
         };

         if(all_ok) {
            if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
               if(has_stop) {
                  do amiq_i2c_symbol keeping {
                     .driver                == driver;
                     .i2c_symbol.sda_symbol == STOP;
                     .i2c_symbol.speed_mode == speed_mode;
                  };
                  driver.ptr_agent_mon.ptr_agent_smp.enable_and_drive_scl_out(0);

               } else {
                  driver.ptr_agent_mon.ptr_agent_smp.enable_and_drive_scl_out(0);
               };
            };
         };
      } else {
         driver.ptr_agent_mon.ptr_agent_smp.enable_and_drive_scl_out(0);
      };
      sync true(driver.ptr_bus_mon.ptr_smp.scl_in$ == 0);
      driver.ptr_agent_mon.ptr_agent_smp.disable_outputs();
   };
};


extend GENERAL_CALL amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   body() @driver.clock is {
      var all_ok : bool = should_transfer_be_dropped();

      if(all_ok) {

         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == START;
            .i2c_symbol.speed_mode == speed_mode;
         };

         do amiq_i2c_byte keeping {
            .driver     == driver;
            .data       == 0;
            .ack        == FALSE;
            .speed_mode == speed_mode;
         };

         var all_ok : bool = TRUE;

         if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
            all_ok = FALSE;
         };

         if(all_ok) {
            //Check that so far the monitor is receiving an ack
            var receiving_ack : bool = check_receiving_ack_m();

            if(receiving_ack == FALSE) {
               messagef(MEDIUM,"No acknowledge at last data transfer");
               if(has_stop) {
                  do amiq_i2c_symbol keeping {
                     .driver                == driver;
                     .i2c_symbol.sda_symbol == STOP;
                     .i2c_symbol.speed_mode == speed_mode;
                  };
               };
            } else {
               messagef(LOW, "Driving MASTER DATA: %02X", data);
               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == data;
                  .ack        == FALSE;
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  all_ok = FALSE;
               };

               if(all_ok) {
                  if(has_stop) {
                     do amiq_i2c_symbol keeping {
                        .driver                == driver;
                        .i2c_symbol.sda_symbol == STOP;
                        .i2c_symbol.speed_mode == speed_mode;
                     };
                  };
               };
            };
         };
      };
   };
};


extend HARDWARE_GENERAL_CALL amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   body() @driver.clock is {
      var all_ok : bool = should_transfer_be_dropped();

      if(all_ok) {
         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == START;
            .i2c_symbol.speed_mode == speed_mode;
         };

         messagef(LOW, "Driving HARDWARE GENERAL CALL - ADDR_MODE: %s, ADDR:%X", addr_mode, addr);

         do amiq_i2c_byte keeping {
            .driver     == driver;
            .data       == 0;
            .ack        == FALSE;
            .speed_mode == speed_mode;
         };

         var all_ok : bool = TRUE;

         if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
            all_ok = FALSE;
         };

         if(all_ok) {
            //Check that so far the monitor is receiving an ack
            var receiving_ack : bool = check_receiving_ack_m();

            if(receiving_ack == FALSE) {
               messagef(MEDIUM,"No acknowledge at last data transfer");
               if(has_stop) {
                  do amiq_i2c_symbol keeping {
                     .driver                == driver;
                     .i2c_symbol.sda_symbol == STOP;
                     .i2c_symbol.speed_mode == speed_mode;
                  };
               };
            } else {
               var data_l : list of byte = data_l.copy();

               case addr_mode {
                  AM_7BITS : {
                     data_l.push0(%{addr[6:0], 1'b1}[7:0]);
                  };

                  AM_10BITS : {
                     data_l.push0(%{5'b1111_0, addr[9:8], 1'b1}[7:0]);
                     data_l.push0(addr[7:0]);
                  };
               };

               for each (data) in data_l {
                  if(index >= (data_l.size() - data_l.size())) {
                     messagef(LOW, "Driving MASTER DATA: %02X", data);
                  };

                  do amiq_i2c_byte keeping {
                     .driver     == driver;
                     .data       == data;
                     .ack        == FALSE;
                     .speed_mode == speed_mode;
                  };

                  if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                     all_ok = FALSE;
                     break;
                  };

                  //Check that so far the monitor is receiving an ack
                  var receiving_ack : bool = check_receiving_ack_m();

                  if(receiving_ack == FALSE) {
                     messagef(MEDIUM,"No acknowledge at last data transfer");
                     break;
                  };
               };

               if(all_ok) {
                  if(has_stop) {
                     do amiq_i2c_symbol keeping {
                        .driver                == driver;
                        .i2c_symbol.sda_symbol == STOP;
                        .i2c_symbol.speed_mode == speed_mode;
                     };
                  };
               };
            };
         };
      };
   };
};


extend START_BYTE amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   body()@driver.clock is only {
      var all_ok : bool = should_transfer_be_dropped();

      if(all_ok) {
         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == START;
            .i2c_symbol.speed_mode == speed_mode;
         };

         do amiq_i2c_byte keeping {
            .driver     == driver;
            .data       == 1;
            .ack        == FALSE;
            .speed_mode == speed_mode;
         };
      };
   };
};


extend HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   body()@driver.clock is only {
      var all_ok : bool = should_transfer_be_dropped();

      if(all_ok) {
         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == START;
            .i2c_symbol.speed_mode == sub_speed_mode;
         };

         do amiq_i2c_byte keeping {
            .driver     == driver;
            .data       == %{5'b0000_1, master_code.as_a(uint(bits:3))};
            .ack        == FALSE;
            .speed_mode == sub_speed_mode;
         };
      };
   };
};


extend CBUS amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;

   body()@driver.clock is only {
   	messagef(LOW, "Sending CBUS with data size: %d...", data_l.size());

      do amiq_i2c_symbol keeping {
         .driver                == driver;
         .i2c_symbol.sda_symbol == START;
         .i2c_symbol.speed_mode == speed_mode;
         .i2c_symbol.force_sda_driving == TRUE;
      };

      var cbus_l : list of bit = {0;0;0;0;0;0;1};

      for each (symbol) in cbus_l {
         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == ((symbol == 0) ? LOGIC_0 : LOGIC_1);
            .i2c_symbol.speed_mode == speed_mode;
            .i2c_symbol.force_sda_driving == TRUE;
         };
      };


      for each (symbol) using index (idx) in data_l {
         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == ((symbol == 0) ? LOGIC_0 : LOGIC_1);
            .i2c_symbol.speed_mode == speed_mode;
            .i2c_symbol.force_sda_driving == TRUE;
         };
      };

      do amiq_i2c_symbol keeping {
         .driver                == driver;
         .i2c_symbol.sda_symbol == STOP;
         .i2c_symbol.speed_mode == speed_mode;
         .i2c_symbol.force_sda_driving == TRUE;
      };
   };
};


extend DEVICE_ID amiq_i2c_m_seq {
   !amiq_i2c_symbol : SYMBOL amiq_i2c_m_seq;
   !amiq_i2c_byte   : BYTE amiq_i2c_m_seq;

   body()@driver.clock is only {
      var all_ok : bool = should_transfer_be_dropped();

      if(all_ok) {
         if(speed_mode == HIGH_SPEED) {
            if(driver.ptr_bus_mon.hs_in_progress == FALSE) {
               if(driver.ptr_agent_config.en_war_p_m_02) {
                  warning("AMIQ_I2C_P_M_WARNING_02: Trying to drive a DEVICE ID transfer in HIGH SPEED mode but the monitor did not detected a HIGH SPEED master code\
                  \n\tTO DISABLE WARNING: en_war_p_m_02 == FALSE");
               };
            };
         };

         do amiq_i2c_symbol keeping {
            .driver                == driver;
            .i2c_symbol.sda_symbol == START;
            .i2c_symbol.speed_mode == speed_mode;
         };

         messagef(LOW, "Driving DEVICE ID - WRITE");

         do amiq_i2c_byte keeping {
            .driver     == driver;
            .data       == 8'b1111_1000;
            .ack        == FALSE;
            .speed_mode == speed_mode;
         };

         if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
            all_ok = FALSE;
         };

         if(all_ok) {
            //Check that so far the monitor is receiving an ack
            var receiving_ack : bool = check_receiving_ack_m();

            if(receiving_ack == FALSE) {
               messagef(LOW,"No SLAVE acknowledged the DEVICE ID");
               all_ok = FALSE;

               if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  do amiq_i2c_symbol keeping {
                     .driver                == driver;
                     .i2c_symbol.sda_symbol == STOP;
                     .i2c_symbol.speed_mode == speed_mode;
                  };
               };
            };
         };

         if(all_ok) {
            case(addr_mode) {
               AM_7BITS : {
                  messagef(LOW, "Driving address: %02X in 7-BITS mode", addr[6:0]);

                  do amiq_i2c_byte keeping {
                     .driver     == driver;
                     .data       in {%{addr[6:0], 1'b0}[7:0]; %{addr[6:0], 1'b1}[7:0]};
                     .ack        == FALSE;
                     .speed_mode == speed_mode;
                  };

                  if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                     all_ok = FALSE;
                  };

                  if(all_ok) {
                     //Check that so far the monitor is receiving an ack
                     var receiving_ack : bool = check_receiving_ack_m();

                     if(receiving_ack == FALSE) {
                        messagef(LOW,"No SLAVE acknowledged the address: %X", addr[6:0]);
                        all_ok = FALSE;

                        if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                           do amiq_i2c_symbol keeping {
                              .driver                == driver;
                              .i2c_symbol.sda_symbol == STOP;
                              .i2c_symbol.speed_mode == speed_mode;
                           };
                        };
                     };
                  };
               };

               AM_10BITS : {
                  messagef(LOW, "Driving address: %02X in 10-BITS mode", addr);

                  do amiq_i2c_byte keeping {
                     .driver     == driver;
                     .data       in {%{5'b1111_0, addr[9:8], 1'b0}[7:0]; %{5'b1111_0, addr[9:8], 1'b1}[7:0]};
                     .ack        == FALSE;
                     .speed_mode == speed_mode;
                  };

                  if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                     all_ok = FALSE;
                  };

                  if(all_ok) {
                     //Check that so far the monitor is receiving an ack
                     var receiving_ack : bool = check_receiving_ack_m();

                     if(receiving_ack == FALSE) {
                        messagef(LOW,"No SLAVE acknowledged the address: %X", addr);
                        all_ok = FALSE;

                        if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                           do amiq_i2c_symbol keeping {
                              .driver                == driver;
                              .i2c_symbol.sda_symbol == STOP;
                              .i2c_symbol.speed_mode == speed_mode;
                           };
                        };
                     } else {
                        do amiq_i2c_byte keeping {
                           .driver     == driver;
                           .data       == addr[7:0];
                           .ack        == FALSE;
                           .speed_mode == speed_mode;
                        };

                        if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                           all_ok = FALSE;
                        };

                        if(all_ok) {
                           //Check that so far the monitor is receiving an ack
                           var receiving_ack : bool = check_receiving_ack_m();

                           if(receiving_ack == FALSE) {
                              messagef(LOW,"No SLAVE acknowledged the address: %X", addr);
                              all_ok = FALSE;

                              if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                                 do amiq_i2c_symbol keeping {
                                    .driver                == driver;
                                    .i2c_symbol.sda_symbol == STOP;
                                    .i2c_symbol.speed_mode == speed_mode;
                                 };
                              };
                           };
                        };
                     };
                  };
               };
            };

            if(all_ok) {
               do amiq_i2c_symbol keeping {
                  .driver                == driver;
                  .i2c_symbol.sda_symbol == START;
                  .i2c_symbol.speed_mode == speed_mode;
               };

               messagef(LOW, "Driving DEVICE ID - READ");

               do amiq_i2c_byte keeping {
                  .driver     == driver;
                  .data       == 8'b1111_1001;
                  .ack        == FALSE;
                  .speed_mode == speed_mode;
               };

               if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                  all_ok = FALSE;
               };

               if(all_ok) {
                  //Check that so far the monitor is receiving an ack
                  var receiving_ack : bool = check_receiving_ack_m();

                  if(receiving_ack == FALSE) {
                     messagef(LOW,"No SLAVE acknowledged the DEVICE ID");
                     all_ok = FALSE;

                     if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        do amiq_i2c_symbol keeping {
                           .driver                == driver;
                           .i2c_symbol.sda_symbol == STOP;
                           .i2c_symbol.speed_mode == speed_mode;
                        };
                     };
                  };
               };

               if(all_ok) {
                  for i from 1 to read_bytes {
                     do amiq_i2c_byte keeping {
                        .driver     == driver;
                        .data       == 8'hFF;
                        .ack        == (i != read_bytes);
                        .speed_mode == speed_mode;
                     };

                     if(driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        all_ok = FALSE;
                        break;
                     };

                     //Check that so far the monitor is receiving an ack
                     var receiving_ack : bool = check_receiving_ack_m();

                     if(receiving_ack == FALSE) {
                        messagef(LOW,"No acknowledge at last data transfer");
                        break;
                     };
                  };

                  if(all_ok) {
                     if(!driver.ptr_agent_mon.is_master_arbitration_lost()) {
                        do amiq_i2c_symbol keeping {
                           .driver                == driver;
                           .i2c_symbol.sda_symbol == STOP;
                           .i2c_symbol.speed_mode == speed_mode;
                        };
                     };
                  };
               };
            };
         };
      };
   };
};

'>