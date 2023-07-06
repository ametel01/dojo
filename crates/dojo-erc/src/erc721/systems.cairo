#[system]
mod erc721_approve {
    use starknet::{ContractAddress, get_caller_address};
    use traits::Into;
    use dojo::world::Context;
    use dojo_erc::erc721::components::{Owners, TokenApprovals};

    fn execute(ctx: Context, token_id: felt252, operator: felt252) {
        let owner = get !(ctx.world, token_id.into(), Owners);
        assert(
            owner.address == ctx.orign | is_approved_for_all(owner, caller),
            'ERC721: unauthorized caller'
        );
        set !(
            ctx.world, (token, operator).into_partitioned(), (TokenApprovals { address: operator })
        )
    }
}

#[system]
mod erc721_set_approval_for_all {
    use starknet::ContractAddress;
    use traits::Into;

    use dojo::world::Context;
    use dojo_erc::erc721::components::OperatorApprovals;

    fn execute(ctx: Context, owner: felt252, operator: felt252, _approved: felt252) {
        assert(owner != operator, 'ERC721: self approval');
        set !(
            ctx.world,
            (owner, operator).into_partitioned(),
            (OperatorApprovals { approved: _approved })
        )
    }
}

#[system]
mod erc721_transfer_from {
    use traits::Into;
    use zeroable::Zeroable;

    use dojo::world::Context;
    use dojo_erc::erc721::components::{Balances, OperatorApprovals, Owners, TokenApprovals};
    use dojo_erc::erc721::erc721::felt252_into_bool;

    fn execute(ctx: Context, from: felt252, to: felt252, token_id: felt252) {
        let owner = get !(ctx.world, token_id.into(), Owners);
        let is_approved_for_all = get !(
            ctx.world, (owner.address, from).into_partitioned(), OperatorApprovals
        );
        assert(
            owner.address == from || felt252_into_bool(is_approved_for_all.approve),
            'ERC721: unauthorized caller'
        );
        assert(from == owner, 'ERC721: wrong sender');
        assert(!to.is_zero(), 'ERC721: invalid receiver');
        let owner = get !(ctx.world, token_id.into(), Owners);
        assert(from == owner.address, 'ERC721: wrong sender');
        set !(ctx.world, (token_id).into(), (TokenApprovals { address: Zeroable::zero() }))
        let from_balance = get !(ctx.world, from.into(), Balances);
        let to_balance = get !(ctx.world, to.into(), Balances);
        set !(ctx.world, (from).into(), (Balances { amount: from_balance.amount - 1 }))
        set !(ctx.world, (to).into(), (Balances { amount: to_balance.amount + 1 }))
    }
}

#[system]
mod erc721_mint {
    use traits::Into;
    use zeroable::Zeroable;
    use dojo::world::Context;
    use dojo_erc::erc721::components::{Balances, Owners};

    fn execute(ctx: Context, token_id: felt252, recipient: felt252) {
        assert(recipient.is_non_zero(), 'ERC721: mint to 0');

        // increase token supply
        let balance = get !(ctx.world, recipient.into(), Balances);
        set !(ctx.world, recipient.into(), (Balances { amount: balance.amount + 1 }));

        set !(ctx.world, token_id.into(), (Owners { address: recipient }));
    }
}

#[system]
mod erc721_burn {
    use traits::Into;
    use zeroable::Zeroable;
    use dojo::world::Context;
    use dojo_erc::erc721::components::{Balances, Owners};

    fn execute(ctx: Context, token_id: felt252) {
        let owner = get !(ctx.world, token_id.into(), Owners);
        let balance = get !(ctx.world, owner.address.into(), Balances);
        set !(ctx.world, owner.address.into(), (Balances { amount: balance.amount - 1 }));
        set !(ctx.world, token_id.into(), (Owners { address: Zeroable::zero() }));
    }
}
