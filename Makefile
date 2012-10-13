ALL=test_register test_counter test_mux test_carry_lookahead test_adder test_adder_acc

all : $(ALL)

test_register : test_register.v register.v
	iverilog -o $@ test_register.v register.v

test_mux : test_mux.v mux.v 
	iverilog -o $@ $^

test_carry_lookahead : test_carry_lookahead.v carry_lookahead.v 
	iverilog -o $@ $^

test_counter : test_counter.v counter.v carry_lookahead.v
	iverilog -o $@ $^

test_adder : test_adder.v adder.v carry_lookahead.v
	iverilog -o $@ $^

test_adder_acc : test_adder_acc.v counter.v mux.v adder.v register.v adder_acc.v carry_lookahead.v
	iverilog -o $@ $^

clean:
	$(RM) $(ALL)
