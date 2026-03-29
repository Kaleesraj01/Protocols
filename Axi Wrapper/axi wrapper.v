module axi_wrapper #(
    parameter depth = 1024, 
    parameter width = 32
)(
    input clk, 
    input rst,
    
    // Write Address Channel
    input [31:0] s_awaddr,
    input s_awvalid,
    output reg s_awready,
    
    // Write Data Channel
    input [width-1:0] s_wdata,
    input s_wvalid,
    output reg s_wready,
    
    // Write Response Channel
    output reg [1:0] s_bresp,
    output reg s_bvalid,
    input s_bready,
    
    // Read Address Channel
    input [31:0] s_araddr,
    input s_arvalid,
    output reg s_arready,
    
    // Read Data Channel
    output reg [width-1:0] s_rdata,
    output reg [1:0] s_rresp,
    output reg s_rvalid,
    input s_rready
);

// Internal signals to connect RAM
reg we;
reg [$clog2(depth)-1:0] addr;
reg [width-1:0] wdata;
wire [width-1:0] rdata;  // Changed from reg to wire (RAM drives it)

// Instantiation
sram #(.depth(depth), .width(width)) 
dut (
    .clk(clk), 
    .we(we), 
    .addr(addr), 
    .wdata(wdata), 
    .rdata(rdata)
);

//write state machine 
reg [1:0] wstate;
parameter w_idle = 2'b00, 
          w_addr = 2'b01, 
          w_data = 2'b10, 
          w_resp = 2'b11;

always @(posedge clk) begin 
    if (rst) begin 
        wstate    <= w_idle;
        s_awready <= 0;
        s_wready  <= 0;
        s_bvalid  <= 0;
        we        <= 0;
        addr      <= 0;
        wdata     <= 0;
    end 
    else begin 
        case (wstate)

        w_idle: begin 
            we        <= 0;
            s_bvalid  <= 0;
            s_awready <= 1;   // ready to accept address

            if (s_awvalid) begin
                addr <= s_awaddr[$clog2(depth)-1:0];  // capture address
                wstate <= w_addr;
            end
        end

        w_addr: begin
            s_awready <= 0;
            s_wready  <= 1;   // now ready for data

            if (s_wvalid) begin
                wdata <= s_wdata;   // capture data
                wstate <= w_data;
            end
        end

        
        w_data: begin 
            s_wready <= 0;
            we <= 1;           // perform write to RAM
            wstate <= w_resp;
        end

        
        w_resp: begin 
            we <= 0;
            s_bvalid <= 1;
            s_bresp  <= 2'b00;   // OKAY

            if (s_bready) begin
                s_bvalid <= 0;
                wstate <= w_idle;
            end
        end

        default: wstate <= w_idle;

        endcase
    end
end
  
  //Read state machine
  reg [1:0] rstate;

parameter r_idle = 2'b00,
          r_addr = 2'b01,
          r_data = 2'b10;
  
  always @(posedge clk) begin 
    if (rst) begin 
        rstate    <= r_idle;
        s_arready <= 0;
        s_rvalid  <= 0;
        s_rdata   <= 0;
        s_rresp   <= 0;
    end 
    else begin 
        case (rstate)

        
        r_idle: begin 
          
            s_arready <= 1;

            if (s_arvalid) begin
                addr <= s_araddr[$clog2(depth)-1:0];
                rstate <= r_addr;
            end
        end

        r_addr: begin
            s_arready <= 0;
            s_rdata   <= rdata;
            s_rresp   <= 2'b00;
            s_rvalid  <= 1;
            rstate <= r_data;
        end

        r_data: begin
            if (s_rready) begin
                s_rvalid <= 0;
                rstate <= r_idle;
            end
        end

        default: rstate <= r_idle;

        endcase
    end
end
  
