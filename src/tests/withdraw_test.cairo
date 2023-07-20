use CairoSink::erc20::ERC20::IERC20DispatcherTrait;
use CairoSink::sink::sink::ISinkDispatcherTrait;
use super::helpers::{NAME, SYMBOL, AMOUNT, END, OWNER, RECEIVER, init_ERC20, init_stream, create_stream};
use starknet::testing::{set_contract_address, set_block_timestamp};
use debug::PrintTrait;

#[test]
#[available_gas(40000000)]
fn withdraw_receiver() {
    'Testing Withdraw'.print();
    let (token_address, token_instance) = init_ERC20(NAME, SYMBOL, 18);
    let (sink_instance, stream_id) = create_stream(AMOUNT, END,  token_instance, RECEIVER(), OWNER());

    set_block_timestamp(END / 2);

    set_contract_address(RECEIVER());
    sink_instance.withdraw(stream_id, AMOUNT / 2);

    let stream = sink_instance.get_stream(stream_id);
    let sink_balance = token_instance.balanceOf(sink_instance.contract_address);

    assert(stream.amount == AMOUNT / 2, 'Invalid amounts');
    assert(stream.start == END / 2, 'Invalid start');    
    assert(sink_balance == AMOUNT / 2, 'Invalid sink balance');
}
