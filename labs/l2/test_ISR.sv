`define HALF_CYCLE 25

`timescale 1ns/100ps

module testbench2();

	logic [63:0] value;
	logic quit, clock, reset;
	logic [31:0] result;
	logic done;

	wire correct = ((result*result <= value) && ((result+1)*(result+1) > value))|~done;

	ISR m0(	.clock(clock),
				.reset(reset),
				.value(value),
				.result(result),
				.done(done));

	always @(posedge clock)
		#(`HALF_CYCLE-5) if(!correct) begin 
			$display("Incorrect at time %4.0f",$time);
			$display("result = %h",result);
			$finish;
		end

	always begin
		#`HALF_CYCLE;
		clock=~clock;
	end

	task wait_until_done;
		forever begin : wait_loop
			@(posedge done);
			@(negedge clock);
			if(done) disable wait_until_done;
		end
	endtask


	initial begin
		$dumpvars;
//		$monitor("Time:%4.0f done:%b a:%h b:%h product:%h result:%h",$time,done,a,b,cres,result);
		$monitor("Time:%4.0f done:%b value: %d, result:%d, correct: %b",$time, done, value, result, correct);
		value=24;
		reset=1;
		clock=0;
		#2000;

		@(negedge clock);
		reset=0;
		@(negedge clock);
		wait_until_done();

		value=0;
		reset=1;
		clock=0;
		#2000;

		@(negedge clock);
		reset=0;
		@(negedge clock);
		wait_until_done();

		quit = 0;
		quit <= #1000000 1;
		while(~quit) begin
		    value = $random;
		    reset = 1;
		    clock = 0;
		    #2000;

			@(negedge clock);
			reset=0;
			wait_until_done();
		end
		$finish;
	end

endmodule



  
  
