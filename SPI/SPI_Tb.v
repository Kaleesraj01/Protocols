module SPI_tb;

reg clk;
reg rst;
reg start;
reg [7:0] master_data_in;
reg [7:0] slave_data_in;
wire mosi;
wire miso;
wire sclk;
wire ss;
wire master_done;
wire slave_done;
wire [7:0] master_received;
wire [7:0] slave_received;


initial begin
clk = 0;
forever #5 clk = ~clk;
end

// Instantiate MASTER
spi_master master (
.clk(clk),
.rst(rst),
.start(start),
.miso(miso),
.data_in(master_data_in),
.sclk(sclk),
.ss(ss),
.mosi(mosi),
.done(master_done),
.received_data(master_received)
);

// Instantiate SLAVE
spi_slave slave (
.clk(clk),
.rst(rst),
.start(start),
.sclk(sclk),
.mosi(mosi),
.ss(ss),
.miso(miso),
.data_in(slave_data_in),
.received_data(slave_received),
.done(slave_done)
);


initial begin
rst = 1;
start = 0;
master_data_in = 8'b10111010;  // Data from master
slave_data_in  = 8'b11000100;  // Data from slave

#20;
rst = 0;
#20;


start = 1;
#10;
start = 0;

#20;

$display("Master sent:      %b", master_data_in);
$display("Slave sent :      %b", slave_data_in);
$display("Master received:  %b", master_received);
$display("Slave received :  %b", slave_received);

#50;
$finish;
end


initial begin
$monitor("Time=%0t | SS=%b | SCLK=%b | MOSI=%b | MISO=%b | MasterRecv=%b | SlaveRecv=%b",
$time, ss, sclk, mosi, miso, master_received, slave_received);
$dumpfile("spi_wave.vcd");
$dumpvars;
end

endmodule
