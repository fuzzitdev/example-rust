set -xe

if [ -z ${1+x} ]; then
    echo "must call with job type as first argument e.g. 'fuzzing' or 'sanity'"
    echo "see https://github.com/fuzzitdev/example-go/blob/master/.travis.yml"
    exit 1
fi

## build fuzzer
cargo fuzz run fuzz_parse_complex -- -runs=0

wget -q -O fuzzit https://github.com/fuzzitdev/fuzzit/releases/download/v2.4.2/fuzzit_Linux_x86_64
chmod a+x fuzzit

if [ $1 == "fuzzing" ]; then
    ./fuzzit auth ${FUZZIT_API_KEY}
    ./fuzzit create job --branch $TRAVIS_BRANCH --revision $TRAVIS_COMMIT fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
else
    ./fuzzit create job --local fuzzitdev/rust-parse-complex ./fuzz/target/x86_64-unknown-linux-gnu/debug/fuzz_parse_complex
fi