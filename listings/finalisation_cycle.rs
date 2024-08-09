#![feature(gc)]
use std::gc::Gc;
use std::sync::Mutex;

struct Node {value: u8, nbr: Option<Gc<Mutex<Node>>>}
impl Drop for Node {
 fn drop(&mut self) {
    let nbr = self.nbr.unwrap();
    println!("nbr {}", nbr.lock().unwrap().value);
 }
}

fn main() {
  let n1 = Mutex::new(Node{value: 1, nbr: None});
  let gc1 = Gc::new(n1);
}
