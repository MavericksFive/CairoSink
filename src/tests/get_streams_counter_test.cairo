use core::traits::Into;
use starknet::{get_block_timestamp, contract_address_const};
use starknet::testing::{set_contract_address, set_block_timestamp};
use CairoSink::erc20::ERC20::{IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::sink::sink::{ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::constants::{ONE_POW_18, ONE_DAY};
use super::helpers::{init_ERC20, init_stream, create_stream, OWNER, RECEIVER, ZERO_ADDRESS};
use traits::{TryInto};
use option::OptionTrait;
use debug::PrintTrait;
use array::ArrayTrait;

#[test]
#[available_gas(40000000)]
fn it_should_get_zero_when_no_stream_has_been_created() {
    let stream_instance = init_stream();
    let streams_counter = stream_instance.get_streams_counter();
    assert(streams_counter == 0, 'Should be 0');
}

#[test]
#[available_gas(40000000)]
fn it_should_get_correct_streams_counter() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let stream_instance = init_stream();

    let mut i: usize = 0;
    loop {
        if i > 10 {
            break;
        }

        let current_timestamp = get_block_timestamp();

        set_contract_address(OWNER());
        erc20_instance.mint(OWNER(), ONE_POW_18);
        erc20_instance.approve(stream_instance.contract_address, ONE_POW_18);

        let stream_id = stream_instance
            .create_stream(RECEIVER(), ONE_POW_18, current_timestamp + ONE_DAY, erc20_instance);

        let streams_counter = stream_instance.get_streams_counter();
        if i + 1 != streams_counter.try_into().unwrap() {
            streams_counter.print();
            let mut data = ArrayTrait::new();
            data.append('Should be equal to i');
            panic(data);
        }

        i += 1;
    }
}

