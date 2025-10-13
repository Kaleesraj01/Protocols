//SPI SLAVE MODULE
module spi_slave( 
input clk,
input rst,
input start,
input sclk,
input mosi,
input ss,
output wire miso,
input wire [7:0] data_in,
output reg [7:0] received_data,
output reg done);

reg miso_reg;
assign miso = (!ss) ? miso_reg : 1'bz;

reg [7:0] shift_out;
reg [3:0] bit_cnt;
reg sclk_prev;

parameter IDLE = 2'b00, LOAD = 2'b01, TRANSFER = 2'b10, DONE = 2'b11;
reg [1:0] state, next_state;

always @(posedge clk or posedge rst) begin
if(rst)
state <= IDLE;
else
state <= next_state;
end

always @(*) begin
case(state)
IDLE: next_state = (start) ? LOAD  : IDLE;
LOAD: next_state = (!ss) ? TRANSFER : LOAD;
TRANSFER: next_state = (bit_cnt == 4'd0) ? DONE : TRANSFER;
DONE: next_state = (ss) ? IDLE : DONE;
default: next_state = IDLE;
endcase
end

always @(posedge clk or posedge rst) begin
if (rst) begin
shift_out <= 8'd0;
bit_cnt <= 4'd8;
miso_reg <= 1'b0;
received_data <= data_in;
done <= 1'b0;
sclk_prev <= 1'b0;
end 
else begin
sclk_prev <= sclk;
case (state)
IDLE: begin
done <= 1'b0;
end
LOAD: begin
shift_out <= data_in;
bit_cnt <= 4'd8;
end
TRANSFER: begin
if (sclk_prev == 0 && sclk) begin
// Rising edge: capture MOSI
received_data <= {received_data[6:0], mosi};
end
if (sclk_prev  && sclk ==0  ) begin
// Falling edge: shift out MISO
miso_reg <= shift_out[7];
shift_out <= {shift_out[6:0], 1'b0};
if (bit_cnt != 0)
bit_cnt <= bit_cnt - 1;
else
bit_cnt <= 0;
end
end
DONE: begin
done <= 1'b1;
end
endcase
end
end
endmodule



