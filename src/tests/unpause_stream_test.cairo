use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use starknet::testing::{set_contract_address, set_block_timestamp};
use CairoSink::sink::sink::{ISink, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{IERC20DispatcherTrait, IERC20Dispatcher};
use super::helpers::{init_ERC20, init_stream, create_stream, NOT_OWNER, RECEIVER, OWNER};
use CairoSink::constants::{ONE_POW_18, ONE_DAY, ONE_WEEK};

#[test]
#[available_gas(40000000)]
fn it_should_unpause_stream_if_owner() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    stream_instance.pause_stream(stream_id);

    stream_instance.unpause_stream(stream_id);

    assert(!stream_instance.is_paused(stream_id), 'stream should be unpaused');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Unauthorized caller', 'ENTRYPOINT_FAILED'))]
fn it_should_not_unpause_stream_if_not_owner() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    set_contract_address(NOT_OWNER());

    stream_instance.unpause_stream(stream_id);
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Stream is already unpaused', 'ENTRYPOINT_FAILED'))]
fn it_should_not_unpause_stream_if_is_already_unpaused() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let current_timestamp = get_block_timestamp();
    set_block_timestamp(current_timestamp + ONE_DAY);
    let (stream_instance, stream_id) = create_stream(
        RECEIVER(), ONE_POW_18, current_timestamp + ONE_WEEK, erc20_instance, OWNER()
    );

    stream_instance.unpause_stream(stream_id);

    stream_instance.unpause_stream(stream_id);
}
