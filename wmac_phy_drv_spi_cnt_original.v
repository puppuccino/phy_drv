/*
SPI通信を行うモジュール。
SPI通信の開始は req が 1 になったときで、com, adr, dat の値をシフトして送信する。

マルチリードをサポートしており、
*/
module cs_orig (
    input clk_spi,
    input clk_spi_n,
    input nrst,
    input test_scan,

    input       req,
    input       mult_read,
    input [7:0] com,
    input [7:0] adr,
    input [7:0] dat,

    output            done,
    output reg [15:0] rdat,

    output     o_spi_sck,
    output reg o_cs_n,
    output reg o_mosi,
    input      i_miso
);
    reg  [ 5:0] stat;
    reg         mosi_nxt;
    reg  [15:0] rdat_nxt;

    wire        trans_done;
    wire        spi_scken;

    assign done = (~mult_read && stat == 6'd27) | (stat == 6'd35);
    assign trans_done = (~mult_read && stat >= 6'd25) | (stat >= 6'd33);

    assign spi_scken = ~o_cs_n & ~trans_done;
    CLK_CG gate_clk_spi_sck (
        .CK  (clk_spi),
        .CKEN(spi_scken),
        .SCEN(test_scan),
        .Y   (o_spi_sck)
    );

    always @(posedge clk_spi or negedge nrst) begin
        if (~nrst) o_cs_n <= 1'b1;
        else if (~req) o_cs_n <= 1'b1;
        else o_cs_n <= (trans_done) ? 1'b1 : (req && stat == 6'd0) ? 1'b0 : o_cs_n;
    end

    always @(posedge clk_spi_n or negedge nrst) begin
        if (~nrst) o_mosi <= 1'b0;
        else o_mosi <= (~o_cs_n) ? mosi_nxt : o_mosi;
    end

    always @(posedge clk_spi or negedge nrst) begin
        if (~nrst) rdat <= {16{1'b0}};
        else rdat <= (~o_cs_n && com[1:0] == 2'b11) ? rdat_nxt : rdat;
    end

    always @(posedge clk_spi or negedge nrst) begin
        if (~nrst) stat <= {6{1'b0}};
        else if (~req) stat <= {6{1'b0}};
        else begin
            stat <= (done) ? {6{1'b0}} : stat + 1'b1;
        end
    end

    always @(*) begin
        case (stat)
            6'd1: mosi_nxt = com[7];
            6'd2: mosi_nxt = com[6];
            6'd3: mosi_nxt = com[5];
            6'd4: mosi_nxt = com[4];
            6'd5: mosi_nxt = com[3];
            6'd6: mosi_nxt = com[2];
            6'd7: mosi_nxt = com[1];
            6'd8: mosi_nxt = com[0];

            6'd9:  mosi_nxt = adr[7];
            6'd10: mosi_nxt = adr[6];
            6'd11: mosi_nxt = adr[5];
            6'd12: mosi_nxt = adr[4];
            6'd13: mosi_nxt = adr[3];
            6'd14: mosi_nxt = adr[2];
            6'd15: mosi_nxt = adr[1];
            6'd16: mosi_nxt = adr[0];

            6'd17: mosi_nxt = dat[7];
            6'd18: mosi_nxt = dat[6];
            6'd19: mosi_nxt = dat[5];
            6'd20: mosi_nxt = dat[4];
            6'd21: mosi_nxt = dat[3];
            6'd22: mosi_nxt = dat[2];
            6'd23: mosi_nxt = dat[1];
            6'd24: mosi_nxt = dat[0];

            default: mosi_nxt = dat[0];
        endcase
    end

    always @(*) begin
        case (stat)
            6'd17:   rdat_nxt = {i_miso, rdat[14:0]};
            6'd18:   rdat_nxt = {rdat[15:15], i_miso, rdat[13:0]};
            6'd19:   rdat_nxt = {rdat[15:14], i_miso, rdat[12:0]};
            6'd20:   rdat_nxt = {rdat[15:13], i_miso, rdat[11:0]};
            6'd21:   rdat_nxt = {rdat[15:12], i_miso, rdat[10:0]};
            6'd22:   rdat_nxt = {rdat[15:11], i_miso, rdat[9:0]};
            6'd23:   rdat_nxt = {rdat[15:10], i_miso, rdat[8:0]};
            6'd24:   rdat_nxt = {rdat[15:9], i_miso, rdat[7:0]};
            6'd25:   rdat_nxt = mult_read ? {rdat[15:8], i_miso, rdat[6:0]} : rdat;
            6'd26:   rdat_nxt = {rdat[15:7], i_miso, rdat[5:0]};
            6'd27:   rdat_nxt = {rdat[15:6], i_miso, rdat[4:0]};
            6'd28:   rdat_nxt = {rdat[15:5], i_miso, rdat[3:0]};
            6'd29:   rdat_nxt = {rdat[15:4], i_miso, rdat[2:0]};
            6'd30:   rdat_nxt = {rdat[15:3], i_miso, rdat[1:0]};
            6'd31:   rdat_nxt = {rdat[15:2], i_miso, rdat[0:0]};
            6'd32:   rdat_nxt = {rdat[15:1], i_miso};
            default: rdat_nxt = rdat[15:0];
        endcase
    end

endmodule
