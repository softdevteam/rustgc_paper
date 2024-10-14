#![feature(gc)]
use std::gc::Gc;
use std::cell::RefCell;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct GcNode<'a> { value: &'a u8, nbr: Option<Gc<RefCell<GcNode<'a>>>> }
impl<'a> Drop for GcNode<'a> { fn drop(&mut self) { println!("drop {}", self.value); } }

fn main() {
 {
   let b: Box<u8> = Box::new(123);
   let gc1 = Gc::new(GcNode{value: &*b, nbr: None});
 } // b is dropped and its memory deallocated

 // causes `gc::drop` finalizer to run which
 // holds a reference to `b`.
 force_gc();
}
