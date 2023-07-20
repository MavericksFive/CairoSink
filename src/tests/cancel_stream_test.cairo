use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use starknet::testing::{set_contract_address, set_block_timestamp};
use CairoSink::sink::sink::{ISink, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{IERC20DispatcherTrait, IERC20Dispatcher};
use super::helpers::{init_ERC20, init_stream, create_stream, OWNER, RECEIVER, NOT_OWNER};
use CairoSink::constants::{ONE_POW_18, ONE_DAY, ONE_WEEK};
use zeroable::Zeroable;

#[test]
#[available_gas(40000000)]
fn it_should_cancel_stream() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    stream_instance.cancel_stream(stream_id);

    let stream = stream_instance.get_stream(stream_id);

    assert(stream.is_cancelled == true, 'Should be cancelled');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('STREAM_NOT_EXIST', 'ENTRYPOINT_FAILED'))]
fn it_should_not_cancel_stream_with_bad_id() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    stream_instance.cancel_stream(stream_id + 1);
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('NOT_AUTHORIZED', 'ENTRYPOINT_FAILED'))]
fn it_should_not_cancel_stream_if_not_owner_or_receiver() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    set_contract_address(NOT_OWNER());
    stream_instance.cancel_stream(stream_id);
}

