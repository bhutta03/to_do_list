#[test_only]
module todo_address::todo {
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::code;
    use aptos_framework::resource_account;
    use std::string::String;
    use aptos_std::smart_table::SmartTable;
    use aptos_framework::event::{EventHandle, emit_event};
    use aptos_std::smart_table;

    const DEFAULT_ADMIN: address = @todo_default_admin;
    const RESOURCE_ACCOUNT: address = @todo_address;
    const DEV: address = @todo_dev;

#[test]
fun add_todo(aptos_framework: &signer, module_owner: &signer) {
    todo_address::todo::init_module(&admin);
    todo_address::todo::add_todo(&user, todo.to_string());
    
    let metadata = borrow_global<ContractData>(todo_address::todo::RESOURCE_ACCOUNT);
    assert!(!smart_table::contains_key(&metadata.todos, signer::address_of(&user)));

    todo(&account, todo_address);
    let todo = string::utf8(b"Complete the assignment");
    add_todo(
        creator, 
        todo
        );
    }
}