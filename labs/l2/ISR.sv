`timescale 1ns/100ps


module SingleBitEvaluator(
	input clock, start, reset,
	input [31:0] result,
	input [4:0] addr,
	input [63:0] value,
	output logic [31:0] result_new,
	output logic [4:0] addr_new,
	output logic done
    );


	wire [63:0] a, b;
	logic [63:0] product;
	logic mult_start, mult_reset;

	mult m0(.clock(clock),
			.reset(mult_reset),
			.mcand(a),
			.mplier(b),
			.start(mult_start),
			.product(product),
			.done(mult_done)
			);


    wire [31:0]revised_result;
	logic [63:0] value_reg;
	logic [4:0] addr_reg;
	logic [31:0] result_reg;

	assign revised_result = result_reg | (32'b1 << addr);
	assign a = {32'b0, revised_result};
	assign b = a;
	
	always_ff @(posedge clock) begin
		if (reset) begin 
			mult_start <= 0;
			mult_reset <= 1;
			done <= 0;	
		end
		else begin
			if (mult_done) begin
				if (product > value_reg) 
					result_new <= result;
				else 
					result_new <= revised_result;
				addr_new <= addr - 1;
				done <= 1;
			end
			else begin
				if (start) begin
					result_reg <= result;
					addr_reg <= addr;
					value_reg <= value;
					mult_start <= 1;
					mult_reset <= 0;
				end				
			end
		end
	end

//    initial begin
//        $monitor("Time: %0t | revised_result: %b, a: %b, b: %b, product: %b, decider_result_new: %b, addr: %b, addr_new: %b, mult_start: %b, mult_done: %b, decider_done: %b", $time, revised_result, a, b, product, decider_result_new, addr, addr_new, mult_start, mult_done, decider_done);
//    end

endmodule


module ISR(
    input reset,
    input [63:0] value,
    input clock,
    output logic [31:0] result,
    output logic done
    );
    
    logic [(31*32)-1:0] internal_results;
    logic [(31*5)-1:0] internal_addr;
    logic [30:0] internal_dones;
    wire [4:0] final_addr;
    
    logic [63:0] value_reg;
    
    always_ff @(posedge clock) begin
        if (reset) 
            value_reg <= value;
    end
	
	SingleBitEvaluator sbe [31:0] (
	   .result({internal_results, 32'b0}),
	   .addr({internal_addr,5'b11111}),
	   .value(value_reg),
	   .clock(clock),
	   .start({internal_dones, ~reset}),
	   .reset(reset),
	   .addr_new({final_addr, internal_addr}),
	   .result_new({result, internal_results}),
	   .done({done, internal_dones})
	);
//    generate
//        genvar i;
//        for (i = 31; i>0; i--) begin
//            OneBitDecider(
                
//            );
//        end
    
//    endgenerate

    
endmodule
