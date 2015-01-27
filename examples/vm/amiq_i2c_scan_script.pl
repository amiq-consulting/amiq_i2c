add_filter ("AMIQ_I2C", 5, 
            '-{55}\n\S?\s*\*{3} Dut error at time (\d+).*?\n\S?\s*Checked at ([^:]+?)\n\S?\s*In (.+?):\n\n(AMIQ_I2C_.+?):(.+?)-{55}', 
	    failure (1,"specman",AMIQ_I2C,"error",'$4')
);
