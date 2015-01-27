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
 * NAME:        amiq_i2c_p_top.e
 * PROJECT:     amiq_i2c
 * Description: This file contains all the imports of amiq_i2c VIP related to
                the protocol functionality.
 *******************************************************************************/
<'

package amiq_i2c;

//Files for I2C eVC protocol communication
import amiq_i2c/e/protocol/amiq_i2c_p_global_h;
import amiq_i2c/e/protocol/amiq_i2c_p_global;
import amiq_i2c/e/protocol/amiq_i2c_p_bus_monitor_h;
import amiq_i2c/e/protocol/amiq_i2c_p_bus_monitor;
import amiq_i2c/e/protocol/amiq_i2c_p_monitor_h;
import amiq_i2c/e/protocol/master/amiq_i2c_p_m_monitor_h;
import amiq_i2c/e/protocol/master/amiq_i2c_p_m_monitor;
import amiq_i2c/e/protocol/master/amiq_i2c_p_m_bfm;
import amiq_i2c/e/protocol/slave/amiq_i2c_p_s_monitor_h;
import amiq_i2c/e/protocol/slave/amiq_i2c_p_s_monitor;
import amiq_i2c/e/protocol/slave/amiq_i2c_p_s_bfm;
import amiq_i2c/e/protocol/amiq_i2c_p_coverage_h;
import amiq_i2c/e/protocol/slave/amiq_i2c_p_s_coverage_h;
import amiq_i2c/e/protocol/master/amiq_i2c_p_m_coverage_h;

'>