use std::rc::Rc;
use std::rc::Weak;
use std::cell::RefCell;

struct RcNode { value: u8, nbr: Option<Weak<RefCell<RcNode>>> }
impl Drop for RcNode { fn drop(&mut self) { println!("drop {}", self.value); } }

fn main() {
  let mut rc1 = Rc::new(RefCell::new(RcNode{value: 1, nbr: None}));
  rc1.borrow_mut().nbr = Some(Rc::downgrade(&rc1));
  let rc2 = Rc::new(RefCell::new(RcNode{value: 2, nbr: None}));
  rc2.borrow_mut().nbr = Some(Rc::downgrade(&rc2));
  rc1 = Rc::clone(&rc2);
  println!("{} {}", rc1.borrow().value,
                      rc1.borrow().nbr.as_ref().unwrap().upgrade().unwrap().borrow().value);
}
