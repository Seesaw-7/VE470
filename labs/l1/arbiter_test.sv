`timescale 1ns/100ps

parameter CLOCK_PERIOD = 200;

module testbench;

    //Internal Wires
    logic correct;
    logic [1:0] a1_state;

    //Module Wires
    logic clock, reset;
    logic [2:0] request;
    logic [2:0] grant;

    arbiterFSM a1(
        .clock(clock), 
        .reset(reset), 
        .request(request), 
        .grant(grant),
        .state_out(a1_state));

    always begin
        #(CLOCK_PERIOD/2);
        clock=~clock;
    end

    //--------------------Test bench helper functions--------------------//
    // It is highly recommended to understand the code here!             //
    task exit_on_error;
		begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ Time:%4.0f clock:%b reset:%h  state=%b  request:%b grant:%b correct:%b expected:%b", $time, clock, reset, a1_state, request, grant, correct, EXPECTED_OUT());
            $display("ENDING TESTBENCH : ERROR !");
            $finish;
		end
	endtask

    always_ff @(negedge clock) begin
		if( !correct ) begin //CORRECT CASE
			exit_on_error( );
		end
	end

    //////////////////////////////////////////////////////
    // Please use this to write your random test cases:)//
    //////////////////////////////////////////////////////
	function [2:0] EXPECTED_OUT;
		begin
			EXPECTED_OUT = (a1_state==2'b11 ? 3'b100 : (a1_state==2'b10 ? 3'b010 : (a1_state==2'b01 ? 3'b001 : 3'b000))) & request;
		end
	endfunction

	task CHECK_GRANT;
		input [2:0] tb_grant;
		begin
			if( tb_grant == grant ) correct =  1;
			else correct = 0;
		end
	endtask

    initial begin
        $display("STARTING TESTBENCH!\n");
        $monitor("Time:%4.0f clock:%b reset:%b request:%b grant:%b correct:%b", 
                 $time, clock, reset, request, grant, correct);

        clock = 1'b0;
        reset = 1'b1;
        request = 3'b000;
        @(negedge clock)
        reset = 1'b0;

        // Test 1
        request = 3'b111;
        @(negedge clock)
        CHECK_GRANT( 3'b100 );
        @(negedge clock)
        CHECK_GRANT( 3'b010 );
        @(negedge clock)
        CHECK_GRANT( 3'b001 );

        // Test 2
        request = 3'b011;
        @(negedge clock)
        CHECK_GRANT( 3'b010 );
        @(negedge clock)
        CHECK_GRANT( 3'b001 );

        // Test 3
        request = 3'b101;
        @(negedge clock)
        CHECK_GRANT( 3'b100 );

        // Test 4
        request = 3'b100;
        @(negedge clock)
        CHECK_GRANT( 3'b100 );

        // Test 5
        request = 3'b010;
        @(negedge clock)
        CHECK_GRANT( 3'b010 );
        
        // Random test
		for (int i=0; i < 30; i=i+1) begin 
            //////////////////////////////////////////////////////
            // TODO: Implement a series of random test cases    //
            //////////////////////////////////////////////////////
            request = $random;
			if(i%10) reset=0;
			else reset=1;
			@(negedge clock)
			CHECK_GRANT(EXPECTED_OUT());
        end
        
        $display("ENDING TESTBENCH : SUCCESS !\n");
		$finish;

    end
endmodule