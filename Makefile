# Makefile using Icarus Verilog for ECE530 homework
#
# davep 13-Oct-2012

ALL=test_register test_counter test_mux test_carry_lookahead test_adder\
    test_adder_acc basys2 test_edge_to_pulse test_freq_div test_time_gen\
    test_bcd_clock

FLAGS=-Wall -D SIMULATION=1

all : $(ALL)

basys2 : bcd_clock.v time_gen.v freq_div.v al_controller.v stub_digits_to_7seg.v basys2.v 
	iverilog $(FLAGS) -o $@ $^

test_bcd_clock : bcd_clock.v test_bcd_clock.v
	iverilog $(FLAGS) -o $@ $^

test_time_gen : time_gen.v edge_to_pulse.v test_time_gen.v
	iverilog $(FLAGS) -o $@ $^

test_freq_div : freq_div.v test_freq_div.v
	iverilog $(FLAGS) -o $@ $^

test_edge_to_pulse : test_edge_to_pulse.v edge_to_pulse.v
	iverilog $(FLAGS) -o $@ $^

test_register : test_register.v register.v
	iverilog $(FLAGS) -o $@ $^

test_mux : test_mux.v mux.v 
	iverilog $(FLAGS) -o $@ $^

test_carry_lookahead : test_carry_lookahead.v carry_lookahead.v 
	iverilog $(FLAGS) -o $@ $^

test_counter : test_counter.v counter.v carry_lookahead.v
	iverilog $(FLAGS) -o $@ $^

test_adder : test_adder.v adder.v carry_lookahead.v
	iverilog $(FLAGS) -o $@ $^

test_adder_acc : test_adder_acc.v counter.v mux.v adder.v register.v adder_acc.v carry_lookahead.v
	iverilog $(FLAGS) -o $@ $^

clean:
	$(RM) $(ALL)
