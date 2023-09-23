# clk input is from the 100 MHz oscillator on Boolean board
# create_clock -period 10.000 -name system_clock [get_ports i_clk]//////////////////////////
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {i_clk}]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# On-board Reset Buttons
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {i_rst}]

# Camera Signals
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_camera_pclk]
# create_clock -period 23.809 -name camera_clock [get_ports i_camera_pclk]
create_clock -period 11.905 -name camera_clock [get_ports i_camera_pclk]

set_property -dict {PACKAGE_PIN N5 IOSTANDARD LVCMOS33} [get_ports {i_camera_pclk}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {i_camera_hsync}]
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports {i_camera_vsync}]

# set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {o_camera_xclk}]/////////////////

set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {io_camera_sda}]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {o_camera_scl}]

set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports {o_camera_resetn}]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports {o_camera_power_down}]
	
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[0]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[1]}]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[2]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[3]}]
set_property -dict {PACKAGE_PIN P6 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[4]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[5]}]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[6]}]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {i_camera_data[7]}]

# HDMI Signals
set_property -dict { PACKAGE_PIN T14   IOSTANDARD TMDS_33 } [get_ports {o_tmds_clk_n}]
set_property -dict { PACKAGE_PIN R14   IOSTANDARD TMDS_33 } [get_ports {o_tmds_clk_p}]

set_property -dict { PACKAGE_PIN T15   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_n[0]}]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_n[1]}]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_n[2]}]
                                    
set_property -dict { PACKAGE_PIN R15   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_p[0]}]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_p[1]}]
set_property -dict { PACKAGE_PIN N15   IOSTANDARD TMDS_33  } [get_ports {o_tmds_data_p[2]}]
