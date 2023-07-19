<<<<<<< HEAD
=======
use starknet::{get_block_timestamp, deploy_syscall, contract_address_const, ContractAddress};
<<<<<<< HEAD
=======
use starknet::testing::{set_contract_address};
use alexandria::math::pow;
>>>>>>> 50a6879 (implemented tests for when pause and unpause is not called by the owner)
use CairoSink::erc20::ERC20::{ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::sink::sink::{Sink, Stream, ISinkDispatcherTrait, ISinkDispatcher, CreateStreamParams};
use CairoSink::constants::{ONE_POW_18, ONE_DAY};
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
mod unpause_stream_test;

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

    return (stream_instance, stream_id);
}
<<<<<<< HEAD
>>>>>>> ea1b8bd (refactored to reuse function)
=======

#[cfg(test)]
fn OWNER() -> ContractAddress {
    contract_address_const::<10>()
}

#[cfg(test)]
fn RECEIVER() -> ContractAddress {
    contract_address_const::<20>()
}

#[cfg(test)]
fn NOT_OWNER() -> ContractAddress {
    contract_address_const::<14>()
}
>>>>>>> 50a6879 (implemented tests for when pause and unpause is not called by the owner)
