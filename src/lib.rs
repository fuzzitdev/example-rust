#[cfg(test)]
mod tests {
    use crate::parse_complex;

    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }

    fn it_works2() {
        assert_eq!(parse_complex(&[]), true);
    }
}

pub fn parse_complex(data: &[u8]) -> bool{
	if data.len() == 5 {
		if data[0] == b'F' && data[1] == b'U' && data[2] == b'Z' && data[3] == b'Z' && data[4] == b'I' && data[5] == b'T' {
			return true
		}
	}
    return true;
}