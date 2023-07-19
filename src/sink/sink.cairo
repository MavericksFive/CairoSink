use starknet::ContractAddress;
use CairoSink::erc20::ERC20::IERC20;


#[derive(Copy, Drop, Serde, storage_access::StorageAccess)]
struct Stream {
    amount: u256,
    end: felt252,
    to: ContractAddress,
    token: ContractAddress,
    is_paused: bool
}

#[starknet::interface]
trait ISink<TContractState> {
    // fn create_stream(ref self: TContractState, stream: Stream) -> felt252;
    // fn cancel_stream(ref self: TContractState, id: felt252);
    // fn pause_stream(ref self: TContractState, id: felt252);
    // fn unpause_stream(ref self: TContractState, id: felt252);
    // fn withdraw(ref self: TContractState, id: felt252, amount: u256);
    // fn get_id_counter(self: @TContractState) -> felt252;
    fn get_stream(self: @TContractState, id: felt252) -> Stream;
}

#[starknet::contract]
mod Sink {
    use starknet::ContractAddress;
    use super::Stream;

    #[storage]
    struct Storage {
        stream_counter: felt252,
        streams: LegacyMap::<felt252, Stream>
    }

    #[external(v0)]
    impl Sink of super::ISink<ContractState> {
        fn get_stream(self: @ContractState, id: felt252) -> Stream {
            return self.streams.read(id);
        }
    }
}
