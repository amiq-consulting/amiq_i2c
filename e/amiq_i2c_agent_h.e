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
 * NAME:        amiq_i2c_agent_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the agent unit.
 *******************************************************************************/
<'

package amiq_i2c;

//agent unit
unit amiq_i2c_agent_u like amiq_i2c_any_agent_unit_u {
	//Pointer to the synchronizer unit
	//Propagated from enclosing env.
	ptr_synch : amiq_i2c_synchronizer_u;

	//Agent configuration unit
	config : amiq_i2c_agent_config_u is instance;
	keep type config.agt_kind == agt_kind;
	keep config.env_name      == read_only(env_name);
	keep config.agt_index     == read_only(agt_index);

	//Pointer to bus monitor
	//Propagated from enclosing env.
	ptr_bus_mon : amiq_i2c_bus_monitor_u;

	//Agent monitor unit
	mon : amiq_i2c_agent_monitor_u is instance;
	keep type mon.agt_kind     == agt_kind;
	keep mon.env_name          == read_only(env_name);
	keep mon.agt_index         == read_only(agt_index);
	keep mon.ptr_synch         == read_only(ptr_synch);
	keep mon.ptr_bus_mon       == read_only(ptr_bus_mon);
	keep mon.ptr_agent_smp     == read_only(smp);
	keep mon.ptr_agent_config  == read_only(config);
	keep soft mon.has_coverage == read_only(config.has_coverage);

	//Agent bfm unit
	bfm : amiq_i2c_bfm_u is instance;
	keep type bfm.agt_kind    == agt_kind;
	keep bfm.env_name         == read_only(env_name);
	keep bfm.agt_index        == read_only(agt_index);
	keep bfm.ptr_synch        == read_only(ptr_synch);
	keep bfm.ptr_bus_mon      == read_only(ptr_bus_mon);
	keep bfm.ptr_agent_smp    == read_only(smp);
	keep bfm.ptr_agent_mon    == read_only(mon);
	keep bfm.ptr_agent_config == read_only(config);

	//Agent smp unit
	smp : amiq_i2c_agent_smp_u is instance;
	keep type smp.agt_kind == agt_kind;
	keep smp.env_name      == read_only(env_name);
	keep smp.agt_index     == read_only(agt_index);

	//String to print in messagef() methods
	short_name : string;

	short_name():string is only {
		return appendf("%s[%d]", short_name, agt_index);
	};

	run() is also {
		if(config.drive_initial_values) {
			smp.disable_outputs();
		};
	};
};

extend MASTER amiq_i2c_agent_u {
	//String to print in messagef() methods
	keep soft short_name == "M";

	//Agent driver unit
	driver : amiq_i2c_m_driver_u is instance;
	keep driver.env_name         == read_only(env_name);
	keep driver.agt_kind         == read_only(agt_kind);
	keep driver.agt_index        == read_only(agt_index);
	keep driver.ptr_agent_config == read_only(config);
	keep driver.ptr_synch        == read_only(ptr_synch);
	keep driver.ptr_bus_mon      == read_only(ptr_bus_mon);
	keep driver.ptr_agent_mon    == read_only(mon);
	keep bfm.driver              == read_only(driver);
};

extend SLAVE amiq_i2c_agent_u {
	//String to print in messagef() methods
	keep soft short_name == "S";

	//Agent driver unit
	driver : amiq_i2c_s_driver_u is instance;
	keep driver.env_name         == read_only(env_name);
	keep driver.agt_kind         == read_only(agt_kind);
	keep driver.agt_index        == read_only(agt_index);
	keep driver.ptr_agent_config == read_only(config);
	keep driver.ptr_synch        == read_only(ptr_synch);
	keep driver.ptr_bus_mon      == read_only(ptr_bus_mon);
	keep driver.ptr_agent_mon    == read_only(mon);
	keep bfm.driver              == read_only(driver);
};

'>