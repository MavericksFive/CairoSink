use starknet::ContractAddress;

#[starknet::interface]

trait ISINK<TContractState> {
    fn get_streamId(self: @TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256) -> felt252;
    fn create_stream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    fn create_stream_with_reason(ref self: TContractState, to: ContractAddress, amount_per_sec: u256, reason: felt252);
    fn withdrawable(self: @TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256) -> (u256, u256, u256);
    fn withdraw(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount_per_sec: u256 );
    fn cance_stream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    fn pause_stream(ref self: TContractState, to: ContractAddress, amount_per_sec: u256);
    fn modifiy_stream(ref self: TContractState, old_to: ContractAddress, old_amount_per_sec: u256, to: ContractAddress, amount_per_sec: u256);
    fn deposit(ref self: TContractState, amount: u256);
    fn deposit_and_create(ref self: TContractState, amount_to_deposit: u256, to: ContractAddress, amount_per_sec: u256);
    fn deposit_and_create_with_reason(ref self: TContractState, amount_to_deposit: u256, to: ContractAddress, amount_per_sec: u256, reason: felt252);
    fn withdraw_payer(ref self: TContractState, amount: u256);
    fn withdraw_payer_all(ref self: TContractState);
    fn get_payer_balance(self: @TContractState, payer_address: ContractAddress) -> u256;
}

#[starknet::contract]
mod SINK {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    struct Payer {
        las_payer_update: u64,
        total_paid_per_sec: u256,
    }

    #[storage]
    struct Storage {
        _stream_to_start: LegacyMap::<felt252, u256>,
        _payers: LegacyMap::<ContractAddress, Payer>,
        _balances: LegacyMap::<ContractAddress, u256>,
        _decimals_divisor: u256,
        _token: IERC20
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[constructor]
    fn constructor(ref self: ContractState) {}
}
