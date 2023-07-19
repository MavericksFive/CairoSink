use starknet::ContractAddress;
use CairoSink::erc20::ERC20::{IERC20, IERC20DispatcherTrait, IERC20Dispatcher};
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

#[starknet::interface]
trait ISink<TContractState> {
    fn create_stream(
        ref self: TContractState,
        receiver: ContractAddress,
        amount: u256,
        end_time: u64,
        token: IERC20Dispatcher
    ) -> felt252;
    // fn cancel_stream(ref self: TContractState, id: felt252);
    fn pause_stream(ref self: TContractState, id: felt252);
    fn unpause_stream(ref self: TContractState, id: felt252);
    // fn withdraw(ref self: TContractState, id: felt252, amount: u256);
    // fn get_id_counter(self: @TContractState) -> felt252;
    fn get_stream(self: @TContractState, id: felt252) -> Stream;
    fn is_owner(self: @TContractState, id: felt252) -> bool;
    fn only_owner(self: @TContractState, id: felt252);
}

#[starknet::contract]
mod Sink {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, get_contract_address};
    use super::{Stream, IERC20DispatcherTrait, IERC20Dispatcher};

    use zeroable::{Zeroable};

    #[storage]
    struct Storage {
        stream_counter: felt252,
        streams: LegacyMap::<felt252, Stream>,
        paused_streams: LegacyMap::<felt252, u64>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Created: Created
    }

    #[derive(Drop, starknet::Event)]
    struct Created {
        #[key]
        owner: ContractAddress,
        #[key]
        receiver: ContractAddress,
        #[key]
        token: IERC20Dispatcher,
        amount: u256,
        end_time: u64,
    }

    #[external(v0)]
    impl Sink of super::ISink<ContractState> {
        // Guard Functions
        #[inline(always)]
        fn is_owner(self: @ContractState, id: felt252) -> bool {
            return self.streams.read(id).owner == get_caller_address();
        }

        #[inline(always)]
        fn only_owner(self: @ContractState, id: felt252) {
            assert(Sink::is_owner(self, id), 'Not owner');
        }

        fn create_stream(
            ref self: ContractState,
            receiver: ContractAddress,
            amount: u256,
            end_time: u64,
            token: IERC20Dispatcher
        ) -> felt252 {
            assert(end_time > get_block_timestamp(), 'End time must be in the future');
            assert(receiver.is_non_zero(), 'Receiver cannot be zero');
            assert(amount.is_non_zero(), 'Amount cannot be zero');

            let stream_id = self.stream_counter.read() + 1;
            let start_time = get_block_timestamp();
            let owner = get_caller_address();
            let stream_data = Stream {
                amount: amount,
                start_time,
                end_time: end_time,
                receiver: receiver,
                owner: get_caller_address(),
                token: token,
                is_paused: false
            };
            self.streams.write(stream_id, stream_data);
            self.stream_counter.write(stream_id);

            token.transferFrom(get_caller_address(), get_contract_address(), amount);
            self.emit(Event::Created(Created { owner, receiver, token, amount, end_time }));
            return stream_id;
        }


        fn get_stream(self: @ContractState, id: felt252) -> Stream {
            return self.streams.read(id);
        }

        fn pause_stream(ref self: ContractState, id: felt252) {
            Sink::only_owner(@self, id);
            assert(self.paused_streams.read(id) != 0, 'Stream is already paused');
            let current_time = get_block_timestamp();
            self.paused_streams.write(id, current_time);
        }

        fn unpause_stream(ref self: ContractState, id: felt252) {
            Sink::only_owner(@self, id);
            assert(self.paused_streams.read(id) == 0, 'Stream is already unpaused');
            self.paused_streams.write(id, 0_u64);
        }
    }
}
