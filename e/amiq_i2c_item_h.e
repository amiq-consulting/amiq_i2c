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
 * NAME:        amiq_i2c_item_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the I2C item.
 *******************************************************************************/
<'

package amiq_i2c;

//I2C item
struct amiq_i2c_item_s like any_sequence_item {

	//Environment name
	env_name : amiq_i2c_env_name_t;
	keep soft env_name == I2C_ENV0;

	//Agent kind
	agt_kind : amiq_i2c_agent_kind_t;

	//Index of the agent
	agt_index : uint;
	keep soft agt_index == 0;

	package !scl_already_low_when_started_driving : bool;
};

//method type for an item
method_type amiq_i2c_mp_item_t(an_item : amiq_i2c_item_s);

'>