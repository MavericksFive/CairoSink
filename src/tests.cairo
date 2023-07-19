use starknet::{get_block_timestamp, deploy_syscall, contract_address_const, ContractAddress};
use CairoSink::erc20::ERC20::{ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::sink::sink::{Sink, Stream, ISinkDispatcher};
use array::ArrayTrait;
use option::OptionTrait;
use result::ResultTrait;
use traits::{TryInto, Into};


#[cfg(test)]
mod create_stream_test;

#[cfg(test)]
fn init_ERC20(name: felt252, symbol: felt252, decimals: u8) -> (ContractAddress, IERC20Dispatcher) {
    let mut calldata = ArrayTrait::new();
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(decimals.into());

    let class_hash = ERC20::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, calldata.span(), true).unwrap();
    let contract_instance = IERC20Dispatcher { contract_address: contract_address }.name();
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
