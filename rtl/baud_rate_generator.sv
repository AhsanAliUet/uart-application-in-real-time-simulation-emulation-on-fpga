
//thid module will generate clock for both transmitter and receiver
//receiver clock will be 16 time that of transmitter

module baud_rate_generator  #(
    parameter CLOCK      = 100000000, //board clock of 100MHz
    parameter BAUD_RATE  = 9600
)(
    input  logic clk,       //system clock (clock of FPGA)
    input  logic rst,
    output logic clk_rx,    //clock for receiver
    output logic clk_tx     //clock for transmitter
);

localparam MAX_COUNT_RX  = CLOCK / (2 * BAUD_RATE * 16); // 16x oversample
localparam MAX_COUNT_TX  = CLOCK / (2 * BAUD_RATE);
localparam RXW           = $clog2(MAX_COUNT_RX);         //width of Rx counter
localparam TXW           = $clog2(MAX_COUNT_TX);         //width of Tx counter

reg [RXW - 1:0] rx_counter = 0;
reg [TXW - 1:0] tx_counter = 0;


always_ff @ (posedge clk, posedge rst) begin
    if (rst) begin
        clk_rx <= 0;
        clk_tx <= 0;
    end

    // Rx clock
    if (rx_counter == MAX_COUNT_RX[RXW-1:0]) begin
        rx_counter <= 0;
        clk_rx     <= ~clk_rx;
    end else begin
        rx_counter <= rx_counter + 1'b1;
    end

    // Tx clock
    if (tx_counter == MAX_COUNT_TX[TXW-1:0]) begin
        tx_counter <= 0;
        clk_tx     <= ~clk_tx;
    end else begin
        tx_counter <= tx_counter + 1'b1;
    end
end

endmodule
