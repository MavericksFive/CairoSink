<<<<<<< HEAD
=======
use starknet::{get_block_timestamp, deploy_syscall, contract_address_const, ContractAddress};
use CairoSink::erc20::ERC20::{ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::sink::sink::{Sink, Stream, ISinkDispatcherTrait, ISinkDispatcher, CreateStreamParams};
use array::ArrayTrait;
use option::OptionTrait;
use result::ResultTrait;
use traits::{TryInto, Into};


>>>>>>> ea1b8bd (refactored to reuse function)
#[cfg(test)]
mod create_stream_test;
#[cfg(test)]
<<<<<<< HEAD
mod helpers;
=======
mod pause_stream_test;

#[cfg(test)]
fn init_ERC20(name: felt252, symbol: felt252, decimals: u8) -> (ContractAddress, IERC20Dispatcher) {
    let mut calldata = ArrayTrait::new();
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(decimals.into());

    let class_hash = ERC20::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, calldata.span(), true).unwrap();
    let contract_instance = IERC20Dispatcher { contract_address: contract_address };
    return (contract_address, contract_instance);
}

#[cfg(test)]
fn init_Stream() -> (ContractAddress, ISinkDispatcher) {
    let calldata = ArrayTrait::new();
    let class_hash = Sink::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, calldata.span(), true).unwrap();
    let contract_instance = ISinkDispatcher { contract_address: contract_address };
    return (contract_address, contract_instance);
}

#[cfg(test)]
fn create_stream() -> (ISinkDispatcher, felt252) {
    let (erc20_address, erc20_instance) = init_ERC20('Test', 'TEST', 18);
    let (stream_address, stream_instance) = init_Stream();
    let current_timestamp = get_block_timestamp();

    let create_data = CreateStreamParams {
        amount: 1_000_000_000_000_000_000,
        end_time: current_timestamp + 1000,
        token: erc20_instance,
        receiver: contract_address_const::<0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7>(),
    };

    let stream_id = stream_instance.create_stream(create_data);

    return (stream_instance, stream_id);
}
>>>>>>> ea1b8bd (refactored to reuse function)
