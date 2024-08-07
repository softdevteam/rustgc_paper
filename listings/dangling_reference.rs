#![feature(gc)]
use std::gc::Gc;
use std::cell::RefCell;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct Node { value: &u8, nbr: Option<Gc<RefCell<Node>>> }
impl Drop for Node { fn drop(&mut self) { println!("drop {}", self.value); } }

fn main() {
    {
        let b: Box<u8> = Box::new(123);
        let gc1 = Gc::new(Node{value: &*b, nbr: None});
    } // b is dropped and its memory deallocated

    // causes `gc::drop` finaliser to run which
    // holds a reference to `b`.
    force_gc();
}
