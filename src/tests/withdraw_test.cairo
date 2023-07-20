use CairoSink::erc20::ERC20::IERC20DispatcherTrait;
use CairoSink::sink::sink::ISinkDispatcherTrait;
use CairoSink::ray_math::ray_math::{RAY};
use super::helpers::{
    NAME, SYMBOL, AMOUNT, END, OWNER, RECEIVER, init_ERC20, init_stream, create_stream
};
use starknet::testing::{set_contract_address, set_block_timestamp};
use debug::PrintTrait;

#[test]
#[available_gas(40000000)]
fn withdraw_receiver() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let (sink_instance, stream_id) = create_stream(
        RECEIVER(), AMOUNT, END, erc20_instance, OWNER()
    );

    set_block_timestamp(END / 2);

    set_contract_address(RECEIVER());
    sink_instance.withdraw(stream_id, AMOUNT / 2);
    let stream = sink_instance.get_stream(stream_id);
    let sink_balance = erc20_instance.balanceOf(sink_instance.contract_address);
    let receiver_balance = erc20_instance.balanceOf(RECEIVER());

    assert(stream.amount == (AMOUNT * RAY) / 2, 'Invalid amounts');
    assert(stream.start_time == END / 2, 'Invalid start');
    assert(sink_balance == AMOUNT / 2, 'Invalid sink balance');
    assert(receiver_balance == AMOUNT / 2, 'Invalid user balance');
}
#[test]
#[available_gas(40000000)]
fn withdraw_owner() {
    let erc20_instance = init_ERC20('Test', 'TEST', 18);
    let (sink_instance, stream_id) = create_stream(
        RECEIVER(), AMOUNT, END, erc20_instance, OWNER()
    );

    set_block_timestamp(END / 2);

    set_contract_address(OWNER());
    sink_instance.withdraw(stream_id, AMOUNT / 2);

    let stream = sink_instance.get_stream(stream_id);
    let sink_balance = erc20_instance.balanceOf(sink_instance.contract_address);
    let owner_balance = erc20_instance.balanceOf(OWNER());
    let withdrawable_amount = sink_instance.get_withdrawable_amount(stream_id);

    assert(stream.amount == (AMOUNT * RAY) / 2, 'Invalid amounts');
    assert(stream.start_time == 0, 'Invalid start');
    assert(sink_balance == AMOUNT / 2, 'Invalid sink balance');
    assert(owner_balance == AMOUNT / 2, 'Invalid user balance');
    assert(withdrawable_amount == (AMOUNT - AMOUNT / 2) / 2, 'Invalid withdrawable amount');
}

