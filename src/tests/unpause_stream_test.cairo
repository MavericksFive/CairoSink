use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use starknet::testing::{set_contract_address};
use CairoSink::sink::sink::{ISink, CreateStreamParams, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{IERC20, ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use super::{init_ERC20, init_stream, create_stream, NOT_OWNER};

#[test]
#[available_gas(40000000)]
fn it_should_unpause_stream_if_owner() {
    let (stream_instance, stream_id) = create_stream();

    stream_instance.unpause_stream(stream_id);

    assert(!stream_instance.is_paused(stream_id), 'stream should be paused');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Not owner', 'ENTRYPOINT_FAILED'))]
fn it_should_not_unpause_stream_if__not_owner() {
    let (stream_instance, stream_id) = create_stream();

    set_contract_address(NOT_OWNER());

    stream_instance.pause_stream(stream_id);
}