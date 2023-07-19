use starknet::{get_block_timestamp, deploy_syscall, contract_address_const, ContractAddress};
use alexandria::math::pow;
use starknet::testing::{set_contract_address};
use CairoSink::erc20::ERC20::{ERC20, IERC20DispatcherTrait, IERC20Dispatcher};
use CairoSink::sink::sink::{Sink, Stream, ISinkDispatcherTrait, ISinkDispatcher};
use array::ArrayTrait;
use option::OptionTrait;
use result::ResultTrait;
use traits::{TryInto, Into};


#[cfg(test)]
fn ZERO_ADDRESS() -> ContractAddress {
    contract_address_const::<0>()
}

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
fn init_stream() -> (ContractAddress, ISinkDispatcher) {
    let calldata = ArrayTrait::new();
    let class_hash = Sink::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, calldata.span(), true).unwrap();
    let contract_instance = ISinkDispatcher { contract_address: contract_address };
    return (contract_address, contract_instance);
}

#[cfg(test)]
fn create_stream(
    receiver: ContractAddress,
    amount: u256,
    end_time: u64,
    token: IERC20Dispatcher,
    caller: ContractAddress
) -> felt252 {
    let (stream_address, stream_instance) = init_stream();
    token.mint(OWNER(), amount);
    token.approve(stream_address, amount);
    let current_timestamp = get_block_timestamp();
    set_contract_address(caller);
    return stream_instance.create_stream(receiver, amount, end_time, token);
}
