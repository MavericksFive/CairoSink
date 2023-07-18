use starknet::ContractAddress;

#[starknet::interface]

trait ISINK<TContractState> {
    fn get_stream_id(self: @TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256) -> felt252;
    fn _createStream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    // fn create_stream_with_reason(ref self: TContractState, to: ContractAddress, amount_per_sec: u256, reason: felt252);
    // fn withdrawable(self: @TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256) -> (u256, u256, u256);
    // fn withdraw(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256 );
    // fn cance_stream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    // fn pause_stream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    // fn modifiy_stream(ref self: TContractState, old_to: ContractAddress, old_amount_per_sec: u256, to: ContractAddress, amount_per_sec: u256);
    // fn deposit(ref self: TContractState, amount: u256);
    // fn deposit_and_create(ref self: TContractState, amount_to_deposit: u256, to: ContractAddress, amount_per_sec: u256);
    // fn deposit_and_create_with_reason(ref self: TContractState, amount_to_deposit: u256, to: ContractAddress, amount_per_sec: u256, reason: felt252);
    // fn withdraw_payer(ref self: TContractState, amount: u256);
    // fn withdraw_payer_all(ref self: TContractState);
    // fn get_payer_balance(self: @TContractState, payer_address: ContractAddress) -> u256;
}

#[starknet::contract]
mod Sink {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    // struct Payer {
    //     las_payer_update: u64,
    //     total_paid_per_sec: u256,
    // }

    #[storage]
    struct Storage {
        _stream_to_start: LegacyMap::<felt252, u256>,
        // _payers: LegacyMap::<ContractAddress, Payer>,
        _balances: LegacyMap::<ContractAddress, u256>,
        // _decimals_divisor: u256,
        token: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StreamCreated: StreamCreated,
        StreamCreatedWithReason: StreamCreatedWithReason,
        StreamCancelled: StreamCancelled,
        StreamPaused:StreamPaused,
        StreamModified: StreamModified,
        Withdraw:Withdraw,
        PayerDeposit:PayerDeposit,
        PayerWithdraw:PayerWithdraw,
    }
    #[derive(Drop, starknet::Event)]
    struct StreamCreated {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amountPerSec: u256,
        streamID: felt252,
    }
    #[derive(Drop, starknet::Event)]
    struct StreamCreatedWithReason {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amountPerSec: u256,
        streamID: felt252,
        reason: felt252,
    }
    #[derive(Drop, starknet::Event)]
    struct StreamCancelled {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amountPerSec: u256,
        streamID: u256,
    }
    #[derive(Drop, starknet::Event)]
    struct StreamPaused {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amountPerSec: u256,
        streamID: u256,
    }
    #[derive(Drop, starknet::Event)]
    struct StreamModified {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        oldAmountPerSec: u256,
        oldStreamId: u256,
        amountPerSec: u256,
        streamID: u256,
    }
    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        oldAmountPerSec: u256,
        oldStreamId: u256,
        amountPerSec: u256,
        streamID: u256,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct PayerDeposit {
        #[key]
        from: ContractAddress,
        amount: u256,
    }
    #[derive(Drop, starknet::Event)]
    struct PayerWithdraw {
        #[key]
        from: ContractAddress,
        amount: u256,
    }


    #[constructor]
    fn constructor(ref self: ContractState, token: ContractAddress, ) {
        self.token.write(token);
        let tokenDecimals: u8 = IERC20Dispatcher{contract_address: self.token.read()}.decimals();
        // self.DECIMALS_DIVISOR.write(10**(20 - tokenDecimals));
    }

    #[external(v0)]
    impl SinkImpl of super::SinkTrait<ContractState> {
        fn get_stream_id(self: @ContractState, payer: ContractAddress, receiver: ContractAddress, amount_per_sec: u256) -> ContractAddress {

        }
    }

    /// @dev Internal Functions implementation for the Sink contract
    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        /// @dev Creates a stream from an address to another address
       fn _createStream(from: ContractAddress, to: ContractAddress) {
            let streamId: u256 = self._get_stream_id(from, to);
            assert(amountPerSec > 0_u256, 'amountPersec cant be 0');
            assert(can_vote == true, 'USER_ALREADY_VOTED');
        }
    }

    /// @dev Asserts implementation for the Vote contract
    #[generate_trait]
    impl AssertsImpl of AssertsTrait {
        // @dev Internal function that checks if an address is allowed to vote
        fn _assert_(ref self: ContractState) {
        }
    }
}
