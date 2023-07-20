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

#[derive(Copy, Drop, Serde, storage_access::StorageAccess)]
struct CreateStreamParams {
    amount: u256,
    endTime: u64,
    token: IERC20Dispatcher,
    receiver: ContractAddress,
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
    fn cancel_stream(ref self: TContractState, id: felt252);
    fn pause_stream(ref self: TContractState, id: felt252);
    fn unpause_stream(ref self: TContractState, id: felt252);
    // fn withdraw(ref self: TContractState, id: felt252, amount: u256);
    fn get_id_counter(self: @TContractState) -> felt252;
    fn get_stream(self: @TContractState, id: felt252) -> Stream;
    fn get_time_when_stream_paused(self: @TContractState, id: felt252) -> u64;
    fn is_paused(self: @TContractState, id: felt252) -> bool;
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
        Created: Created,
        Cancelled: Cancelled,
    }

    #[derive(Drop, starknet::Event)]
    struct Created {
        stream_id: felt252,
        #[key]
        owner: ContractAddress,
        #[key]
        receiver: ContractAddress,
        #[key]
        token: IERC20Dispatcher,
        amount: u256,
        end_time: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct Cancelled {
        #[key]
        owner: ContractAddress,
        #[key]
        receiver: ContractAddress,
        amount: u256,
        stream_id: felt252
    }

    #[external(v0)]
    impl Sink of super::ISink<ContractState> {
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
            self.paused_streams.write(stream_id, 0_u64);
            self.stream_counter.write(stream_id);

            token.transferFrom(get_caller_address(), get_contract_address(), amount);
            self
                .emit(
                    Event::Created(Created { stream_id, owner, receiver, token, amount, end_time })
                );
            return stream_id;
        }


        fn get_stream(self: @ContractState, id: felt252) -> Stream {
            return self.streams.read(id);
        }

        fn cancel_stream(ref self: ContractState, id: felt252) {
            let mut stream = self._get_stream(id);
            let caller = get_caller_address();
            assert((caller == stream.owner) | (caller == stream.receiver), 'NOT_AUTHORIZED');

            //InternalFunctions::_withdraw(ref self, id);
            stream.receiver = Zeroable::zero();
            stream.owner = Zeroable::zero();
            stream.amount = Zeroable::zero();
            stream.end_time = Zeroable::zero();

            self.streams.write(id, stream);

            self
                .emit(
                    Event::Cancelled(
                        Cancelled {
                            owner: stream.owner,
                            receiver: stream.receiver,
                            amount: stream.amount,
                            stream_id: id
                        }
                    )
                );
        }

        fn get_id_counter(self: @ContractState) -> felt252 {
            self.stream_counter.read()
        }

        fn get_time_when_stream_paused(self: @ContractState, id: felt252) -> u64 {
            return self.paused_streams.read(id);
        }

        fn is_paused(self: @ContractState, id: felt252) -> bool {
            return self.paused_streams.read(id) != 0_u64;
        }

        fn pause_stream(ref self: ContractState, id: felt252) {
            Sink::only_owner(@self, id);
            assert(!Sink::is_paused(@self, id), 'Stream is already paused');
            let current_time = get_block_timestamp();
            self.paused_streams.write(id, current_time);
        }

        fn unpause_stream(ref self: ContractState, id: felt252) {
            Sink::only_owner(@self, id);
            assert(Sink::is_paused(@self, id), 'Stream is already unpaused');
            self.paused_streams.write(id, 0_u64);
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _get_stream(self: @ContractState, id: felt252) -> Stream {
            assert(InternalFunctions::_exists(self, id), 'STREAM_NOT_EXIST');
            self.streams.read(id)
        }

        fn _exists(self: @ContractState, id: felt252) -> bool {
            !self.streams.read(id).receiver.is_zero()
        }

        fn _withdraw(ref self: ContractState, id: felt252) { //TODO
        }
    }
}
