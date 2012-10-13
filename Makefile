# Makefile using Icarus Verilog for ECE530 homework
#
# davep 13-Oct-2012

ALL=test_register test_counter test_mux test_carry_lookahead test_adder test_adder_acc

FLAGS=-Wall

all : $(ALL)

test_register : test_register.v register.v
	iverilog $(FLAGS) -o $@ test_register.v register.v

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
