#![feature(gc)]
use std::gc::Gc;
use std::rc::Rc;
use std::cell::RefCell;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct Node { value: u8, nbr: Option<Rc<RefCell<Node>>> }

fn main() {
  let n1 = RefCell::new(Node{value:1, nbr: None});
  let gc1 = Gc::new(n1);
  let n2 = RefCell::new(Node{value:2, nbr: None});
  let rc1 = Rc::new(n2);
  gc1.borrow_mut().nbr = Some(Rc::clone(&rc1));
}
