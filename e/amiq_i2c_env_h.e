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
 * NAME:        amiq_i2c_env_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the environment unit.
 *******************************************************************************/
<'

package amiq_i2c;

//environment unit
unit amiq_i2c_env_u like any_env {
	//Environment name
	env_name : amiq_i2c_env_name_t;
	keep soft env_name == I2C_ENV0;

	//ACTIVE PASSIVE aspect
	active_passive : erm_active_passive_t;
	keep soft active_passive == PASSIVE;

	//Instance of the message logger unit
	logger : message_logger is instance;
	keep logger.tags == {NORMAL; AMIQ_I2C_COMMON_BFM};

	//Instance for environment configuration unit
	config : amiq_i2c_env_config_u is instance;
	keep config.env_name == read_only(env_name);

	//Instance for environment smp unit
	smp : amiq_i2c_env_smp_u is instance;

	//Instance of the synchronizer unit
	synch : amiq_i2c_synchronizer_u is instance;
	keep synch.ptr_smp == read_only(smp);

	//Instance of the bus monitor unit
	bus_mon : amiq_i2c_bus_monitor_u is instance;
	keep bus_mon.env_name          == read_only(env_name);
	keep bus_mon.ptr_env_config    == read_only(config);
	keep bus_mon.ptr_smp           == read_only(smp);
	keep bus_mon.ptr_synch         == read_only(synch);
	keep soft bus_mon.has_coverage == read_only(config.has_coverage);
	keep soft bus_mon.has_checker  == read_only(config.has_checker);

	when ACTIVE'active_passive amiq_i2c_env_u {
		//List of master agents
		master_agt_l : list of MASTER amiq_i2c_agent_u is instance;
		keep master_agt_l.size() == read_only(config.nof_master_agts);
		keep for each in master_agt_l {
			it.agt_index   == index;
			it.env_name    == read_only(env_name);
			it.ptr_synch   == read_only(synch);
			it.ptr_bus_mon == read_only(bus_mon);
			it.smp.sda_in  == read_only(smp.sda_in);
			it.smp.scl_in  == read_only(smp.scl_in);
			it.smp.clock   == read_only(smp.clock);
			it.smp.reset_n == read_only(smp.reset_n);

			soft it.config.has_coverage == read_only(config.has_coverage);
			soft it.config.has_checker  == read_only(config.has_checker);
		};

		//List of slave agents
		slave_agt_l : list of SLAVE amiq_i2c_agent_u is instance;
		keep slave_agt_l.size() == read_only(config.nof_slave_agts);
		keep for each in slave_agt_l {
			it.agt_index   == config.nof_master_agts + index;
			it.env_name    == read_only(env_name);
			it.ptr_synch   == read_only(synch);
			it.ptr_bus_mon == read_only(bus_mon);
			it.smp.sda_in  == read_only(smp.sda_in);
			it.smp.scl_in  == read_only(smp.scl_in);
			it.smp.clock   == read_only(smp.clock);
			it.smp.reset_n == read_only(smp.reset_n);

			soft it.config.has_coverage == read_only(config.has_coverage);
			soft it.config.has_checker  == read_only(config.has_checker);
		};

		//reset rising edge
		event reset_rise is @synch.rst_r_e;

		//reset falling edge
		event reset_fall is @synch.rst_f_e;

		on reset_fall {
			for each in master_agt_l {
				it.quit();
				it.mon.quit();
				it.bfm.quit();
				it.config.quit();
				it.driver.quit();
			};
			for each in slave_agt_l {
				it.quit();
				it.mon.quit();
				it.bfm.quit();
				it.config.quit();
				it.driver.quit();
			};
			bus_mon.quit();
		};

		on reset_rise {
			for each in master_agt_l {
				it.rerun();
				it.mon.rerun();
				it.bfm.rerun();
				it.config.rerun();
				it.driver.rerun();
			};
			for each in slave_agt_l {
				it.rerun();
				it.mon.rerun();
				it.bfm.rerun();
				it.config.rerun();
				it.driver.rerun();
			};
			bus_mon.rerun();
		};
	};

	//String to print in messagef() methods
	short_name() : string is only {
		return env_name.as_a(string);
	};

	short_name_style() : vt_style is {
		return LIGHT_CYAN;
	};
};

'>