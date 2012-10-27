# Makefile using Icarus Verilog for ECE530 homework
#
# davep 13-Oct-2012

ALL=test_register test_counter test_mux test_carry_lookahead test_adder\
    test_adder_acc basys2 test_edge_to_pulse test_freq_div test_time_gen

FLAGS=-Wall

all : $(ALL)

basys2 : basys2.v tb.v adder.v adder_acc.v mux.v counter.v register.v\
 carry_lookahead.v stub_digits_to_7seg.v edge_to_pulse.v
	iverilog $(FLAGS) -o $@ $^

test_time_gen : time_gen.v test_time_gen.v
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
