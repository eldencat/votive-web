//! Front Page

use sycamore::prelude::*;

mod table;

fn main() {
    sycamore::render(|cx| {
        view! { cx,
            table::Table(label_table="try this".to_string())
            // table::Table { }
        }
    });
}
