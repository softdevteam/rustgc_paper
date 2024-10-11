#![feature(gc)]
use std::gc::Gc;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::Mutex;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct GcNode { value: Rc<Mutex<u8>>, nbr: Option<Gc<RefCell<Node>>> }

impl Drop for GcNode {
  fn drop(&mut self) { println!("drop {}", self.value.lock().unwrap()); }
}

fn main() {
  let counter = Rc::new(Mutex::new(0));
  { let _ = Gc::new(GcNode { value: Rc::clone(&counter), nbr: None }); }
  let r1 = counter.lock().unwrap(); // Can deadlock
  force_gc();
  assert_eq!(*r1, 0);
}
