[![Build Status](https://travis-ci.org/fuzzitdev/example-go.svg?branch=master)](https://travis-ci.org/fuzzitdev/example-rust)
[![fuzzit](https://app.fuzzit.dev/badge?org_id=fuzzitdev&branch=master)](https://fuzzit.dev)

# Continuous Rust Fuzzing Example

This is an example of how to integrate your [cargo-fuzz](https://github.com/rust-fuzz/cargo-fuzz) targets with 
[Fuzzit](https://fuzzit.dev) Continuous Fuzzing Platform (Rust support is currently in Alpha).

This example will show the following steps:
* [Building and running locally a simple cargo-fuzz target](#building--running-the-fuzzer)
* [Integrate the cargo-fuzz target with Fuzzit via Travis-CI](#integrating-with-fuzzit-from-ci)

Result:
* Fuzzit will run the fuzz targets continuously on daily basis with the latest release.
* Fuzzit will run regression tests on every pull-request with the generated corpus and crashes to catch bugs early on.

Fuzzing for Rust can both help find complex bugs as well as correctness bugs. Rust is a safe language so memory corruption bugs
are very unlikely to happen but some bugs can still have security implications.

This tutorial is less about how to build cargo-fuzz targets but more about how to integrate the targets with Fuzzit. A lot of 
great information is available at the [cargo-fuzz](https://rust-fuzz.github.io/book/cargo-fuzz.html) repository.

### Understanding the bug

The bug is located at `src/lib.rs` with the following code

```rust

pub fn parse_complex(data: &[u8]) -> bool{
	if data.len() == 5 {
		if data[0] == b'F' && data[1] == b'U' && data[2] == b'Z' && data[3] == b'Z' && data[4] == b'I' && data[5] == b'T' {
			return true
		}
	}
    return true;
}
```

This is the simplest example to demonstrate a classic off-by-one/out-of-bound error which causes the program to crash.
Instead of `len(data) == 5` the correct code will be `len(data) == 6`.

### Understanding the fuzzer

the fuzzer is located at `fuzz/fuzz_targets/fuzz_target_1.rs` with the following code:

```rust

fuzz_target!(|data: &[u8]| {
    let _ = example_rust::parse_complex(&data);
});

```

### Building & Running the fuzzer

Cargo fuzz required the nightly compiled ar describe in the cargo fuzz [book](https://rust-fuzz.github.io/book/cargo-fuzz.html)

```bash
cargo fuzz run fuzz_target_1
```


Will print the following output and stacktrace:

```text
INFO: Seed: 3265732669
INFO: Loaded 1 modules   (480 guards): 480 [0x100da12d8, 0x100da1a58), 
INFO:        6 files found in /Users/yevgenyp/PycharmProjects/example-rust/fuzz/corpus/fuzz_target_1
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
INFO: seed corpus: files: 6 min: 1b max: 5b total: 26b rss: 27Mb
#7      INITED cov: 87 ft: 87 corp: 5/21b lim: 4 exec/s: 0 rss: 27Mb
#262144 pulse  cov: 87 ft: 87 corp: 5/21b lim: 261 exec/s: 131072 rss: 51Mb
thread '<unnamed>' panicked at 'index out of bounds: the len is 5 but the index is 5', /Users/yevgenyp/PycharmProjects/example-rust/src/lib.rs:17:101
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
==84593== ERROR: libFuzzer: deadly signal
    #0 0x1025ae445 in __sanitizer_print_stack_trace (lib__rustc__clang_rt.asan_osx_dynamic.dylib:x86_64+0x4c445)
    #1 0x100d23b12 in fuzzer::PrintStackTrace() FuzzerUtil.cpp:206
    #2 0x100d0756a in fuzzer::Fuzzer::CrashCallback() FuzzerLoop.cpp:237
    #3 0x100d0750d in fuzzer::Fuzzer::StaticCrashSignalCallback() FuzzerLoop.cpp:209
    #4 0x100d50a07 in fuzzer::CrashHandler(int, __siginfo*, void*) FuzzerUtilPosix.cpp:36
    #5 0x7fff69804b5c in _sigtramp (libsystem_platform.dylib:x86_64+0x4b5c)
    #6 0x106db5b75 in dyld::fastBindLazySymbol(ImageLoader**, unsigned long) (dyld:x86_64+0x4b75)
    #7 0x7fff696be6a5 in abort (libsystem_c.dylib:x86_64+0x5b6a5)
    #8 0x100d79288 in panic_abort::__rust_start_panic::abort::h15c0489ebcc623d0 lib.rs:48
    #9 0x100d79278 in __rust_start_panic lib.rs:44
    #10 0x100d78b98 in rust_panic panicking.rs:526
    #11 0x100d78b79 in std::panicking::rust_panic_with_hook::h111bdf4b9efb2f62 panicking.rs:497
    #12 0x100d7858c in std::panicking::continue_panic_fmt::ha408c1f6b7a89584 panicking.rs:384
    #13 0x100d78478 in rust_begin_unwind panicking.rs:311
    #14 0x100d8b3d1 in core::panicking::panic_fmt::h22e65e952cbe8c74 panicking.rs:85
    #15 0x100d8b388 in core::panicking::panic_bounds_check::h3ed7e9d8bf4f5005 panicking.rs:61
    #16 0x100cf963e in example_rust::parse_complex::h2ee809da6efcf96d lib.rs:17
    #17 0x100cf82aa in rust_fuzzer_test_input fuzz_target_1.rs:6
    #18 0x100d048c5 in libfuzzer_sys::test_input_wrap::_$u7b$$u7b$closure$u7d$$u7d$::h39216f33af358cfa lib.rs:11
    #19 0x100d0022c in std::panicking::try::do_call::h99bafe87b57c13d6 panicking.rs:296
    #20 0x100d7926b in __rust_maybe_catch_panic lib.rs:28
    #21 0x100cff9fc in std::panicking::try::he224cd8d43f275c5 panicking.rs:275
    #22 0x100cfe3a5 in std::panic::catch_unwind::hdccdbf00115971fe panic.rs:394
    #23 0x100d04419 in LLVMFuzzerTestOneInput lib.rs:9
    #24 0x100d09111 in fuzzer::Fuzzer::ExecuteCallback(unsigned char const*, unsigned long) FuzzerLoop.cpp:576
    #25 0x100d087b9 in fuzzer::Fuzzer::RunOne(unsigned char const*, unsigned long, bool, fuzzer::InputInfo*, bool*) FuzzerLoop.cpp:485
    #26 0x100d0ac78 in fuzzer::Fuzzer::MutateAndTestOne() FuzzerLoop.cpp:713
    #27 0x100d0bfb1 in fuzzer::Fuzzer::Loop(std::__1::vector<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, fuzzer::fuzzer_allocator<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > > const&) FuzzerLoop.cpp:844
    #28 0x100d3f4bb in fuzzer::FuzzerDriver(int*, char***, int (*)(unsigned char const*, unsigned long)) FuzzerDriver.cpp:765
    #29 0x100d61629 in main FuzzerMain.cpp:20
    #30 0x7fff696193d4 in start (libdyld.dylib:x86_64+0x163d4)

NOTE: libFuzzer has rudimentary signal handlers.
      Combine libFuzzer with AddressSanitizer or similar for better crash reports.
SUMMARY: libFuzzer: deadly signal
MS: 1 ChangeByte-; base unit: e4fd1292391a997176aa1c86db666f2d5d48fb90
0x46,0x55,0x5a,0x5a,0x49,
FUZZI
artifact_prefix='/Users/yevgenyp/PycharmProjects/example-rust/fuzz/artifacts/fuzz_target_1/'; Test unit written to /Users/yevgenyp/PycharmProjects/example-rust/fuzz/artifacts/fuzz_target_1/crash-df779ced6b712c5fca247e465de2de474d1d23b9
Base64: RlVaWkk=
```

## Integrating with Fuzzit from CI

The best way to integrate with Fuzzit is by adding a two stages in your Contintous Build system
(like Travis CI or Circle CI).

Fuzzing stage:

* Build a fuzz target
* Download `fuzzit` cli
* Authenticate via passing `FUZZIT_API_KEY` environment variable
* Create a fuzzing job by uploading fuzz target

Regression stage
* Build a fuzz target
* Download `fuzzit` cli
* Authenticate via passing `FUZZIT_API_KEY` environment variable OR defining the corpus as public. This way
No authentication would be require and regression can be used for [forked PRs](https://docs.travis-ci.com/user/pull-requests#pull-requests-and-security-restrictions) as well
* create a local regression fuzzing job - This will pull all the generated corpus and run them through
the fuzzing binary. If new bugs are introduced this will fail the CI and alert

here is the relevant snippet from the [./ci/fuzzit.sh](https://github.com/fuzzitdev/example-rust/blob/master/ci/fuzzit.sh)
which is being run by [.travis.yml](https://github.com/fuzzitdev/example-rust/blob/master/.travis.yml)

```bash
wget -q -O fuzzit https://github.com/fuzzitdev/fuzzit/releases/download/v2.4.29/fuzzit_Linux_x86_64
chmod a+x fuzzit
if [ $1 == "fuzzing" ]; then
    ./fuzzit create job fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
else
    ./fuzzit create job --type local-regression fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
fi
``` 

NOTE: In production it is advised to download a pinned version of the [CLI](https://github.com/fuzzitdev/fuzzit)
like in the example. In development you can use latest version:
https://github.com/fuzzitdev/fuzzit/releases/latest/download/fuzzit_${OS}_${ARCH}.
Valid values for `${OS}` are: `Linux`, `Darwin`, `Windows`.
Valid values for `${ARCH}` are: `x86_64` and `i386`.

The steps are:
* Authenticate with the API key (you should keep this secret) you can find in the fuzzit settings dashboard.
* Upload the fuzzer via create job command and create the fuzzing job. In This example we use two type of jobs:
    * Fuzzing job which is run on every push to master which continuous the previous job just with the new release.
    Continuous means all the current corpus is kept and the fuzzer will try to find new paths in the newly added code
    * In a Pull-Request the fuzzer will run a quick "sanity" test running the fuzzer through all the generated corpus
    and crashes to see if the Pull-Request doesnt introduce old or new crashes. This will be alred via the configured
    channel in the dashboard
* The Target is not a secret. This ID can be retrieved from the dashboard after your create the appropriate target in the dashboard.
Each target has it's own corpus and crashes.