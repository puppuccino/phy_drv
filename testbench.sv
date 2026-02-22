/*
DMA送信動作のテストベンチ
*/

module testbench;
    // Declare the inputs and outputs here
    bit nreset;  // Power on reset
    bit MAC_CLK;  // 16MHz clock
    bit sysclk;  // CPU BUS clock

    logic ncpucs, ncpucs_extra;
    logic [11:0] cpuad;
    logic [3:0] nwe, nre;
    logic [31:0] cpuwd, cpurd;

    logic nrxirq, ntxirq, nifirq, ndmareq;  // (O)
    logic da_clk_2T, da_clk_4T;  // (I)

    logic         tx_start;  // (O)
    logic [317:0] tx_frame;  // (O)
    logic [ 10:0] tx_lg;  // (O)
    logic         mac_sin_on;  // (O)

    logic tx_done, pilot_on, frm_det, rx_sync, rx_en, rxdata, rx_delay;  // (I)
    logic rx_ok, rx_ng, da_clk_en, npdn_da;  // (O)
    logic dac_sw_en, npdn_ad, adc_nonstop, da_20m_cng;  // (O)
    logic [11:0] dbg_mac;  // (O)
    logic pnp_mode_1mhz, pnp_mode_1mhz_cgen;  // (O)
    logic txbuff_sw, rxbuff_sw;  // (O)

    // Instantiate your DUT module here
    mac_top u_mac_top (

        .nreset (nreset),  // Power on reset
        .MAC_CLK(MAC_CLK), // main clock 500kHz

        // CPU BUS signal
        .sysclk      (sysclk),        // CPU BUS clock
        .ncpucs      (ncpucs),        // CPU Chip select for 0x200~0x2FF registeres
        // CPU Chip select for 0x300~0x3FF registeres (RX_DAT8~15, TX_DAT8~15)
        .ncpucs_extra(ncpucs_extra),
        .cpuad       (cpuad),         // CPU Address
        .nwe         (nwe),           // write enable
        .nre         (nre),           // read enable
        .cpuwd       (cpuwd),         // write data bus
        .cpurd       (cpurd),         // read data bus

        .nrxirq   (nrxirq),     // data rx interrupt
        .ntxirq   (ntxirq),     // data tx interrupt
        .nifirq   (nifirq),     // rx beacon interrupt
        .ndmareq  (ndmareq),    // DMA request
        .da_clk_2T(da_clk_2T),  // DA CLK 2 times
        .da_clk_4T(da_clk_4T),  // DA CLK 4 times

        // PHY-IF signal 
        .tx_start          (tx_start),            // Tx start trigger pulse
        .tx_frame          (tx_frame),            // Tx frame data
        .tx_lg             (tx_lg),               // Tx frame length
        .mac_sin_on        (mac_sin_on),          // Tx wake signal flag
        .tx_done           (tx_done),             // transmit done flag
        .pilot_on          (pilot_on),            // pilot simbol insert flag
        .frm_det           (frm_det),             // frame detect flag
        .rx_sync           (rx_sync),             // frame sync detect flag 
        .rx_en             (rx_en),               // rx data valid flag
        .rxdata            (rxdata),              // rx data latest bit
        .rx_delay          (rx_delay),            // rx data delay demand
        .rx_ok             (rx_ok),               // rx frame receive ok pulse
        .rx_ng             (rx_ng),               // rx frame receive ng pulse
        .da_clk_en         (da_clk_en),           // DAC clock gating signal
        .npdn_da           (npdn_da),             // DAC power down signal
        .dac_sw_en         (dac_sw_en),           // DAC SW select signal
        .npdn_ad           (npdn_ad),             // ADC power down signal
        .adc_nonstop       (adc_nonstop),         // ADC nonstop mode
        .da_20m_cng        (da_20m_cng),          // DAC 20mA force
        .dbg_mac           (dbg_mac),             // MAC MONITOR signal 12bit
        .pnp_mode_1mhz     (pnp_mode_1mhz),       // 0: now in mode A, 1: now in mode B
        .pnp_mode_1mhz_cgen(pnp_mode_1mhz_cgen),  // ↑の clkgen の現在値
        .txbuff_sw         (txbuff_sw),
        .rxbuff_sw         (rxbuff_sw)

    );

    // Add clock and reset signals if needed
    initial begin
        MAC_CLK = 0;
        forever #62.5 MAC_CLK = ~MAC_CLK;  // 8MHz clock
    end

    initial begin
        sysclk = 0;
        forever #2000 sysclk = ~sysclk;  // 250kHz clock
    end

    initial begin
        nreset = 1;
        #100 nreset = 0;
    end


    // Add stimulus generation code here
    initial begin
        ncpucs       = 1;
        ncpucs_extra = 1;
        cpuad        = 12'h000;
        nwe          = 4'b1111;
        nre          = 4'b1111;
        cpuwd        = 32'h0000_0000;
        da_clk_2T    = 0;
        da_clk_4T    = 0;
        tx_done      = 0;
        pilot_on     = 0;
        frm_det      = 0;
        rx_sync      = 0;
        rx_en        = 0;
        rxdata       = 0;
        rx_delay     = 0;
    end

    // Add assertions or checks here

    // Add code for capturing and displaying waveforms if needed
    initial begin
        $dumpfile("dump.fst");
        $dumpvars();
    end

    // Add code for ending the simulation
    initial begin
        #1000000 $finish;
    end

endmodule
