use std::rc::Rc;
use std::rc::Weak;
use std::cell::RefCell;

struct Node { value: u8, nbr: Option<Weak<RefCell<Node>>> }
impl Drop for Node { fn drop(&mut self) { println!("drop {}", self.value); } }

fn main() {
  let mut rc1 = Rc::new(RefCell::new(Node{value: 1, nbr: None}));
  rc1.borrow_mut().nbr = Some(Rc::downgrade(&rc1));
  let rc2 = Rc::new(RefCell::new(Node{value: 2, nbr: None}));
  rc2.borrow_mut().nbr = Some(Rc::downgrade(&rc2));
  rc1 = Rc::clone(&rc2);
  println!("{} {}", rc1.borrow().value, rc1.borrow().nbr.as_ref().unwrap().upgrade().unwrap().borrow().value);
}
