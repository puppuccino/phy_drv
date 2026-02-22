from pathlib import Path
import os
import sys

from cocotb_tools.runner import get_runner


TEST_MODULES = [
    "tests.test_spi_shift_and_done_single",
    "tests.test_spi_multiread_captures_16bit_rdat",
]


def run() -> None:
    proj_root = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(proj_root))
    os.environ.setdefault("CCACHE_DIR", str(proj_root / ".ccache"))

    sim_name = os.getenv("SIM", "verilator")
    runner = get_runner(sim_name)
    build_dir = proj_root / "sim_build" / "wmac_phy_drv_spi_cnt"
    for stale_file in (build_dir / "dump.vcd", build_dir / "results.xml"):
        stale_file.unlink(missing_ok=True)

    runner.build(
        sources=[
            proj_root / "wmac_phy_drv_spi_cnt.v",
            proj_root / "CLK_CG.v",
        ],
        hdl_toplevel="wmac_phy_drv_spi_cnt",
        build_dir=build_dir,
        always=True,
        waves=True,
    )

    for test_module in TEST_MODULES:
        test_name = test_module.rsplit(".", 1)[-1]
        test_dir = build_dir / "tests" / test_name
        test_args = []

        if sim_name.lower() == "verilator":
            wave_file = test_dir / f"{test_name}.vcd"
            test_args = ["--trace-file", str(wave_file)]

        runner.test(
            hdl_toplevel="wmac_phy_drv_spi_cnt",
            test_module=test_module,
            test_dir=test_dir,
            results_xml=f"{test_name}.results.xml",
            test_args=test_args,
            waves=True,
        )


if __name__ == "__main__":
    run()
