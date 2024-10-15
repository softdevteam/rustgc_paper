#![feature(gc)]
use std::gc::Gc;
use std::cell::RefCell;

struct GcNode { value: u8, nbr: Option<Gc<RefCell<GcNode>>> }
impl Drop for GcNode {
  fn drop(&mut self) {
    self.value = 0;
    println!("{}", self.nbr.unwrap().borrow().value);
  }
}

fn main()  {
  let mut gc1 = Gc::new(RefCell::new(GcNode{value: 1, nbr: None}));
  let gc2 = Gc::new(RefCell::new(GcNode{value: 2, nbr: None}));
  gc1.borrow_mut().nbr = Some(gc2);
  gc2.borrow_mut().nbr = Some(gc1);
}
