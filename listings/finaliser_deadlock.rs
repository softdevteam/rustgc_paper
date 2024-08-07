#![feature(gc)]
use std::gc::Gc;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::Mutex;
fn force_gc() { std::gc::GcAllocator::force_gc() }

struct Node { value: Rc<Mutex<u8>>, nbr: Option<Gc<RefCell<Node>>> }

impl Drop for Node {
    fn drop(&mut self) {
        let d = self.value.lock().unwrap();
        println!("drop {}", d);
    } // d is dropped
}

fn main() {
    // Create a reference counted counter object protected by a mutex.
    let counter = Rc::new(Mutex::new(0));

    {
        let gc1 = Gc::new(Node { value: Rc::clone(&counter), nbr: None });
    }

    force_gc();

    // If the finalizer for the `Gc<Node>` is asynchronously called
    // while `counter.lock()` below is already acquired, a deadlock will occur.
    let r1 = counter.lock().unwrap();

    assert_eq!(*r1, 0);
}
