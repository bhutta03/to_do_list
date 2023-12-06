# to_do_list
An example smart contract

## Usage

1. Initialize your aptos account
```shell
aptos init --network testnet
```
you will get a `.aptos` folder in your current folder.
```yaml
profiles:
  default:
    private_key: "0x1e01c30f82f1b2383825f0ec380c00eb9318d7607fc7a36be4af02499fabea54"
    public_key: "0x176464e023aa25fedc021714a5f8ccf375b2352cc3c49707ead5007ce485c19e"
    account: a8bbe10fc3aa57445c1daae3b4eb3a0b5c45acf0f33a200800589285d5406058
    rest_url: "https://fullnode.testnet.aptoslabs.com"
    faucet_url: "https://faucet.testnet.aptoslabs.com"
```

2. Get some test APTs
```shell
aptos account fund-with-faucet --account YOUR_ORIGINAL_ACCOUNT --amount 1000000000000
```



3. Create a resource account for `to-do-list`
```shell
aptos move run --function-id '0x1::resource_account::create_resource_account_and_fund' --args 'string:reminder' 'hex:YOUR_ORIGINAL_ACCOUNT' 'u64:10000000'
```

4. Find the address of the resource account
```shell
aptos account list --query resources
```

```txt
{
   "0x1::resource_account::Container": {
     "store": {
       "data": [
          {
            "key": "9164c6c42d7ef611379d09d598e9b9e0cdc82b84c5d78bdce7d2acf9aae4affc",
            "value": {
               "account": "9164c6c42d7ef611379d09d598e9b9e0cdc82b84c5d78bdce7d2acf9aae4affc" # this is it, pad zeros to the left if it's shorter than 64 hex chars
          }
        }
      ]
    }
  }
}
```

Or find it on explorer: `https://explorer.aptoslabs.com/account/YOUR_ACCOUNT/resources?network=testnet`

5. Add the resource account in `config.yaml`
```yaml
profiles:
  default:
    private_key: "0x1e01c30f82f1b2383825f0ec380c00eb9318d7607fc7a36be4af02499fabea54"
    public_key: "0x176464e023aa25fedc021714a5f8ccf375b2352cc3c49707ead5007ce485c19e"
    account: a8bbe10fc3aa57445c1daae3b4eb3a0b5c45acf0f33a200800589285d5406058
    rest_url: "https://fullnode.testnet.aptoslabs.com"
    faucet_url: "https://faucet.testnet.aptoslabs.com"

  todo:
    private_key: "0x1e01c30f82f1b2383825f0ec380c00eb9318d7607fc7a36be4af02499fabea54"
    public_key: "0x176464e023aa25fedc021714a5f8ccf375b2352cc3c49707ead5007ce485c19e"
    account: 9164c6c42d7ef611379d09d598e9b9e0cdc82b84c5d78bdce7d2acf9aae4affc
    rest_url: "https://fullnode.testnet.aptoslabs.com"
    faucet_url: "https://faucet.testnet.aptoslabs.com"
```

6. Edit `Move.toml`
  ```toml
[package]
name = "todo"
version = "1.0.0"
authors = []

[addresses]
todo_address = "9164c6c42d7ef611379d09d598e9b9e0cdc82b84c5d78bdce7d2acf9aae4affc" # replace with the resource account
todo_default_admin = "a8bbe10fc3aa57445c1daae3b4eb3a0b5c45acf0f33a200800589285d5406058" # replace with your account
todo_dev = "a8bbe10fc3aa57445c1daae3b4eb3a0b5c45acf0f33a200800589285d5406058" # replace with your account

[dependencies.AptosFramework]
git = "https://github.com/aptos-labs/aptos-core.git"
rev = "mainnet"
subdir = "aptos-move/framework/aptos-framework"

[dev-dependencies]

```

7. Compile
```shell
aptos move compile
```

8. Publish
```shell
aptos move publish --profile reminder
```
