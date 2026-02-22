module miter;
    (*gclk*)logic gclk;

    logic clk_spi = 1'b0;
    always_ff @(posedge gclk) clk_spi <= ~clk_spi;

    wire         clk_spi_n = ~clk_spi;

    // anyseqをつけると毎サイクル自由に変わりうる入力（= 無制約入力）
    (* anyseq *)logic        nrst;
    wire         test_scan = 1'b0;
    (* anyseq *)logic        req;
    (* anyseq *)logic        mult_read;
    (* anyseq *)logic [ 7:0] com;
    (* anyseq *)logic [ 7:0] adr;
    (* anyseq *)logic [ 7:0] dat;
    (* anyseq *)logic        i_miso;


    // 0 for orig, 1 for new
    logic        o_done               [2];
    logic [15:0] o_rdat               [2];
    logic        o_spi_sck            [2];
    logic        o_cs_n               [2];
    logic        o_mosi               [2];

    cs_orig u0 (
        .clk_spi,
        .clk_spi_n,
        .nrst,
        .test_scan,
        .req,
        .mult_read,
        .com,
        .adr,
        .dat,
        .i_miso,
        .done(o_done[0]),
        .rdat(o_rdat[0]),
        .o_spi_sck(o_spi_sck[0]),
        .o_cs_n(o_cs_n[0]),
        .o_mosi(o_mosi[0])
    );

    wmac_phy_drv_spi_cnt u1 (
        .clk_spi,
        .clk_spi_n,
        .nrst,
        .test_scan,
        .req,
        .mult_read,
        .com,
        .adr,
        .dat,
        .i_miso,
        .done(o_done[1]),
        .rdat(o_rdat[1]),
        .o_spi_sck(o_spi_sck[1]),
        .o_cs_n(o_cs_n[1]),
        .o_mosi(o_mosi[1])
    );

`ifdef FORMAL
    always_comb begin
        assume (nrst == !$initstate);
    end
`endif

    logic past_valid;
    always_ff @(posedge clk_spi or negedge nrst) begin
        if (!nrst) begin
            past_valid <= 1'b0;
        end else begin
            past_valid <= 1'b1;
        end
    end

    // 「一度nrstが1になったら戻らない」くらいは縛っておくと探索が安定します（任意）
    always_ff @(posedge clk_spi) if (past_valid && $past(nrst)) assume (nrst);

    // 等価性：常に同じ値（必要なら nrst==1 のときだけ等価、などにしてもOK）
    always_ff @(posedge clk_spi)
        if (past_valid) begin
            assert (o_done[0] == o_done[1]);
            assert (o_rdat[0] == o_rdat[1]);
            assert (o_spi_sck[0] == o_spi_sck[1]);
            assert (o_cs_n[0] == o_cs_n[1]);
            assert (o_mosi[0] == o_mosi[1]);
        end
endmodule
