use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use starknet::testing::{set_contract_address};
use CairoSink::sink::sink::{ISink, CreateStreamParams, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{IERC20, ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::constants::{ONE_POW_18, ONE_DAY};
use super::{init_ERC20, init_stream, OWNER, RECEIVER};

#[test]
#[available_gas(40000000)]
fn it_should_create_stream() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_stream();
    let current_timestamp = get_block_timestamp();
    let create_data = CreateStreamParams {
        amount: ONE_POW_18,
        end_time: current_timestamp + ONE_DAY,
        token: erc20_instance,
        receiver: RECEIVER()
    };

    set_contract_address(OWNER());

    let stream_id = stream_instance.create_stream(create_data);
    assert(stream_id == 1, 'Stream id should be 1');

    let stream = stream_instance.get_stream(stream_id);
    assert(stream.owner == OWNER(), 'Wrong owner');
    assert(stream.receiver == RECEIVER(), 'Wrong receiver');
    assert(stream.start_time == current_timestamp, 'Wrong start time');
    assert(stream.end_time == current_timestamp + ONE_DAY, 'Wrong start time');
    assert(stream.is_paused == false, 'is_paused should be false');
    assert(stream.token.contract_address == erc20_address, 'Wrong erc20 address');
}

