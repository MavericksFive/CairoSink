use starknet::{get_block_timestamp, contract_address_const};
use starknet::testing::{set_contract_address, set_block_timestamp};
use CairoSink::sink::sink::{ISink, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::constants::{ONE_POW_18, ONE_DAY};
use super::helpers::{init_ERC20, init_stream, create_stream, OWNER, RECEIVER, ZERO_ADDRESS};

#[test]
#[available_gas(40000000)]
fn it_should_create_stream() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let stream_instance = init_stream();
    let current_timestamp = get_block_timestamp();

    set_contract_address(OWNER());
    erc20_instance.mint(OWNER(), ONE_POW_18);
    erc20_instance.approve(stream_instance.contract_address, ONE_POW_18);

    let stream_id = stream_instance
        .create_stream(RECEIVER(), ONE_POW_18, current_timestamp + ONE_DAY, erc20_instance);
    assert(stream_id == 1, 'Stream id should be 1');

    let stream = stream_instance.get_stream(stream_id);
    assert(stream.owner == OWNER(), 'Wrong owner');
    assert(stream.receiver == RECEIVER(), 'Wrong receiver');
    assert(stream.start_time == current_timestamp, 'Wrong start time');
    assert(stream.end_time == current_timestamp + ONE_DAY, 'Wrong start time');
    assert(stream.token.contract_address == erc20_instance.contract_address, 'Wrong erc20 address');
}
#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Receiver cannot be zero', 'ENTRYPOINT_FAILED'))]
fn it_should_panic_when_receiver_is_address_zero() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();

    create_stream(ZERO_ADDRESS(), ONE_POW_18, current_timestamp + ONE_DAY, erc20_instance, OWNER());
}
#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Amount cannot be zero', 'ENTRYPOINT_FAILED'))]
fn it_should_panic_when_amount_is_zero() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();

    create_stream(RECEIVER(), 0, current_timestamp + ONE_DAY, erc20_instance, OWNER());
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('End time must be in the future', 'ENTRYPOINT_FAILED'))]
fn it_should_panic_when_end_time_pasted() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY + 1);
    create_stream(RECEIVER(), ONE_POW_18, current_timestamp + ONE_DAY, erc20_instance, OWNER());
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('u256_sub Overflow', 'ENTRYPOINT_FAILED', 'ENTRYPOINT_FAILED'))]
fn it_should_panic_when_owner_balance_not_enough() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let stream_instance = init_stream();
    let current_timestamp = get_block_timestamp();

    set_contract_address(OWNER());

    stream_instance
        .create_stream(RECEIVER(), ONE_POW_18, current_timestamp + ONE_DAY, erc20_instance);
}

