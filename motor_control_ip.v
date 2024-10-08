module motor_control_ip(
    
    // AXI4-Lite Interface signals 
    input wire [2:0] s_axi_araddr,    // Read address from AXI interface
    output reg s_axi_arready,         // Read address ready    
    input wire s_axi_arvalid,         // Read address valid signal
    input wire [2:0] s_axi_awaddr,    // Write address from AXI interface
    output reg s_axi_awready,         // Write address ready
    input wire s_axi_awvalid,         // Write address valid signal
    input wire s_axi_bready,          // Write response ready
    output reg [1:0] s_axi_bresp,     // Write response
    output reg s_axi_bvalid,          // Write response valid
    output reg [31:0] s_axi_rdata,    // Read data for AXI interface
    input wire s_axi_rready,           // Read data ready acknowledgment
    output reg [1:0] s_axi_rresp,     // Read response
    output reg s_axi_rvalid,          // Read data valid signal
    input wire [31:0] s_axi_wdata,    // Write data from AXI interface
    output reg s_axi_wready,          // Write data ready
    input wire [3:0] s_axi_wstrb,     // Write strobe signal (byte enable)
    input wire s_axi_wvalid,          // Write data valid signal
    
    
    
    input wire clk,                 // System clock for the IP logic
    input wire rst_n,               // Active-low reset signal
    input wire s_axi_clk,             // AXI clock for the AXI transactions
    input wire s_axi_aresetn,          // AXI reset signal (active low)
    //input wire [31:0] pwm_period,   // 32-bit PWM period input (from AXI)
    //input wire [31:0] pwm_duty,     // 32-bit PWM duty cycle input (from AXI)
    input wire encoder_signal,      // Encoder signal from motor (10 pulses per revolution)
    output reg [31:0] motor_speed,  // Output register for motor speed in RPM
    output wire pwm_out            // Output PWM signal for motor control       
);

// Parameters
parameter PULSES_PER_REV = 10;   // Pulses per revolution (encoder)
parameter CLK_FREQ = 100000000;  // System clock frequency (assumed 100 MHz)

// AXI registers
reg [31:0] pwm_period_reg;   // Register to hold PWM period
reg [31:0] pwm_duty_reg;     // Register to hold PWM duty cycle

// Internal variables for PWM and speed calculation
reg [31:0] period_count;     // Counter for PWM period
reg [31:0] duty_count;       // Counter for PWM duty cycle
reg pwm_reg;                 // Register to hold current PWM state
reg [31:0] pulse_count;      // Pulse count from encoder
reg [31:0] speed_update_count; // Speed update counter (for 100ms intervals)
reg encoder_prev;            // Previous encoder state (for edge detection)

// AXI Write logic for PWM period and duty cycle
always @(posedge s_axi_clk) begin
    if (!s_axi_aresetn) begin
        s_axi_awready <= 0;
        s_axi_wready <= 0;
        s_axi_bvalid <= 0;
        s_axi_bresp <= 2'b00;    // OKAY response
        pwm_period_reg <= 32'd10000;  // Default period value
        pwm_duty_reg <= 32'd5000;     // Default duty cycle value (50%)
    end else begin
        // AXI write address handshake
        if (s_axi_awvalid && !s_axi_awready) begin
            s_axi_awready <= 1;
        end else begin
            s_axi_awready <= 0;
        end
        
        // AXI write data handshake
        if (s_axi_wvalid && !s_axi_wready) begin
            s_axi_wready <= 1;
            if (s_axi_wstrb[3:0] == 4'b1111) begin
                case (s_axi_awaddr)
                    3'b000: pwm_period_reg <= s_axi_wdata;  // Write to PWM period register
                    3'b001: pwm_duty_reg <= s_axi_wdata;    // Write to PWM duty cycle register
                endcase
            end
        end else begin
            s_axi_wready <= 0;
        end
        
        // Write response (bvalid and bready handshake)
        if (!s_axi_bvalid && s_axi_awvalid && s_axi_wvalid && s_axi_wready) begin
            s_axi_bvalid <= 1;
            s_axi_bresp <= 2'b00;  // OKAY response
        end else if (s_axi_bvalid && s_axi_bready) begin
            s_axi_bvalid <= 0;
        end
    end
end

// AXI Read logic for motor speed
always @(posedge s_axi_clk) begin
    if (!s_axi_aresetn) begin
        s_axi_arready <= 0;
        s_axi_rvalid <= 0;
        s_axi_rdata <= 32'b0;
        s_axi_rresp <= 2'b00;  // OKAY response
    end else begin
        if (s_axi_arvalid && !s_axi_rvalid) begin
            s_axi_arready <= 1;
            s_axi_rvalid <= 1;
            // Reading motor speed based on address
            case (s_axi_araddr)
                3'b000: s_axi_rdata <= motor_speed;  // Read motor speed register
            endcase
            s_axi_rresp <= 2'b00;  // OKAY response
        end else if (s_axi_rvalid && s_axi_rready) begin
            s_axi_arready <= 0;
            s_axi_rvalid <= 0;
        end
    end
end

// PWM generation logic
always @(posedge clk) begin
    if (!rst_n) begin
        period_count <= 32'd0;
        duty_count <= 32'd0;
        pwm_reg <= 1'b0;
    end else begin
        if (period_count < pwm_period_reg)
            period_count <= period_count + 1;
        else
            period_count <= 32'd0;

        if (duty_count < pwm_duty_reg)
            duty_count <= duty_count + 1;
        else
            duty_count <= 32'd0;

        pwm_reg <= (duty_count < pwm_duty_reg) ? 1 : 0;
    end
end

assign pwm_out = pwm_reg;

// RPM Calculation based on encoder signal
always @(posedge clk) begin
    if (!rst_n) begin
        pulse_count <= 32'd0;
        motor_speed <= 32'd0;
        speed_update_count <= 32'd0;
        encoder_prev <= 1'b0;
    end else begin
        // Detect rising edge of encoder signal
        if (encoder_signal && !encoder_prev) begin
            pulse_count <= pulse_count + 1;
        end
        encoder_prev <= encoder_signal;

        // Update motor speed every 100ms
        if (speed_update_count < CLK_FREQ / 10) begin
            speed_update_count <= speed_update_count + 1;
        end else begin
            motor_speed <= (pulse_count * 60 * CLK_FREQ) / (PULSES_PER_REV * 10);
            pulse_count <= 32'd0;
            speed_update_count <= 32'd0;
        end
    end
end

endmodule 