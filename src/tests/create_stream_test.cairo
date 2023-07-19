use starknet::{get_block_timestamp, deploy_syscall, contract_address_const};
use CairoSink::sink::sink::{ISink, CreateStreamParams};
use CairoSink::erc20::ERC20::{IERC20, ERC20, IERC20Dispatcher};
use super::{init_ERC20, init_Stream};

#[test]
fn it_should_create_stream() {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 10,
        endTime: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);
}
