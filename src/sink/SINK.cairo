use starknet::ContractAddress;

#[starknet
:: contract ] mod SINK {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[constructor]
    fn constructor() {}
}
