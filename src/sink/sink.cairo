use core::debug::PrintTrait;
use starknet::ContractAddress;
use CairoSink::erc20::ERC20::{IERC20, IERC20Dispatcher};
use traits::{TryInto, Into};

#[derive(Copy, Drop, Serde, storage_access::StorageAccess)]
struct Stream {
    amount: u256,
    start_time: u64,
    end_time: u64,
    receiver: ContractAddress,
    owner: ContractAddress,
    token: IERC20Dispatcher,
    is_paused: bool
}

#[derive(Copy, Drop, Serde)]
struct CreateStreamParams {
    amount: u256,
    end_time: u64,
    token: IERC20Dispatcher,
    receiver: ContractAddress,
}

#[starknet::interface]
trait ISink<TContractState> {
    fn create_stream(ref self: TContractState, data: CreateStreamParams) -> felt252;
    // fn cancel_stream(ref self: TContractState, id: felt252);
    // fn pause_stream(ref self: TContractState, id: felt252);
    // fn unpause_stream(ref self: TContractState, id: felt252);
    // fn withdraw(ref self: TContractState, id: felt252, amount: u256);
    // fn get_id_counter(self: @TContractState) -> felt252;
    fn get_stream(self: @TContractState, id: felt252) -> Stream;
}

#[starknet::contract]
mod Sink {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use super::{Stream, CreateStreamParams};

    #[storage]
    struct Storage {
        stream_counter: felt252,
        streams: LegacyMap::<felt252, Stream>
    }

    #[external(v0)]
    impl Sink of super::ISink<ContractState> {
        fn create_stream(ref self: ContractState, data: CreateStreamParams) -> felt252 {
            let stream_id = self.stream_counter.read() + 1;
            let start_time = get_block_timestamp();
            let owner = get_caller_address();
            let stream_data = Stream {
                amount: data.amount,
                start_time,
                end_time: data.end_time,
                receiver: data.receiver,
                owner: get_caller_address(),
                token: data.token,
                is_paused: false
            };
            self.streams.write(stream_id, stream_data);
            self.stream_counter.write(stream_id);
            return stream_id;
        }

        fn get_stream(self: @ContractState, id: felt252) -> Stream {
            return self.streams.read(id);
        }
    }
}
