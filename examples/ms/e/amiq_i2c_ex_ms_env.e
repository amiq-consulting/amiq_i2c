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
 * NAME:        amiq_i2c_ex_ms_env.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the environment unit used
 *              in master-slave example
 *******************************************************************************/
<'

method_type amiq_i2c_ex_ms_m_seq_mp(seq : amiq_i2c_m_seq);

extend amiq_i2c_m_driver_u {
	out_current_sequence : out method_port of amiq_i2c_ex_ms_m_seq_mp is instance;
	keep bind(out_current_sequence, empty);
};

extend CBUS amiq_i2c_m_seq {
	body()@driver.clock is first {
		driver.out_current_sequence$(me);
	};
};

extend TRANSFER amiq_i2c_m_seq {
	hook_address_acknowledged(seq : amiq_i2c_m_seq) is {
		driver.out_current_sequence$(seq);
	};
};

method_type amiq_i2c_ex_ms_s_seq_mp(seq : amiq_i2c_s_seq);

extend amiq_i2c_s_driver_u {
	out_current_sequence : out method_port of amiq_i2c_ex_ms_s_seq_mp is instance;
	keep bind(out_current_sequence, empty);
};

extend SLAVE_BYTE amiq_i2c_s_seq {
	hook_send_response(data : byte) is {
		driver.out_current_sequence$(me);
	};
};

extend amiq_i2c_ex_ms_scoreboard_u {
	in_m_current_sequence : in method_port of amiq_i2c_ex_ms_m_seq_mp is instance;
	keep bind(in_m_current_sequence, empty);

	in_s_current_sequence : in method_port of amiq_i2c_ex_ms_s_seq_mp is instance;
	keep bind(in_s_current_sequence, empty);

	//Method port for receiving an item
	receive_i2c_item_mp : in method_port of amiq_i2c_mp_item_t is instance;
	keep bind(receive_i2c_item_mp, empty);

	//master transfer bytes
	!transfer_data : list of byte;

	//master CBUS bits
	!cbus_data : list of bit;

	in_m_current_sequence(seq : amiq_i2c_m_seq) is {
		if(seq is a WRITE'rw TRANSFER amiq_i2c_m_seq (casted_seq)) {
			transfer_data.push(casted_seq.data_l);
		}
		else if(seq is a CBUS amiq_i2c_m_seq (casted_seq)) {
			cbus_data.push(casted_seq.data_l);
		};
	};

	in_s_current_sequence(seq : amiq_i2c_s_seq) is {
		if(seq is a SLAVE_BYTE amiq_i2c_s_seq (casted_seq)) {
			if(bus_mon.first_byte_info in {NORMAL_10BITS; NORMAL_7BITS}) {
				transfer_data.push(casted_seq.data);
			};
		};
	};

	receive_i2c_byte_mp(data : byte) is only {
		if(bus_mon.first_byte_info in {NORMAL_10BITS; NORMAL_7BITS}) {
			if(bus_mon.cs_decode_phase == DATA) {
				check that transfer_data.size() > 0 else
				dut_error("transfer_data is empty but it should have some data in it");

				var expecetd_byte := transfer_data.pop0();

				check that expecetd_byte == data else
				dut_error(appendf("Data mismatch - expected: %02X but received %02X", expecetd_byte, data));
			};
		};
	};

	receive_i2c_item_mp(an_item : amiq_i2c_item_s) is {
		if(bus_mon.first_byte_info in {CBUS_ADDR}) {
			if((bus_mon.cs_decode_phase == DATA) || (bus_mon.cs_decode_phase == ADDR && bus_mon.cnt_bits >= 7)) {
				check that cbus_data.size() > 0 else
				dut_error("cbus_data is empty but it should have some data in it");

				var data := cbus_data.pop0();

				check that ((data == 1 && an_item.sda_symbol == LOGIC_1) || (data == 0 && an_item.sda_symbol == LOGIC_0)) else
				dut_error(appendf("Data mismatch - expected: %b but received %s", data, an_item.sda_symbol));
			};
		};
	};

	check() is also {
		check that transfer_data.size() == 0 else
		dut_error(appendf("There are still %d bytes in transfer_data", transfer_data.size()));

		check that cbus_data.size() == 0 else
		dut_error(appendf("There are still %d bits in cbus_data", cbus_data.size()));
	};

	event reset_started is fall(bus_mon.ptr_smp.reset_n$)@sim;

	on reset_started {
		cbus_data.clear();
		transfer_data.clear();
	};
};

//declaration of the verification environment
unit amiq_i2c_ex_ms_env_u {
	//Create a ACTIVE instance of the environment
	i2c_env : ACTIVE amiq_i2c_env_u is instance;

	keep soft i2c_env.config.nof_master_agts == 1;
	keep soft i2c_env.config.nof_slave_agts == 1;

	//virtual driver
	virtual_driver : amiq_i2c_ex_virtual_driver_u is instance;
	keep virtual_driver.master == i2c_env.master_agt_l[0];
	keep virtual_driver.slave == i2c_env.slave_agt_l[0];

	//scoreboard
	scoreboard : amiq_i2c_ex_ms_scoreboard_u is instance;
	keep bind(scoreboard.receive_i2c_byte_mp, i2c_env.bus_mon.send_i2c_byte_mp);
	keep bind(scoreboard.receive_i2c_item_mp, i2c_env.bus_mon.send_i2c_item_mp);
	keep bind(scoreboard.in_m_current_sequence, i2c_env.master_agt_l[0].driver.out_current_sequence);
	keep bind(scoreboard.in_s_current_sequence, i2c_env.slave_agt_l[0].driver.out_current_sequence);
	keep scoreboard.bus_mon == i2c_env.bus_mon;

	keep hdl_path() == "~/amiq_i2c_ex_tb";
};

'>
