set -xe

## build fuzzer
cargo fuzz run fuzz_parse_complex -- -runs=0

wget -q -O fuzzit https://github.com/fuzzitdev/fuzzit/releases/download/v2.4.29/fuzzit_Linux_x86_64
chmod a+x fuzzit

if [ $1 == "fuzzing" ]; then
    ./fuzzit create job fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
else
    ./fuzzit create job --type local-regression fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
fi