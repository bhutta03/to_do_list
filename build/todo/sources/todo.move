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

    // errors
    const ERROR_ONLY_ADMIN: u64 = 0;
    const ERROR_UPGRADE_ONLY_ADMIN: u64 = 1;

    struct ContractData has key {
        signer_cap: account::SignerCapability,
        admin: address,

        // smart table to store everyone's todos
        todos: SmartTable<address, String>,

        // events to emit on every action
        todo_created_event: EventHandle<CreateTodoEvent>,
        todo_deleted_event: EventHandle<DeleteTodoEvent>,
    }

    struct CreateTodoEvent has drop, store {
        sender: address,
        todo: String,
    }

    struct DeleteTodoEvent has drop, store {
        sender: address,
    }

    fun init_module(sender: &signer) {
        let signer_cap = resource_account::retrieve_resource_account_cap(sender, DEV);
        let resource_signer = account::create_signer_with_capability(&signer_cap);

        move_to(
            &resource_signer,
            ContractData {
                signer_cap,
                admin: DEFAULT_ADMIN,
                todos: smart_table::new<address, String>(),
                todo_created_event: account::new_event_handle<CreateTodoEvent>(sender),
                todo_deleted_event: account::new_event_handle<DeleteTodoEvent>(sender),
            },
        );
    }

    public entry fun upgrade_contract(sender: &signer, metadata_serialized: vector<u8>, code: vector<vector<u8>>) acquires ContractData {
        let sender_addr = signer::address_of(sender);
        let metadata = borrow_global<ContractData>(RESOURCE_ACCOUNT);
        assert!(sender_addr == metadata.admin, ERROR_ONLY_ADMIN);
        assert!(sender_addr == metadata.admin, ERROR_UPGRADE_ONLY_ADMIN);
        let resource_signer = account::create_signer_with_capability(&metadata.signer_cap);
        code::publish_package_txn(&resource_signer, metadata_serialized, code);
    }

    public entry fun set_admin(sender: &signer, new_admin: address) acquires ContractData {
        let sender_addr = signer::address_of(sender);
        let metadata = borrow_global_mut<ContractData>(RESOURCE_ACCOUNT);

        // only admin can assign new admin
        assert!(sender_addr == metadata.admin, ERROR_ONLY_ADMIN);
        metadata.admin = new_admin;
    }

    // Function to add a todo
    public entry fun add_todo(user: &signer, todo: String) acquires ContractData {
        let sender_address = signer::address_of(user);
        let metadata = borrow_global_mut<ContractData>(RESOURCE_ACCOUNT);

       smart_table::add(&mut metadata.todos, sender_address, todo);
        
        emit_event<CreateTodoEvent>(
            &mut metadata.todo_created_event,
            CreateTodoEvent {
                sender: sender_address,
                todo,
            },
        );
    }

    // Function to delete a todo
    public entry fun delete_todo(user: &signer) acquires ContractData {
        let sender_address = signer::address_of(user);
        let metadata = borrow_global_mut<ContractData>(RESOURCE_ACCOUNT);

        smart_table::remove(&mut metadata.todos, sender_address);

        emit_event<DeleteTodoEvent>(
            &mut metadata.todo_deleted_event,
            DeleteTodoEvent {
                sender: sender_address,
            },
        );
    }
}
