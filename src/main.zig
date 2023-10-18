const std = @import("std");
const microzig = @import("microzig");
const rp2040 = microzig.hal;
const gpio = rp2040.gpio;
const peripherals = microzig.chip.peripherals;

pub const std_options = struct {
    pub const log_level = .info;
    pub const logFn = rp2040.uart.log;
};

const uart = rp2040.uart.num(0);

pub fn main() !void {
    uart.apply(.{
        .baud_rate = 115200,
        .tx_pin = gpio.num(0),
        .rx_pin = gpio.num(1),
        .clock_config = rp2040.clock_config,
    });
    rp2040.uart.init_logger(uart);

    std.log.info("Hello", .{});

    const pin_config = rp2040.pins.GlobalConfiguration{
        .GPIO25 = .{
            .name = "led",
            .direction = .out,
        },
    };

    const pins = pin_config.apply();

    while (true) {
        std.log.info("Hello", .{});
        pins.led.toggle();

        rp2040.time.sleep_ms(1000);
    }
}
