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
 * NAME:        amiq_i2c_top.e
 * PROJECT:     amiq_i2c
 * Description: This file contains all the imports of amiq_i2c VIP
 *******************************************************************************/
<'

package amiq_i2c;

import amiq_i2c/e/amiq_i2c_defines.e;
import amiq_i2c/e/amiq_i2c_types;
import amiq_i2c/e/amiq_i2c_any_unit_h;
import amiq_i2c/e/amiq_i2c_any_agent_unit_h.e;
import amiq_i2c/e/amiq_i2c_env_config_h;
import amiq_i2c/e/amiq_i2c_env_smp_h;
import amiq_i2c/e/amiq_i2c_agent_config_h;
import amiq_i2c/e/master/amiq_i2c_m_agent_config_h;
import amiq_i2c/e/slave/amiq_i2c_s_agent_config_h;
import amiq_i2c/e/amiq_i2c_agent_smp_h;
import amiq_i2c/e/amiq_i2c_synchronizer_h;
import amiq_i2c/e/amiq_i2c_item_h;
import amiq_i2c/e/amiq_i2c_bus_monitor_h;
import amiq_i2c/e/amiq_i2c_agent_monitor_h;
import amiq_i2c/e/amiq_i2c_seq_h;
import amiq_i2c/e/amiq_i2c_bfm_h;
import amiq_i2c/e/master/amiq_i2c_m_bfm;
import amiq_i2c/e/slave/amiq_i2c_s_bfm;
import amiq_i2c/e/amiq_i2c_agent_h;
import amiq_i2c/e/amiq_i2c_env_h;
import amiq_i2c/e/amiq_i2c_env;

import amiq_i2c/e/interface/amiq_i2c_i_top;
import amiq_i2c/e/protocol/amiq_i2c_p_top;

import amiq_i2c/e/master/amiq_i2c_m_seq_lib_h;
import amiq_i2c/e/master/amiq_i2c_m_seq_lib;

import amiq_i2c/e/slave/amiq_i2c_s_seq_lib_h;
import amiq_i2c/e/slave/amiq_i2c_s_seq_lib;

'>