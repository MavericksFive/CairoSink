use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use CairoSink::sink::sink::{ISink, CreateStreamParams, ISinkDispatcherTrait, ISinkDispatcher};
use CairoSink::erc20::ERC20::{IERC20, ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use super::{init_ERC20, init_Stream};
use zeroable::Zeroable;
use starknet::testing::set_contract_address;

#[test]
#[available_gas(40000000)]
fn it_should_create_stream() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 1_000_000_000_000_000_000,
        endTime: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);
    assert(stream_id == 1, 'no good');
}

#[test]
#[available_gas(40000000)]
fn it_should_cancel_stream() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 1_000_000_000_000_000_000,
        endTime: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);

    stream_instance.cancel_stream(stream_id);

    let stream = stream_instance.get_stream(stream_id);

    assert(stream.receiver.is_zero(), 'no good');
    assert(stream.owner.is_zero(), 'no good');
    assert(stream.amount.is_zero(), 'no good');
    assert(stream.endTime.is_zero(), 'no good');
}


#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('STREAM_NOT_EXIST','ENTRYPOINT_FAILED'))]
fn it_should_not_cancel_stream_with_bad_id() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 1_000_000_000_000_000_000,
        endTime: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);

    stream_instance.cancel_stream(stream_id+1);
}


#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('NOT_AUTHORIZED','ENTRYPOINT_FAILED'))]
fn it_should_not_cancel_stream_if_not_owner_or_receiver() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 1_000_000_000_000_000_000,
        endTime: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);

    set_contract_address(contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC8>());
    stream_instance.cancel_stream(stream_id);
}