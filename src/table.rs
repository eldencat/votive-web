use sycamore::prelude::*;

#[derive(Prop)]
pub struct TableProps {
    pub label_table: String,
    // field_labels: String,
    // field_values: String // TODO Any types Box dyn
}

#[component]
fn TableHeader<G: Html>(cx: Scope) -> View<G> {
    view! { cx,
        //  Get Dictionary Headers
        p { "Test" } // TODO Editable fields linked to REST calls
        p { "here" }
    }
}

#[component]
fn TableRow<G: Html>(cx: Scope) -> View<G> {
    view! { cx,
        //  Get Dictionary Row Values
        p { "Test" }
        p { "here" }
    }
}

#[component]
pub fn Table<G: Html>(cx: Scope, props: TableProps) -> View<G> {
    // TODO Get Dictionary from props.label_table or id
    view! { cx,
        h1 { (props.label_table) }
        TableHeader { }
        TableRow { }
    }
}
