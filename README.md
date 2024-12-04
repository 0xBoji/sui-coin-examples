# A Sui Coin Example

![QRCode of this repo](https://akrd.net/vl1VeM0H-8c2ONAztup3kNakgur0dxgKoMNDmAM8D-M)

In this example, we will demonstrate:

* Modify a simple Coin contract and deploy it on Movement M2 devnet or on Sui testnet;
* Mint some of this Coin for yourself;
* Create a token pair of this Coin with other Coin and provide initial liquidity on a decentralized exchange (DEX) called Flex.

--------

Hint: Flex has published their test contract on Movement M2 devnet.
The information of the contract package ID and the Exchange object ID on it is as follows:

```text
PackageID: 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd

ObjectType: 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd::exchange::Exchange
ObjectID: 0x39a5098d25482d8948f9f1eef3f43cc6ec5b39ddc53c6057af3650a06c5539ea
```

Information about the test contract that Flex published on Sui testnet:

```text
PackageID: 0x1fbb91bd77221cf17450a4378f2d93100cf65725e0099e4da71f62070ce4b729

objectType: 0x1fbb91bd77221cf17450a4378f2d93100cf65725e0099e4da71f62070ce4b729::exchange::Exchange
objectId: 0xa556bc09e966ab42ddcc98b84bc1d26c00cc6438d8dc61a787cfc696200099e7
```

## Preparation

We suggest that you consider configuring the Sui CLI tool to switch to Movement M2 devnet for the following tests.

* Install [Git](https://git-scm.com/downloads).
* Install [Sui CLI](https://docs.sui.io/build/install).
* [Configure your Sui CLI](https://docs.movementlabs.xyz/developers/sui-developers/using-sui-cli).
  This way, if you are a Sui developer, 
  you basically don't need to change your workflow to deploy your application on the Movement network.


### Confirm your Sui CLI environment

View the currently active environment of the Sui CLI client:

```shell
sui client envs
```

The output should be similar to the following:

```text
╭───────────┬────────────────────────────────────────────┬────────╮
│ alias     │ url                                        │ active │
├───────────┼────────────────────────────────────────────┼────────┤
│ devnet    │ https://fullnode.devnet.sui.io:443         │        │
│ testnet   │ https://fullnode.testnet.sui.io:443        │        │
│ mainnet   │ https://fullnode.mainnet.sui.io:443        │        │
│ m2-devnet │ https://sui.devnet.m2.movementlabs.xyz:443 │ *      │
╰───────────┴────────────────────────────────────────────┴────────╯
```

View currently active Sui CLI wallet address:

```shell
sui client active-address
```

The output should be similar to the following:

```text
0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2
```

See what gas coins are currently in your Sui CLI wallet:

```shell
sui client gas
```

If you don't have any coins, you can get some from the Movement M2 devnet faucet:
https://faucet.movementlabs.xyz/?network=devnet


## Modify Coin Contracts and Deployment

First, clone the example coin repository:

```shell
git clone https://github.com/dddappp/sui-coin-example.git
```

Change the coin metadata in `./sources/my_coin.move` to your liking. The main are as follows:

```move
    // ...
    const COIN_DECIMALS: u8 = 9; // The number of decimal places of the coin
    
    // The coin type.
    struct MY_COIN has drop {}

    fun init(otw: MY_COIN, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<MY_COIN>(
            otw,
            COIN_DECIMALS,
            b"MY_COIN", // symbol of the coin
            b"My coin name", // name of the coin
            b"My coin description", 
            option::none(), // icon URL
            ctx
        );
        // ...
    }
    // ...
```

In the following lines, for the sake of convenience,
we may directly refer to the "Coin you want to publish" as `MY_COIN` without further explanation, hope you notice this.

Publish the modified contract to the Sui network:

```shell
sui client publish --gas-budget 200000000 --skip-fetch-latest-git-deps --skip-dependency-verification
```

To speed things up when compile/publish repeatedly, consider use the `--skip-dependency-verification` option.
Or consider modifying the dependencies in the `Move.toml` file, make use of the local Sui Framework. For example:

```toml
[dependencies]
#Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "mainnet" }
Sui = { local = "../../MystenLabs/sui/crates/sui-framework/packages/sui-framework" }
```


If the publishing is successful, the output will be similar to the following:

```text
Transaction Digest: 5TobcdrTY35aJupfw1UsaQ2BsJ9bgYc9dQwgXzSNh7aj

│ Created Objects:                                                                                                              │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0x27518522f67c0f8161116a9f93ba3c75a488449ac93876177f7cc5a103b41b82                                               │
│  │ Sender: 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2                                                 │
│  │ Owner: Account Address ( 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2 )                              │
│  │ ObjectType: 0x2::coin::TreasuryCap<0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN>   │


│ Published Objects:                                                                                                            │
│  ┌──                                                                                                                          │
│  │ PackageID: 0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49                                              │
│  │ Version: 1                                                                                                                 │
│  │ Digest: FFfcVavBko2QCxLzCbwYxbxaevbeKqU3rucrPbgz7iYx                                                                       │

```

Record the ID of the created `TreasuryCap` object in the output (`0x27518522f67c0f8161116a9f93ba3c75a488449ac93876177f7cc5a103b41b82` in the above example),
and the ID of the "Published" package in the output (`0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49` in the above example),
as they will be used later.


## Mint yourself some coins

Assuming you want to mint 1 million `MY_COIN` for yourself,
you can use the following command (note that replacing the Package ID (`0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49`),
and the ID of the `TreasuryCap` object (`0x27518522f67c0f8161116a9f93ba3c75a488449ac93876177f7cc5a103b41b82`), to the actual values you got when you publish the contract):

```shell
sui client call --package 0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49 \
--module my_coin --function mint \
--args 0x27518522f67c0f8161116a9f93ba3c75a488449ac93876177f7cc5a103b41b82 \
1000000000000000 \
--gas-budget 20000000
```

If mint succeeds, the output looks like this:

```text

╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                               │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                             │
│  ┌──                                                                                                                         │
│  │ ObjectID: 0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1                                              │
│  │ Sender: 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2                                                │
│  │ Owner: Account Address ( 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2 )                             │
│  │ ObjectType: 0x2::coin::Coin<0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN>         │

```

Record the ID of the created `Coin` object in the output.
(`0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1` in the above example).
It will be used later.


### View `MY_COIN` objects you own

You can also view what `MY_COIN` objects you own by using the following command
(Note that to replace the placeholders `{YOUR_ADDRESS}` and `{MY_COIN_PACKAGE_ID}` with the actual values).

```shell
# For Movement M2 devnet
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"suix_getCoins","params":["{YOUR_ADDRESS}","{MY_COIN_PACKAGE_ID}::my_coin::MY_COIN"]}' https://sui.devnet.m2.movementlabs.xyz

# For Sui testnet
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"suix_getCoins","params":["{YOUR_ADDRESS}","{MY_COIN_PACKAGE_ID}::my_coin::MY_COIN"]}' https://fullnode.testnet.sui.io
```


## Creating token pairs and initializing liquidity in Flex DEX

Below we show how to create a token pair (a "pool") and initialize liquidity in Flex DEX, 
using the Flex DEX contract deployed on the Movement M2 devnet network.
Of course, you will need to first publish the `MY_COIN` contract on the Movement M2 devnet as described above.

Take a look at your Sui CLI wallet to see how many gas coin objects of the current network you own:

```shell
sui client gas
```

The output is similar to the following:

```text
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x1ed9b740efd757ed9135b4e1d53ea8974ee4fa7dda566ae9b9cce32c4f56dba4 │ 1357383478         │ 1.35             │
│ 0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829 │ 200000000          │ 0.20             │
```

Records the ID of one of the coin objects, which will be used later.

---

Tip: If less than one object is returned,
you can split one coin object into two by transferring some amount to your Sui CLI wallet account.
You can execute the transfer command like this (note that replace the placeholders `{YOUR_ADDRESS}` and `{YOUR_COIN_OBJECT_ID}` with your actual values ):

```shell
sui client pay-sui --amounts 200000000 --recipients {YOUR_ADDRESS} --gas-budget 10000000 \
--input-coins {YOUR_COIN_OBJECT_ID}
```

By the way, you can check the address of your Sui CLI wallet account using the following command:

```shell
sui client active-address
```

---

Now, you can use the following command to create a token pair and initialize liquidity in the Flex DEX.
In the following example command, we have assumed the values of the following parameters (you will need to replace them with the actual values):

* The contract package ID of the Flex DEX is `0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd`;
* The type of `MY_COIN` is `0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN`;
* Your Sui CLI wallet own a gas coin object with ID `0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829`;
* The ID of the `MY_COIN` object owned by your Sui CLI wallet is `0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1`;
* The initialized liquidity you want to provide is 0.1 gas coin of the network and 1 `MY_COIN`.
* The fee rate for the token pair (the "pool") is 3 thousandths (0.3%).

Execute the following command:

```shell
sui client call --package 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd \
--module token_pair_service --function initialize_liquidity \
--type-args '0x2::sui::SUI' \
0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN \
--args \
0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829 \
100000000 \
0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1 \
1000000000 \
3 1000 \
--gas-budget 30000000
```

If it is successful, the output looks similar to the following:

```text
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                                                                                                           │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                                                                                                         │
│  ┌──                                                                                                                                                                                                                     │
│  │ ObjectID: 0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052                                                                                                                                          │
│  │ Sender: 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2                                                                                                                                            │
│  │ Owner: Shared                                                                                                                                                                                                         │
│  │ ObjectType: 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd::token_pair::TokenPair<0x2::sui::SUI, 0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN>            │
│  │ Version: 2961795                                                                                                                                                                                                      │
│  │ Digest: B4Up72dnoKVMCTFFbGfVUNsDpAb8Nip9ZBddtKkzarBf                                                                                                                                                                  │
│  └──                                                                                                                                                                                                                     │
│  ┌──                                                                                                                                                                                                                     │
│  │ ObjectID: 0x52fc66b4bb96f8a7cef27db9ece28f0509b26fe0c6b000d6a027006f900ca6b5                                                                                                                                          │
│  │ Sender: 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2                                                                                                                                            │
│  │ Owner: Account Address ( 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2 )                                                                                                                         │
│  │ ObjectType: 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd::liquidity_token::LiquidityToken<0x2::sui::SUI, 0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN>  │
│  │ Version: 2961795                                                                                                                                                                                                      │
│  │ Digest: 2bWVe2CpwXmEUQ6361DHbihDQGyWrgB5Cj8QBe2VpDDp                                                                                                                                                                  │
│  └──                                                                                                                                                                                                                     │
│  ┌──                                                                                                                                                                                                                     │
│  │ ObjectID: 0xa52d9f92f0a12f85f1108cc612f214e13e564d51b3b340633a8bac150e7f910c                                                                                                                                          │
│  │ Sender: 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2                                                                                                                                            │
│  │ Owner: Account Address ( 0xfc50aa2363f3b3c5d80631cae512ec51a8ba94080500a981f4ae1a2ce4d201c2 )                                                                                                                         │
│  │ ObjectType: 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd::token_pair::AdminCap                                                                                                                  │
│  │ Version: 2961795                                                                                                                                                                                                      │
│  │ Digest: 8jRe4jG3aLqvZNaYXEFezfKzpuraLP69o7Vx4tExMgGb                                                                                                                                                                  │
│  └──                                                                                                                                                                                                                     │

```

In the example above, the ID of the token pair you created (the "pool") is `0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052`.
You can use the Sui CLI to view information about this pool:

```shell
sui client object 0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052
```

Note the ID of the `AdminCap` object in the output.
This object is the one that the contract transfers to you when you create a token pair,
and it represents the administrative permission of the pool.
You will need it if you want to update the fee rate of the pool.

```text
│               │ │ fields            │ ╭─────────────────┬───────────────────────────────────────────────────────────────────────────────╮                                                                                              │ │
│               │ │                   │ │ admin_cap       │  0xa52d9f92f0a12f85f1108cc612f214e13e564d51b3b340633a8bac150e7f910c           │                                                                                              │ │
│               │ │                   │ │ fee_denominator │  1000                                                                         │                                                                                              │ │
│               │ │                   │ │ fee_numerator   │  3                                                                            │ 
```


## Swap gas coin for `MY_COIN`

The parameters of this function are as follows:

* `token_pair`: `&mut TokenPair<X, Y>`. The ID of the token pair object.
* `x_coin`: `Coin<X>`. Pass the Object ID of the gas coin in the CLI.
* `x_amount`: `u64`. The amount of gas coin to be swapped in.
* `y_coin`: `&mut Coin<Y>`. The ID of the `MY_COIN` object to accept the amount swapped out.
* `expected_y_amount_out`: `u64`. The minimum amount of `MY_COIN` swapped out you can accept. 
  If the contract calculates that the amount swapped out is less than this value, 
  the transaction abort. We'll ignore how to calculate this value here and just pass in a very small value.

Assuming that the object ID of the pool is `0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052`,
The ID of the gas coin object you own is `0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829`.
The ID of the `MY_COIN` object you are using to receive the amount is `0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1`.
The minimum `MY_COIN` amount you can accept is 0.000000001.
Execute the following command:

```shell
sui client call --package 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd --module token_pair_service --function swap_x \
--type-args '0x2::sui::SUI' \
0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN \
--args \
'0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052' \
'0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829' \
'"100"' \
'0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1' \
'"1"' \
--gas-budget 30000000
```

Perhaps you're asking, how does a user pass in the `y_coin` parameter if they don't have a `MY_COIN` object inside their wallet?
Good question. At this point, if you're a front-end developer, you can use [PTBs](https://docs.sui.io/concepts/transactions/prog-txn-blocks),
[create a "zero" `MY_COIN` object](https://docs.sui.io/references/framework/sui-framework/coin#function-zero) first.
Then pass a reference of this object into this function;
finally, don't forget to transfer this `MY_COIN` object to the user's wallet.


## Swap `MY_COIN` for gas coin

You can, of course, swap `MY_COIN` for gas coin.
Execute command this way:

```shell
sui client call --package 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd --module token_pair_service --function swap_y \
--type-args '0x2::sui::SUI' \
0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN \
--args \
'0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052' \
'0x4f8f7415357f31da4df9e713084d72ef1fb455186824db9df7b5bb5fa42f84d1' \
'"1000000000"' \
'0x4130234b30141d0003f0f005c1e28b231dfc8a5653e4641b5e3b88ec4e61a829' \
'"1"' \
--gas-budget 30000000
```


## Modifying the fee rate of a token pair

If you want to change the fee rate of a pool,
assume that the object ID of the pool is `0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052`.
The ID of its `AdminCap` object is `0xa52d9f92f0a12f85f1108cc612f214e13e564d51b3b340633a8bac150e7f910c` (which you need to own).
You want to change the rate to 1/1000, you can execute the command like this:

```shell
sui client call --package 0x71ec440c694153474dd2a9c5c19cf60e2968d1af51aacfa24e34ee96a2df44dd \
--module token_pair_aggregate --function update_fee_rate \
--type-args '0x2::sui::SUI' \
0xa666a577f4b1c4eda0e4113a8ded8fb1002c2fc5f8ce676e097c8e0be9694e49::my_coin::MY_COIN \
--args 0x31ee0a05a8a1348da363255e4eb8eeac19a6440f7f33ff7796f1d2e01dce8052 \
0xa52d9f92f0a12f85f1108cc612f214e13e564d51b3b340633a8bac150e7f910c \
1 1000 \
--gas-budget 30000000
```

