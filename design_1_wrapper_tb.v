`timescale 1ns / 1ns

module design_1_wrapper_tb;

    reg clk;
    reg encoder_signal_0;
    wire [31:0] motor_speed_0;
    wire pwm_out_0;
    reg reset;

    // Instantiate the DUT (design under test)
    design_1_wrapper dut (
        .clk(clk),
        .encoder_signal_0(encoder_signal_0),
        .motor_speed_0(motor_speed_0),
        .pwm_out_0(pwm_out_0),
        .reset(reset)
    );                     

    // Clock generation: 10ns clock period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5ns to make 10ns clock (100 MHz)
    end

    // Reset logic
    initial begin
        reset = 0;
        #100 reset = 1;
    end

    // Encoder signal generation to simulate different RPMs
    initial begin
        encoder_signal_0 = 0;
        
        // Simulate 3000 RPM (50 pulses per 100ms)
        repeat (50) begin
            #2000000 encoder_signal_0 = 1;
            #2000000 encoder_signal_0 = 0;  // Pulse width 2ms (2,000,000 ns)
        end
        
        #100000000;  // Wait for 100ms

        // Simulate 5000 RPM (83 pulses per 100ms)
        repeat (83) begin
            #1204819 encoder_signal_0 = 1;
            #1204819 encoder_signal_0 = 0;  // Pulse width approx 1.2ms (1,204,819 ns)
        end
        
        #100000000;  // Wait for 100ms

        // Simulate 2000 RPM (33 pulses per 100ms)
        repeat (33) begin
            #3030303 encoder_signal_0 = 1;
            #3030303 encoder_signal_0 = 0;  // Pulse width approx 3ms (3,030,303 ns)
        end
    end

endmodule



//`timescale 1ms / 1ms

//module design_1_wrapper_tb;

//    reg clk;
//    reg encoder_signal_0;
//    wire [31:0] motor_speed_0;
//    wire pwm_out_0;
//    reg reset;

//    // Instantiate the DUT (design under test)
//    design_1_wrapper dut (
//        .clk(clk),
//        .encoder_signal_0(encoder_signal_0),
//        .motor_speed_0(motor_speed_0),
//        .pwm_out_0(pwm_out_0),
//        .reset(reset)
//    );                     

//    // Clock generation: 0.01ms clock period (100 MHz)
//    initial begin
//        clk = 0;
//        forever #0.005 clk = ~clk;  // Toggle every 0.005ms (5us) to make 0.01ms clock (100 MHz)
//    end

//    // Reset logic
//    initial begin
//        reset = 0;
//        #0.1 reset = 1;  // Reset after 0.1ms
//    end

//    // Encoder signal generation to simulate different RPMs
//    initial begin
//        encoder_signal_0 = 0;
        
//        // Simulate 3000 RPM (50 pulses per 100ms)
//        repeat (50) begin
//            #2 encoder_signal_0 = 1;   // High for 2ms
//            #2 encoder_signal_0 = 0;   // Low for 2ms
//        end
        
//        #100;  // Wait for 100ms

//        // Simulate 5000 RPM (83 pulses per 100ms)
//        repeat (83) begin
//            #1.204 encoder_signal_0 = 1;  // High for 1.204ms
//            #1.204 encoder_signal_0 = 0;  // Low for 1.204ms
//        end
        
//        #100;  // Wait for 100ms

//        // Simulate 2000 RPM (33 pulses per 100ms)
//        repeat (33) begin
//            #3.03 encoder_signal_0 = 1;   // High for 3.03ms
//            #3.03 encoder_signal_0 = 0;   // Low for 3.03ms
//        end
//    end

//endmodule




















//`timescale 1ms / 1ms

//module design_1_wrapper_tb;

//    reg clk;
//    reg encoder_signal_0;
//    wire [31:0] motor_speed_0;
//    wire pwm_out_0;
//    reg reset;

//    // Instantiate the DUT (design under test)
//    design_1_wrapper dut (
//        .clk(clk),
//        .encoder_signal_0(encoder_signal_0),
//        .motor_speed_0(motor_speed_0),
//        .pwm_out_0(pwm_out_0),
//        .reset(reset)
//    );                     

//    // Clock generation: 0.01ms clock period (100 MHz)
//    initial begin
//        clk = 0;
//        forever #1 clk = ~clk;  // Toggle every 0.005ms (5us) to make 0.01ms clock (100 MHz)
//    end

//    // Reset logic
//    initial begin
//        reset = 0;
//        #1 reset = 1;  // Reset after 0.1ms
//    end

//    // Encoder signal generation to simulate different RPMs
//    initial begin
//        encoder_signal_0 = 0;
        
//        // Simulate 3000 RPM (50 pulses per 100ms)
//        repeat (50) begin
//            #2 encoder_signal_0 = 1;   // High for 2ms
//            #2 encoder_signal_0 = 0;   // Low for 2ms
//        end
        
//        #100;  // Wait for 100ms

//        // Simulate 5000 RPM (83 pulses per 100ms)
//        repeat (83) begin
//            #1 encoder_signal_0 = 1;  // High for 1.204ms
//            #1 encoder_signal_0 = 0;  // Low for 1.204ms
//        end
        
//        #100;  // Wait for 100ms

//        // Simulate 2000 RPM (33 pulses per 100ms)
//        repeat (33) begin
//            #3 encoder_signal_0 = 1;   // High for 3.03ms
//            #3 encoder_signal_0 = 0;   // Low for 3.03ms
//        end
//    end

//endmodule
