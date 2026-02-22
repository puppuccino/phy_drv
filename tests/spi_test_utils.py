from cocotb.triggers import RisingEdge, Timer


async def drive_spi_clocks(dut, period_ns: int = 10) -> None:
    half_period = period_ns / 2
    while True:
        dut.clk_spi.value = 0
        dut.clk_spi_n.value = 1
        await Timer(half_period, unit="ns")
        dut.clk_spi.value = 1
        dut.clk_spi_n.value = 0
        await Timer(half_period, unit="ns")


async def reset_dut(dut) -> None:
    dut.req.value = 0
    dut.mult_read.value = 0
    dut.com.value = 0
    dut.adr.value = 0
    dut.dat.value = 0
    dut.i_miso.value = 0
    dut.test_scan.value = 0
    dut.nrst.value = 0

    await Timer(30, unit="ns")
    dut.nrst.value = 1
    await RisingEdge(dut.clk_spi)
    await RisingEdge(dut.clk_spi)


def msb_first_bits(byte_val: int) -> list[int]:
    return [(byte_val >> idx) & 1 for idx in range(7, -1, -1)]


async def capture_mosi_bits(dut, nbits: int) -> list[int]:
    bits = []

    while int(dut.o_cs_n.value) == 1:
        await RisingEdge(dut.clk_spi_n)

    while len(bits) < nbits:
        await RisingEdge(dut.clk_spi_n)
        bits.append(int(dut.o_mosi.value))

    return bits
