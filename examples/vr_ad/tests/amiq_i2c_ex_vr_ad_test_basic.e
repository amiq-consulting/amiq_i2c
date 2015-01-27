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
 * NAME:        amiq_i2c_ex_vr_ad_test_basic.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the basic test used in
 *              vr_ad example.
 *******************************************************************************/
<'

import amiq_i2c/examples/vr_ad/e/amiq_i2c_ex_vr_ad_config;

extend MAIN vr_ad_sequence {
	!i2c_vr_ad_seq : I2C'kind vr_ad_sequence;

	//Raise an objection to TEST_DONE
	pre_body()@driver.clock is first {
		message(LOW, "Raise objection: TEST_DONE");
		driver.raise_objection(TEST_DONE);
		wait [100];
	};

	body() @driver.clock is only {
		do i2c_vr_ad_seq keeping {
			.driver == get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).lof_vr_ad_sequence_driver[0];
		};
	};

	//Drop the objection to TEST_DONE
	post_body()@driver.clock is also {
		message(LOW, "Drop objection: TEST_DONE");
		driver.drop_objection(TEST_DONE);
	};
};

'>