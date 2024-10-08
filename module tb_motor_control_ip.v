`timescale 1ns / 1ps

module tb_motor_control_ip;

// Testbench signals
reg [2:0] s_axi_araddr;
reg s_axi_arvalid;
wire s_axi_arready;
reg [2:0] s_axi_awaddr;
reg s_axi_awvalid;
wire s_axi_awready;
reg s_axi_bready;
wire [1:0] s_axi_bresp;
wire s_axi_bvalid;
wire [31:0] s_axi_rdata;
reg s_axi_rready;
wire [1:0] s_axi_rresp;
wire s_axi_rvalid;
reg [31:0] s_axi_wdata;
wire s_axi_wready;
reg [3:0] s_axi_wstrb;
reg s_axi_wvalid;

reg clk;
reg rst_n;
reg s_axi_clk;
reg s_axi_aresetn;
reg encoder_signal;
wire [31:0] motor_speed;
wire pwm_out;

// Instantiate the DUT (Device Under Test)
motor_control_ip uut (
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rready(s_axi_rready),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wready(s_axi_wready),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .clk(clk),
    .rst_n(rst_n),
    .s_axi_clk(s_axi_clk),
    .s_axi_aresetn(s_axi_aresetn),
    .encoder_signal(encoder_signal),
    .motor_speed(motor_speed),
    .pwm_out(pwm_out)
);

// Clock generation
always #5 clk = ~clk;  // 100 MHz clock
always #5 s_axi_clk = ~s_axi_clk;  // AXI clock

initial begin
    // Initialize inputs
    clk = 0;
    s_axi_clk = 0;
    rst_n = 0;
    s_axi_aresetn = 0;
    s_axi_araddr = 0;
    s_axi_arvalid = 0;
    s_axi_awaddr = 0;
    s_axi_awvalid = 0;
    s_axi_bready = 0;
    s_axi_rready = 0;
    s_axi_wdata = 32'b0;
    s_axi_wstrb = 4'b1111;
    s_axi_wvalid = 0;
    encoder_signal = 0;

    // Reset the system
    #10;
    rst_n = 1;
    s_axi_aresetn = 1;

    // Simulate write to the PWM period register (Address 3'b000)
    #20;
    s_axi_awaddr = 3'b000;
    s_axi_awvalid = 1;
    s_axi_wdata = 32'd20000;  // Set period to 20000
    s_axi_wvalid = 1;
    #10;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;

    // Simulate write to the PWM duty cycle register (Address 3'b001)
    #20;
    s_axi_awaddr = 3'b001;
    s_axi_awvalid = 1;
    s_axi_wdata = 32'd10000;  // Set duty cycle to 50%
    s_axi_wvalid = 1;
    #10;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;

    // Simulate encoder signal pulses
    #50;
    repeat (10) begin
        encoder_signal = 1;
        #10;
        encoder_signal = 0;
        #10;
    end

    // Simulate AXI read for motor speed (Address 3'b000)
    #100;
    s_axi_araddr = 3'b000;
    s_axi_arvalid = 1;
    #10;
    s_axi_arvalid = 0;
    #10;
    
    // Monitor outputs
    $monitor("Time: %0t | Motor Speed: %0d RPM | PWM Out: %b", $time, motor_speed, pwm_out);

    // End the simulation
    #200;
    $finish;
end

endmodule
