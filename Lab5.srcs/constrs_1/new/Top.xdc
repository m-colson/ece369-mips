##Set clock frequency to 100 MHz. Helps guide the placement and routing algorithm
##to synthesize design that satisfies this constraint, and gives better power estimations
## 100 MHz frequency, 10 ns period,, duty cycle 50%, no phase shift
create_clock -period 10 -name MASTER_CLOCK [get_ports Clk]
create_generated_clock -name DP_CLOCK -source [get_ports Clk] -divide_by 100000000 [get_nets ClkSlow]

##This part is to assign a pin number to 100MHz clock signal
set_property PACKAGE_PIN E3 [get_ports Clk]
set_property IOSTANDARD LVCMOS33 [get_ports Clk]

## This part is to activate or deactive ANODE of each display digit
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[0]}]
set_property PACKAGE_PIN J17 [get_ports {en_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[1]}]
set_property PACKAGE_PIN J18 [get_ports {en_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[2]}]
set_property PACKAGE_PIN T9 [get_ports {en_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[3]}]
set_property PACKAGE_PIN J14 [get_ports {en_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[4]}]
set_property PACKAGE_PIN P14 [get_ports {en_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[5]}]
set_property PACKAGE_PIN T14 [get_ports {en_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[6]}]
set_property PACKAGE_PIN K2 [get_ports {en_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_out[7]}]
set_property PACKAGE_PIN U13 [get_ports {en_out[7]}]

##This part is to assign pin numbers for 7 segments of the digit display
set_property IOSTANDARD LVCMOS33 [get_ports {out7[6]}]
set_property PACKAGE_PIN T10 [get_ports {out7[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[5]}]
set_property PACKAGE_PIN R10 [get_ports {out7[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[4]}]
set_property PACKAGE_PIN K16 [get_ports {out7[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[3]}]
set_property PACKAGE_PIN K13 [get_ports {out7[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[2]}]
set_property PACKAGE_PIN P15 [get_ports {out7[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[1]}]
set_property PACKAGE_PIN T11 [get_ports {out7[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out7[0]}]
set_property PACKAGE_PIN L18 [get_ports {out7[0]}]

# Assigning pin for sending Reset signal to the circuit.
# Corresponds to the center button of the 5 push buttons.
set_property IOSTANDARD LVCMOS33 [get_ports {Reset}]
set_property PACKAGE_PIN N17 [get_ports {Reset}]