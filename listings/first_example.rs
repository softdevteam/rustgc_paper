#![feature(gc)]
use std::gc::Gc;
use std::cell::RefCell;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct GcNode { value: u8, nbr: Option<Gc<RefCell<GcNode>>> }
impl Drop for GcNode { fn drop(&mut self) { println!("drop {}", self.value); } }

fn main() {
  let mut gc1 = Gc::new(RefCell::new(GcNode { value: 1, nbr: None } ));
  gc1.borrow_mut().nbr = Some(gc1);
  let gc2 = Gc::new(RefCell::new(GcNode { value: 2, nbr: None } ));
  gc2.borrow_mut().nbr = Some(gc2);
  gc1 = gc2;
  force_gc();
  println!("{} {}", gc1.borrow().value, gc1.borrow().nbr.unwrap().borrow().value);
}
