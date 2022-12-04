
module rx (
    input  logic        clk,   // baud rate
    input  logic        en,
    input  logic        in,    // rx
    output logic  [7:0] out,  // received data
    output logic        done, // end on transaction
    output logic        busy, // transaction is in process
    output logic        err   // error while receiving data
);
    //states of uart

    localparam [1:0] RESET     = 2'b00;
    localparam [1:0] IDLE      = 2'b01;
    localparam [1:0] DATA_BITS = 2'b10;
    localparam [1:0] STOP_BIT  = 2'b11;

    logic [2:0] state;
    logic [2:0] bitIdx       = 3'b0; // for 8-bit data
    logic [1:0] inputSw      = 2'b0; // shift logic for input signal state
    logic [3:0] clockCount   = 4'b0; // count clocks for 16x oversample
    logic [7:0] receivedData = 8'b0; // temporary storage for input data

    always_ff @ (posedge clk) begin
        inputSw = { inputSw[0], in };

        if (!en) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                out <= 8'b0;
                err <= 1'b0;
                done <= 1'b0;
                busy <= 1'b0;
                bitIdx <= 3'b0;
                clockCount <= 4'b0;
                receivedData <= 8'b0;

                if (en) begin
                    state <= IDLE;
                end
            end

            IDLE: begin
                done <= 1'b0;
                if (&clockCount) begin
                    state <= DATA_BITS;
                    out <= 8'b0;
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;
                    err <= 1'b0;
                end else if (!(&inputSw) || |clockCount) begin
                    // Check bit to make sure it's still low
                    if (&inputSw) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                    clockCount <= clockCount + 4'b1;
                end
            end

            // Wait 8 full cycles to receive serial data
            DATA_BITS: begin
                if (&clockCount) begin // save one bit of received data
                    clockCount <= 4'b0;
                    // TODO: check the most popular value
                    receivedData[bitIdx] <= inputSw[0];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 3'b1;
                    end
                end else begin
                    clockCount <= clockCount + 4'b1;
                end
            end

            
            //Baud clock may not be running at exactly the same rate as the
            //transmitter. Next start bit is allowed on at least half of stop bit.
            STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|inputSw))) begin
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 1;
                    // Check bit to make sure it's still high
                    if (!(|inputSw)) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                end
            end

            default: state <= IDLE;
        endcase
    end

endmodule
