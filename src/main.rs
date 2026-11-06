use std::net::UdpSocket;

fn main() -> std::io::Result<()> {
    let socket = UdpSocket::bind("0.0.0.0:67").expect("bind should succeed");
    let mut buf = [0; 1522];

    loop {
        let (amt, src) = socket.recv_from(&mut buf)?;
        let buf = &buf[..amt];
        println!("{amt} bytes from {src}");

        for (i, chunk) in buf.chunks(16).enumerate() {
            print!("{:04x}", i * 16);
            chunk.iter().for_each(|b| print!(" {b:02x}"));
            println!();
        }
        println!();
    }
}
