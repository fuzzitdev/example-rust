#![no_main]
#[macro_use] extern crate libfuzzer_sys;
extern crate example_rust;

fuzz_target!(|data: &[u8]| {
    let _ = example_rust::parse_complex(&data);
});
