use CairoSink::sink::sink::Sink;
use starknet::ContractAddress;
use starknet::contract_address_const;

const OWNER: ContractAddress = 1;
const RECEIVER: ContractAddress = 2;

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
fn withdraw_receiver() {}
